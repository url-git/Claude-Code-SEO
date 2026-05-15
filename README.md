# Claude Code — Audyt SEO z MCP Playwright

Projekt nauki Claude Code zbudowany wokół konkretnego zadania: **automatyczny audyt SEO strony https://ntfy.pl/** przy użyciu MCP (Model Context Protocol) i Playwright do kontroli przeglądarki Chrome.

Każdy plik i folder w projekcie odpowiada jednej funkcjonalności Claude Code — uczysz się jej przez praktyczne użycie, nie przez ćwiczenia w próżni.

---

## Jak uruchomić audyt

```
/seo-audit
```

Wpisz tę komendę w sesji Claude Code. Claude otworzy https://ntfy.pl/ przez Playwright, sprawdzi wszystkie elementy SEO i zapisze raport do folderu `reports/`.

---

## Struktura projektu

### `CLAUDE.md`
Plik odczytywany automatycznie przez Claude **na początku każdej sesji** w tym projekcie. Zawiera kontekst projektu, cel (audyt SEO ntfy.pl) i mapę folderów. Dzięki niemu Claude wie co robi ten projekt bez tłumaczenia od zera przy każdej rozmowie.

---

### `.claude/settings.json`
Centralna konfiguracja projektu. Zawiera trzy kluczowe sekcje:

**MCP — podłączenie Playwright:**
```json
"mcpServers": {
  "playwright": {
    "command": "npx",
    "args": ["@playwright/mcp@latest"]
  }
}
```
To tutaj rejestrujesz serwer MCP. Po uruchomieniu sesji Claude ma dostęp do narzędzi Playwright: otwieranie stron, czytanie DOM, klikanie, robienie screenshotów.

**Zmienna środowiskowa z URL do audytu:**
```json
"env": {
  "AUDIT_URL": "https://ntfy.pl/"
}
```
Chcesz audytować inną stronę? Zmień tylko ten jeden wpis — komenda `/seo-audit` używa `$AUDIT_URL` automatycznie.

**Rejestracja hooków:**
```json
"hooks": {
  "Stop": [{ "hooks": [{ "type": "command", "command": "hooks/on-stop.sh" }] }]
}
```
Wskazuje Claude Code, który skrypt ma uruchomić po zakończeniu odpowiedzi.

---

### `.claude/commands/seo-audit.md`
Definicja komendy `/seo-audit`. Zawiera szczegółowy prompt dla Claude: jakie elementy SEO sprawdzić, w jakiej kolejności, w jakim formacie zapisać raport. Gdy wpiszesz `/seo-audit`, Claude dostaje zawartość tego pliku jako instrukcję.

**Co audytuje:**
- Title tag i meta description (obecność + długość)
- Struktura nagłówków H1/H2/H3
- Open Graph tags (og:title, og:description, og:image)
- Canonical URL
- Alt text na obrazkach
- HTTPS i mobile viewport
- robots.txt i sitemap.xml
- Linki wewnętrzne i zewnętrzne
- Schema.org / JSON-LD markup

---

### `hooks/on-stop.sh`
Skrypt shell uruchamiany przez Claude Code **automatycznie po każdym zakończeniu odpowiedzi**. Sprawdza czy w folderze `reports/` pojawił się nowy raport i wypisuje jego ścieżkę w terminalu. Przykład praktycznego użycia hooków — automatyzacja bez ingerencji w samą komendę.

---

### `reports/`
Folder na wygenerowane raporty SEO w formacie Markdown. Każdy audyt tworzy nowy plik z datą w nazwie (`ntfy-pl-2026-05-15.md`). Dzięki temu możesz porównywać wyniki między sesjami i śledzić postęp optymalizacji strony w czasie.

---

### `docs/`
Notatki z nauki — jeden plik Markdown na temat (np. jak działają hooki, jak skonfigurować MCP, jak pisać komendy slash). Folder czeka na treść — uzupełniaj go w trakcie nauki.

---

### `examples/`
Gotowe ćwiczenia pogrupowane tematycznie:

| Podfolder | Co ćwiczysz |
|-----------|-------------|
| `hooks/` | Pisanie własnych skryptów hooków, blokowanie operacji |
| `tool-use/` | Narzędzia wbudowane i własne serwery MCP |
| `agents/` | Subagenci, równoległe audyty wielu podstron |
| `memory/` | Porównywanie raportów między sesjami, zarządzanie kontekstem |
