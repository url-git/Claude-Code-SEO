# Konfiguracja Claude Code — `/config`

Panel ustawień dostępny przez wpisanie `/config` w terminalu. Zawiera 5 zakładek: **Settings**, Status, Config, Usage, Stats.

Twoje aktualne wartości (z `/config` → Config, 2026-05-19).

---

## Zakładka Config — wszystkie ustawienia

| Ustawienie | Twoja wartość | Co robi |
|------------|--------------|---------|
| **Auto-compact** | `true` | Automatycznie podsumowuje rozmowę gdy kontekst zbliża się do limitu — zamiast urwać sesję, Claude kompresuje historię i kontynuuje |
| **Show tips** | `true` | Wyświetla wskazówki i podpowiedzi dotyczące Claude Code podczas pracy |
| **Reduce motion** | `false` | Wyłącza animacje w interfejsie terminala (dla osób wrażliwych na ruch lub wolniejszych terminali) |
| **Thinking mode** | `true` | Włącza tryb Extended Thinking — Claude pokazuje wewnętrzne rozumowanie w bloku `<thinking>` przed odpowiedzią |
| **Prompt suggestions** | `true` | Wyświetla podpowiedzi komend i pytań podczas pisania w terminalu |
| **Session recap** | `true` | Po wznowieniu sesji (`/resume`) Claude pokazuje krótkie podsumowanie co było zrobione poprzednio |
| **Rewind code (checkpoints)** | `true` | Zapisuje checkpointy po każdej edycji pliku — możesz cofnąć zmiany do dowolnego punktu w sesji |
| **Verbose output** | `false` | Pokazuje szczegółowe logi wewnętrznych operacji Claude Code (przydatne do debugowania, na co dzień wyłączone) |
| **Terminal progress bar** | `true` | Wyświetla pasek postępu w terminalu podczas długich operacji |
| **Show turn duration** | `true` | Pokazuje czas wykonania każdej tury (ile sekund zajęła odpowiedź) |
| **Default permission mode** | `Default` | Tryb uprawnień dla narzędzi: `Default` = pyta o zgodę przy nieznanych akcjach; `Auto` = akceptuje wszystko; `Manual` = pyta o każdą akcję |
| **Worktree base ref** | `fresh` | Punkt bazowy dla izolowanych worktree tworzonych przez agentów: `fresh` = zawsze od aktualnego HEAD |
| **Respect .gitignore in file picker** | `true` | Pliki wymienione w `.gitignore` są ukryte w podpowiedziach i autocompletion ścieżek |
| **Skip the /copy picker** | `false` | Gdy `false` — `/copy` pokazuje picker do wyboru której odpowiedzi skopiować; `true` = kopiuje ostatnią bez pytania |
| **Open agents view by default** | `false` | Gdy otwierasz Claude Code, domyślnie pokazuje widok agentów zamiast rozmowy |
| **← opens agents** | `true` | Naciśnięcie strzałki ← w pustym prompcie otwiera panel zarządzania agentami |
| **Auto-update channel** | `latest` | Kanał aktualizacji Claude Code: `latest` = najnowsza stabilna wersja; `beta` = wersje beta |
| **Theme** | `Dark mode` | Motyw kolorystyczny interfejsu terminala (`Dark mode` / `Light mode` / `System`) |
| **Local notifications** | `Auto` | Powiadomienia systemowe macOS: `Auto` = tylko gdy terminal jest w tle; `Always` / `Never` |
| **Push when actions required** | `false` | Wysyła push notification na urządzenia mobilne gdy Claude czeka na twoją decyzję (wymaga połączonego konta) |

---

## Pozostałe ustawienia (10 poniżej widocznych na ekranie)

| Ustawienie | Opis |
|------------|------|
| **Model** | Wybór modelu: Sonnet 4.6 (domyślny), Opus 4.7, Haiku 4.5 |
| **Custom system prompt** | Dodatkowe instrukcje globalne dołączane do każdej sesji |
| **Preferred language** | Język odpowiedzi Claude (domyślnie angielski, jeśli nie ustawiono inaczej) |
| **Notification sound** | Dźwięk powiadomienia gdy Claude skończy długie zadanie |
| **MCP timeout** | Czas oczekiwania na odpowiedź serwera MCP zanim sesja uzna go za niedostępnego |
| **Max output tokens** | Maksymalna długość pojedynczej odpowiedzi Claude |
| **Safe mode** | Dodatkowe potwierdzenia dla operacji destrukcyjnych (rm, git reset --hard itp.) |
| **Status line** | Konfiguracja paska statusu w terminalu (co wyświetla, gdzie) |
| **Keymap** | Układ skrótów klawiszowych: `default` / `vim` |
| **Include co-author trailer** | Automatycznie dodaje `Co-Authored-By: Claude` do commitów |

---

## Zakładki panelu `/config`

| Zakładka | Co pokazuje |
|----------|------------|
| **Settings** | Szybkie przełączniki najważniejszych opcji |
| **Status** | Status połączenia, zalogowane konto, wersja Claude Code |
| **Config** | Pełna lista wszystkich ustawień (ten plik) |
| **Usage** | Zużycie tokenów i kosztów w bieżącym miesiącu |
| **Stats** | Statystyki sesji: liczba komend, czas pracy, narzędzia |

---

## Jak zmienić ustawienie

Dwa sposoby:

1. **Przez panel** — wpisz `/config`, przejdź do Config, znajdź ustawienie i zmień wartość
2. **Przez plik** — edytuj `~/.claude/settings.json` (globalne) lub `.claude/settings.json` (projektowe)
