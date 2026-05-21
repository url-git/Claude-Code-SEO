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
      "command": "npx",
      "args": ["@playwright/mcp@0.0.75"]
    }
  }
}
```

### Dlaczego `@0.0.75` a nie `@latest`?

Przy tagu `@latest` `npx` nie może bezpiecznie buforować pakietu — za każdym razem gdy Claude Code startuje sesję, `npx` musi odpytać rejestr npm czy nie pojawiła się nowsza wersja. To powoduje:

1. **Opóźnienie startu** — sieciowe zapytanie do rejestru npm zajmuje czas
2. **Ryzyko timeout** — Claude Code ma limit czasu na nawiązanie połączenia z MCP; jeśli pakiet musi być jeszcze pobrany, serwer nie zdąży się połączyć i w `/mcp` pojawia się błąd zamiast statusu `connected`
3. **Nieoczekiwane zmiany** — `@latest` może pobrać nową wersję z innym API i zepsuć działające audyty

Przypięcie konkretnej wersji (`@0.0.75`) rozwiązuje wszystkie trzy problemy: `npx` buforuje pakiet lokalnie po pierwszym pobraniu, każdy kolejny start jest natychmiastowy.

---

## Dlaczego nie instalacja globalna?

Globalna instalacja (`npm install -g @playwright/mcp`) działa technicznie, ale ma istotne wady:

**Problem z zasobami:**
Globalnie zainstalowane MCP serwery są dostępne we **wszystkich** projektach Claude Code na tym komputerze. Jeśli masz 5 projektów z różnymi MCP, przy każdym starcie dowolnego projektu mogą startować wszystkie serwery — nawet jeśli dany projekt ich nie potrzebuje.

**Problem z izolacją:**
Globalna wersja pakietu jest wspólna dla wszystkich projektów. Aktualizacja pod potrzeby jednego projektu może zepsuć inny.

**Problem z przenośnością:**
Projekt przestaje być samodzielny — na innym komputerze lub w CI/CD trzeba pamiętać o osobnej instalacji globalnej.

Konfiguracja w `.claude/settings.json` z `npx` i przypiętą wersją sprawia, że projekt jest **samowystarczalny**: wszystko czego potrzeba jest opisane w jednym pliku, który jest w repozytorium.

---

## Weryfikacja — czy MCP działa?

Po otwarciu projektu w Claude Code wpisz:

```
/mcp
```

Powinieneś zobaczyć listę serwerów. Przy `playwright` powinien być status `connected`. Jeśli pojawia się `error` lub `playwright` nie ma go na liście:

1. Sprawdź czy `node` i `npx` są dostępne: `! node --version`
2. Sprawdź logi MCP: w panelu `/mcp` kliknij nazwę serwera po szczegóły błędu
3. Uruchom ręcznie: `! npx @playwright/mcp@0.0.75 --help` — jeśli działa, problem jest z konfiguracją `settings.json`

---

## Aktualizacja wersji w przyszłości

Gdy będziesz chciał zaktualizować Playwright MCP do nowszej wersji:

1. Sprawdź aktualną najnowszą wersję: `! npx @playwright/mcp@latest --version`
2. Zaktualizuj numer wersji w `.claude/settings.json`
3. Zrestartuj sesję Claude Code — nowa wersja zostanie pobrana i zbuforowana

Nie aktualizuj pochopnie — nowe wersje MCP mogą zmieniać nazwy narzędzi, co wymaga aktualizacji promptów w komendach slash.
