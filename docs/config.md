# Konfiguracja Claude Code — `/config`

Panel ustawień dostępny przez `/config`. Zawiera 5 zakładek: **Settings**, Status, Config, Usage, Stats.

---

## Zakładka Config — ustawienia widoczne na ekranie

| Ustawienie | Wartość | Co robi |
|---|---|---|
| **Auto-compact** | `true` | Auto-kompresja historii przy zbliżaniu się do limitu kontekstu |
| **Show tips** | `true` | Wskazówki podczas pracy |
| **Reduce motion** | `false` | Wyłącza animacje (dla wolniejszych terminali) |
| **Thinking mode** | `true` | Pokazuje wewnętrzne rozumowanie (`▶ Myślenie`) |
| **Prompt suggestions** | `true` | Podpowiedzi komend podczas pisania |
| **Session recap** | `true` | Przy `/resume` Claude pokazuje co było zrobione |
| **Rewind code (checkpoints)** | `true` | Checkpointy po każdej edycji — cofnięcie zmian |
| **Verbose output** | `false` | Logi wewnętrznych operacji (do debugowania) |
| **Terminal progress bar** | `true` | Pasek postępu w terminalu |
| **Show turn duration** | `true` | Czas wykonania każdej tury |
| **Default permission mode** | `Default` | `Default` (pyta) / `Auto` (akceptuje) / `Manual` (pyta o każdą) |
| **Worktree base ref** | `fresh` | Punkt bazowy worktree dla agentów: `fresh` = aktualny HEAD |
| **Respect .gitignore in file picker** | `true` | Ignorowane pliki ukryte w autocompletion |
| **Skip the /copy picker** | `false` | `true` = `/copy` kopiuje ostatnią bez pytania |
| **Open agents view by default** | `false` | Domyślnie widok agentów zamiast rozmowy |
| **← opens agents** | `true` | ← w pustym prompcie otwiera panel agentów |
| **Auto-update channel** | `latest` | `latest` (stable) / `beta` |
| **Theme** | `Dark mode` | `Dark` / `Light` / `System` |
| **Local notifications** | `Auto` | `Auto` (gdy terminal w tle) / `Always` / `Never` |
| **Push when actions required** | `false` | Push notyfikacje gdy Claude czeka na decyzję |

## Pozostałe ustawienia

| Ustawienie | Opis |
|---|---|
| **Model** | Sonnet 4.6 (domyślny), Opus 4.7, Haiku 4.5 |
| **Custom system prompt** | Globalne instrukcje dla każdej sesji |
| **Preferred language** | Język odpowiedzi |
| **Notification sound** | Dźwięk po długim zadaniu |
| **MCP timeout** | Czas oczekiwania na serwer MCP |
| **Max output tokens** | Limit długości odpowiedzi |
| **Safe mode** | Dodatkowe potwierdzenia dla operacji destrukcyjnych |
| **Status line** | Konfiguracja paska statusu |
| **Keymap** | `default` / `vim` |
| **Include co-author trailer** | Auto-dodawanie `Co-Authored-By: Claude` do commitów |

---

## Zakładki `/config`

| Zakładka | Co pokazuje |
|---|---|
| Settings | Szybkie przełączniki |
| Status | Połączenie, konto, wersja |
| Config | Pełna lista ustawień |
| Usage | Zużycie tokenów i kosztów |
| Stats | Statystyki sesji |

---

## Jak zmienić ustawienie

1. **Panel:** `/config` → Config → znajdź ustawienie
2. **Plik:** `~/.claude/settings.json` (globalne) lub `.claude/settings.json` (projekt)
