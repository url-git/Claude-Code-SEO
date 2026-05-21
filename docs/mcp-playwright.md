# MCP Playwright — konfiguracja w tym projekcie

MCP (Model Context Protocol) to mechanizm, który pozwala Claude Code łączyć się z zewnętrznymi narzędziami — w tym przypadku z przeglądarką Chrome sterowaną przez Playwright. Bez MCP Claude nie może otworzyć strony internetowej ani odczytać jej zawartości.

---

## Jak MCP Playwright działa w praktyce

Gdy Claude Code startuje sesję, odczytuje `.claude/settings.json` i uruchamia zdefiniowane serwery MCP jako oddzielne procesy. Playwright MCP uruchamia instancję przeglądarki i wystawia narzędzia, z których Claude może korzystać:

| Narzędzie MCP | Co robi |
|---------------|---------|
| `browser_navigate` | Otwiera podany URL w przeglądarce |
| `browser_snapshot` | Pobiera strukturę DOM strony (tytuły, nagłówki, linki) |
| `browser_take_screenshot` | Robi zrzut ekranu |
| `browser_click` | Klika element na stronie |
| `browser_evaluate` | Wykonuje JavaScript na stronie |

Claude widzi te narzędzia tak samo jak `Read` czy `Bash` — może je wywołać w dowolnym momencie sesji.

---

## Konfiguracja w tym projekcie

Plik `.claude/settings.json`:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "/Users/p/.nvm/versions/node/v24.11.0/bin/playwright-mcp"
    }
  }
}
```

Pakiet jest zainstalowany globalnie: `npm install -g @playwright/mcp@0.0.75`

Żeby znaleźć ścieżkę binarki na swoim komputerze:

```bash
which playwright-mcp
```

### Globalna instalacja npm ≠ globalny MCP

Ważne rozróżnienie: `npm install -g` instaluje binarkę systemowo, ale **nie sprawia, że MCP jest aktywny we wszystkich projektach**. Claude Code ładuje serwery MCP wyłącznie z `.claude/settings.json` danego projektu. Otwarcie innego projektu — nawet na tym samym komputerze — nie uruchomi Playwright MCP, bo tamten projekt nie ma go w swojej konfiguracji.

Globalna instalacja npm to tylko sposób na szybki dostęp do binarki (żeby nie czekać na `npx`). Które projekty faktycznie korzystają z serwera — decyduje ich własny `settings.json`.

---

## Dlaczego bezpośrednia ścieżka, a nie `npx`?

Pierwotna konfiguracja używała `npx @playwright/mcp@0.0.75`. Problem: przy starcie sesji Claude Code ma limit czasu na nawiązanie połączenia z każdym MCP. Jeśli `npx` musi w tym czasie pobrać lub zweryfikować pakiet w rejestrze npm — serwer nie zdąży się połączyć i w `/mcp` pojawia się `error` zamiast `connected`.

Bezpośrednia ścieżka do binarki omija `npx` całkowicie — serwer startuje natychmiast.

---

## Weryfikacja — czy MCP działa?

Po otwarciu projektu w Claude Code wpisz:

```
/mcp
```

Przy `playwright` powinien być status `connected`. Jeśli pojawia się `error`:

1. Sprawdź czy binarka istnieje: `! which playwright-mcp`
2. Sprawdź logi MCP: w panelu `/mcp` kliknij nazwę serwera po szczegóły błędu
3. Uruchom ręcznie: `! playwright-mcp --help` — jeśli działa, problem jest ze ścieżką w `settings.json`

---

## Aktualizacja wersji w przyszłości

Gdy będziesz chciał zaktualizować Playwright MCP do nowszej wersji:

1. Zainstaluj nową wersję: `! npm install -g @playwright/mcp@<nowa-wersja>`
2. Ścieżka binarki pozostaje ta sama (`which playwright-mcp` nie zmienia się)
3. Zrestartuj sesję Claude Code

Nie aktualizuj pochopnie — nowe wersje MCP mogą zmieniać nazwy narzędzi, co wymaga aktualizacji promptów w komendach slash.
