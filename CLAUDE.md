# Claude Code — Projekt Nauki

Ten projekt służy do nauki kluczowych funkcjonalności Claude Code.
Środowisko: macOS, zsh.

## Struktura projektu

| Ścieżka | Do czego służy |
|---------|----------------|
| `CLAUDE.md` | Ten plik. Claude wczytuje go automatycznie na początku każdej sesji — tu trzymasz kontekst, konwencje i instrukcje dla Claude. |
| `.claude/settings.json` | Konfiguracja sesji: uprawnienia (allow/deny), rejestracja hooków, zmienne środowiskowe. |
| `.claude/commands/` | Własne komendy slash. Każdy plik `.md` staje się komendą `/nazwa` dostępną w sesji. |
| `docs/` | Notatki z nauki — jeden plik Markdown na temat (hooki, MCP, agenci…). |
| `hooks/` | Skrypty shell uruchamiane przez Claude Code przy zdarzeniach (PreToolUse, PostToolUse, Stop…). |
| `examples/` | Ćwiczenia pogrupowane w podkatalogi: `hooks/`, `tool-use/`, `agents/`, `memory/`. |

## Tematy do nauki

- **CLAUDE.md** — hierarchia plików (globalny → projektowy → lokalny), co warto w nim trzymać
- **settings.json** — uprawnienia, hooki, zmienne env
- **Komendy slash** — tworzenie własnych komend w `.claude/commands/`
- **Hooki** — przechwytywanie zdarzeń, blokowanie operacji, automatyzacja
- **MCP** — własne serwery narzędzi (Model Context Protocol)
- **Agenci** — subagenci, równoległe wywołania, pipeline'y
- **Pamięć** — zarządzanie kontekstem między sesjami
