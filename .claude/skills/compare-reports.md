---
name: compare-reports
description: Porównuje dwa raporty z audytu SEO z folderu reports/, żeby śledzić poprawki i regresje w czasie. Użyj gdy użytkownik mówi "porównaj raporty", "co się zmieniło w SEO", "czy SEO się poprawiło", "różnice między audytami", "trendy SEO", lub pyta co się zmieniło między dwoma audytami.
allowed-tools:
  - Read
  - Write
  - Bash
model: haiku
---

# Compare SEO Reports

Porównaj dwa raporty z audytu SEO i wygeneruj diff — co się poprawiło, co się pogorszyło, co bez zmian.

## Krok 1 — Wybierz raporty do porównania

1. Wylistuj pliki w `reports/` posortowane po dacie (pomijaj pliki `compare-*` i `subpages-*`)
2. Jeśli użytkownik podał dwa pliki lub daty — użyj ich
3. W przeciwnym razie weź dwa najnowsze raporty automatycznie
4. Potwierdź wybór: "Porównuję: `[plik1]` vs `[plik2]`"

Jeśli jest tylko jeden raport — poinformuj i zakończ: nie ma z czym porównać.

## Krok 2 — Odczytaj oba raporty

Przeczytaj oba pliki Markdown w całości narzędziem Read.

## Krok 3 — Porównaj metryki

Dla każdego wymiaru zanotuj wartość STARA → NOWA i sklasyfikuj:
- ✅ Poprawione
- ❌ Regresja lub nowy problem
- ➡️ Bez zmian

**Techniczne**
- Status robots.txt (blokuje/nie blokuje)
- Sitemap (obecna/brakuje/błędy)
- Tagi canonical (poprawne/problem)
- HTTPS (OK/problem)
- Przekierowania (brak problemów/łańcuchy/pętle)

**On-Page**
- Title tag: długość, czy zawiera słowo kluczowe
- Meta description: długość, czy jest
- H1: obecny, jeden, słowo kluczowe
- Hierarchia nagłówków: problemy tak/nie

**Treść i linki**
- Cienkie treści (thin content): liczba problemów
- Linki wewnętrzne: problemy tak/nie
- Alt text na obrazkach: OK/problem

**Priorytety**
- Problemy krytyczne: liczba STARA → NOWA
- Problemy wysokie: liczba STARA → NOWA
- Quick Wins: nowe vs rozwiązane

## Krok 4 — Zapisz i wyświetl raport

Zapisz do `reports/compare-YYYY-MM-DD.md` (użyj dzisiejszej daty):

```
# Porównanie SEO: [plik1] vs [plik2]
Data porównania: [dzisiaj]
Zakres: [data raportu 1] → [data raportu 2]

## Podsumowanie

| Kategoria | Poprzednio | Teraz | Zmiana |
|-----------|-----------|-------|--------|
| Problemy krytyczne | X | Y | +/-Z |
| Problemy wysokie | X | Y | +/-Z |
| Quick Wins | X | Y | +/-Z |

## ✅ Co się poprawiło
- [konkretne zmiany z dowodami z raportów]

## ❌ Co się pogorszyło lub nowe problemy
- [konkretne regresje]

## ➡️ Bez zmian (ale nadal wymaga uwagi)
- [rzeczy które wciąż są problemem]

## Rekomendacja na ten tydzień
[1–2 zdania: co warto zrobić teraz, bazując na trendzie]
```

Następnie wydrukuj tabelę podsumowania i rekomendację w rozmowie (nie tylko w pliku).
