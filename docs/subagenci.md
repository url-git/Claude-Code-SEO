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
- może używać tych samych narzędzi co główna sesja (Playwright, Bash, Read, Write)
- zapisuje swój wynik do pliku, który główna sesja potem odczytuje

---

## Krok 1 — Upewnij się, że MCP Playwright działa

Subagenci dziedziczą konfigurację MCP z `settings.json`. Sprawdź, czy serwer Playwright jest zdefiniowany:

```json
// .claude/settings.json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

Zweryfikuj działanie wpisując `/mcp` w sesji — powinna pojawić się pozycja `playwright` ze statusem `connected`.

---

## Krok 2 — Struktura katalogów dla raportów

Przed uruchomieniem równoległego audytu upewnij się, że katalog `reports/` istnieje:

```bash
mkdir -p reports
```

Subagenci będą zapisywać raporty do oddzielnych plików:

```
reports/
├── audit-ntfy-pl-home.md
├── audit-ntfy-pl-rabat.md
└── audit-ntfy-pl-longevity.md
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
Wykonaj równoległy audyt SEO za pomocą subagentów dla następujących URL:
- $AUDIT_URL (strona główna)
- $AUDIT_URL_2
- $AUDIT_URL_3

[... reszta promptu jak w Kroku 3 ...]
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
| Subagent nie widzi Playwright | MCP nie zainicjowany w subsesji | Sprawdź `/mcp` — upewnij się, że `playwright` ma status `connected` |
| Subagent zawiesza się | Strona nie ładuje się w limicie czasu | Dodaj timeout w prompcie: "poczekaj max 15 sekund na załadowanie" |
| Brak pliku wynikowego | Subagent skończył z błędem | Wejdź w `/agents`, wybierz agenta i sprawdź jego logi |
| Raporty nadpisują się | Takie same nazwy plików | W prompcie podaj unikalne nazwy plików dla każdego subagenta |

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

Subagenci to najprostszy sposób na skrócenie czasu audytów wielostronicowych. Nie wymagają żadnej dodatkowej konfiguracji poza tym, co już masz — wystarczy odpowiedni prompt.
