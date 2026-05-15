# Claude Code — Projekt Nauki

Repozytorium do nauki Claude Code. Konkretny cel: **audyt SEO https://ntfy.pl/** z użyciem MCP (Playwright) do kontroli przeglądarki Chrome.

## Struktura

| Ścieżka | Do czego służy |
|---------|----------------|
| `CLAUDE.md` | Instrukcje dla Claude wczytywane automatycznie na początku każdej sesji. |
| `.claude/settings.json` | Konfiguracja: MCP serwer Playwright, uprawnienia, hooki, zmienna `AUDIT_URL`. |
| `.claude/commands/` | Własne komendy slash — `/seo-audit` uruchamia pełny audyt SEO. |
| `docs/` | Notatki z nauki — jeden plik Markdown na temat. |
| `hooks/` | Skrypty hooków — `on-stop.sh` wypisuje ścieżkę raportu po zakończeniu sesji. |
| `examples/` | Ćwiczenia: `hooks/`, `tool-use/`, `agents/`, `memory/`. |
| `reports/` | Wygenerowane raporty SEO w formacie Markdown. |

## Szybki start

```
/seo-audit
```
