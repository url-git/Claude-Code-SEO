# MCP Playwright — konfiguracja w tym projekcie

MCP (Model Context Protocol) to mechanizm, który pozwala Claude Code łączyć się z zewnętrznymi narzędziami — w tym z przeglądarką Chrome przez Playwright. Bez MCP Claude nie otworzy strony ani nie odczyta jej zawartości.

---

## Jak działa w praktyce

Przy starcie sesji Claude Code czyta `.mcp.json` (lub `.claude/settings.json`) i uruchamia zdefiniowane serwery MCP jako oddzielne procesy. Playwright MCP odpala instancję przeglądarki i wystawia narzędzia:

| Narzędzie MCP | Co robi |
|---|---|
| `browser_navigate` | Otwiera URL |
| `browser_snapshot` | Pobiera strukturę DOM (tytuły, nagłówki, linki) |
| `browser_take_screenshot` | Robi zrzut ekranu |
| `browser_click` | Klika element |
| `browser_evaluate` | Wykonuje JavaScript na stronie |

Claude widzi je tak samo jak `Read` czy `Bash` — wywołuje w dowolnym momencie.

---

## Konfiguracja

`.mcp.json` (zalecane — dedykowany plik dla MCP):

```json
{
  "mcpServers": {
    "playwright": {
      "command": "/Users/p/.nvm/versions/node/v24.11.0/bin/playwright-mcp"
    }
  }
}
```

Alternatywnie można umieścić `mcpServers` w `.claude/settings.json` — oba formaty działają, ale `.mcp.json` jest dedykowanym miejscem na konfigurację MCP i nie miesza jej z uprawnieniami czy hookami.

Instalacja: `npm install -g @playwright/mcp@0.0.75`. Ścieżkę binarki znajdziesz przez `which playwright-mcp`.

### Globalna instalacja npm ≠ globalny MCP

`npm install -g` instaluje binarkę systemowo, ale Claude Code ładuje serwery MCP **z `.mcp.json` lub `.claude/settings.json` danego projektu**. Inny projekt na tym samym komputerze nie uruchomi Playwright MCP, dopóki nie ma go w swoim pliku konfiguracyjnym. Globalna instalacja to tylko sposób na szybki dostęp do binarki (zamiast czekać na `npx`).

---

## Dlaczego bezpośrednia ścieżka, a nie `npx`?

Claude Code ma limit czasu na połączenie z każdym MCP przy starcie. Jeśli `npx` musi w tym czasie pobrać lub zweryfikować pakiet w rejestrze — serwer nie zdąży i w `/mcp` widać `error` zamiast `connected`. Bezpośrednia ścieżka omija `npx` — serwer startuje natychmiast.

---

## Weryfikacja

```
/mcp
```

Przy `playwright` powinien być `connected`. Jeśli `error`:

1. `! which playwright-mcp` — czy binarka istnieje
2. W panelu `/mcp` kliknij nazwę po szczegóły błędu
3. `! playwright-mcp --help` — jeśli działa, problem jest ze ścieżką w `settings.json`