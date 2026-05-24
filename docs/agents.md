# Custom Subagenty w Claude Code

## Czym są custom subagenty?

Custom subagent (agent) to plik Markdown w `.claude/agents/`, który definiuje **własny system prompt** dla Claude — mówi mu kim jest, jakie ma priorytety, jakie narzędzia może używać, a nawet jakiego modelu ma użyć.

Agent działa w **oddzielnym kontekście** — ma własne okno kontekstowe, nie widzi historii głównej sesji (chyba że mu ją przekażesz), i zwraca tylko wynik.

### Agent vs. komenda vs. skil

| Mechanizm | Lokalizacja | System prompt | Narzędzia | Model | Pamięć |
|-----------|-------------|---------------|-----------|-------|--------|
| **Komenda** `/seo-audit` | `.claude/commands/` | Tylko domyślny CC | Nie da się ograniczyć | Taki jak sesja | Nie |
| **Skil** `/audit-subpages` | `.claude/skills/*/SKILL.md` | Tylko domyślny CC | Da się (allowed-tools) | Da się zmienić | Nie |
| **Agent** `@seo-specialist` | `.claude/agents/` | **Własny prompt** + domyślny CC | Da się (tools) | Da się zmienić | Tak (memory) |

**Krótko:** Agent to najpotężniejszy mechanizm — daje system prompt, ograniczenie narzędzi, wybór modelu i trwałą pamięć. Komenda i skil to tylko instrukcje.

---

## Built-in agenty a custom subagenty

Claude Code ma wbudowane agenty. Różnica kluczowa:

| Agent | Typ | Widzi skille? | Model | Narzędzia |
|-------|-----|---------------|-------|-----------|
| **Explore** | built-in | ⚠️ Nie z automatu | Haiku | Tylko read-only |
| **Plan** | built-in | ⚠️ Nie z automatu | Taki jak sesja | Tylko read-only |
| **General-purpose** | built-in | ⚠️ Nie z automatu | Taki jak sesja | Wszystkie |
| **Custom** (twój) | zdefiniowany | **✅ Tak** | Ustawiasz sam | Ustawiasz sam |

### Dlaczego "nie z automatu" — mieć narzędzie ≠ wiedzieć kiedy użyć

Wbudowane agenty technicznie **mają** narzędzie `Skill` w swoim zestawie (Explore i Plan mają wszystkie narzędzia oprócz Agent/Edit/Write, General ma `*`). Ale samo posiadanie narzędzia nie wystarczy — żeby agent wywołał skilla, musi:

1. **Wiedzieć, że skille istnieją** — ich nazwy i triggery muszą być w kontekście
2. **Znać nazwę skilla** — `Skill` tool wymaga podania konkretnej nazwy
3. **Uznać, że zadanie pasuje** — na podstawie opisu skilla

Główna sesja Claude Code to robi, bo system-reminder wstrzykuje jej listę dostępnych skilli z triggerami. Wbudowany subagent dostaje **wąski prompt zadania** (np. "przeszukaj pliki pod X") — bez listy skilli, bez CLAUDE.md w pełnej formie. Więc nawet jeśli technicznie może wywołać `Skill`, nie wie co wołać.

**Jedyny wyjątek:** jeśli w prompcie przekazanym do subagenta explicite napiszesz "użyj skilla X", to go wywoła. Ale to ręczna instrukcja, nie automatyczne wykrycie.

**Custom agenty z `skills:` w frontmatterze** mają inaczej — treść skilli jest **wstrzyknięta do kontekstu od razu** przy starcie, więc agent wie o nich zanim dostanie jakiekolwiek zadanie.

---

## Gdzie definiować?

| Lokalizacja | Zasięg | Kiedy użyć |
|-------------|--------|------------|
| `.claude/agents/` (w projekcie) | Tylko ten projekt, commitowane | Agent specyficzny dla projektu |
| `~/.claude/agents/` (katalog domowy) | Wszystkie projekty, tylko dla Ciebie | Osobisty agent — np. code-reviewer |
| `--agents` (flaga CLI) | Tylko ta sesja | Testowanie, jednorazowe użycie |
| Plugin `agents/` | Gdzie plugin aktywny | Agent dystrybuowany przez plugin |

Priorytet (wyższy wygrywa): managed settings > `--agents` > `.claude/agents/` > `~/.claude/agents/` > plugin.

---

## Struktura pliku agenta

```markdown
---
name: seo-specialist
description: Specjalista SEO do audytu i optymalizacji stron...
tools: Read, Write, Bash, WebFetch, Glob, Grep, Agent
model: sonnet
skills:
  - audit-subpages
  - compare-reports
memory: project
---

Jesteś ekspertem SEO...
```

### Frontmatter — pola

| Pole | Wymagany | Co robi |
|------|----------|---------|
| `name` | **Tak** | Unikalny identyfikator, małe litery i myślniki |
| `description` | **Tak** | Kiedy Claude ma delegować zadanie do tego agenta |
| `tools` | Nie | Lista dozwolonych narzędzi (allowlista). Jeśli pominięte — dziedziczy wszystkie |
| `disallowedTools` | Nie | Lista zablokowanych narzędzi (denylista) |
| `model` | Nie | `sonnet`, `opus`, `haiku`, pełne ID modelu, lub `inherit` (domyślnie) |
| `permissionMode` | Nie | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns` | Nie | Maksymalna liczba tur agenta |
| `skills` | Nie | Lista skilli do preloadu — ich treść trafia do kontekstu od razu |
| `memory` | Nie | `user`, `project`, lub `local` — trwała pamięć między sesjami |
| `background` | Nie | `true` = zawsze w tle |
| `effort` | Nie | `low`, `medium`, `high`, `xhigh`, `max` |
| `isolation` | Nie | `worktree` = izolowana kopia repo |
| `color` | Nie | Kolor w UI: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` |
| `initialPrompt` | Nie | Automatyczna pierwsza wiadomość przy starcie z `--agent` |

### Body — system prompt agenta

To co piszesz po frontmatterze staje się **system promptem** agenta. To **nie jest instrukcja zadania** — to definicja tożsamości:

```markdown
Jesteś ekspertem SEO z wieloletnim doświadczeniem w technical SEO, on-page optimization i content strategy.

## Zasady pracy

1. Priorytety: crawlability → technical SEO → on-page → content → authority
2. Raporty zapisuj do reports/ w Markdown
3. Po audycie zapisz wzorce do agent-memory
```

Różnica między system promptem a instrukcją:
- **System prompt (body agenta):** "Kim jesteś, jak pracujesz, co Ci wolno"
- **Instrukcja (komenda `/seo-audit`):** "Co masz zrobić krok po kroku"

Dlatego połączenie `@seo-specialist /seo-audit` daje **oba** — najpełniejszy przekaz.

---

## Jak preloadować skille do agenta

Pole `skills` w frontmatterze wstrzykuje **pełną treść** skilli do kontekstu agenta na starcie:

```yaml
skills:
  - audit-subpages   # treść .claude/skills/audit-subpages/SKILL.md wchodzi do kontekstu
  - compare-reports  # treść .claude/skills/compare-reports/SKILL.md wchodzi do kontekstu
```

**Zaleta:** Agent nie musi ładować skilli przez Skill tool w trakcie pracy — ma je od razu.
**Wada:** Więcej tokenów na starcie (treść skilli zajmuje kontekst).

Bez preloadu agent może nadal używać skilli przez Skill tool — tyle że musi je odkryć i załadować samodzielnie.

---

## Pamięć agenta (`memory`)

Agent może zapamiętywać wzorce między sesjami:

| Scope | Lokalizacja | Commitowane? |
|-------|-------------|--------------|
| `project` | `.claude/agent-memory/<nazwa>/` | Tak (drużyna widzi) |
| `user` | `~/.claude/agent-memory/<nazwa>/` | Nie (tylko Twoje) |
| `local` | `.claude/agent-memory-local/<nazwa>/` | Nie (gitignored) |

Agent sam tworzy i aktualizuje `MEMORY.md` w swoim katalogu pamięci. Przy starcie czyta pierwsze 200 linii (lub 25KB) — reszta doładowywana na żądanie.

**Przykład użycia w system prompcie:**
```markdown
Po każdym audycie zapisz do agent-memory:
- znalezione wzorce i powtarzające się problemy
- nietypowe konfiguracje strony
- cokolwiek co ułatwi następny audyt
```

---

## Jak wywoływać agenta

### 1. `@`-mention (najczęstsze)

```
@seo-specialist /seo-audit
```

Gwarantuje, że agent zostanie użyty. Autocomplete podpowiada po wpisaniu `@`.

### 2. Natural language

Claude sam decyduje czy delegować na podstawie opisu agenta:
```
Użyj seo-specialist do audytu ntfy.pl
```

### 3. CLI flag — cała sesja jako agent

```bash
claude --agent seo-specialist
```

System prompt agenta zastępuje domyślny. CLAUDE.md i pamięć projektu wciąż działają.

### 4. Ustawienie domyślne w `.claude/settings.json`

```json
{
  "agent": "seo-specialist"
}
```

Każda nowa sesja w tym projekcie startuje jako ten agent.

---

## Agent vs. subagenci (zagnieżdżanie)

**Subagenty nie mogą uruchamiać innych subagentów.** Główna sesja może uruchomić subagenta, ale subagent nie może odpalić kolejnego.

W projekcie mamy to rozwiązane przez skill `audit-subpages` — to **główna sesja** (lub agent) uruchamia subagentów, nie subagent subagenta.

Jeśli potrzebujesz zagnieżdżania:
- **Chain subagentów** — główna sesja uruchamia A → czeka na wynik → uruchamia B z wynikiem A
- **Skill** — skil może uruchomić subagentów (jak `audit-subpages`)
- **Agent teams** — eksperymentalna funkcja z prawdziwą komunikacją między agentami

---

## Podsumowanie

```
.ciąude/agents/
└── seo-specialist.md

@seo-specialist = system prompt "jesteś ekspertem SEO"
/seo-audit      = instrukcja "zrób audyt krok po kroku"
@seo-specialist /seo-audit = jedno i drugie = najwięcej kontekstu
```

**Kiedy używać agenta:**
- Chcesz zmienić **system prompt** (kim jest Claude)
- Chcesz ograniczyć **narzędzia** (nie może edytować kodu)
- Chcesz **preloadować skille** (ma wiedzę od razu)
- Chcesz **pamięć między sesjami** (uczy się na błędach)
- Chcesz inny **model** niż reszta sesji

**Kiedy wystarczy komenda lub skil:**
- Potrzebujesz tylko instrukcji "zrób X"
- Nie potrzebujesz zmiany system promptu
- Nie potrzebujesz pamięci

---

## Dokumentacja

Źródło: https://code.claude.com/docs/en/sub-agents

Kluczowe sekcje:
- `#built-in-subagents` — Explore, Plan, General — co każdy robi
- `#invoke-subagents-explicitly` — `@`-mention, natural language, `--agent` flag
- `#supported-frontmatter-fields` — wszystkie opcje frontmattera
- `#preload-skills-into-subagents` — jak działa preload skilli
- `#enable-persistent-memory` — jak działa pamięć agenta
