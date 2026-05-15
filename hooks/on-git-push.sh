#!/bin/zsh
# Uruchamiany przez Claude Code po każdym wywołaniu narzędzia Bash (zdarzenie PostToolUse).
# Wysyła natywne powiadomienie macOS tylko wtedy, gdy Claude wykonał git push.

input=$(cat)
command=$(echo "$input" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('command', ''))
" 2>/dev/null)

if echo "$command" | grep -q "git push"; then
  osascript -e "display notification \"Zmiany wysłane na zdalny serwer\" with title \"Claude Code\" subtitle \"git push wykonany\" sound name \"Glass\""
  echo "Hook: wykryto git push — $command"
fi
