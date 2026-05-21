# Subagenci w Claude Code — równoległe audyty wielu podstron

Subagenci to oddzielne instancje Claude uruchamiane przez głównego agenta w tle. Każdy subagent działa niezależnie, ma własny kontekst i własne narzędzia. Dzięki temu wiele zadań może być wykonanych **jednocześnie**, zamiast kolejno.

## Dlaczego subagenci?

Audyt SEO pojedynczej strony trwa od kilkudziesięciu sekund do kilku minut. Przy 3 podstronach:

| Podejście | Czas (szacunkowy) |
|-----------|------------------|
| Sekwencyjne (jedna po drugiej) | ~6 minut |
| Równoległe (subagenci) | ~2 minuty |

Zysk rośnie liniowo z liczbą stron.

---

## Jak działają subagenci technicznie

```
Główna sesja Claude Code
│
├─▶ Subagent A — audyt ntfy.pl/         (działa w tle)
├─▶ Subagent B — audyt ntfy.pl/rabat    (działa w tle)
└─▶ Subagent C — audyt ntfy.pl/diety-z-wyborem/longevity  (działa w tle)
│
│   (wszystkie trzy działają jednocześnie)
│
└─▶ Główna sesja zbiera wyniki i scala raport
```

Każdy subagent:
- ma **odizolowany kontekst** — nie widzi rozmów pozostałych agentów
- może używać `Bash`, `Read`, `Write` i `WebFetch` — pod warunkiem że są na allowliście w `settings.json` (patrz Krok 1)
- **nie ma interaktywnych promptów uprawnień** — wszystko musi być zatwierdzone z góry
- **MCP serwery (np. Playwright) mogą się nie załadować** w jego kontekście — niezawodny fallback to `curl`
- zapisuje swój wynik do pliku, który główna sesja potem odczytuje

---

## Krok 1 — Warunki wstępne (`settings.json`)

Subagenci dziedziczą konfigurację z `settings.json`, ale **nie zatwierdzają uprawnień interaktywnie**. Każde narzędzie, którego mają użyć, musi być na allowliście z góry — inaczej zostanie zablokowane bez możliwości zgody w trakcie pracy.

### 1.1 — Serwer MCP Playwright (opcjonalnie)

Jeśli chcesz, żeby subagenci próbowali renderować strony przez Playwright:

```json
// .claude/settings.json
{
  "mcpServers": {
    "playwright": {
      "command": "/Users/p/.nvm/versions/node/v24.11.0/bin/playwright-mcp"
    }
  }
}
```

Zweryfikuj wpisując `/mcp` w sesji głównej — pozycja `playwright` powinna mieć status `connected`.

> **Uwaga:** Nawet z poprawną konfiguracją Playwright MCP może nie załadować się w kontekście subagenta. Zawsze planuj fallback przez `curl`.

### 1.2 — Allowlista uprawnień (wymagana)

Minimalna konfiguracja dla subagentów audytujących strony:

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

Co daje każdy wpis:
- `Bash(curl -s https://*)` — pobranie HTML przez fallback (niezawodny)
- `Bash(mkdir -p *)` — utworzenie `reports/` jeśli nie istnieje
- `WebFetch(https://domena/*)` — alternatywa dla `curl`, węższy zakres
- `Write(/pełna/ścieżka/reports/*)` — zapis raportów (ścieżka musi być pełna, nie względna)
- `mcp__playwright__*` — narzędzia Playwright MCP (jeśli się załadują)

---

## Krok 2 — Struktura katalogów dla raportów

Przed uruchomieniem równoległego audytu upewnij się, że katalog `reports/` istnieje:

```bash
mkdir -p reports
```

Subagenci będą zapisywać raporty do oddzielnych plików, a główna sesja scala je w raport zbiorczy:

```
reports/
├── audit-home.md          # subagent 1
├── audit-rabat.md         # subagent 2
├── audit-longevity.md     # subagent 3
└── audit-porownanie.md    # sesja główna (scala 1-3)
```

---

## Krok 3 — Uruchomienie równoległego audytu (prompt)

Wpisz w sesji Claude Code:

```
Wykonaj równoległy audyt SEO trzech podstron za pomocą subagentów.

Uruchom trzy subagenty równolegle — każdy audytuje jedną podstronę
zgodnie z instrukcjami z `.claude/commands/seo-audit.md`:

1. https://ntfy.pl/
2. https://ntfy.pl/rabat
3. https://ntfy.pl/diety-z-wyborem/longevity

Każdy subagent zapisuje wynik do osobnego pliku w katalogu reports/
(użyj unikalnych nazw, np. audit-home.md, audit-rabat.md, audit-longevity.md).
Na końcu połącz wyniki w zbiorczy raport reports/audit-porownanie.md
z tabelą porównawczą kluczowych elementów SEO.
```

Claude Code automatycznie uruchomi trzy subagenty równolegle i poczeka na wyniki.

---

## Krok 4 — Obserwowanie pracy subagentów

Podczas gdy subagenci pracują, możesz śledzić ich postęp:

- Naciśnij **←** (strzałka w lewo) w pustym prompcie — otworzy panel agentów
- Lub wpisz `/agents` — lista aktywnych i zakończonych subagentów

W panelu agentów widzisz:
- Status każdego subagenta (`running` / `done` / `error`)
- Ostatnią akcję, którą wykonał
- Możliwość wejścia do kontekstu subagenta (inspekcja)

---

## Krok 5 — Wynik: raport porównawczy

Po zakończeniu pracy subagentów główna sesja scala wyniki. Przykładowy format tabeli porównawczej (`reports/audit-porownanie.md`):

```markdown
# Porównanie SEO — ntfy.pl

| Element SEO          | /                        | /rabat                   | /diety.../longevity      |
|----------------------|--------------------------|--------------------------|--------------------------|
| Title (długość)      | "Ntfy — dieta..." (52)   | "Rabat — ntfy..." (48)   | "Longevity..." (44)      |
| Meta description     | ✅ wypełniona (148 zn.)  | ⚠️ brak                  | ✅ wypełniona (132 zn.)  |
| H1                   | ✅ 1 nagłówek            | ✅ 1 nagłówek            | ⚠️ brak H1               |
| Canonical            | ✅ obecny                | ✅ obecny                | ✅ obecny                |
| Open Graph           | ✅ kompletny             | ⚠️ brak og:image         | ✅ kompletny             |
| Alt teksty obrazków  | ✅ wszystkie             | ⚠️ 3 brakujące           | ✅ wszystkie             |
```

---

## Konfiguracja zaawansowana — własna komenda slash

Żeby uruchamiać równoległy audyt jednym poleceniem, utwórz plik `.claude/commands/seo-audit-parallel.md`:

```markdown
Wykonaj równoległy audyt SEO trzech podstron za pomocą subagentów.

Uruchom trzy subagenty równolegle — każdy audytuje jedną podstronę
zgodnie z instrukcjami z `.claude/commands/seo-audit.md`:

1. $AUDIT_URL
2. $AUDIT_URL_2
3. $AUDIT_URL_3

Każdy subagent zapisuje wynik do osobnego pliku w `reports/`
(audit-home.md, audit-rabat.md, audit-longevity.md).
Na końcu scal wyniki w `reports/audit-porownanie.md` z tabelą
porównawczą kluczowych elementów SEO.
```

Następnie w `settings.json` zdefiniuj zmienne środowiskowe:

```json
{
  "env": {
    "AUDIT_URL": "https://ntfy.pl/",
    "AUDIT_URL_2": "https://ntfy.pl/rabat",
    "AUDIT_URL_3": "https://ntfy.pl/diety-z-wyborem/longevity"
  }
}
```

Teraz wystarczy wpisać `/seo-audit-parallel` — adresy URL są wstrzyknięte automatycznie.

---

## Częste problemy

| Problem | Przyczyna | Rozwiązanie |
|---------|-----------|-------------|
| Subagent nie widzi Playwright | MCP nie ładuje się w kontekście subagenta | Użyj `curl -s https://...` jako fallbacku; Playwright działa pewnie tylko w sesji głównej |
| Subagent nie może zapisać pliku | Brak `Write` w `permissions.allow` | Dodaj `"Write(/ścieżka/do/reports/*)"` do `settings.json` |
| `WebFetch` zablokowany mimo allowlisty | Subagent nie zatwierdza interaktywnie | Dodaj `"WebFetch(https://domena/*)"` do `permissions.allow` w `settings.json` |
| `Bash(curl -s https://...)` odrzucony | Wzorzec w allowliście nie pasuje dokładnie | Upewnij się, że wpis to `"Bash(curl -s https://*)"`  — sprawdź spacje i znaki |
| Subagent zawiesza się | Strona nie ładuje się w limicie czasu | Dodaj timeout w prompcie: "poczekaj max 15 sekund na załadowanie" |
| Brak pliku wynikowego | Subagent skończył z błędem | Wejdź w `/agents`, wybierz agenta i sprawdź jego logi |
| Raporty nadpisują się | Takie same nazwy plików | W prompcie podaj unikalne nazwy plików dla każdego subagenta |

> **Strategia awaryjna:** Gdy subagenci wielokrotnie failują z powodu uprawnień lub braku MCP — nie restartuj ich w pętli. Szybciej przejąć pracę w sesji głównej: `curl -s url > /tmp/page.html` + parsowanie przez własny skrypt Python.

---

## Podsumowanie

```
/seo-audit-parallel
       │
       ├── Subagent 1: ntfy.pl/          → reports/audit-home.md
       ├── Subagent 2: ntfy.pl/rabat     → reports/audit-rabat.md
       └── Subagent 3: ntfy.pl/longevity → reports/audit-longevity.md
                                                    │
                                         reports/audit-porownanie.md
```

Subagenci skracają czas audytu wielostronicowego liniowo z liczbą stron, ale **nie są darmowe konfiguracyjnie**:

- Każde narzędzie musi być na allowliście w `settings.json` — brak interaktywnej zgody
- MCP serwery (Playwright) potrafią nie załadować się w kontekście subagenta
- Niezawodny fallback: `curl` + Python do parsowania HTML
- Gdy subagent failuje 2× — przejdź na ręczną pracę w sesji głównej zamiast restartować
