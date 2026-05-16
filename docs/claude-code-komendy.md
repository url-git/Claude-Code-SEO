# Ściągawka: Komendy Claude Code

## Komendy wbudowane

| Komenda | Opis (PL) |
|---------|-----------|
| `/add-dir` | Dodaj nowy katalog roboczy do sesji |
| `/advisor` | Skonfiguruj Advisor Tool — konsultuje silniejszy model w kluczowych momentach |
| `/agents` | Zarządzaj konfiguracją agentów |
| `/autofix-pr` | Monitoruj i automatycznie naprawiaj problemy w bieżącym PR |
| `/background` | Kontynuuj sesję w tle i zwolnij terminal |
| `/branch` | Utwórz gałąź bieżącej rozmowy w tym miejscu |
| `/btw` | Zadaj szybkie pytanie poboczne bez przerywania głównej rozmowy |
| `/chrome` | Ustawienia Claude w Chrome (wersja beta) |
| `/clear` | Rozpocznij nową sesję z pustym kontekstem (poprzednia zostaje na dysku, można wznowić przez `/resume`) |
| `/color` | Ustaw kolor paska promptu dla tej sesji |
| `/compact` | Zwolnij kontekst przez podsumowanie dotychczasowej rozmowy |
| `/config` | Otwórz panel konfiguracji |
| `/context` | Zwizualizuj bieżące użycie kontekstu jako kolorową siatkę |
| `/copy` | Skopiuj ostatnią odpowiedź Claude do schowka (lub `/copy N` dla N-tej od końca) |
| `/desktop` | Kontynuuj bieżącą sesję w Claude Desktop |
| `/diff` | Pokaż niezatwierdzone zmiany i diffy z każdej tury |
| `/exit` | Zakończ sesję Claude Code |
| `/fast` | Przełącz tryb Fast (Claude Opus z szybszym wyjściem) |
| `/feedback` | Wyślij opinię o Claude Code |
| `/fix` | Napraw błędy w bieżącym pliku lub zadaniu |
| `/help` | Pokaż pomoc i listę dostępnych komend |
| `/history` | Pokaż historię rozmów |
| `/ide` | Zarządzaj integracją z IDE (VS Code, JetBrains) |
| `/init` | Zainicjuj plik CLAUDE.md z dokumentacją projektu |
| `/install-github-app` | Zainstaluj aplikację GitHub dla Claude Code |
| `/login` | Zaloguj się na konto Anthropic |
| `/logout` | Wyloguj się z konta Anthropic |
| `/mcp` | Zarządzaj serwerami MCP (Model Context Protocol) |
| `/memory` | Wyświetl i zarządzaj pamięcią Claude |
| `/model` | Zmień model Claude używany w sesji |
| `/new` | Rozpocznij nową rozmowę |
| `/onboard` | Uruchom onboarding — wprowadzenie do projektu |
| `/open` | Otwórz plik lub zasób |
| `/permissions` | Zarządzaj uprawnieniami narzędzi |
| `/plan` | Wejdź w tryb planowania implementacji |
| `/pr-comments` | Pokaż komentarze z bieżącego Pull Requesta |
| `/release-notes` | Pokaż informacje o wydaniu Claude Code |
| `/resume` | Wznów poprzednią sesję |
| `/review` | Zrecenzuj Pull Request |
| `/run` | Uruchom komendę lub skrypt |
| `/schedule` | Zarządzaj zaplanowanymi zadaniami (agenci cron) |
| `/session` | Zarządzaj sesjami |
| `/settings` | Edytuj ustawienia Claude Code |
| `/share` | Udostępnij sesję |
| `/status` | Pokaż status bieżącej sesji i zadań |
| `/statusline` | Skonfiguruj pasek statusu Claude Code |
| `/summarize` | Podsumuj bieżącą sesję — własna komenda slash z `.claude/commands/summarize.md` |
| `/terminal-setup` | Skonfiguruj terminal dla Claude Code |
| `/theme` | Zmień motyw kolorystyczny interfejsu |
| `/todos` | Pokaż listę zadań (TODO) |
| `/ultrareview` | Uruchom wieloagentowy przegląd kodu bieżącej gałęzi lub PR |
| `/update` | Zaktualizuj Claude Code do najnowszej wersji |
| `/vim` | Przełącz tryb edycji Vim |
| `/voice` | Włącz/wyłącz sterowanie głosem |

## Komendy projektu (własne / umiejętności)

| Komenda | Opis (PL) |
|---------|-----------|
| `/seo-audit` | Uruchom pełny audyt SEO strony (otwiera ntfy.pl przez Playwright i zapisuje raport) |
| `/claude-api` | Buduj, debuguj i optymalizuj aplikacje z Claude API / Anthropic SDK |
| `/review` | Zrecenzuj zmiany w bieżącym PR (umiejętność rozszerzona) |
| `/security-review` | Przeprowadź przegląd bezpieczeństwa zmian na bieżącej gałęzi |
| `/simplify` | Przejrzyj zmieniony kod pod kątem jakości i uprość go |
| `/update-config` | Skonfiguruj zachowania automatyczne i uprawnienia w `settings.json` |
| `/keybindings-help` | Dostosuj skróty klawiszowe (`~/.claude/keybindings.json`) |
| `/fewer-permission-prompts` | Skanuj transkrypty i dodaj allowlist, by zmniejszyć liczbę próśb o uprawnienia |
| `/loop` | Uruchom prompt lub komendę cyklicznie w określonym interwale |
| `/init` | Zainicjuj plik CLAUDE.md z dokumentacją kodu projektu |

## Skróty klawiszowe (terminal)

| Skrót | Działanie |
|-------|-----------|
| `Ctrl+C` | Przerwij bieżące zadanie |
| `Ctrl+L` | Wyczyść ekran |
| `Tab` | Autouzupełnianie komend i ścieżek |
| `↑ / ↓` | Przeglądaj historię komend |
| `Shift+Enter` | Nowa linia w prompcie (bez wysyłania) |
| `!<komenda>` | Uruchom komendę powłoki bezpośrednio (np. `!git status`) |
