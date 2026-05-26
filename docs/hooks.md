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

## Praktyczne przypadki użycia

### `PreToolUse` — przed wywołaniem narzędzia

Odpala się **zanim** Claude uruchomi narzędzie. Może zablokować wywołanie (exit code != 0).

| Przypadek | Matcher | Co robi |
|---|---|---|
| Blokada `rm -rf` poza projektem | `Bash` | Parsuje `tool_input.command`, jeśli zawiera `rm -rf` z ścieżką spoza `$PWD` — exit 1 i wywołanie nie startuje |
| Wymuszenie formatowania przed `Edit` | `Edit` | Sprawdza czy plik `.py`/`.ts` ma uruchomiony linter, jeśli nie — odpala `ruff`/`prettier` na pliku przed edycją |
| Whitelist domen dla `WebFetch` | `WebFetch` | Czyta URL z `tool_input`, porównuje z listą dozwolonych domen (np. `ntfy.pl`, `developer.mozilla.org`), blokuje resztę |

### `PostToolUse` — po wywołaniu narzędzia

Odpala się **po** zakończeniu narzędzia. Ma dostęp do `tool_response`.

| Przypadek | Matcher | Co robi |
|---|---|---|
| Auto-commit po edycji `docs/` | `Edit` lub `Write` | Sprawdza czy zmieniony plik leży w `docs/`, jeśli tak — `git add` + `git commit` z opisem z nazwy pliku |
| Powiadomienie macOS po `git push` | `Bash` | Aktualny hook w tym projekcie (`hooks/on-git-push.sh`) |
| Walidacja raportu SEO po zapisie | `Write` | Po zapisie do `reports/*.md` uruchamia `markdownlint` + sprawdza obecność wymaganych sekcji (title, meta, h1) |

### `Stop` — po zakończeniu odpowiedzi Claude

Odpala się po **każdej** odpowiedzi (niezależnie od narzędzi). Dobre do podsumowań i logów sesji.

| Przypadek | Co robi |
|---|---|
| Log sesji do pliku | Dopisuje timestamp + krótkie podsumowanie tury do `~/.claude/sessions/$(date +%F).log` |
| Synchronizacja `reports/` do chmury | Jeśli w sesji powstał nowy plik w `reports/`, robi `rsync` na NAS / S3 / iCloud |
| Statystyka tokenów | Czyta metadane sesji, zapisuje liczbę tokenów + koszt do `docs/koszty.csv` — pozwala śledzić budżet w czasie |
