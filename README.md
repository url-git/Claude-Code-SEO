# Claude Code — Audyt SEO z MCP Playwright

Projekt nauki Claude Code zbudowany wokół konkretnego zadania: **automatyczny audyt SEO strony https://ntfy.pl/** przy użyciu MCP (Model Context Protocol) i Playwright do kontroli przeglądarki Chrome.

## Jak uruchomić audyt

```
/seo-audit
```

---

## Struktura projektu

```
Claude-Code/
│
├── CLAUDE.md                        # instrukcje dla Claude — wczytywane automatycznie na starcie każdej sesji
├── README.md                        # ten plik — mapa projektu dla człowieka
│
├── .claude/
│   ├── settings.json                # ← tu jest cała konfiguracja projektu:
│   │                                #   • MCP: rejestracja serwera Playwright (npx @playwright/mcp@latest)
│   │                                #   • env: AUDIT_URL=https://ntfy.pl/ — zmień tu, żeby audytować inną stronę
│   │                                #   • hooks: rejestracja skryptu on-stop.sh
│   │                                #   • permissions: lista dozwolonych/blokowanych operacji
│   │
│   └── commands/
│       └── seo-audit.md             # komenda /seo-audit — profesjonalny framework audytu SEO v2.0
│                                    # źródło: github.com/coreyhaines31/marketingskills/skills/seo-audit
│                                    # sprawdza: title, meta, H1-H3, OG, canonical, alt, HTTPS,
│                                    # viewport, robots.txt, sitemap, linki, schema, Core Web Vitals
│
├── docs/                            # notatki z nauki — jeden plik .md na temat (uzupełniaj w trakcie)
│
├── hooks/
│   └── on-stop.sh                   # uruchamiany automatycznie po każdym zakończeniu odpowiedzi Claude
│                                    # wysyła natywne powiadomienie macOS (tytuł + podtytuł + nazwa pliku)
│                                    # oraz wypisuje ścieżkę raportu w terminalu
│
├── examples/
│   ├── hooks/                       # ćwiczenia: pisanie własnych skryptów hooków, blokowanie operacji
│   ├── tool-use/                    # ćwiczenia: narzędzia wbudowane i własne serwery MCP
│   ├── agents/                      # ćwiczenia: subagenci, równoległe audyty wielu podstron
│   └── memory/                      # ćwiczenia: porównywanie raportów między sesjami
│
└── reports/                         # wygenerowane raporty SEO w formacie Markdown
                                     # każdy audyt tworzy: ntfy-pl-YYYY-MM-DD.md
```

---

## Jak to działa

1. Claude Code startuje sesję → wczytuje `CLAUDE.md` i `settings.json`
2. `settings.json` rejestruje serwer MCP Playwright → Claude ma dostęp do przeglądarki
3. Wpisujesz `/seo-audit` → Claude dostaje instrukcje z `.claude/commands/seo-audit.md`
4. Claude otwiera `$AUDIT_URL` przez Playwright → czyta DOM, sprawdza wszystkie elementy SEO
5. Zapisuje raport do `reports/` → hook `on-stop.sh` wysyła powiadomienie macOS z nazwą pliku

---

## MCP i Playwright — jak to naprawdę działa

### Co to jest MCP?

MCP (Model Context Protocol) to protokół, który pozwala Claude Code korzystać z zewnętrznych narzędzi — tu: z przeglądarki Chrome przez Playwright. Konfiguracja w `settings.json` startuje serwer MCP jako osobny proces (`npx @playwright/mcp@latest`), a Claude komunikuje się z nim przez standardowe wejście/wyjście (stdio).

### Headless vs. widoczna przeglądarka

**Domyślnie przeglądarka NIE jest widoczna** — Playwright uruchamia Chromium w trybie headless (bez GUI). Claude otwiera strony, czyta ich zawartość i wykonuje akcje, ale nie zobaczysz żadnego okna przeglądarki na ekranie.

Żeby przeglądarka była widoczna, trzeba uruchomić MCP z flagą `--headed`:

```json
"mcpServers": {
  "playwright": {
    "command": "npx",
    "args": ["@playwright/mcp@latest", "--headed"]
  }
}
```

Po tej zmianie (i restarcie sesji Claude Code) Chromium otworzy się jako widoczne okno — będziesz widzieć, jak Claude nawiguje po stronie.

### Co Claude robi przez MCP — narzędzia Playwright

Claude nie „klika jak człowiek" — wysyła kolejne wywołania narzędzi do serwera MCP. W praktyce wywołuje m.in.:

| Narzędzie MCP | Co robi |
|---------------|---------|
| `browser_navigate` | Otwiera URL w przeglądarce |
| `browser_snapshot` | Pobiera dostępnościowy snapshot DOM (tekst, atrybuty, struktura) |
| `browser_click` | Klika element na stronie |
| `browser_screenshot` | Robi zrzut ekranu strony |
| `browser_evaluate` | Uruchamia JavaScript bezpośrednio w kontekście strony |

Podczas audytu SEO Claude głównie używa `browser_navigate` i `browser_snapshot` — czyta strukturę DOM, tytuły, meta tagi, nagłówki, linki i atrybuty alt, bez konieczności klikania.

### Przepływ danych w audycie

```
Claude Code
    │
    │  wywołanie narzędzia MCP (np. browser_snapshot)
    ▼
Serwer MCP (@playwright/mcp)   ←→   Chromium (headless lub --headed)
    │
    │  zwraca snapshot DOM / zrzut ekranu / wynik JS
    ▼
Claude Code
    │
    │  analizuje dane, formułuje wyniki SEO
    ▼
reports/ntfy-pl-YYYY-MM-DD.md
```

### Kiedy używać `--headed`?

- **Debugging** — chcesz zobaczyć, co Claude widzi na stronie
- **Nauka** — obserwujesz, jak działa automatyzacja przeglądarki
- **Strony z CAPTCHA lub wykrywaniem botów** — tryb headless bywa blokowany

Na co dzień tryb headless jest szybszy i nie wymaga środowiska graficznego.
