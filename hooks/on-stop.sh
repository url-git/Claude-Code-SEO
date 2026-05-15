#!/bin/zsh
# Uruchamiany przez Claude Code po każdym zakończeniu odpowiedzi (zdarzenie Stop).
# Jeśli w reports/ istnieje raport, wysyła natywne powiadomienie macOS.

REPORTS_DIR="$(dirname "$0")/../reports"

if [ -d "$REPORTS_DIR" ]; then
  latest=$(ls -t "$REPORTS_DIR"/*.md 2>/dev/null | head -1)
  if [ -n "$latest" ]; then
    filename=$(basename "$latest")
    osascript -e "display notification \"$filename\" with title \"Claude Code — Audyt SEO\" subtitle \"Nowy raport gotowy w reports/\" sound name \"Glass\""
    echo "Raport SEO: $latest"
  fi
fi
