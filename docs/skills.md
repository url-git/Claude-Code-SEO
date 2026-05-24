# Skills w Claude Code

## Czym są skile?

Plik `SKILL.md` w `.claude/skills/nazwa/`, który definiuje własną komendę slash. Tworzysz plik i od razu możesz wywołać `/nazwa` — Claude wczyta zawartość jako instrukcję.

Skile rozwiązują konkretny problem: zamiast opisywać Claude'owi audyt SEO za każdym razem, zapisujesz raz i wywołujesz jedną komendą.

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

Żadne pole frontmattera nie jest obowiązkowe — nazwę komendy Claude bierze z nazwy katalogu. `description` jest mocno zalecany.

| Pole | Wymagany | Opis |
|---|---|---|
| `name` | Nie | Nadpisuje nazwę katalogu |
| `description` | Zalecany | Używany do dopasowania skila do zapytania |
| `allowed-tools` | Nie | Narzędzia bez pytania o zgodę gdy skil aktywny |
| `model` | Nie | `haiku` / `sonnet` / `opus` |

---

## Jak pisać dobry `description`

Opis odpowiada na: *co robi skil?* i *kiedy Claude ma go użyć?* Claude dopasowuje skile do zapytań po opisie — im więcej słów kluczowych z typowych zapytań, tym lepsze trafienie.

**Słaby:**
```
description: Audyt SEO.
```

**Dobry:**
```
description: Przeprowadza równoległe audyty SEO wielu podstron ntfy.pl przy użyciu
  subagentów. Użyj gdy użytkownik mówi "audytuj podstrony", "sprawdź wszystkie strony",
  "audyt wielu stron", lub chce sprawdzić więcej niż jeden URL jednocześnie.
```

Opis po polsku działa równie dobrze — Claude dopasowuje do tego, co piszesz w rozmowie.

---

## Skąd Claude wie o skillu? — `system-reminder`

Główna sesja ma w kontekście cztery źródła:

| Źródło | Co zawiera | Kto wstrzykuje |
|---|---|---|
| **CLAUDE.md** | Instrukcje projektu, struktura | Ty (plik w repo) |
| **settings.json** | Uprawnienia, MCP, env | Ty |
| **MEMORY.md** | Pamięć z poprzednich sesji | Claude automatycznie |
| **system-reminder** | Lista skilli z triggerami | Harness automatycznie |

`system-reminder` to niewidoczny blok wstrzykiwany przez harness — zawiera listę dostępnych skilli z opisami i triggerami. Dlatego Claude "sam z siebie" wie kiedy wywołać `/audit-subpages` — bo system-reminder mówi mu *"użyj gdy użytkownik mówi: audytuj podstrony..."*.

**Subagenci tego nie dostają** — wbudowane (Explore, Plan, General) startują z wąskim promptem zadania, bez listy skilli. Technicznie mają narzędzie `Skill`, ale nie wiedzą jakie skille istnieją. Custom agent z `skills:` w frontmatterze omija to — treść skilli wstrzyknięta od startu.

---

## `allowed-tools` — po co ograniczać

Domyślnie Claude ma dostęp do wszystkich narzędzi. `allowed-tools` ogranicza dostęp do listy. **Dwie korzyści:** bezpieczeństwo (skil do raportów nie powinien móc edytować kodu) + czytelność intencji.

### Jak dobieramy w tym projekcie

**`compare-reports`** — porównuje pliki Markdown:
```yaml
allowed-tools:
  - Read   # czyta raporty z reports/
  - Write  # zapisuje compare-*.md
  - Bash   # ls plików
```

**`audit-subpages`** — pobiera strony, uruchamia subagentów:
```yaml
allowed-tools:
  - Bash      # curl
  - WebFetch  # alternatywa
  - Agent     # subagenci równolegle
  - Write     # raport zbiorczy
```

---

## `model` — kiedy zmieniać

Domyślnie skil używa modelu sesji. Nadpisać warto gdy zadanie ma inne wymagania.

- **`compare-reports` → `haiku`** — porównanie tekstu strukturalnie proste, Haiku szybszy i tańszy przy identycznej jakości
- **`audit-subpages` → bez override** — subagenci działają równolegle, czas zależy od sieci, nie od modelu

Zasada: prosta analiza i formatowanie → `haiku`; złożone rozumowanie → `sonnet`/`opus`.

---

## Progressive Disclosure — skile wieloplikowe

Gdy skil rośnie powyżej ~500 linii, rozbij na wiele plików:

```
.claude/skills/audit-subpages/
├── SKILL.md                       ← główny (max ~500 linii)
└── references/
    └── subagent-audit-prompt.md   ← ładowany tylko gdy potrzebny
```

Claude ładuje pliki pomocnicze **tylko gdy są potrzebne** — okno kontekstu nie jest zapychane instrukcjami nieużywanymi. Skrypty w `scripts/`: do kontekstu trafia tylko wynik, nie cały kod.

W tym projekcie: `audit-subpages/SKILL.md` odwołuje się do `references/subagent-audit-prompt.md` — prompt subagenta ładowany dopiero w Kroku 2, gdy realnie uruchamiane są subagenty.

---

## Struktura skili w projekcie

```
.claude/skills/
├── audit-subpages/
│   ├── SKILL.md                      # /audit-subpages
│   └── references/subagent-audit-prompt.md
└── compare-reports/
    └── SKILL.md                      # /compare-reports
```

| Komenda | Model | Narzędzia | Zastosowanie |
|---|---|---|---|
| `/audit-subpages` | Sonnet | Bash, WebFetch, Agent, Write | Audyt wielu podstron równolegle |
| `/compare-reports` | haiku | Read, Write, Bash | Porównanie dwóch raportów SEO |
