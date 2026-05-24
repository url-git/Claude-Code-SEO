# Ściągawka: Komendy Claude Code

## Komendy wbudowane

| Komenda | Opis |
|---|---|
| `/add-dir` | Dodaj katalog roboczy do sesji |
| `/advisor` | Konsultuje silniejszy model w kluczowych momentach |
| `/agents` | Zarządzaj agentami |
| `/autofix-pr` | Auto-naprawa problemów w PR |
| `/background` | Sesja w tle, zwolnij terminal |
| `/branch` | Gałąź bieżącej rozmowy |
| `/btw` | Szybkie pytanie poboczne bez przerywania |
| `/chrome` | Ustawienia Claude w Chrome (beta) |
| `/clear` | Nowa sesja z pustym kontekstem (wznowienie przez `/resume`) |
| `/color` | Kolor paska promptu |
| `/compact` | Podsumuj rozmowę, zwolnij kontekst |
| `/config` | Panel konfiguracji |
| `/context` | Wizualizacja użycia kontekstu |
| `/copy` | Skopiuj odpowiedź do schowka (`/copy N` = N-ta od końca) |
| `/desktop` | Kontynuuj sesję w Claude Desktop |
| `/diff` | Niezatwierdzone zmiany i diffy z tur |
| `/exit` | Zakończ sesję |
| `/fast` | Tryb Fast (Opus z szybszym wyjściem) |
| `/feedback` | Wyślij opinię o Claude Code |
| `/fix` | Napraw błędy w pliku lub zadaniu |
| `/help` | Pomoc i lista komend |
| `/history` | Historia rozmów |
| `/ide` | Integracja z IDE (VS Code, JetBrains) |
| `/init` | Inicjalizuj CLAUDE.md |
| `/install-github-app` | Zainstaluj aplikację GitHub |
| `/login` / `/logout` | Zalogowanie / wylogowanie |
| `/mcp` | Zarządzaj serwerami MCP |
| `/memory` | Pamięć Claude |
| `/model` | Zmień model |
| `/new` | Nowa rozmowa |
| `/onboard` | Onboarding projektu |
| `/open` | Otwórz plik lub zasób |
| `/permissions` | Zarządzaj uprawnieniami |
| `/plan` | Tryb planowania implementacji |
| `/pr-comments` | Komentarze z PR |
| `/release-notes` | Informacje o wydaniu |
| `/resume` | Wznów poprzednią sesję |
| `/review` | Recenzja PR |
| `/run` | Uruchom komendę lub skrypt |
| `/schedule` | Zaplanowane rutyny (cron w chmurze Anthropic) |
| `/session` | Zarządzaj sesjami |
| `/settings` | Edycja ustawień |
| `/share` | Udostępnij sesję |
| `/status` | Status sesji i zadań |
| `/statusline` | Konfiguracja paska statusu |
| `/summarize` | Podsumuj sesję (z `.claude/commands/summarize.md`) |
| `/terminal-setup` | Konfiguracja terminala |
| `/theme` | Motyw kolorystyczny |
| `/todos` | Lista zadań |
| `/ultrareview` | Wieloagentowy przegląd kodu gałęzi/PR |
| `/update` | Aktualizacja Claude Code |
| `/vim` | Tryb edycji Vim |
| `/voice` | Sterowanie głosem |

## Komendy projektu (własne / skille)

| Komenda | Opis |
|---|---|
| `/seo-audit` | Pełny audyt SEO (ntfy.pl przez Playwright, zapis do `reports/`) |
| `/audit-subpages` | Równoległy audyt podstron przez subagentów |
| `/compare-reports` | Porównanie dwóch raportów SEO |
| `/claude-api` | Buduj/debuguj aplikacje z Claude API |
| `/security-review` | Przegląd bezpieczeństwa zmian |
| `/update-config` | Konfiguracja `settings.json` (hooki, uprawnienia) |
| `/keybindings-help` | Skróty klawiszowe (`~/.claude/keybindings.json`) |
| `/fewer-permission-prompts` | Dodaj allowlist na podstawie transkryptów |
| `/loop` | Cykliczne uruchamianie promptu/komendy |

## Skróty klawiszowe

| Skrót | Działanie |
|---|---|
| `Ctrl+C` | Przerwij zadanie |
| `Ctrl+L` | Wyczyść ekran |
| `Tab` | Autouzupełnianie |
| `↑ / ↓` | Historia komend |
| `Shift+Enter` | Nowa linia bez wysyłania |
| `!<komenda>` | Uruchom komendę powłoki (np. `!git status`) |
| `←` (w pustym prompcie) | Panel agentów |
