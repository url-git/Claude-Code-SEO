# Claude Code — Projekt Nauki

Ten projekt służy do nauki kluczowych funkcjonalności Claude Code poprzez konkretny cel: **audyt SEO strony https://ntfy.pl/** przy użyciu MCP (Playwright) do kontroli przeglądarki.

Środowisko: macOS, zsh.

## Struktura projektu

| Ścieżka | Do czego służy |
|---------|----------------|
| `CLAUDE.md` | Ten plik. Claude wczytuje go automatycznie na początku każdej sesji. |
| `.claude/settings.json` | Konfiguracja sesji: MCP serwer Playwright, uprawnienia, hooki, zmienna `AUDIT_URL`. |
| `.claude/commands/` | Własne komendy slash. `/seo-audit` uruchamia pełny audyt SEO. |
| `docs/` | Notatki z nauki — jeden plik Markdown na temat. |
| `hooks/` | Skrypty hooków. `on-stop.sh` wypisuje ścieżkę raportu po zakończeniu sesji. |
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
- **Hooki** — zdarzenie `Stop`, rejestracja skryptu, odczyt stdout
- **settings.json** — uprawnienia, zmienne env, MCP serwery
- **Agenci** — równoległe audyty wielu podstron
- **Pamięć** — porównywanie raportów między sesjami
