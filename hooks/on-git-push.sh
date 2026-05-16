#!/bin/zsh
# Uruchamiany przez Claude Code po każdym wywołaniu narzędzia Bash (zdarzenie PostToolUse).
# Wysyła natywne powiadomienie macOS tylko wtedy, gdy Claude wykonał git push.
#
# Problem z echo: echo "$input" w zsh uszkadza długie stringi z backslashami i znakami
# specjalnymi — JSON trafia do parsera uszkodzony. Rozwiązanie: stdin → plik tymczasowy.

TMPFILE=$(mktemp /tmp/claude-hook-XXXXXX.json)
cat > "$TMPFILE"

command=$(jq -r '.tool_input.command // ""' "$TMPFILE" 2>/dev/null)

if echo "$command" | grep -qE "git( -[^ ]+ [^ ]+)* push"; then
  osascript -e "display notification \"Zmiany wysłane na zdalny serwer\" with title \"Claude Code\" subtitle \"git push wykonany\" sound name \"Glass\""
  echo "Hook: wykryto git push — $command"
fi

rm -f "$TMPFILE"
