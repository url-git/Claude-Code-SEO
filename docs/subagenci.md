# Subagenci w Claude Code — równoległe audyty wielu podstron

Subagenci to oddzielne instancje Claude uruchamiane przez głównego agenta w tle. Każdy ma własny kontekst i narzędzia. Wiele zadań wykonuje się **jednocześnie**, zamiast kolejno.

## Dlaczego subagenci?

| Podejście | Czas dla 3 podstron |
|---|---|
| Sekwencyjne | ~6 min |
| Równoległe (subagenci) | ~2 min |

Zysk rośnie liniowo z liczbą stron.

---

## Jak działają technicznie

```
Główna sesja Claude Code
│
├─▶ Subagent A — audyt ntfy.pl/         (w tle)
├─▶ Subagent B — audyt ntfy.pl/rabat    (w tle)
└─▶ Subagent C — audyt ntfy.pl/longevity (w tle)
│
└─▶ Główna sesja zbiera wyniki i scala raport
```

Każdy subagent:
- ma **odizolowany kontekst** — nie widzi pozostałych
- używa `Bash`, `Read`, `Write`, `WebFetch` **tylko z allowlisty** w `settings.json`
- **nie zatwierdza uprawnień interaktywnie** — wszystko z góry
- **MCP serwery (Playwright) mogą się nie załadować** — fallback: `curl`
- zapisuje wynik do pliku, główna sesja go odczytuje

---

## Krok 1 — Warunki wstępne (`settings.json`)

Subagenci dziedziczą konfigurację, ale **nie zatwierdzają interaktywnie**. Każde narzędzie musi być na allowliście — inaczej zablokowane bez możliwości zgody.

### Serwer MCP Playwright (opcjonalnie)

```json
{
  "mcpServers": {
    "playwright": {
      "command": "/Users/p/.nvm/versions/node/v24.11.0/bin/playwright-mcp"
    }
  }
}
```

Zweryfikuj `/mcp` w sesji — pozycja `playwright` powinna być `connected`. **Uwaga:** mimo poprawnej konfiguracji MCP może nie załadować się w kontekście subagenta. Zawsze planuj fallback przez `curl`.

### Allowlista uprawnień (wymagana)

```json
{
  "permissions": {
    "allow": [
      "Bash(curl -sI *)",
      "Bash(curl -s https://*)",
      "Bash(mkdir -p *)",
      "WebFetch(https://ntfy.pl/*)",
      "Write(/Users/p/Documents/dev/Claude-Code-SEO/reports/*)",
      "mcp__playwright__browser_navigate",
      "mcp__playwright__browser_snapshot",
      "mcp__playwright__browser_evaluate",
      "mcp__playwright__browser_close"
    ]
  }
}
```

- `Bash(curl -s https://*)` — niezawodny fallback
- `Bash(mkdir -p *)` — utworzenie `reports/`
- `Write(/pełna/ścieżka/reports/*)` — zapis raportów (ścieżka pełna, nie względna)
- `mcp__playwright__*` — narzędzia Playwright (jeśli się załadują)

---

## Krok 2 — Struktura katalogów

```bash
mkdir -p reports
```

```
reports/
├── audit-home.md          # subagent 1
├── audit-rabat.md         # subagent 2
├── audit-longevity.md     # subagent 3
└── audit-porownanie.md    # sesja główna (scala)
```

---

## Krok 3 — Prompt równoległego audytu

```
Wykonaj równoległy audyt SEO trzech podstron za pomocą subagentów.

Uruchom trzy subagenty równolegle — każdy audytuje jedną podstronę
zgodnie z `.claude/commands/seo-audit.md`:

1. https://ntfy.pl/
2. https://ntfy.pl/rabat
3. https://ntfy.pl/diety-z-wyborem/longevity

Każdy subagent zapisuje wynik do osobnego pliku w reports/
(audit-home.md, audit-rabat.md, audit-longevity.md).
Na końcu połącz wyniki w reports/audit-porownanie.md z tabelą porównawczą.
```

Claude Code automatycznie uruchomi subagenty równolegle.

---

## Krok 4 — Wynik: raport porównawczy

Format `reports/audit-porownanie.md`:

```markdown
| Element SEO       | /                  | /rabat            | /longevity        |
|-------------------|--------------------|-------------------|--------------------|
| Title (długość)   | "Ntfy..." (52)    | "Rabat..." (48)   | "Longevity..." (44)|
| Meta description  | ✅ 148 zn.        | ⚠️ brak           | ✅ 132 zn.         |
| H1                | ✅ 1 nagłówek     | ✅ 1 nagłówek     | ⚠️ brak H1         |
| Canonical         | ✅ obecny         | ✅ obecny         | ✅ obecny          |
| Open Graph        | ✅ kompletny      | ⚠️ brak og:image  | ✅ kompletny       |
| Alt teksty        | ✅ wszystkie      | ⚠️ 3 brakujące    | ✅ wszystkie       |
```

Postęp: strzałka **←** w pustym prompcie lub `/agents` — lista aktywnych/zakończonych.

---

## Konfiguracja zaawansowana — własna komenda slash

`.claude/commands/seo-audit-parallel.md`:

```markdown
Wykonaj równoległy audyt SEO trzech podstron za pomocą subagentów,
zgodnie z .claude/commands/seo-audit.md:

1. $AUDIT_URL
2. $AUDIT_URL_2
3. $AUDIT_URL_3

Każdy zapisuje do reports/ z unikalną nazwą.
Na końcu scal w reports/audit-porownanie.md.
```

W `settings.json`:
```json
{
  "env": {
    "AUDIT_URL": "https://ntfy.pl/",
    "AUDIT_URL_2": "https://ntfy.pl/rabat",
    "AUDIT_URL_3": "https://ntfy.pl/diety-z-wyborem/longevity"
  }
}
```

Wystarczy `/seo-audit-parallel` — URL-e wstrzyknięte automatycznie.

---

## Częste problemy

| Problem | Przyczyna | Rozwiązanie |
|---|---|---|
| Subagent nie widzi Playwright | MCP nie ładuje się | Fallback: `curl -s https://...` |
| Nie może zapisać pliku | Brak `Write` w allowliście | Dodaj `"Write(/ścieżka/reports/*)"` |
| `WebFetch` zablokowany | Brak interaktywnej zgody | Dodaj `"WebFetch(https://domena/*)"` |
| `Bash(curl ...)` odrzucony | Wzorzec nie pasuje | Sprawdź spacje: `"Bash(curl -s https://*)"` |
| Subagent się zawiesza | Strona za wolno ładuje | W prompcie: "poczekaj max 15s" |
| Raporty nadpisują się | Te same nazwy plików | Wymuś unikalne nazwy w prompcie |

> **Strategia awaryjna:** gdy subagenci 2× failują z powodu uprawnień/MCP — nie restartuj w pętli. Szybciej przejąć pracę w sesji głównej: `curl + Python` (patrz [[feedback_subagenci_strategia]]).

---

## Podsumowanie

```
/seo-audit-parallel
       │
       ├── Subagent 1: ntfy.pl/          → audit-home.md
       ├── Subagent 2: ntfy.pl/rabat     → audit-rabat.md
       └── Subagent 3: ntfy.pl/longevity → audit-longevity.md
                                                   │
                                        reports/audit-porownanie.md
```

Subagenci skracają audyt liniowo z liczbą stron, ale **nie są darmowe konfiguracyjnie**:
- Każde narzędzie z góry na allowliście (brak interaktywnej zgody)
- MCP (Playwright) potrafi nie załadować się w kontekście subagenta
- Niezawodny fallback: `curl` + Python do parsowania HTML
- 2× fail z uprawnień → przejdź na sesję główną zamiast restartować
