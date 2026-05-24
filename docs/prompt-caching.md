# Prompt Caching — wersja Opus 4.7

> Ten plik powstał na modelu **Opus 4.7** dla porównania z `prompt-caching.md` napisanym przez Sonnet 4.6. Treść tematycznie ta sama, ale możesz zobaczyć, jak różni się głębia ujęcia, struktura argumentacji i konkrety praktyczne.

---

> ## Kiedy ta wiedza jest Ci potrzebna?
>
> | Scenariusz | Czy musisz konfigurować cache? | Dlaczego |
> |---|---|---|
> | Claude Code w terminalu | ❌ Nie | Anthropic kesuje automatycznie pod maską |
> | Własne komendy slash (`/seo-audit`) | ❌ Nie | To nadal Claude Code — działa autocache |
> | Skrypt Python z `anthropic.Anthropic()` | ✅ Tak | Bez `cache_control` cache nie powstaje |
> | Usługa na Cloud Run / Cloud Functions / Lambda | ✅ **Tak — kluczowe** | Każdy request usługi = osobne wywołanie API; bez cache koszty rosną liniowo z ruchem |
> | Batch API (wiele audytów naraz) | ✅ Tak | Cache + batch = największa redukcja kosztu |
>
> **Niuans dla serverless:** cache żyje po stronie Anthropica, nie Twojej. Zimny start Cloud Run, nowa instancja kontenera, request trafiający do innego node'a — cache i tak działa, bo jest powiązany z kombinacją (API key + treść prefiksu), a nie z Twoją infrastrukturą.
>
> Krótko: **w terminalu — ciekawostka. We własnej aplikacji wołającej API — decyzja architektoniczna z bezpośrednim wpływem na rachunek.**

---

## Czym właściwie jest prompt caching — model mentalny

Standardowo każde wywołanie API to świeży start: model dostaje cały kontekst (system prompt, historia, dokumenty) i przetwarza go od zera. To jak otwieranie tej samej grubej książki za każdym razem, gdy chcesz zadać jedno pytanie.

Prompt caching odwraca tę logikę: pierwsze wywołanie buduje na serwerze migawkę stanu modelu **po przeczytaniu Twojego długiego kontekstu**. Kolejne wywołania nie czytają książki na nowo — startują od tej migawki i dodają tylko nowe pytanie. To dlatego cache hit kosztuje ~10% zwykłej stawki: serwer pomija najdroższy etap (atencję nad całym kontekstem) i wraca do gotowego stanu.

Konsekwencja praktyczna: cache opłaca się tym bardziej, im **większy stosunek stałej części do zmiennej**. Audyt SEO ntfy.pl ma idealne proporcje — 4600 tokenów stałych instrukcji vs 50 tokenów zmiennego URL-a. Stosunek 90:1.

---

## Trzy parametry, które trzeba zrozumieć

| Parametr | Wartość | Co oznacza |
|---|---|---|
| **Minimalna długość** | ~1024 tokeny (Sonnet/Opus) | Krótsze fragmenty nie są keszowane — API zignoruje `cache_control` |
| **TTL** | 5 minut (standard), 1 godzina (beta) | Czas od **ostatniego** użycia, nie od utworzenia. Każdy cache hit resetuje licznik |
| **Koszt zapisu** | 125% zwykłej stawki | Pierwsze wywołanie **droższe** niż bez cache — to inwestycja |

Trzeci punkt jest często przegapiany: cache **nie jest darmowy**. Jeśli wykonasz tylko jedno wywołanie i cache nigdy nie zostanie odczytany — przepłaciłeś o 25%. Break-even przy standardowej cenie wynosi **2 wywołania w ciągu TTL**. Trzecie i każde kolejne to czysta oszczędność.

```
Wywołanie 1: 1.25× (zapis cache)
Wywołanie 2: 0.10× (odczyt)  → razem 1.35× zamiast 2.00× — oszczędność 32%
Wywołanie 3: 0.10× (odczyt)  → razem 1.45× zamiast 3.00× — oszczędność 52%
Wywołanie 10: 0.10× × 9 = 0.9 + 1.25 = 2.15× zamiast 10.00× — oszczędność 78%
```

---

## Jak działa kolejność cache breakpoints (rzecz, o której Sonnet milczy)

Możesz ustawić do **4 breakpointów** w jednym wywołaniu — każdy wyznacza prefix do keszowania. Działa to kaskadowo: gdy zmieni się fragment przy breakpoincie #2, prefix do #1 dalej trafi z cache, ale od #2 w górę musi być przeliczony od nowa.

W audycie SEO daje to projekt warstwowy:

```
[breakpoint 1] system prompt + seo-audit.md         ← najbardziej stabilne
[breakpoint 2] kontekst projektu (CLAUDE.md)        ← rzadko się zmienia
[breakpoint 3] poprzedni raport ntfy-pl-…           ← zmienia się co tydzień
                                                       (bez breakpointu)
   wiadomość użytkownika: "audytuj URL X"             ← zmienne, nigdy nie keszowane
```

Im głębiej w hierarchii zmiana, tym mniej cache się unieważnia. Dlatego **kolejność ma znaczenie**: stałe na samym początku, zmienne na końcu.

---

## Kiedy cache się myli (czyli kiedy nie pomaga)

Sonnet napisał o pułapkach, ale nie zhierarchizował ich. Z mojej perspektywy:

**Krytyczne (cache nie zadziała wcale):**
1. Fragment poniżej 1024 tokenów — API milcząco ignoruje `cache_control`
2. Pierwsze wywołanie po >5 min przerwy — TTL wygasł
3. Jakikolwiek znak różnicy w prefiksie — nawet whitespace lub data w komentarzu

**Istotne (cache działa, ale ekonomicznie wątpliwie):**
4. Tylko 1-2 wywołania na sesję — break-even niedociągnięty
5. Bardzo krótkie sesje (1-2 audyty raz dziennie) — TTL wygasa między wywołaniami
6. Dane zmienne wstawione w środek prefiksu — wszystko od tego miejsca w górę przelicza się od nowa

**Subtelne (łatwo przegapić):**
7. Streaming kasuje statystyki — jeśli używasz streamingu, `usage` nie zawiera danych cache w niektórych SDK
8. Cache jest per-API-key — różne klucze nie współdzielą cache, nawet dla identycznego promptu
9. Tryb thinking (Extended) tworzy osobny cache niż tryb standardowy

Punkt 9 wiąże się bezpośrednio z poprzednim tematem w backlogu: jeśli używasz Opus 4.7 z Extended Thinking dla strategicznej analizy raportów, a Sonneta dla rutynowych audytów — masz **dwa niezależne cache** mimo identycznych instrukcji. To nie jest błąd projektowy, tylko świadoma decyzja Anthropica (różne modele = różne wewnętrzne reprezentacje).

---

## Praktyczny scenariusz, którego Sonnet nie pokazał

Załóżmy, że co poniedziałek `/schedule` uruchamia audyt ntfy.pl. Raz w tygodniu, zimny start, jedno wywołanie. **Cache nie pomaga w ogóle** — w tym scenariuszu rezygnujesz z `cache_control`, bo płacisz 125% za nic.

Ale gdy audytujesz **wiele podstron** w tej samej sesji `/schedule`:

```python
SUBSTRONY = [
    "https://ntfy.pl/",
    "https://ntfy.pl/longevity/",
    "https://ntfy.pl/rabat/",
    "https://ntfy.pl/blog/",
    "https://ntfy.pl/o-nas/",
]

for url in SUBSTRONY:
    run_audit(url)  # 5 wywołań w ciągu ~2 minut
```

Oszczędność:
- Bez cache: 5 × 4800 = 24 000 tokenów wejściowych
- Z cache: 1.25 × 4650 + 4 × 465 + 5 × 200 = 5812 + 1860 + 1000 = **8672 tokenów**
- Redukcja: **64%**

Wniosek strategiczny: **cache nie opłaca się przy pojedynczych audytach, ale staje się obowiązkowy przy audytach multi-page**. To naturalnie prowadzi do tematu subagentów (punkt 1 backlogu) — równoległe audyty wielu podstron to dokładnie scenariusz, w którym cache świeci.

---

## Skrypt diagnostyczny — bardziej kompletny

```python
"""
scripts/cache-diagnose.py — mierzy realną oszczędność cache
dla audytu SEO multi-page.
"""
import anthropic
import time
from pathlib import Path
from dataclasses import dataclass

client = anthropic.Anthropic()
INSTRUCTIONS = Path(".claude/commands/seo-audit.md").read_text()

@dataclass
class CallStats:
    input_tokens: int
    cache_read: int
    cache_write: int
    output_tokens: int
    duration_s: float

    @property
    def billed_input(self) -> float:
        """Efektywne tokeny wejściowe po uwzględnieniu cache."""
        return self.cache_write * 1.25 + self.cache_read * 0.10 + self.input_tokens

def audit(url: str) -> CallStats:
    t0 = time.time()
    response = client.messages.create(
        model="claude-opus-4-7",  # użyj Opus, by zobaczyć cache w trybie thinking
        max_tokens=4096,
        system=[
            {
                "type": "text",
                "text": INSTRUCTIONS,
                "cache_control": {"type": "ephemeral"},
            }
        ],
        messages=[{"role": "user", "content": f"Audyt SEO: {url}"}],
    )
    u = response.usage
    return CallStats(
        input_tokens=u.input_tokens,
        cache_read=u.cache_read_input_tokens,
        cache_write=u.cache_creation_input_tokens,
        output_tokens=u.output_tokens,
        duration_s=time.time() - t0,
    )

def main():
    urls = [
        "https://ntfy.pl/",
        "https://ntfy.pl/longevity/",
        "https://ntfy.pl/rabat/",
    ]

    total_without_cache = 0
    total_with_cache = 0

    for i, url in enumerate(urls, 1):
        s = audit(url)
        without = s.input_tokens + s.cache_read + s.cache_write
        with_ = s.billed_input

        total_without_cache += without
        total_with_cache += with_

        print(f"#{i} {url}")
        print(f"   czas:               {s.duration_s:.1f}s")
        print(f"   bez cache:          {without:>6} tokenów")
        print(f"   z cache (efektywne): {with_:>6.0f} tokenów")
        print(f"   oszczędność:        {(1 - with_/without)*100:>5.1f}%\n")

    print(f"SUMA bez cache:  {total_without_cache:>6} tokenów")
    print(f"SUMA z cache:    {total_with_cache:>6.0f} tokenów")
    print(f"REDUKCJA:        {(1 - total_with_cache/total_without_cache)*100:>5.1f}%")

if __name__ == "__main__":
    main()
```

Różnica względem przykładu Sonneta: liczę **efektywny koszt** (z mnożnikami 1.25× i 0.10×), a nie surowe tokeny. Surowe liczby pokazują "ile cache odczytano", ale nie odpowiadają na pytanie "ile zapłaciłem".

---

## Co warto zapamiętać

1. **Cache to inwestycja, nie automatyczny zysk** — pierwsze wywołanie kosztuje 125%, break-even przy drugim
2. **Kolejność breakpointów odwzorowuje stabilność** — najstabilniejsze na początku
3. **5 minut to nie 5 minut od utworzenia, tylko od ostatniego użycia** — aktywne sesje samoodnawiają cache
4. **Cache jest osobny per model i per tryb** — Opus thinking i Sonnet to dwa różne cache
5. **Realna oszczędność liczy się efektywnymi tokenami (×1.25 / ×0.10)**, nie surowymi liczbami z `usage`

---

## Co dalej w projekcie

Naturalna kontynuacja to **Batch API** (punkt 5 backlogu). Batch wywołuje wiele requestów asynchronicznie z 50% rabatem cenowym, a cache działa też wewnątrz batcha — efekty się składają. Audyt 20 podstron ntfy.pl w batchu z cache to praktycznie najtańszy możliwy sposób skanowania całego serwisu.

---

## Notatka do porównania z wersją Sonneta

Czytając oba pliki obok siebie, zwróć uwagę na:

- **Strukturę argumentacji**: Sonnet listuje fakty; Opus buduje model mentalny, potem na nim opiera szczegóły
- **Hierarchizację**: Sonnet podaje pułapki jako bullet list; Opus dzieli je na krytyczne / istotne / subtelne
- **Liczby**: Sonnet pokazuje surowe tokeny; Opus liczy break-even i efektywny koszt
- **Połączenia**: Sonnet wspomina o innych tematach na końcu; Opus pokazuje, jak cache mechanicznie sprzęga się z subagentami i `/schedule`
- **Zakres**: Opus dorzuca rzeczy, których Sonnet nie ruszył — koszt zapisu 125%, cache breakpoints, różnice między modelami, streaming gubiący stats

To nie jest "Opus lepszy, Sonnet gorszy" — to **dwa różne profile zwrotu z inwestycji w model**. Dla notatki o cache Opus daje więcej, ale za 3-4× wyższy koszt. Sonneta wystarczy do większości codziennych zadań.
