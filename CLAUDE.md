# Claude Code — Projekt Nauki

Ten projekt służy do nauki kluczowych funkcjonalności Claude Code poprzez konkretny cel: **audyt SEO strony https://ntfy.pl/** przy użyciu MCP (Playwright) do kontroli przeglądarki.

Środowisko: macOS, zsh.

## Struktura projektu

| Ścieżka | Do czego służy |
|---------|----------------|
| `CLAUDE.md` | Ten plik. Claude/OpenCode wczytuje go automatycznie na początku każdej sesji. |
| `.claude/settings.json` | Konfiguracja MCP Playwright, uprawnienia, zmienna `AUDIT_URL`. |
| `.claude/commands/` | Własne komendy slash. `/seo-audit` uruchamia pełny audyt SEO. |
| `.opencode/plugins/` | Pluginy OpenCode. `git-push-notification.js` wysyła powiadomienie macOS po `git push`. |
| `docs/` | Notatki z nauki — jeden plik Markdown na temat. |
| `hooks/` | (Nieużywane w OpenCode) Skrypty hooków Claude Code. |
| `examples/` | Ćwiczenia: `hooks/`, `tool-use/`, `agents/`, `memory/`. |
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
- **Hooki / Pluginy** — OpenCode używa pluginów JS/TS (`.opencode/plugins/`) zamiast hooków shell Claude Code; zdarzenia `tool.execute.before/after`, `session.idle`
- **settings.json** — uprawnienia, zmienne env, MCP serwery
- **Agenci** — równoległe audyty wielu podstron
- **Pamięć** — porównywanie raportów między sesjami
