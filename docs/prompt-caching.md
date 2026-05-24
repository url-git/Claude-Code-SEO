# Prompt Caching — szybsze i tańsze powtórne audyty

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
> **Niuans dla serverless:** cache żyje po stronie Anthropica. Zimny start Cloud Run, nowa instancja kontenera, request do innego node'a — cache i tak działa, bo jest powiązany z (workspace + treść prefiksu), a nie z Twoją infrastrukturą.
>
> Krótko: **w terminalu — ciekawostka. We własnej aplikacji wołającej API — decyzja architektoniczna z bezpośrednim wpływem na rachunek.**

---

## Model mentalny

Standardowo każde wywołanie API to świeży start — model przetwarza cały kontekst od zera. Prompt caching odwraca logikę: pierwsze wywołanie buduje na serwerze migawkę stanu modelu **po przeczytaniu Twojego długiego kontekstu**, a kolejne wywołania startują od tej migawki. Cache hit kosztuje ~10% stawki, bo serwer pomija najdroższy etap (atencję nad całym kontekstem).

Cache opłaca się tym bardziej, im **większy stosunek stałej części do zmiennej**. Audyt ntfy.pl ma idealne proporcje — 4600 tok. stałych instrukcji vs 50 tok. zmiennego URL-a. Stosunek 90:1.

---

## Trzy parametry, które trzeba zrozumieć

| Parametr | Wartość | Co oznacza |
|---|---|---|
| **Minimalna długość** | 1024 tok. (Sonnet 4.6 / Opus 4.1) lub **4096 tok.** (Opus 4.7/4.6/4.5, Haiku 4.5) | Krótsze fragmenty nie są keszowane — API milcząco zignoruje `cache_control` |
| **TTL** | 5 minut (default) lub 1 godzina (`ttl: "1h"`) | Czas od **ostatniego** użycia. Każdy cache hit resetuje licznik bez dodatkowej opłaty |
| **Koszt zapisu** | 125% stawki (5m) lub **200%** (1h) | Pierwsze wywołanie droższe niż bez cache — to inwestycja |
| **Koszt odczytu** | 10% stawki | Cache hit zawsze taki sam, niezależnie od TTL |
| **Izolacja** | per-workspace (Claude API/AWS/Foundry od 5.02.2026), per-org (Bedrock/Vertex) | Różne workspace'y nie współdzielą cache mimo identycznego promptu |

Trzeci punkt jest często przegapiany: cache **nie jest darmowy**. Jeśli wykonasz tylko jedno wywołanie i cache nigdy nie zostanie odczytany — przepłaciłeś o 25% (lub 100% przy TTL 1h). Break-even dla 5m wynosi **2 wywołania w ciągu TTL**.

```
Wywołanie 1: 1.25× (zapis cache)
Wywołanie 2: 0.10× (odczyt)  → razem 1.35× zamiast 2.00× — oszczędność 32%
Wywołanie 3: 0.10× (odczyt)  → razem 1.45× zamiast 3.00× — oszczędność 52%
Wywołanie 10: 0.10× × 9 = 0.9 + 1.25 = 2.15× zamiast 10.00× — oszczędność 78%
```

---

## Jak działa kolejność cache breakpoints

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

**Krytyczne (cache nie zadziała wcale):**
1. Fragment poniżej progu modelu (1024 lub 4096 tok.) — API milcząco ignoruje `cache_control`
2. Pierwsze wywołanie po wygaśnięciu TTL
3. Jakikolwiek znak różnicy w prefiksie — nawet whitespace lub data w komentarzu

**Istotne (cache działa, ale ekonomicznie wątpliwie):**
4. Tylko 1-2 wywołania na sesję — break-even niedociągnięty
5. Dane zmienne wstawione w środek prefiksu — wszystko od tego miejsca w górę przelicza się od nowa

**Subtelne (łatwo przegapić):**
6. Streaming kasuje statystyki w niektórych SDK — `usage` nie zawiera danych cache
7. Cache jest per-workspace (Claude API) — różne workspace'y nie współdzielą cache
8. Tryb thinking (Extended) tworzy osobny cache niż tryb standardowy; różne modele też mają osobne cache

---

## Praktyczny scenariusz multi-page

Załóżmy, że co poniedziałek `/schedule` uruchamia audyt ntfy.pl. Raz w tygodniu, zimny start, jedno wywołanie. **Cache nie pomaga w ogóle** — rezygnujesz z `cache_control`, bo płacisz 125% za nic.

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

Wniosek strategiczny: **cache nie opłaca się przy pojedynczych audytach, ale staje się obowiązkowy przy audytach multi-page** — równoległe audyty subagentami to dokładnie scenariusz, w którym cache świeci.

### Pre-warming cache (`max_tokens: 0`)

Nowa funkcja: można załadować system prompt do cache **przed** pierwszym requestem użytkownika, eliminując latencję cache-miss na pierwszej interakcji:

```python
client.messages.create(
    model="claude-opus-4-7",
    max_tokens=0,                # zero output, sam zapis cache
    system=[{"type": "text", "text": INSTRUCTIONS,
             "cache_control": {"type": "ephemeral"}}],
    messages=[{"role": "user", "content": "warmup"}],
)
```

Zwraca `stop_reason: "max_tokens"`, pusty `content`, ale wypełniony `usage` — cache jest gotowy.

---

## Skrypt diagnostyczny

```python
# scripts/cache-diagnose.py — mierzy realną oszczędność cache
import anthropic, time
from pathlib import Path

client = anthropic.Anthropic()
INSTRUCTIONS = Path(".claude/commands/seo-audit.md").read_text()

def audit(url: str):
    t0 = time.time()
    r = client.messages.create(
        model="claude-opus-4-7",
        max_tokens=4096,
        system=[{"type": "text", "text": INSTRUCTIONS,
                 "cache_control": {"type": "ephemeral"}}],
        messages=[{"role": "user", "content": f"Audyt SEO: {url}"}],
    )
    u = r.usage
    raw = u.input_tokens + u.cache_read_input_tokens + u.cache_creation_input_tokens
    billed = u.input_tokens + u.cache_creation_input_tokens * 1.25 + u.cache_read_input_tokens * 0.10
    return raw, billed, time.time() - t0

urls = ["https://ntfy.pl/", "https://ntfy.pl/longevity/", "https://ntfy.pl/rabat/"]
total_raw = total_billed = 0
for i, url in enumerate(urls, 1):
    raw, billed, dt = audit(url)
    total_raw += raw; total_billed += billed
    print(f"#{i} {url}: {dt:.1f}s, raw={raw}, billed={billed:.0f}, oszczędność={100*(1-billed/raw):.1f}%")
print(f"REDUKCJA SUMA: {100*(1-total_billed/total_raw):.1f}%")
```

Skrypt liczy **efektywny koszt** (×1.25 zapis, ×0.10 odczyt), a nie surowe tokeny — odpowiada na pytanie "ile zapłaciłem", a nie "ile cache odczytano".

---

## Co warto zapamiętać

1. **Inwestycja, nie automat** — zapis 125% (5m) / 200% (1h); break-even przy drugim wywołaniu
2. **Próg zależy od modelu** — Opus 4.7 / Haiku 4.5 wymagają 4096 tok.; Sonnet 4.6 tylko 1024
3. **Kolejność = stabilność** — najstabilniejsze fragmenty na początku
4. **TTL liczy się od ostatniego użycia** — aktywne sesje samoodnawiają cache bezpłatnie
5. **Cache osobny per workspace / model / tryb** — różne workspace'y, modele lub thinking = osobne cache

Kontynuacja: **Batch API** — 50% rabatu, a cache działa też wewnątrz batcha. Audyt 20 podstron w batchu z cache = najtańszy sposób skanowania serwisu.
