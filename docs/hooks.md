# Hooki w Claude Code

Hooki to skrypty powłoki uruchamiane automatycznie przez Claude Code w reakcji na zdarzenia.

## Dostępne zdarzenia

| Zdarzenie | Kiedy odpala |
|---|---|
| `PreToolUse` | Przed każdym wywołaniem narzędzia |
| `PostToolUse` | Po każdym wywołaniu narzędzia |
| `Stop` | Po zakończeniu odpowiedzi Claude |
| `Notification` | Gdy Claude generuje powiadomienie systemowe |

## Konfiguracja w `settings.json`

```json
"hooks": {
  "PostToolUse": [
    {
      "matcher": "Bash",
      "hooks": [{ "type": "command", "command": "hooks/on-git-push.sh" }]
    }
  ]
}
```

- **matcher** — nazwa narzędzia (`Bash`, `Edit`, `Write`, `Read`...). Puste `""` = każde narzędzie.
- **type** — zawsze `"command"`
- **command** — ścieżka relatywna do projektu

## Dane wejściowe (stdin)

Przy `PreToolUse`/`PostToolUse` Claude Code przekazuje JSON przez stdin:

```json
{
  "tool_name": "Bash",
  "tool_input": { "command": "git push origin main" },
  "tool_response": { "output": "..." }
}
```

Skrypt może je odczytać przez `cat` i sparsować (`python3 -c "import sys,json; ..."`).

## Hook w tym projekcie: `on-git-push.sh`

| | |
|---|---|
| Plik | `hooks/on-git-push.sh` |
| Zdarzenie | `PostToolUse`, matcher `Bash` |
| Działanie | Powiadomienie macOS (`osascript`) gdy Claude wykona `git push` |

**Krok po kroku:** Claude kończy wywołanie Bash → JSON na stdin do `hooks/on-git-push.sh` → skrypt sprawdza czy komenda zawiera `git push` → jeśli tak, wyświetla powiadomienie z dźwiękiem „Glass".

### Dlaczego nie `Stop`?

`Stop` odpala się po **każdej** odpowiedzi Claude. `PostToolUse` z matcherem `Bash` + filtr `git push` w skrypcie daje powiadomienie **tylko** gdy coś faktycznie trafiło na zdalny serwer.
