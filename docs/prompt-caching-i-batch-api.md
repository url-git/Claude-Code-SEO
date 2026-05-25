# Prompt Caching i Batch API — szybsze, tańsze audyty

---

# Część 1: Prompt Caching — szybsze i tańsze powtórne audyty

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

---

---

# Część 2: Batch API — asynchroniczne przetwarzanie wielu audytów

> ## Kiedy ta wiedza jest Ci potrzebna?
>
> | Scenariusz | Batch API ma sens? |
> |---|---|
> | Pojedyncza rozmowa w Claude Code | ❌ — Batch nie istnieje w sesji interaktywnej |
> | Audyt 1-2 stron raz w tygodniu | ❌ — narzut konfiguracji większy niż oszczędność |
> | Audyt 20-100+ podstron ntfy.pl | ✅ — oszczędność 50% + równoległość |
> | Codzienna analiza wielu klientów (skrypt) | ✅ — idealny use case |
> | Aplikacja real-time | ❌ — Batch ma 5min–24h opóźnienia |
>
> Krótko: **Batch API = narzędzie do operacji masowych, których wynik nie jest potrzebny natychmiast.** Jeśli możesz poczekać kilkadziesiąt minut, płacisz 50%. Jeśli potrzebujesz odpowiedzi w 3 s — to nie jest to narzędzie.

---

## Model mentalny

Standardowe API = **dialog**: request → czekasz → response, blokuje kod. Batch API = **lista zakupów**: wrzucasz 20-100 requestów naraz, Anthropic przetwarza je równolegle w momentach niskiego obciążenia, wracasz po wyniki później. Stąd 50% rabat.

| | Standardowe API | Batch API |
|---|---|---|
| Działanie | Sync, request-response | Async, prześlij i odbierz |
| Cena | 100% | **50%** |
| Czas odpowiedzi | Sekundy | <1h zwykle, max 24h |
| Max requestów | 1 / wywołanie | **100 000** / batch |
| Limit rozmiaru | brak | 256 MB |
| Retencja wyników | natychmiast | 29 dni |
| Cache działa | ✅ | ✅ best-effort (30-98% hit rate) |

---

## Trzy decyzje przed użyciem Batch

**1. Czy wynik może poczekać?** Czas przetwarzania niedeterministyczny — zwykle 5-60 min, max 24h. Workflow „audyt w niedzielę o 03:00, raport rano" → tak. Klient klika i czeka → nie.

**2. Czy masz wystarczająco dużo requestów?** Próg opłacalności: ~5 requestów (powyżej narzut się amortyzuje). Dla 1-2 — szybciej zwykłym API.

**3. Czy requesty są niezależne?** Batch nie obsługuje sekwencji — każdy request widzi tylko swój prompt. Nadaje się do równoległych, niezależnych zadań.

---

## Format batcha

Plik JSONL, każda linia to osobny request:

```jsonl
{"custom_id": "audit-home", "params": {"model": "claude-sonnet-4-6", "max_tokens": 4096, "messages": [{"role": "user", "content": "Audyt SEO: https://ntfy.pl/"}]}}
{"custom_id": "audit-longevity", "params": {"model": "claude-sonnet-4-6", "max_tokens": 4096, "messages": [{"role": "user", "content": "Audyt SEO: https://ntfy.pl/longevity/"}]}}
```

**`custom_id`** = Twoje ID, po którym mapujesz wyniki. Anthropic nie gwarantuje kolejności, więc bez `custom_id` nie wiesz, który raport dotyczy której strony.

---

## Cykl życia batcha

```
CREATE  → JSONL → batch_id, status: "in_progress"
PROCESS → Anthropic przetwarza równolegle (<1h zwykle, max 24h)
ENDED   → status: "ended" / "canceled" / "expired"
RETRIEVE→ pobierasz JSONL, parsujesz po custom_id
CLEANUP → wyniki dostępne 29 dni
```

Polling: nie w sekundowej pętli. Sensownie **30-60 s** dla małych batchy, **5 min** dla dużych.

---

## Praktyczny skrypt — audyt podstron ntfy.pl

```python
# scripts/batch-audit.py — audyt SEO przez Batch API z cache
import time
from pathlib import Path
import anthropic

client = anthropic.Anthropic()
INSTRUCTIONS = Path(".claude/commands/seo-audit.md").read_text()

URLS = [
    "https://ntfy.pl/",
    "https://ntfy.pl/longevity/",
    "https://ntfy.pl/rabat/",
    "https://ntfy.pl/blog/",
    "https://ntfy.pl/o-nas/",
]

requests = [{
    "custom_id": f"audit-{(u.rstrip('/').split('/')[-1] or 'home')}",
    "params": {
        "model": "claude-sonnet-4-6",
        "max_tokens": 4096,
        "system": [{"type": "text", "text": INSTRUCTIONS,
                    "cache_control": {"type": "ephemeral", "ttl": "1h"}}],
        "messages": [{"role": "user", "content": f"Audyt SEO: {u}"}],
    },
} for u in URLS]

batch = client.messages.batches.create(requests=requests)
print(f"Batch {batch.id}, status: {batch.processing_status}")

while batch.processing_status == "in_progress":
    print(f"  {batch.request_counts}")
    time.sleep(60)
    batch = client.messages.batches.retrieve(batch.id)

out_dir = Path("reports/batch")
out_dir.mkdir(parents=True, exist_ok=True)
for r in client.messages.batches.results(batch.id):
    if r.result.type == "succeeded":
        (out_dir / f"{r.custom_id}.md").write_text(r.result.message.content[0].text)
        print(f"✓ {r.custom_id}")
    else:
        print(f"✗ {r.custom_id}: {r.result.type}")
```

**Uwaga**: dla Batch używaj `ttl: "1h"` cache — batch może trwać dłużej niż 5 min default TTL, co kasuje cache hit rate.

---

## Matematyka oszczędności — Batch + Cache

Audyt 20 podstron: `seo-audit.md` ~4600 tok. instrukcji, pytanie ~200 tok., odpowiedź ~1000 tok.

| Wariant | Suma za 20 audytów |
|---|---|
| Sync, bez cache | **2000%** |
| Sync, z cache | ~**540%** |
| Batch, bez cache | **1000%** |
| **Batch + cache** | ~**270%** |

Redukcja **~86%** względem najgorszego wariantu. Cache i Batch działają multiplikatywnie.

---

## Batch vs subagenci vs `/schedule`

| Wymiar | Subagenci | Batch API | `/schedule` |
|---|---|---|---|
| Gdzie | W sesji Claude Code | Serwery Anthropic, async | Cron Anthropic |
| Cena | 100% | 50% | 100% |
| Czas wyniku | Sekundy-minuty | <1h zwykle | natychmiast (gdy odpalony) |
| Limit | ~10 równolegle | 100 000 | 1 agent na trigger |
| Idealny case | Interaktywne, 5-10 podstron | Bulk 100+, async | Cykliczne wykonanie |

Można **łączyć**: rutyna `/schedule` co poniedziałek o 03:00 wewnątrz generuje listę URL-i i odpala Batch API z cache. Najwyższy poziom optymalizacji.

---

## Pułapki

1. **JSONL musi być poprawny syntaktycznie** — jedna źle sformatowana linia odrzuca cały batch
2. **`custom_id` musi być unikalny w batchu** — duplikat = błąd; bezpiecznie: prefiks + hash URL-a
3. **Wyniki nie zachowują kolejności wysłania** — zawsze mapuj po `custom_id`
4. **Niektóre requesty mogą zawieść** — sprawdzaj `result.type`: `succeeded` / `errored` / `canceled` / `expired`
5. **Cache hit best-effort** — typowo 30-98%, dla shared context użyj `ttl: "1h"`
6. **`max_tokens: 0` (pre-warming cache) NIE działa w batchu** — wymaga ≥ 1

---

## Co warto zapamiętać

1. **50% rabatu w zamian za elastyczność czasową** — możesz poczekać 30 min → płacisz połowę
2. **Batch + Cache multiplikatywnie** — łączny efekt: redukcja kosztu ~80-90%
3. **Async to nie zawsze plus** — narzut nie opłaca się przy 1-2 requestach
4. **`custom_id` to Twoja kotwica** — bez niego nie powiążesz wyników
5. **Dla batchy używaj TTL 1h** — batch trwa zwykle dłużej niż 5 min default cache

Naturalna kontynuacja: napisz `scripts/batch-audit.py` i przetestuj na 5 podstronach ntfy.pl. Cel nie jest „obniżyć rachunek" (przy 5 podstronach to grosze), tylko **poczuć cykl async**: create → polling → parse. Gdy zrozumiesz mechanikę, skok do 100 podstron jest trywialny.
