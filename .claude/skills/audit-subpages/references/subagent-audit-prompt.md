# Prompt subagenta — uproszczony audyt SEO

Przekaż ten prompt każdemu subagentowi (podstaw konkretny URL za `[URL]`).

---

Przeprowadź uproszczony audyt SEO strony: **[URL]**

Użyj curl i/lub WebFetch aby sprawdzić poniższe punkty. Nie pytaj o uprawnienia — działaj w ramach dozwolonych narzędzi.

Sprawdź:

1. **Title tag** — pełny tekst, liczba znaków, czy zawiera słowo kluczowe strony
2. **Meta description** — pełny tekst, liczba znaków, czy jest obecna
3. **H1** — tekst, ile razy występuje na stronie
4. **Hierarchia nagłówków** — czy są skoki (np. H1→H3 bez H2)
5. **Canonical** — wartość atrybutu href, czy wskazuje na siebie
6. **Robots meta** — wartość (index/noindex, follow/nofollow)
7. **Czas odpowiedzi** — użyj `curl -sI -w "%{time_total}" -o /dev/null [URL]` i odczytaj ms
8. **Liczba linków wewnętrznych** — ile linków do tej samej domeny jest na stronie

Zwróć wynik **wyłącznie jako JSON** (bez dodatkowego tekstu przed/po):

```json
{
  "url": "...",
  "title": {"text": "...", "length": 0, "ok": true},
  "meta_description": {"text": "...", "length": 0, "ok": true},
  "h1": {"text": "...", "count": 1, "ok": true},
  "headings_hierarchy_ok": true,
  "canonical": {"url": "...", "self_referencing": true, "ok": true},
  "robots_meta": "index,follow",
  "response_time_ms": 0,
  "internal_links_count": 0,
  "issues": [],
  "score": 0
}
```

Oblicz `score` (0–100), odejmując:
- -20 jeśli brak title lub długość >70 znaków
- -15 jeśli brak meta description lub długość >160 znaków
- -20 jeśli brak H1 lub count > 1
- -10 jeśli skoki w hierarchii nagłówków
- -15 jeśli brak canonical lub wskazuje na inną stronę
- -10 jeśli robots = noindex
- -5 za każdy dodatkowy problem w `issues` (max -20)
