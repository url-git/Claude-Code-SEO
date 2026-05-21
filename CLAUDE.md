# Claude Code SEO — Projekt Nauki

Ten projekt służy do nauki kluczowych funkcjonalności Claude Code poprzez konkretny cel: **audyt SEO strony https://ntfy.pl/** przy użyciu MCP (Playwright) do kontroli przeglądarki.

Folder lokalny: `~/Documents/dev/Claude-Code-SEO` | Repo: `github.com/url-git/Claude-Code-SEO`

Środowisko: macOS, zsh.

## Struktura projektu

| Ścieżka | Do czego służy |
|---------|----------------|
| `CLAUDE.md` | Ten plik. Claude wczytuje go automatycznie na początku każdej sesji. |
| `.claude/settings.json` | Konfiguracja sesji: MCP serwer Playwright, uprawnienia, hooki, zmienna `AUDIT_URL`. |
| `.claude/commands/` | Własne komendy slash. `/seo-audit` uruchamia pełny audyt SEO. |
| `docs/` | Notatki z nauki — jeden plik Markdown na temat. |
| `hooks/` | Skrypty hooków. `on-git-push.sh` wysyła powiadomienie macOS gdy Claude wykona `git push`. |
| `reports/` | Wygenerowane raporty SEO w formacie Markdown. |

## Jak uruchomić audyt

Wpisz w sesji Claude Code:

```
/seo-audit
```

Claude otworzy https://ntfy.pl/ przez Playwright, sprawdzi wszystkie elementy SEO i zapisze raport do `reports/`.

## Tematy do nauki

- **MCP** — konfiguracja serwera Playwright w `settings.json`, narzędzia do kontroli przeglądarki
- **Komendy slash** — tworzenie własnych komend w `.claude/commands/`
- **Hooki** — zdarzenie `PostToolUse` z matcherem `Bash`, wykrywanie `git push`, powiadomienia macOS
- **settings.json** — uprawnienia, zmienne env, MCP serwery
- **Agenci** — równoległe audyty wielu podstron (`/agents`, subagenci w Claude Code)
- **Pamięć** — porównywanie raportów między sesjami (system memory w `~/.claude/projects/-Users-p-Documents-dev-Claude-Code-SEO/memory/`)
