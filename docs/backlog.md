# Backlog — funkcje Anthropic do nauki

> **Od czego zacząć:** Zacznij od **Subagentów** i **`/schedule`** — oba bezpośrednio rozszerzają istniejący audyt SEO i dają natychmiastowy, praktyczny efekt. Pozostałe tematy zostawiamy na później.

---

## 1. Subagenci — równoległe audyty wielu podstron

Claude Code pozwala uruchamiać wiele niezależnych agentów jednocześnie, co skraca czas złożonych zadań. W kontekście audytu SEO oznacza to, że zamiast kolejno sprawdzać stronę główną, blog i dokumentację — Claude uruchamia trzy osobne procesy naraz, każdy z własnym kontekstem i zadaniem. Każdy subagent dostaje instrukcję, audytuje jedną podstronę przez Playwright i zwraca wynik do agenta-orkiestratora. Orkiestrator zbiera wyniki i scala je w jeden spójny raport z sekcją porównawczą. W projekcie można to zrealizować jako nową komendę `/seo-audit-multi`, która odczytuje listę URL-i z pliku konfiguracyjnego i uruchamia agentów. Kluczową lekcją jest zrozumienie, jak Claude Code zarządza równoległością — kiedy agenci mogą pracować niezależnie, a kiedy muszą czekać na wynik poprzedniego. Narzędzie do zarządzania agentami to `/agents` w Claude Code — warto zapoznać się z jego panelem podczas ćwiczenia. To ćwiczenie pokazuje też granice równoległości: zbyt wiele agentów naraz może wyczerpać limit kontekstu lub API.

---

## 2. `/schedule` — automatyczny audyt cotygodniowy

Funkcja `/schedule` pozwala zlecić Claude Code wykonanie zadania w określonym czasie lub cyklicznie — bez udziału człowieka. Dla tego projektu naturalnym zastosowaniem jest automatyczny audyt SEO ntfy.pl uruchamiany np. co poniedziałek rano o 8:00. Claude sam odpala `/seo-audit`, zapisuje raport do `reports/` z datą w nazwie pliku i commituje go do repozytorium — wszystko bez interakcji użytkownika. Dzięki temu `reports/` staje się archiwum historycznych audytów, które można porównywać między sesjami i śledzić trendy SEO w czasie. Ćwiczenie uczy, jak pisać komendy odporne na brak kontekstu — zaplanowany agent startuje „na zimno", bez historii rozmowy, więc instrukcje w `seo-audit.md` muszą być kompletne i samodzielne. Warto połączyć tę funkcję z hookiem `on-git-push.sh` — po automatycznym commicie i pushu przyjdzie powiadomienie macOS, które potwierdzi, że job się wykonał. To jest też dobry moment na naukę `/loop`, który działa podobnie, ale w ramach bieżącej sesji zamiast jako zaplanowane zdarzenie zewnętrzne. Różnica między `/schedule` a `/loop` to ważna koncepcja: pierwszy działa jak cron (niezależnie od sesji), drugi jak pętla wewnątrz aktywnej rozmowy.

---

## 3. Extended Thinking — głębsza analiza z Opus 4.7

Extended Thinking to tryb, w którym Claude poświęca dodatkowy czas na wewnętrzne rozumowanie przed udzieleniem odpowiedzi — widoczne jako blok `<thinking>` w odpowiedzi. Dla audytu SEO oznacza to, że zamiast mechanicznie wylistować brakujące meta tagi, Claude faktycznie analizuje, dlaczego strona może mieć słabe wyniki i formułuje głębsze rekomendacje. Tryb włącza się przez przełączenie modelu na Opus 4.7 (`/model`) i ustawienie odpowiedniego poziomu wysiłku (`low`, `medium`, `high`). Różnica jakościowa w raporcie SEO jest wyraźna: standardowy model zbiera fakty, Opus z thinking wyciąga wnioski i priorytetyzuje je w kontekście biznesowym strony. Ćwiczenie polega na uruchomieniu audytu dwa razy — raz Sonnetem, raz Opusem z `high effort` — i porównaniu obu raportów. Uczy to, kiedy warto płacić za droższy model, a kiedy Sonnet w zupełności wystarczy. Warto też zobaczyć, jak długo trwa generowanie z thinking włączonym — to praktyczna lekcja o trade-offie między jakością a czasem odpowiedzi. Extended Thinking jest szczególnie przydatny dla złożonych, wielokrokowych analiz — audyt SEO jest idealnym przykładem.

---

## 4. Prompt Caching — szybsze i tańsze powtórne audyty

Prompt caching to mechanizm, w którym Anthropic API zapamiętuje część kontekstu między kolejnymi zapytaniami, eliminując potrzebę jego ponownego przetwarzania. W tym projekcie największym kandydatem do keszowania jest plik `seo-audit.md` — ma ponad 350 linii instrukcji, które są identyczne przy każdym uruchomieniu audytu. Gdy Claude uruchamia `/seo-audit` wielokrotnie w ciągu sesji (np. po każdej zmianie na stronie), kesh może zaoszczędzić znaczną część tokenów wejściowych i przyspieszyć odpowiedź. Cache działa automatycznie dla długich, niezmiennych fragmentów kontekstu — wystarczy upewnić się, że instrukcje są na początku promptu, a zmienne dane (URL, data) na końcu. Lekcja praktyczna polega na obserwowaniu wskaźnika `cache_read_input_tokens` w odpowiedziach API i porównaniu kosztu pierwszego vs. kolejnych wywołań. Projekt można rozszerzyć o skrypt, który loguje te liczby do pliku i pokazuje oszczędności w czasie. Prompt caching ma TTL (czas życia) wynoszący 5 minut — ważna informacja przy planowaniu, jak często odświeżać kontekst. To ćwiczenie łączy się naturalnie z tematem Batch API, bo oba dotyczą optymalizacji kosztowej przy wielokrotnych wywołaniach.

---

## 5. Batch API — asynchroniczne przetwarzanie wielu audytów

Batch API pozwala wysyłać do 10 000 zapytań do Claude naraz i odbierać wyniki asynchronicznie — bez czekania na każde z osobna. Dla projektu SEO oznacza to możliwość zlecenia audytu dziesiątek podstron jednocześnie i odebrania wyników, gdy wszystkie będą gotowe. Różnica względem subagentów jest koncepcyjna: Batch API to wywołanie zewnętrzne przez API (np. ze skryptu Python), a subagenci to orkiestracja wewnątrz sesji Claude Code. Ćwiczenie polega na napisaniu skryptu `batch-audit.py` w `examples/`, który wysyła listę URL-i jako batch i zapisuje wyniki do osobnych plików w `reports/`. Batch API kosztuje 50% mniej niż standardowe wywołania — to znacząca oszczędność przy regularnych audytach dużych serwisów. Odpowiedzi są dostępne do 29 dni — można je pobrać w dowolnym momencie, co daje elastyczność przy długich zadaniach. Lekcja uczy, jak budować pipeline SEO wykraczający poza interaktywną sesję Claude Code — bardziej inżynieryjne podejście do automatyzacji. To naturalny most między Claude Code jako narzędziem a Claude API jako serwisem integrowanym z własnymi aplikacjami.
