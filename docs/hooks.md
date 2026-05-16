# Hooki: Claude Code vs OpenCode

Ten projekt był początkowo tworzony dla **Claude Code (Anthropic)**, ale obecnie działa na **OpenCode**. Oba narzędzia mają system hooków/pluginów, ale działają inaczej.

---

## Claude Code (Anthropic) — hooki shell

Hooki to skrypty powłoki uruchamiane automatycznie przez Claude Code w reakcji na określone zdarzenia.

### Dostępne zdarzenia

| Zdarzenie | Kiedy odpala się |
|-----------|-----------------|
| `PreToolUse` | Przed każdym wywołaniem narzędzia przez Claude |
| `PostToolUse` | Po każdym wywołaniu narzędzia przez Claude |
| `Stop` | Po każdym zakończeniu odpowiedzi Claude |
| `Notification` | Gdy Claude generuje powiadomienie systemowe |

### Konfiguracja w .claude/settings.json

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

### Dane wejściowe hooka (stdin)

Przy zdarzeniach `PreToolUse` i `PostToolUse` Claude Code przekazuje do skryptu przez stdin JSON:

```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "git push origin main"
  }
}
```

---

## OpenCode — pluginy JS/TS

**OpenCode nie wspiera hooków shell z `.claude/settings.json`** (GitHub issue [#12472](https://github.com/anomalyco/opencode/issues/12472)). Zamiast tego używa **pluginów JavaScript/TypeScript** w katalogu `.opencode/plugins/`.

### Mapowanie zdarzeń

| Claude Code | OpenCode |
|-------------|----------|
| `PreToolUse` | `tool.execute.before` |
| `PostToolUse` | `tool.execute.after` |
| `Stop` | `session.idle` |
| — | `session.created`, `session.diff`, `session.error` |
| — | `command.executed`, `file.edited` |

### Plugin w tym projekcie: git-push-notification

**Plik:** `.opencode/plugins/git-push-notification.js`  
**Zdarzenie:** `tool.execute.after` z filtrem `bash` + `git push`  
**Działanie:** Wysyła natywne powiadomienie macOS (`osascript`) gdy OpenCode wykona `git push`.

### Jak to działa

1. OpenCode kończy wywołanie narzędzia (`tool.execute.after`)
2. Plugin sprawdza, czy to `bash` i czy komenda zawiera `git push`
3. Jeśli tak — wywołuje `osascript` przez Bun Shell API (`$`)

### Tworzenie własnego pluginu

```javascript
// .opencode/plugins/moj-plugin.js
export const MojPlugin = async ({ project, client, $, directory, worktree }) => {
  return {
    "tool.execute.after": async (input, output) => {
      // input.tool — nazwa narzędzia (bash, read, write, edit)
      // output.args — argumenty narzędzia
      // $ — Bun Shell API do wykonywania komend
    },
  }
}
```

Więcej w dokumentacji: https://opencode.ai/docs/plugins/
