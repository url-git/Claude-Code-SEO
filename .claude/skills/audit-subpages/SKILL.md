---
name: audit-subpages
description: Przeprowadza równoległe audyty SEO wielu podstron ntfy.pl przy użyciu subagentów. Użyj gdy użytkownik mówi "audytuj podstrony", "sprawdź wszystkie strony", "audyt wielu stron", "wszystkie podstrony", "uruchom agentów", lub chce sprawdzić więcej niż jeden URL jednocześnie.
allowed-tools:
  - Bash
  - WebFetch
  - Agent
  - Write
---

# Parallel Subpage Audit

Audyt wielu podstron ntfy.pl równolegle przy użyciu subagentów. Każdy subagent dostaje jeden URL i przeprowadza niezależny audyt SEO — wszystkie działają jednocześnie.

## Krok 1 — Załaduj listę URL-i

Sprawdź czy istnieje `config/audit-urls.txt`. Jeśli tak — wczytaj (jedna linia = jeden URL, pomijaj puste linie i linie zaczynające się od `#`).

Jeśli plik nie istnieje, użyj domyślnej listy:
```
https://ntfy.pl/
https://ntfy.pl/blog/
https://ntfy.pl/cennik/
https://ntfy.pl/kontakt/
```

Jeśli użytkownik podał URL-e w rozmowie — użyj tych zamiast powyższych.

Wydrukuj: "Uruchamiam audyt dla [N] podstron równolegle: [lista URL-i]"

## Krok 2 — Uruchom subagentów równolegle

Uruchom jednego subagenta na każdy URL. Wszyscy agenci startują **jednocześnie** (w jednym wywołaniu Agent tool z wieloma blokami).

Prompt dla każdego subagenta znajduje się w `references/subagent-audit-prompt.md` — wczytaj go i podstaw konkretny URL za `[URL]`.

## Krok 3 — Zbierz wyniki

Poczekaj aż wszyscy subagenci skończą. Sparsuj ich JSON-y.

Jeśli subagent zwrócił błąd lub nieparseable output — zanotuj to jako `"score": 0, "issues": ["błąd subagenta: [treść błędu]"]`.

## Krok 4 — Wygeneruj raport zbiorczy

Zapisz do `reports/subpages-YYYY-MM-DD.md` (użyj dzisiejszej daty):

```
# Audyt podstron ntfy.pl — [data]
Liczba przebadanych stron: [N]
Czas audytu: równoległy (subagenci)

## Ranking stron

| Strona | Score | Title | Meta | H1 | Canonical | Czas |
|--------|-------|-------|------|----|-----------|------|
| /      |  85   | ✅    |  ✅  | ✅ |  ✅       | 210ms|
| /blog/ |  60   | ⚠️    |  ❌  | ✅ |  ✅       | 340ms|

(sortuj malejąco po score; ✅ = OK, ⚠️ = ostrzeżenie, ❌ = problem)

## Najczęstsze problemy (≥2 strony)
- [problem]: dotknięte strony: /x/, /y/

## Strony wymagające pilnej uwagi (score < 70)
[szczegóły dla każdej takiej strony]

## Szczegóły per strona
[dla każdego URL: wszystkie dane + pełna lista issues]
```

Następnie wydrukuj tabelę rankingową i najczęstsze problemy w rozmowie.

## Ważne: uprawnienia subagentów

Subagenci nie pytają interaktywnie o potwierdzenie uprawnień. Muszą mieć w `.claude/settings.json` w sekcji `permissions.allow`:

```json
"Bash(curl -sI *)",
"Bash(curl -s https://*)",
"WebFetch(domain:ntfy.pl)"
```

Te wpisy są już w tym projekcie. Jeśli subagent zgłosi błąd uprawnień dla innej domeny — dodaj odpowiedni wpis i uruchom ponownie.
