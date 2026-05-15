# Claude Code — Projekt Nauki

Repozytorium do nauki kluczowych funkcjonalności Claude Code.

## Struktura

| Ścieżka | Do czego służy |
|---------|----------------|
| `CLAUDE.md` | Instrukcje dla Claude wczytywane automatycznie na początku każdej sesji. Tu trzymasz kontekst projektu, konwencje i skróty. |
| `.claude/settings.json` | Konfiguracja sesji: uprawnienia (allow/deny), rejestracja hooków, zmienne środowiskowe. |
| `.claude/commands/` | Własne komendy slash. Każdy plik `.md` staje się komendą `/nazwa` dostępną w sesji. |
| `docs/` | Notatki z nauki — jeden plik Markdown na temat. |
| `hooks/` | Skrypty shell uruchamiane przez Claude Code przy zdarzeniach (PreToolUse, PostToolUse, Stop…). |
| `examples/` | Ćwiczenia pogrupowane w podkatalogi: `hooks/`, `tool-use/`, `agents/`, `memory/`. |
