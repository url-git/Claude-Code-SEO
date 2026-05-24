# Extended Thinking w Claude Code

Extended Thinking to tryb, w którym Claude poświęca dodatkowy czas na wewnętrzne rozumowanie przed udzieleniem odpowiedzi. Model „myśli na głos" w ukrytym bloku — waży argumenty, odrzuca złe ścieżki — a dopiero potem formułuje odpowiedź. W Claude Code widoczne jako zwijany blok `▶ Myślenie`.

---

## Czym różni się od zwykłego trybu?

| | Standardowy | Extended Thinking |
|---|---|---|
| Rozumowanie | Ukryte, skrócone | Widoczne, wieloetapowe |
| Czas odpowiedzi | Szybki | Wolniejszy (30–90 s) |
| Koszt | Niższy | Wyższy (myślenie też jest billowane jako output) |
| Kiedy warto | Zadania rutynowe | Decyzje, strategie, diagnoza |

---

## Adaptive thinking vs manual (stan 2026)

Anthropic zmienił model API:

| Model | Tryb |
|---|---|
| **Opus 4.7** | Tylko **adaptive thinking** — manualne `budget_tokens` zwraca 400 |
| **Opus 4.6, Sonnet 4.6** | Adaptive zalecane, manual deprecated (ale działa) |
| Starsze modele | Manual `budget_tokens` |

**Adaptive** = Claude sam decyduje, ile myśleć, na podstawie złożoności promptu i opcjonalnego `effort` parametru. W Claude Code dzieje się to automatycznie — nie musisz nic konfigurować.

```python
# stare (deprecated)
thinking={"type": "enabled", "budget_tokens": 10000}

# nowe (zalecane)
thinking={"type": "adaptive"}
```

---

## Jak uruchomić w Claude Code

### Zmiana modelu na Opus

```
/model
```

Wybierz `claude-opus-4-7`. Od tej chwili Claude używa Opusa z adaptive thinking.

### Tryb Fast

```
/fast
```

Przełącza Opus w tryb szybszego outputu — **nie wyłącza thinking**, tylko przyspiesza odpowiedź. Dostępne na Opus 4.6 i 4.7.

### Wymuszenie głębszego myślenia w prompcie

Adaptive thinking reaguje na złożoność zapytania — wystarczy poprosić wprost:

```
Przeanalizuj ten raport SEO dokładnie, zanim odpiszesz. Weź pod uwagę
wszystkie zależności między problemami i zaproponuj priorytety.
```

Nie musisz wpisywać żadnej komendy technicznej — model sam dobiera budżet myślenia.

---

## Zastosowania w tym projekcie

### 1. Priorytetyzacja problemów SEO

Sonnet zbiera fakty: „brak meta description, wolny LCP, brak sitemapy". Opus z thinking pyta głębiej: **które problemy realnie blokują ruch?** Uwzględnia kontekst biznesowy, konkurencję, stan indeksacji.

```
/model → claude-opus-4-7

Mam raport SEO ntfy.pl z maja 2026 (reports/ntfy-pl-2026-05-15.md).
Wskaż 3 problemy z największym wpływem na ruch organiczny. Uzasadnij.
```

### 2. Porównanie raportów tygodniowych

Zamiast diff-a linii — ocena **czy zmiany idą w dobrym kierunku** i czy poprawa w jednym miejscu nie ukrywa regresji w innym.

```
Porównaj reports/ntfy-pl-2026-05-15.md i ntfy-pl-2026-05-22.md.
Oceń trend: czy SEO się poprawia? Co mogło spowodować zmiany?
```

### 3. Diagnoza spadku ruchu i strategia contentowa

Złożone, syntetyczne zadania — Opus z thinking analizuje hipotezy pod kątem prawdopodobieństwa, sprawdza spójność z aktualizacjami Google, proponuje plan na 3 miesiące z uwzględnieniem luk tematycznych i realiów małego SaaS.

---

## Kiedy NIE używać Extended Thinking

- Sprawdzenie robots.txt — wystarczy `curl`
- Pobranie tytułu strony — Sonnet daje radę
- Zapis raportu do pliku — bez sensu angażować Opusa
- Szybkie pytanie o składnię komendy

Reguła: zadanie mechaniczne (fetch → zapis) → Sonnet. Zadanie wymagające oceny, priorytetyzacji, strategii → Opus.

---

## Interakcje z prompt caching

- **System prompt cache jest zachowywany** mimo zmian w thinking
- **Message-level cache jest unieważniany** przy zmianie `budget_tokens` (nie dotyczy adaptive)
- **Bloki thinking są keszowane** i liczą się jako input tokens przy odczycie
- Dla zadań trwających >5 min użyj **TTL 1h** — thinking często przekracza domyślne 5 minut cache

---

## Porównanie wyników — ćwiczenie

Uruchom to samo zapytanie dwa razy: na Sonnet i na Opus (`/model → claude-opus-4-7`).

Porównaj:
- Długość bloku `▶ Myślenie`
- Czy Opus odrzucił hipotezy, które Sonnet przyjął bez refleksji?
- Czy priorytety są inne?
- Ile czasu zajęła każda odpowiedź?

---

## Podsumowanie

```
Sonnet (domyślny)          Opus + adaptive thinking
─────────────────          ────────────────────────
Fetch strony               Priorytetyzacja problemów
Zapis raportu              Porównanie raportów
Sprawdzenie robots.txt     Diagnoza spadku ruchu
Rutynowe audyty            Strategia contentowa
```

Kluczowa lekcja: Extended Thinking nie zastępuje dobrego promptu — wzmacnia go. Im lepiej opisany kontekst i cel, tym głębsza analiza.
