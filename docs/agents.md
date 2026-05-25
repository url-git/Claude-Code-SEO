# Custom Subagenty w Claude Code

## Czym są custom subagenty?

Plik Markdown w `.claude/agents/`, który definiuje **własny system prompt** dla Claude — kim jest, jakie ma priorytety, jakich narzędzi może używać, jaki model. Agent działa w **oddzielnym kontekście** — własne okno kontekstowe, nie widzi historii głównej sesji, zwraca tylko wynik.

### Agent vs komenda vs skil

| Mechanizm | Lokalizacja | System prompt | Narzędzia | Model | Pamięć |
|---|---|---|---|---|---|
| **Komenda** `/seo-audit` | `.claude/commands/` | Wbudowany CC¹ | Brak ograniczeń | Sesji | Nie |
| **Skil** `/audit-subpages` | `.claude/skills/*/SKILL.md` | Wbudowany CC¹ | Allowed-tools | Konfigurowalny | Nie |
| **Agent** `@seo-specialist` | `.claude/agents/` | **Własny body** + wbudowany CC¹ | Tools (allow/deny) | Konfigurowalny | **Tak** |

¹ **Wbudowany CC** = system prompt zakodowany w aplikacji Claude Code (niewidoczny, niedytowalny). CLAUDE.md to *nie* system prompt — to project instructions doklejane jako dodatkowy kontekst.

Agent = najpotężniejszy mechanizm: system prompt + ograniczenie narzędzi + wybór modelu + trwała pamięć.

---

## Built-in vs custom

| Agent | Typ | Widzi skille? | Model | Narzędzia |
|---|---|---|---|---|
| **Explore** | built-in | ⚠️ Nie z automatu | Haiku | Read-only |
| **Plan** | built-in | ⚠️ Nie z automatu | Sesji | Read-only |
| **General-purpose** | built-in | ⚠️ Nie z automatu | Sesji | Wszystkie |
| **Custom** | własny | **✅ Tak (z `skills:`)** | Ustawiasz | Ustawiasz |

### Dlaczego "nie z automatu"

Wbudowane agenty technicznie mają narzędzie `Skill`, ale nie wiedzą, *które* skille wywołać. Główna sesja dostaje listę skilli przez system-reminder, subagent dostaje tylko wąski prompt zadania — bez listy skilli, bez pełnego CLAUDE.md.

**Wyjątek:** prompt explicite mówiący "użyj skilla X" — wtedy subagent wie co wołać.

**Custom agenty z `skills:` w frontmatterze** mają treść skilli wstrzykniętą do kontekstu od razu na starcie.

---

## Gdzie definiować

| Lokalizacja | Zasięg | Kiedy |
|---|---|---|
| `.claude/agents/` (projekt) | Tylko projekt, commitowane | Agent specyficzny dla projektu |
| `~/.claude/agents/` | Wszystkie projekty | Osobisty (np. code-reviewer) |
| `--agents` (flaga CLI) | Sesja | Testowanie, jednorazowe |
| Plugin `agents/` | Gdzie plugin aktywny | Dystrybucja przez plugin |

Priorytet (wyższy wygrywa): managed > `--agents` > `.claude/agents/` > `~/.claude/agents/` > plugin.

---

## Struktura pliku

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

### Pola frontmattera

| Pole | Wymagany | Co robi |
|---|---|---|
| `name` | **Tak** | Unikalny identyfikator (małe litery, myślniki) |
| `description` | **Tak** | Kiedy delegować zadanie do agenta |
| `tools` | Nie | Allowlist narzędzi (pominięte = wszystkie) |
| `disallowedTools` | Nie | Denylist narzędzi |
| `model` | Nie | `sonnet` / `opus` / `haiku` / pełne ID / `inherit` |
| `permissionMode` | Nie | `default` / `acceptEdits` / `auto` / `dontAsk` / `bypassPermissions` / `plan` |
| `maxTurns` | Nie | Limit tur |
| `skills` | Nie | Lista skilli do preloadu |
| `memory` | Nie | `user` / `project` / `local` |
| `background` | Nie | `true` = zawsze w tle |
| `effort` | Nie | `low` / `medium` / `high` / `xhigh` / `max` |
| `isolation` | Nie | `worktree` = izolowana kopia repo |
| `color` | Nie | UI: `red`/`blue`/`green`/`yellow`/`purple`/`orange`/`pink`/`cyan` |
| `initialPrompt` | Nie | Pierwsza wiadomość przy starcie z `--agent` |

### Body = system prompt

To co po frontmatterze to **system prompt** agenta — definicja tożsamości, nie instrukcja zadania.

- **System prompt (body):** "Kim jesteś, jak pracujesz, co Ci wolno"
- **Instrukcja (komenda):** "Co masz zrobić krok po kroku"

Połączenie `@seo-specialist /seo-audit` daje **oba** — najpełniejszy przekaz.

---

## Preload skilli

Pole `skills` w frontmatterze wstrzykuje **pełną treść** skilli do kontekstu agenta na starcie:

```yaml
skills:
  - audit-subpages   # treść SKILL.md trafia do kontekstu
  - compare-reports
```

**Zaleta:** agent nie musi ładować skilli przez Skill tool w trakcie. **Wada:** więcej tokenów na starcie. Bez preloadu agent może nadal używać skilli przez Skill tool — tyle że musi je odkryć.

---

## Pamięć agenta (`memory`)

| Scope | Lokalizacja | Commitowane? |
|---|---|---|
| `project` | `.claude/agent-memory/<nazwa>/` | Tak |
| `user` | `~/.claude/agent-memory/<nazwa>/` | Nie |
| `local` | `.claude/agent-memory-local/<nazwa>/` | Nie (gitignored) |

Agent sam tworzy i aktualizuje `MEMORY.md`. Przy starcie czyta pierwsze 200 linii / 25KB — reszta doładowywana na żądanie.

W system prompcie:
```markdown
Po każdym audycie zapisz do agent-memory:
- znalezione wzorce i powtarzające się problemy
- nietypowe konfiguracje strony
```

---

## Jak wywoływać agenta

```
@seo-specialist /seo-audit               # @-mention, gwarantuje wywołanie
Użyj seo-specialist do audytu ntfy.pl    # natural language (Claude decyduje)
claude --agent seo-specialist            # cała sesja jako agent
```

Domyślny agent dla projektu w `.claude/settings.json`:
```json
{ "agent": "seo-specialist" }
```

---

## Zagnieżdżanie

**Subagenty nie mogą uruchamiać innych subagentów.** W projekcie rozwiązane przez skill `audit-subpages` — to **główna sesja** uruchamia subagentów, nie subagent.

Alternatywy:
- **Chain** — sesja: A → wynik → B z wynikiem A
- **Skill** — skil może uruchomić subagentów (jak `audit-subpages`)

---

## Podsumowanie

```
.claude/agents/seo-specialist.md

@seo-specialist           = system prompt "jesteś ekspertem SEO"
/seo-audit                = instrukcja "zrób audyt krok po kroku"
@seo-specialist /seo-audit = jedno i drugie = najwięcej kontekstu
```

**Użyj agenta gdy chcesz:** zmienić system prompt / ograniczyć narzędzia / preloadować skille / pamięć między sesjami / inny model.

**Wystarczy komenda lub skil gdy:** potrzebujesz tylko instrukcji "zrób X" bez zmiany tożsamości i pamięci.

---

## Dokumentacja

Źródło: https://docs.claude.com/en/docs/claude-code/sub-agents
