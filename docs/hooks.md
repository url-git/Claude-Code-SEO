# Hooki w Claude Code

Hooki to skrypty powłoki uruchamiane automatycznie przez Claude Code w reakcji na określone zdarzenia.

## Dostępne zdarzenia

| Zdarzenie | Kiedy odpala się |
|-----------|-----------------|
| `PreToolUse` | Przed każdym wywołaniem narzędzia przez Claude |
| `PostToolUse` | Po każdym wywołaniu narzędzia przez Claude |
| `Stop` | Po każdym zakończeniu odpowiedzi Claude |
| `Notification` | Gdy Claude generuje powiadomienie systemowe |

## Konfiguracja w settings.json

```json
"hooks": {
  "PostToolUse": [
    {
      "matcher": "Bash",
      "hooks": [
        { "type": "command", "command": "hooks/on-git-push.sh" }
      ]
    }
  ]
}
```

- **matcher** — nazwa narzędzia, które ma wyzwolić hook (`Bash`, `Edit`, `Write`, `Read`, itp.). Puste `""` oznacza każde narzędzie.
- **type** — zawsze `"command"` (uruchamia skrypt powłoki)
- **command** — ścieżka do skryptu, relatywna względem katalogu projektu

## Dane wejściowe hooka (stdin)

Przy zdarzeniach `PreToolUse` i `PostToolUse` Claude Code przekazuje do skryptu przez stdin JSON z informacją o wywołaniu narzędzia:

```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "git push origin main"
  },
  "tool_response": {
    "output": "..."
  }
}
```

Skrypt może odczytać te dane przez `cat` i sparsować `python3 -c "import sys,json; ..."`.

## Hook w tym projekcie: on-git-push.sh

**Plik:** `hooks/on-git-push.sh`  
**Zdarzenie:** `PostToolUse` → matcher: `Bash`  
**Działanie:** Wysyła natywne powiadomienie macOS (`osascript`) gdy Claude wykona `git push`.

### Jak to działa krok po kroku

1. Claude Code kończy wywołanie narzędzia `Bash`
2. Przekazuje JSON z komendą przez stdin do `hooks/on-git-push.sh`
3. Skrypt parsuje JSON i sprawdza, czy komenda zawiera `git push`
4. Jeśli tak — wyświetla powiadomienie systemowe macOS z dźwiękiem „Glass"

### Dlaczego nie Stop?

Zdarzenie `Stop` odpala się po **każdej** odpowiedzi Claude — niezależnie od tego, co zrobiła. `PostToolUse` z matcherem `Bash` odpala się tylko po wywołaniu powłoki, a skrypt dodatkowo filtruje wyłącznie komendy `git push`. Dzięki temu powiadomienie przychodzi tylko wtedy, gdy coś faktycznie trafiło na zdalny serwer.
