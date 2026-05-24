# Batch API — asynchroniczne przetwarzanie wielu audytów

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
