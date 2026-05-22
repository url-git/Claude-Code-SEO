# Extended Thinking w Claude Code

Extended Thinking to tryb, w którym Claude poświęca dodatkowy czas na wewnętrzne rozumowanie przed udzieleniem odpowiedzi. Zamiast od razu generować wynik, model „myśli na głos" w ukrytym bloku — waży argumenty, odrzuca złe ścieżki, wraca do pytania — a dopiero potem formułuje odpowiedź.

W Claude Code widoczne jest jako zwijany blok `<thinking>` przed odpowiedzią.

---

## Czym różni się od zwykłego trybu?

| | Standardowy model | Extended Thinking |
|---|---|---|
| Rozumowanie | Ukryte, skrócone | Widoczne, wieloetapowe |
| Czas odpowiedzi | Szybki | Wolniejszy |
| Koszt tokenów | Niższy | Wyższy |
| Jakość analizy złożonych problemów | Dobra | Znacznie lepsza |
| Kiedy warto | Zadania rutynowe | Decyzje, strategie, diagnoza |

Extended Thinking jest dostępne w modelach **Opus 4.7** i **Sonnet 4.5+**. Największy efekt daje Opus — ma najgłębsze rozumowanie.

---

## Jak uruchomić w Claude Code

### Zmiana modelu na Opus

W sesji wpisz:

```
/model
```

Wybierz `claude-opus-4-7`. Od tej chwili Claude używa Opusa z domyślnym poziomem myślenia.

### Tryb Fast (wyłącza thinking)

```
/fast
```

Przełącza Opus w tryb szybki — bez extended thinking. Przydatne gdy potrzebujesz szybkiej odpowiedzi, a nie głębokiej analizy.

### Wymuszenie głębszego myślenia w prompcie

Możesz poprosić wprost:

```
Przeanalizuj ten raport SEO dokładnie, zanim odpiszesz. Weź pod uwagę
wszystkie zależności między problemami i zaproponuj priorytety.
```

Claude automatycznie uruchomi dłuższe rozumowanie dla złożonych zapytań — nie musisz wpisywać żadnej komendy technicznej.

---

## Jak to wygląda w praktyce

Gdy Extended Thinking jest aktywne, przed odpowiedzią pojawia się zwijany blok:

```
▶ Myślenie (23s) ...
```

Po rozwinięciu widać wewnętrzny monolog Claude'a — hipotezy, odrzucone ścieżki, porównania. To diagnostycznie cenne: możesz zobaczyć, dlaczego Claude doszedł do danego wniosku, a nie tylko co stwierdził.

---

## Zastosowania w tym projekcie

### 1. Priorytetyzacja problemów SEO

Standardowy Sonnet zbiera fakty: „brak meta description na 3 podstronach, wolny LCP, brak sitemapy". Extended Thinking z Opusem zadaje pytanie głębiej: **które z tych problemów realnie blokują ruch, a które to drobiazgi?** Uwzględnia kontekst biznesowy ntfy.pl, konkurencję i aktualny stan indeksacji.

Przykład użycia:

```
/model → claude-opus-4-7

Mam raport SEO ntfy.pl z maja 2026 (plik reports/ntfy-pl-2026-05-15.md).
Przeanalizuj go i powiedz, które 3 problemy mają największy wpływ na ruch
organiczny. Uzasadnij wybór.
```

### 2. Porównanie dwóch raportów tygodniowych

Zamiast diff-a linii, Opus może ocenić **czy zmiany idą w dobrym kierunku** i czy poprawa w jednym miejscu nie ukrywa regresji w innym.

```
Porównaj raporty reports/ntfy-pl-2026-05-15.md i reports/ntfy-pl-2026-05-22.md.
Oceń trend: czy SEO ntfy.pl się poprawia? Wskaż, co mogło spowodować zmiany.
```

### 3. Diagnoza spadku ruchu

Gdy pojawi się nagły spadek pozycji, Sonnet wylistuje możliwe przyczyny. Opus z thinking przeanalizuje je pod kątem prawdopodobieństwa, sprawdzi spójność z datami aktualizacji Google i zaproponuje kolejność działań diagnostycznych.

### 4. Strategia contentowa

```
Na podstawie audytu ntfy.pl zaproponuj plan contentowy na najbliższe
3 miesiące. Uwzględnij luki tematyczne, wolumen słów kluczowych i
realistyczne możliwości małego serwisu SaaS.
```

To zadanie wymaga syntezy wielu sygnałów — idealny przypadek dla Extended Thinking.

---

## Kiedy NIE używać Extended Thinking

- Sprawdzenie robots.txt — wystarczy `curl`
- Pobranie tytułu strony — rutynowe, Sonnet daje radę
- Zapis raportu do pliku — bez sensu angażować Opusa
- Szybkie pytanie o składnię komendy

Reguła: jeśli zadanie można wykonać mechanicznie (fetch → zapis), używaj Sonnet. Jeśli wymaga oceny, priorytetyzacji lub strategii — włącz Opusa z thinking.

---

## Porównanie wyników — ćwiczenie praktyczne

Żeby poczuć różnicę, uruchom to samo zapytanie dwa razy:

**Krok 1** — na domyślnym modelu (Sonnet):
```
Jakie są największe problemy SEO na ntfy.pl na podstawie ostatniego raportu?
```

**Krok 2** — przełącz na Opus (`/model → claude-opus-4-7`) i zadaj to samo pytanie.

Porównaj:
- Długość bloku `<thinking>`
- Czy Opus odrzucił jakieś hipotezy, które Sonnet przyjął bez refleksji?
- Czy priorytety są inne?
- Ile czasu zajęła każda odpowiedź?

Zanotuj obserwacje w `docs/backlog.md`.

---

## Koszt i ograniczenia

- Opus 4.7 jest droższy niż Sonnet — nie używaj go do zadań rutynowych
- Extended Thinking zużywa więcej tokenów (myślenie też jest billowane)
- Czas odpowiedzi może wynosić 30–90 sekund dla złożonych analiz
- Cache prompt działa też z Opusem — długie instrukcje (jak `seo-audit.md`) są keszowane między wywołaniami, co częściowo kompensuje wyższy koszt

---

## Podsumowanie

```
Kiedy używać Extended Thinking w tym projekcie:

Sonnet (domyślny)          Opus + Extended Thinking
─────────────────          ────────────────────────
Fetch strony               Priorytetyzacja problemów
Zapis raportu              Porównanie tygodniowych raportów
Sprawdzenie robots.txt     Diagnoza spadku ruchu
Rutynowe audyty            Strategia contentowa
```

Kluczowa lekcja: Extended Thinking nie zastępuje dobrego promptu — wzmacnia go. Im lepiej opisany kontekst i cel, tym głębsza analiza.
