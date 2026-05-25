---
name: project-tools-agenta-pytanie
description: Aktualna lista tools agenta pytanie (.claude/agents/pytanie.md) - od 2026-05-25 bez Bash
metadata:
  type: project
---

W dniu 2026-05-25 usunęliśmy `Bash` z listy tools w konfiguracji agenta `pytanie` (`.claude/agents/pytanie.md`). Aktualna lista tools to: **Read, WebFetch, WebSearch**.

**Why:** Agent `pytanie` służy wyłącznie do odpowiadania na pytania edukacyjne o Claude Code — nie wykonuje operacji na systemie. Usunięcie `Bash` ogranicza powierzchnię uprawnień i zapobiega niezamierzonym akcjom w shellu.

**How to apply:** Gdy pomagasz użytkownikowi modyfikować konfigurację agenta `pytanie` lub gdy w odpowiedziach sugerujesz mu możliwości tego agenta — pamiętaj, że nie ma dostępu do `Bash`. Jeśli pytanie wymaga wykonania komendy shell (np. sprawdzenia stanu repo, uruchomienia skryptu), poinformuj że ten agent tego nie zrobi i odeślij do sesji głównej.
