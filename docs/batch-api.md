# Batch API — asynchroniczne przetwarzanie wielu audytów

> ## Kiedy ta wiedza jest Ci potrzebna?
>
> | Scenariusz | Batch API ma sens? |
> |---|---|
> | Pojedyncza rozmowa w Claude Code | ❌ — Batch nie istnieje w sesji interaktywnej |
> | Audyt 1-2 stron raz w tygodniu | ❌ — narzut konfiguracji większy niż oszczędność |
> | Audyt 20-100+ podstron ntfy.pl | ✅ — oszczędność 50% + równoległość |
> | Codzienna analiza wielu klientów (skrypt) | ✅ — idealny use case |
> | Aplikacja na Cloud Run odpowiadająca w czasie rzeczywistym | ❌ — Batch ma 5min-24h opóźnienia |
>
> Krótko: **Batch API to narzędzie do operacji masowych, których wynik nie jest potrzebny natychmiast.** Jeśli możesz poczekać kilka–kilkadziesiąt minut, płacisz 50% mniej. Jeśli potrzebujesz odpowiedzi w 3 sekundy — to nie jest to narzędzie.

---

## Model mentalny — czym Batch różni się od standardowego API

Standardowe API to **dialog**: wysyłasz request, czekasz, dostajesz odpowiedź, wysyłasz kolejny. Każde wywołanie jest synchroniczne i blokuje Twój kod do momentu otrzymania wyniku.

Batch API to **lista zakupów**: wrzucasz na nią 20-100 requestów naraz, oddajesz Anthropicowi i wracasz za jakiś czas po wszystkie wyniki naraz. Anthropic przetwarza je równolegle na swojej infrastrukturze, korzystając z momentów niskiego obciążenia. Stąd 50% rabat — w zamian za elastyczność czasową dostajesz znacznie niższą cenę.

| | Standardowe API | Batch API |
|---|---|---|
| Sposób działania | Sync, request-response | Async, prześlij batch i odbierz później |
| Cena | 100% | **50%** |
| Czas odpowiedzi | Sekundy | Zwykle 5 min – 1h, max 24h |
| Maksymalna liczba requestów | 1 na wywołanie | **100 000 w jednym batchu** |
| Limit rozmiaru | brak | 256 MB |
| Gwarancja czasowa | natychmiast | tylko górna granica (24h) |
| Cache działa | ✅ | ✅ (jeśli requesty bliskie czasowo) |

---

## Trzy decyzje, które trzeba podjąć przed użyciem Batch

### 1. Czy wynik może poczekać?

Realny czas przetwarzania batcha jest **niedeterministyczny**. Zwykle wyniki są gotowe w 5-30 minut, ale Anthropic gwarantuje tylko 24 godziny. Jeśli Twój workflow zakłada „audyt zaplanowany na poniedziałek o 03:00, raport gotowy do śniadania" — Batch to idealne narzędzie. Jeśli klient klika przycisk i czeka na ekranie — nie.

### 2. Czy masz wystarczająco dużo requestów?

Batch ma narzut: serializacja JSONL, upload, polling statusu, parsowanie wyników. Dla 1-2 requestów to dłużej niż zwykłe wywołanie. Próg opłacalności jest dwojaki:
- **Czasowy**: ~5 requestów (powyżej narzut się amortyzuje)
- **Kosztowy**: dowolna liczba, jeśli wartość 50% rabatu > Twój czas konfiguracji

### 3. Czy wszystkie requesty są niezależne?

Batch nie obsługuje sekwencji — każdy request widzi tylko swój własny prompt. Jeśli audyt podstrony B musi zacząć się od wyniku audytu podstrony A, to **nie jest** scenariusz dla Batch — to seria sync calls. Batch nadaje się do równoległych, niezależnych zadań.

---

## Format batcha — co właściwie wysyłasz

Batch to plik JSONL, gdzie każda linia to osobny request o znanej strukturze:

```jsonl
{"custom_id": "audit-home", "params": {"model": "claude-sonnet-4-6", "max_tokens": 4096, "messages": [{"role": "user", "content": "Audyt SEO: https://ntfy.pl/"}]}}
{"custom_id": "audit-longevity", "params": {"model": "claude-sonnet-4-6", "max_tokens": 4096, "messages": [{"role": "user", "content": "Audyt SEO: https://ntfy.pl/longevity/"}]}}
{"custom_id": "audit-rabat", "params": {"model": "claude-sonnet-4-6", "max_tokens": 4096, "messages": [{"role": "user", "content": "Audyt SEO: https://ntfy.pl/rabat/"}]}}
```

Najważniejsze pole to **`custom_id`** — Twoje własne ID, po którym potem mapujesz wynik z powrotem na konkretną podstronę. Anthropic nie gwarantuje kolejności wyników, więc bez `custom_id` byś nie wiedział, który raport dotyczy której strony.

---

## Cykl życia batcha

```
1. CREATE        → wysyłasz JSONL, dostajesz batch_id
                   status: "in_progress"
                                │
2. PROCESSING    → Anthropic przetwarza równolegle (5min - 24h)
                   możesz pollować status co N minut
                                │
3. ENDED         → wszystkie requesty zakończone
                   status: "ended" lub "canceled" / "expired"
                                │
4. RETRIEVE      → pobierasz wyniki jako JSONL
                   parsujesz po custom_id
                                │
5. CLEANUP       → wyniki dostępne do pobrania 29 dni, potem znikają
```

Polling: nie pollujesz w sekundowej pętli — to marnotrawstwo. Sensowny interwał to **30-60 sekund** dla małych batchy, **5 minut** dla dużych.

---

## Praktyczny skrypt — audyt wielu podstron ntfy.pl

```python
"""
scripts/batch-audit.py — audyt SEO wszystkich podstron ntfy.pl
przez Batch API z włączonym cache.
"""
import json
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
    # ... dodaj resztę
]

# ─── KROK 1: zbuduj requesty ────────────────────────────────────────
requests = []
for url in URLS:
    custom_id = url.rstrip("/").split("/")[-1] or "home"
    requests.append({
        "custom_id": f"audit-{custom_id}",
        "params": {
            "model": "claude-sonnet-4-6",
            "max_tokens": 4096,
            "system": [
                {
                    "type": "text",
                    "text": INSTRUCTIONS,
                    "cache_control": {"type": "ephemeral"},
                }
            ],
            "messages": [
                {"role": "user", "content": f"Wykonaj audyt SEO strony: {url}"}
            ],
        },
    })

# ─── KROK 2: wyślij batch ───────────────────────────────────────────
batch = client.messages.batches.create(requests=requests)
print(f"Batch utworzony: {batch.id}")
print(f"Status: {batch.processing_status}")

# ─── KROK 3: pollowanie statusu ─────────────────────────────────────
while batch.processing_status == "in_progress":
    print(f"  Przetwarzanie... {batch.request_counts}")
    time.sleep(60)  # 1 minuta między pollami
    batch = client.messages.batches.retrieve(batch.id)

print(f"Batch zakończony: {batch.processing_status}")
print(f"Wyniki: {batch.request_counts}")

# ─── KROK 4: pobierz i zapisz wyniki ────────────────────────────────
out_dir = Path("reports/batch")
out_dir.mkdir(parents=True, exist_ok=True)

for result in client.messages.batches.results(batch.id):
    cid = result.custom_id
    if result.result.type == "succeeded":
        content = result.result.message.content[0].text
        (out_dir / f"{cid}.md").write_text(content)
        print(f"✓ {cid} → reports/batch/{cid}.md")
    else:
        print(f"✗ {cid}: {result.result.type}")

# ─── KROK 5: podsumowanie kosztów ───────────────────────────────────
print("\nBatch API kosztował 50% normalnej ceny synch API.")
print("Plus cache na instrukcjach — efektywnie ~10% × 50% za prefix.")
```

---

## Matematyka oszczędności — Batch + Cache

Załóżmy audyt 20 podstron ntfy.pl. `seo-audit.md` to ~4600 tokenów instrukcji, każde pytanie ~200 tokenów, odpowiedź ~1000 tokenów.

| Wariant | Cena per audyt | Suma za 20 audytów |
|---|---|---|
| Sync, bez cache | 100% wejścia + 100% wyjścia | 100% × 20 = **2000%** |
| Sync, z cache | 125%/10% wejścia + 100% wyjścia (per audyt) | ~**540%** |
| Batch, bez cache | 50% wszystkiego | 50% × 20 = **1000%** |
| **Batch + cache** | 50% × (125%/10% + 100%) | ~**270%** |

Skala: **redukcja ~86%** względem najgorszego wariantu. Cache i Batch działają multiplikatywnie, nie addytywnie — to dlatego są wymieniane razem w backlogu.

---

## Kiedy Batch a kiedy subagenci

To są dwa różne narzędzia do podobnie wyglądającego problemu („zrób 20 rzeczy naraz"), ale ekonomicznie zupełnie inne:

| Wymiar | Subagenci (w sesji) | Batch API (skrypt) |
|---|---|---|
| Gdzie działają | W Twojej sesji Claude Code | Na serwerach Anthropica, async |
| Cena | 100% (standard) | 50% |
| Czas wyniku | Sekundy-minuty | 5min - 24h |
| Limit liczby | ~10 równoległych | 100 000 |
| Twój udział | Widzisz wyniki w sesji | Musisz pollować skryptem |
| Idealne dla | Interaktywne, średnia skala | Bulk, wielka skala, asynchroniczne |

**Reguła praktyczna:** jeśli siedzisz przy terminalu i chcesz natychmiastowy wynik na 5-10 podstron → subagenci. Jeśli planujesz cykliczny audyt 100+ podstron i nie pilisz się z wynikiem → Batch.

---

## Kiedy Batch a kiedy `/schedule` (rutyny)

Te dwa narzędzia są często mylone, bo oba są „nie tu i teraz". Różnica jest fundamentalna:

| Wymiar | Batch API | `/schedule` (rutyna) |
|---|---|---|
| Co uruchamia | Wiele requestów naraz | Jednego agenta |
| Trigger | Twój skrypt | Cron na serwerach Anthropic |
| Częstotliwość | Jednorazowo (per batch) | Cyklicznie (np. co poniedziałek) |
| Inteligencja | Niska — surowe wywołania API | Wysoka — pełny agent z toolami |
| Idealny case | Audytuj 100 stron jednorazowo | Co tydzień audytuj 1 stronę |

Można je **łączyć**: rutyna uruchamiana co poniedziałek o 03:00, wewnątrz której agent generuje listę URL-i i odpala Batch API. To najwyższy poziom optymalizacji w tym projekcie — automatyczny, masowy, najtańszy.

---

## Pułapki

**1. JSONL musi być poprawny syntaktycznie** — jedna źle sformatowana linia odrzuci cały batch. Walidator: każda linia powinna być parsowalnym JSON-em i mieć pola `custom_id` + `params`.

**2. `custom_id` musi być unikalny w obrębie batcha** — duplikat = błąd. Bezpieczna konwencja: prefiks + hash URL-a.

**3. Wyniki nie zachowują kolejności wysłania** — zawsze mapuj po `custom_id`, nie po indeksie.

**4. Niektóre requesty w batchu mogą zawodzić** — Batch nie jest „all-or-nothing". Sprawdzaj `result.result.type` per request: może być `succeeded`, `errored`, `canceled` lub `expired`.

**5. Token API musi mieć włączony Batch** — niektóre konta organizacyjne mają to wyłączone domyślnie. Sprawdź console.anthropic.com → Settings.

**6. Cache w Batchu działa tylko, jeśli requesty są bliskie czasowo** — gdy Anthropic rozproszy batch po 6 godzinach, środkowe requesty mogą trafić w pusty cache. To rzadkość, ale możliwa.

---

## Co warto zapamiętać

1. **50% rabatu w zamian za elastyczność czasową** — jeśli możesz poczekać 30 minut, płacisz połowę
2. **Batch + Cache multiplikatywnie** — łączny efekt: redukcja kosztu o ~80-90% w typowych scenariuszach masowych
3. **Async to nie zawsze plus** — narzut konfiguracji nie opłaca się przy 1-2 requestach
4. **`custom_id` to Twoja kotwica** — bez niego nie powiążesz wyników z requestami
5. **Batch ≠ subagenci ≠ rutyny** — trzy różne narzędzia do trzech różnych problemów

---

## Co dalej w tym projekcie

Naturalny krok następny: **napisz `scripts/batch-audit.py` i przetestuj go na 5 podstronach ntfy.pl**. Cel ćwiczeniowy nie jest „obniżyć rachunek" (przy 5 podstronach oszczędność to grosze), tylko **poczuć cykl async**: utworzenie batcha, polling, parsowanie wyników. Gdy zrozumiesz mechanikę na małej skali, przejście do 100 podstron jest trywialne.

Po Batch API backlog wyczerpany. Logiczna kontynuacja to **połączenie wszystkich pięciu tematów** w jeden zaawansowany pipeline:
- Rutyna co poniedziałek (punkt 3)
- Rutyna generuje listę podstron (subagenci, punkt 1)
- Wysyła Batch API z cache (punkty 4 + 5)
- Opus 4.7 z thinking analizuje wyniki porównawczo (punkt 2)
- Commit + push raportu zbiorczego

To jest właściwa skala dojrzałości Claude Code: nie jedna funkcjonalność, tylko ich kompozycja.
