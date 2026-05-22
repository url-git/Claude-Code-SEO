# Skills w Claude Code

## Czym są skile?

Skill (skil) to plik `SKILL.md` w dedykowanym katalogu, który definiuje własną komendę slash w Claude Code. Tworzysz plik `.claude/skills/nazwa/SKILL.md` i od razu możesz wywołać `/nazwa` w sesji — Claude automatycznie wczyta jego zawartość jako instrukcję.

Skile rozwiązują konkretny problem: zamiast opisywać Claude'owi za każdym razem jak przeprowadzić audyt SEO, zapisujesz to raz i wywołujesz jedną komendą.

---

## Struktura pliku

```markdown
---
name: nazwa-komendy
description: Co robi skil i kiedy Claude powinien go użyć.
allowed-tools:
  - Read
  - Write
  - Bash
model: haiku
---

# Treść instrukcji dla Claude...
```

Żadne pole frontmattera nie jest obowiązkowe — nazwę komendy Claude bierze z nazwy katalogu. `description` jest jednak mocno zalecany.

| Pole | Wymagany | Opis |
|------|----------|------|
| `name` | Nie | Nadpisuje nazwę katalogu jako nazwę komendy. Jeśli pominięty, używana jest nazwa katalogu. |
| `description` | Zalecany | Opis używany przez Claude do automatycznego dopasowania skila do zapytania |
| `allowed-tools` | Nie | Narzędzia, których Claude może używać bez pytania o zgodę gdy skil jest aktywny |
| `model` | Nie | Model Claude dla tego skila (`haiku`, `sonnet`, `opus`) |

---

## Jak pisać dobry opis (`description`)

Opis odpowiada na dwa pytania: *co robi skil?* i *kiedy Claude powinien go użyć?*

Claude dopasowuje skile do zapytań użytkownika na podstawie opisu — im więcej słów kluczowych pasujących do typowych zapytań, tym lepsze dopasowanie. Zbyt ogólny opis sprawia, że skil się nie włącza gdy trzeba.

**Przykład słabego opisu:**
```
description: Audyt SEO.
```

**Przykład dobrego opisu:**
```
description: Przeprowadza równoległe audyty SEO wielu podstron ntfy.pl przy użyciu
  subagentów. Użyj gdy użytkownik mówi "audytuj podstrony", "sprawdź wszystkie strony",
  "audyt wielu stron", "wszystkie podstrony", lub chce sprawdzić więcej niż jeden URL
  jednocześnie.
```

Skoro sesja toczy się po polsku, opis po polsku działa równie dobrze jak angielski —
Claude dopasowuje skil do tego, co faktycznie piszesz w rozmowie.

---

## `allowed-tools` — po co ograniczać narzędzia?

Domyślnie Claude ma dostęp do wszystkich narzędzi. `allowed-tools` ogranicza dostęp wyłącznie do listy, którą podasz.

**Dwie korzyści:**

1. **Bezpieczeństwo** — skil do czytania raportów nie powinien móc uruchamiać przeglądarki Playwright ani modyfikować kodu. Jawna lista narzędzi chroni przed przypadkowym użyciem.

2. **Czytelność intencji** — patrząc na `allowed-tools`, od razu wiesz czego skil potrzebuje, bez czytania całej treści.

### Jak dobieramy narzędzia w tym projekcie

**`compare-reports`** — porównuje dwa pliki Markdown i zapisuje wynik:
```yaml
allowed-tools:
  - Read    # czyta raporty z reports/
  - Write   # zapisuje plik compare-*.md
  - Bash    # listuje pliki w reports/ (ls)
```
Playwright, WebFetch, Agent — niepotrzebne, więc wykluczone.

**`audit-subpages`** — pobiera strony i uruchamia subagentów:
```yaml
allowed-tools:
  - Bash      # curl do pobierania stron
  - WebFetch  # alternatywa dla curl
  - Agent     # uruchamianie subagentów równolegle
  - Write     # zapis raportu zbiorczego
```
Read czy Edit kodu — niepotrzebne, więc wykluczone.

---

## `model` — kiedy zmieniać model?

Domyślnie skil używa aktualnego modelu sesji. Możesz to nadpisać.

**`compare-reports` używa `haiku`** — porównywanie tekstu to zadanie proste strukturalnie: wczytaj dwa pliki, zestawij wartości, zapisz tabelę. Nie wymaga zaawansowanego rozumowania. Haiku jest szybszy i tańszy, a jakość wyniku jest identyczna jak przy Sonnecie.

**`audit-subpages` nie definiuje modelu** — każdy subagent wykonuje kilka zapytań curl i parsuje HTML. Domyślny Sonnet wystarczy; subagenci i tak działają równolegle, więc czas wykonania zależy od sieci, nie od modelu.

Ogólna zasada: prostą analizę tekstu i formatowanie → `haiku`; złożone rozumowanie, wieloetapowe planowanie → `sonnet` lub `opus`.

---

## Progressive Disclosure — skile wieloplikowe

Gdy skil rośnie powyżej ~500 linii, rozbij go na wiele plików:

```
.claude/skills/
└── audit-subpages/
    ├── SKILL.md                      ← główny plik (max ~500 linii)
    └── references/
        └── subagent-audit-prompt.md  ← ładowany tylko gdy potrzebny
```

**Dlaczego to ważne:** Claude ładuje pliki pomocnicze *tylko gdy są potrzebne*, nie wszystko naraz. Dzięki temu okno kontekstu nie jest zapychane instrukcjami, które w danym momencie nie są używane.

**Skrypty w `scripts/`:** jeśli skil używa skryptu bash lub Python, Claude uruchamia go i do kontekstu trafia tylko wynik — nie cały kod. To oszczędza tokeny.

### Zastosowanie w tym projekcie

`audit-subpages/SKILL.md` oryginalnie miał wbudowany cały prompt subagenta (42 linie JSON-a i instrukcji). Po refaktorze:

- `audit-subpages/SKILL.md` odwołuje się do: `references/subagent-audit-prompt.md`
- Prompt jest ładowany tylko w Kroku 2, gdy faktycznie uruchamiane są subagenty
- Główny plik pozostaje czytelny i krótki

---

## Struktura skili w tym projekcie

```
.claude/skills/
├── audit-subpages/
│   ├── SKILL.md                      # /audit-subpages — równoległy audyt podstron
│   └── references/
│       └── subagent-audit-prompt.md  # prompt przekazywany subagentom audytu
└── compare-reports/
    └── SKILL.md                      # /compare-reports — porównanie dwóch raportów SEO
```

| Komenda | Model | Narzędzia | Zastosowanie |
|---------|-------|-----------|--------------|
| `/audit-subpages` | domyślny (Sonnet) | Bash, WebFetch, Agent, Write | Audyt wielu podstron równolegle |
| `/compare-reports` | haiku | Read, Write, Bash | Porównanie dwóch raportów SEO |
