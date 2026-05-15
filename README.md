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
│                                    # wypisuje ścieżkę ostatniego raportu z folderu reports/
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
5. Zapisuje raport do `reports/` → hook `on-stop.sh` wypisuje ścieżkę pliku
