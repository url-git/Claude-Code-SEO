#!/bin/zsh
# Uruchamiany przez Claude Code po każdym zakończeniu odpowiedzi (zdarzenie Stop).
# Jeśli w tej sesji powstał nowy raport, wypisuje jego ścieżkę.

REPORTS_DIR="$(dirname "$0")/../reports"

if [ -d "$REPORTS_DIR" ]; then
  latest=$(ls -t "$REPORTS_DIR"/*.md 2>/dev/null | head -1)
  if [ -n "$latest" ]; then
    echo "Raport SEO: $latest"
  fi
fi
