# Prompt Caching — szybsze i tańsze powtórne audyty

> ## Kiedy ta wiedza jest Ci potrzebna?
>
> | Scenariusz | Czy musisz konfigurować cache? |
> |---|---|
> | Używasz Claude Code w terminalu | ❌ Nie — działa automatycznie |
> | Piszesz własne komendy slash (`/seo-audit`) | ❌ Nie — Claude Code kesuje za Ciebie |
> | Piszesz skrypt Python z `anthropic.Anthropic()` | ✅ Tak — dodaj `cache_control` ręcznie |
> | Stawiasz własną usługę (Cloud Run, Cloud Functions, Lambda) | ✅ Tak — to decyzja architektoniczna i kosztowa |
> | Robisz Batch API dla wielu audytów | ✅ Tak — cache + batch = największe oszczędności |
>
> Innymi słowy: w codziennej pracy z Claude Code możesz traktować to jako ciekawostkę. Gdy zaczniesz pisać własne aplikacje wołające API Anthropica — to przestaje być teoria.

---

Prompt Caching to mechanizm, w którym API Anthropica zapamiętuje część kontekstu między wywołaniami i nie przetwarza go ponownie. Zamiast płacić pełną cenę za każdy token przy każdym wywołaniu, powtarzające się fragmenty (instrukcje, dokumenty, system prompt) są odczytywane z cache — taniej i szybciej.

---

## Jak to działa

Przy pierwszym wywołaniu API przetwarza cały kontekst normalnie i zapisuje wskazane fragmenty w cache. Przy kolejnych wywołaniach, jeśli cache jest aktualny, te fragmenty są pomijane w obliczeniach — API zwraca odpowiedź szybciej i pobiera niższą opłatę.

| | Bez cache | Z cache (cache hit) |
|---|---|---|
| Koszt tokenów wejściowych | 100% | ~10% |
| Czas przetwarzania | Pełny | Znacznie krótszy |
| Kiedy działa | Zawsze | Gdy kontekst się nie zmienił |
| TTL (czas życia cache) | — | 5 minut |

Cache wygasa po **5 minutach bezczynności**. Jeśli przerwa między wywołaniami jest dłuższa, cache jest zimny i pierwsze wywołanie płaci pełną cenę — po czym cache znów się tworzy.

---

## Co się nadaje do keszowania

Cache opłaca się dla fragmentów, które:
- są **długie** (setki linii)
- **nie zmieniają się** między wywołaniami
- powtarzają się **wielokrotnie w jednej sesji**

W tym projekcie idealnym kandydatem jest **`seo-audit.md`** — ma ponad 350 linii instrukcji, które są identyczne przy każdym uruchomieniu audytu. Przy trzech audytach z rzędu w ciągu 5 minut płacisz pełną cenę tylko raz.

Złe kandydaty: dane, które zmieniają się przy każdym wywołaniu (wyniki fetch strony, datowane raporty, historia rozmowy).

---

## Prompt Caching w Claude Code (automatyczny)

W sesji interaktywnej Claude Code **włącza cache automatycznie** dla długich system promptów i plików wczytanych do kontekstu. Nie musisz nic konfigurować — działa z `CLAUDE.md`, wczytanymi plikami przez `@` i zawartością komend slash.

Żeby zobaczyć, czy cache działa, uruchom audyt kilka razy z rzędu:

```
/seo-audit
/seo-audit
/seo-audit
```

Drugie i trzecie wywołanie powinny być zauważalnie szybsze — to znak, że instrukcje z `seo-audit.md` są serwowane z cache.

---

## Prompt Caching przez API (skrypt Python)

Gdy wywołujesz Claude przez API (np. skrypt `batch-audit.py`), musisz **jawnie oznaczyć** fragmenty do keszowania przez `cache_control`. API zwraca wtedy statystyki cache w odpowiedzi.

### Instalacja SDK

```bash
pip install anthropic
```

### Przykładowy skrypt — audyt z cache

```python
import anthropic
from pathlib import Path

client = anthropic.Anthropic()

# Wczytaj instrukcje audytu — to będzie keszowane
audit_instructions = Path(".claude/commands/seo-audit.md").read_text()

def run_audit(url: str) -> dict:
    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=4096,
        system=[
            {
                "type": "text",
                "text": audit_instructions,
                "cache_control": {"type": "ephemeral"}  # oznacz do keszowania
            }
        ],
        messages=[
            {
                "role": "user",
                "content": f"Wykonaj audyt SEO strony: {url}"
            }
        ]
    )

    usage = response.usage
    print(f"Tokeny wejściowe:     {usage.input_tokens}")
    print(f"Z cache (odczyt):     {usage.cache_read_input_tokens}")
    print(f"Zapisane do cache:    {usage.cache_creation_input_tokens}")
    print(f"Tokeny wyjściowe:     {usage.output_tokens}")

    return {
        "content": response.content[0].text,
        "cache_hit": usage.cache_read_input_tokens > 0
    }

if __name__ == "__main__":
    print("=== Wywołanie 1 (zimny cache) ===")
    result1 = run_audit("https://ntfy.pl/")

    print("\n=== Wywołanie 2 (ciepły cache) ===")
    result2 = run_audit("https://ntfy.pl/longevity/")

    print("\n=== Wywołanie 3 (ciepły cache) ===")
    result3 = run_audit("https://ntfy.pl/rabat/")
```

### Co zobaczysz w wynikach

**Wywołanie 1 (zimny cache):**
```
Tokeny wejściowe:     4821
Z cache (odczyt):     0
Zapisane do cache:    4650    ← instrukcje zapisane
Tokeny wyjściowe:     892
```

**Wywołanie 2 (ciepły cache):**
```
Tokeny wejściowe:     171
Z cache (odczyt):     4650    ← instrukcje z cache, nie liczone normalnie
Zapisane do cache:    0
Tokeny wyjściowe:     876
```

Przy drugim i trzecim wywołaniu płacisz tylko za 171 tokenów (samo pytanie) zamiast za 4821. Instrukcje audytu są keszowane i kosztują ~10% normalnej stawki.

---

## Ile można zaoszczędzić

Dla `seo-audit.md` (~4600 tokenów instrukcji), audyt 10 podstron w ciągu 5 minut:

| | Bez cache | Z cache |
|---|---|---|
| Tokeny wejściowe per audyt | 4800 | 200 + 460 (cache) |
| Łącznie za 10 audytów | 48 000 | 6 600 |
| Szacunkowy koszt (Sonnet) | ~$0.14 | ~$0.03 |

Oszczędność rośnie proporcjonalnie do liczby audytów i długości instrukcji.

---

## Praktyczne ćwiczenie

1. Zapisz skrypt powyżej jako `scripts/cache-test.py`
2. Uruchom: `python scripts/cache-test.py`
3. Sprawdź pole `cache_read_input_tokens` w każdym wywołaniu
4. Odczekaj 6 minut i uruchom ponownie — cache wygasł, `cache_read_input_tokens` wróci do zera
5. Porównaj czas odpowiedzi między zimnym a ciepłym cache

---

## Pułapki

**Cache wygasa po 5 minutach** — jeśli Twój workflow ma dłuższe przerwy między wywołaniami, cache nie pomoże. Rozwiązanie: grupuj wywołania, używaj Batch API (następny temat w backlogu).

**Cache nie działa, jeśli kontekst się zmienia** — nawet jedna różna linia w system prompcie tworzy nowy cache. Trzymaj instrukcje stabilne, a zmienne dane (URL, data) przekazuj w wiadomości użytkownika, nie w system prompcie.

**`cache_control` musisz dodać ręcznie w API** — w sesji interaktywnej Claude Code robi to za Ciebie. Przy skryptach Python — musisz to oznaczyć sam.

---

## Związek z innymi tematami

- **Batch API** (punkt 5 backlogu) — batch wywołuje wiele requestów asynchronicznie; cache działa też w batchu, jeśli wywołania są bliskie czasowo
- **Extended Thinking** — Opus z thinking zużywa więcej tokenów; cache na instrukcjach częściowo kompensuje ten koszt
- **`/schedule`** — zaplanowany agent startuje na zimno, więc pierwsze wywołanie zawsze płaci pełną cenę; cache zaczyna działać od drugiego wywołania w tej samej sesji agenta
