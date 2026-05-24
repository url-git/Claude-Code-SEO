# `/schedule` w Claude Code — automatyczny cotygodniowy audyt SEO

`/schedule` pozwala zlecić Claude Code wykonanie zadania w określonym czasie lub cyklicznie — **w chmurze Anthropica**, niezależnie od tego, czy masz otwartą sesję, czy włączony komputer. Agent startuje jak cron, klonuje repo z GitHub, wykonuje zadanie i wyłącza się.

> Pełny opis mechanizmu rutyn chmurowych: [`schedule-routines.md`](schedule-routines.md). Ten plik skupia się na zastosowaniu w audycie SEO.

---

## Jak różni się od `/loop` i sesji interaktywnej?

| | Sesja interaktywna | `/loop` | `/schedule` (rutyna) |
|---|---|---|---|
| Wymaga otwartej sesji | ✅ | ✅ | ❌ |
| Działa gdy Mac śpi | ❌ | ❌ | ✅ |
| Pamięta historię rozmowy | ✅ | ✅ | ❌ |
| Uruchamia się o godzinie | ❌ | ❌ | ✅ |
| Gdzie działa | Lokalnie | Lokalnie | **Serwery Anthropic** |
| Analogia | rozmowa | pętla w rozmowie | cron job w chmurze |

### Przykłady komend `/loop`

| Komenda | Co robi |
|---------|---------|
| `/loop 5m /seo-audit` | Co 5 min pełny audyt SEO — dopóki Ctrl+C |
| `/loop 1m sprawdź, czy ntfy.pl odpowiada` | Co minutę pinguje stronę |
| `/loop` | Tryb autonomiczny — Claude sam dobiera tempo |

Interwał: `30s`, `5m`, `1h`. Pętla działa tylko w otwartej sesji — zamknięcie terminala ją przerywa.

---

Kluczowa różnica rutyn: **agent startuje „na zimno"** — bez kontekstu z poprzednich sesji. Instrukcje w komendzie muszą być kompletne i samodzielne.

---

## Dlaczego to ma sens dla audytu SEO?

Folder `reports/` staje się archiwum z datą w nazwie:

```
reports/
├── ntfy-pl-2026-05-12.md
├── ntfy-pl-2026-05-19.md
├── ntfy-pl-2026-05-26.md   ← wygenerowany automatycznie
└── ntfy-pl-2026-06-02.md
```

Możesz śledzić trendy SEO ntfy.pl bez żadnej ręcznej pracy.

---

## Krok 1 — Upewnij się, że `seo-audit.md` jest samodzielny

Agent wczyta `CLAUDE.md` i `settings.json` ze sklonowanego repo, ale **nie zna żadnej poprzedniej rozmowy**. Komenda `/seo-audit` musi działać bez założeń kontekstowych. Sprawdź, czy zawiera:

- ✅ URL audytowanej strony (lub zmienną `$AUDIT_URL` z `settings.json`)
- ✅ Nazwę pliku wynikowego z datą (np. `reports/YYYY-MM-DD.md`)
- ✅ Instrukcję commitu i pushu po zapisaniu raportu

Aktualny `settings.json`:
```json
{ "env": { "AUDIT_URL": "https://ntfy.pl/" } }
```

`$AUDIT_URL` jest wstrzykiwany automatycznie — `/seo-audit` jest samodzielne.

---

## Krok 2 — Auto-commit w `seo-audit.md`

Agent po zapisaniu raportu musi sam go zacommitować i spushować — bez tego raport zostanie tylko w tymczasowej kopii roboczej agenta i zniknie po sesji.

Dodaj na końcu `.claude/commands/seo-audit.md`:

```markdown
## Automatyczny commit po audycie

Po zapisaniu raportu wykonaj:
1. `git add reports/`
2. `git commit -m "Automatyczny audyt SEO — [data]"`
3. `git push origin main`

Nie pytaj o potwierdzenie — wykonaj od razu.
```

Uprawnienia w `settings.json`:
```json
{
  "permissions": {
    "allow": ["Bash(git add *)", "Bash(git commit *)", "Bash(git push *)"]
  }
}
```

---

## Krok 3 — Uruchom `/schedule`

```
/schedule
```

Kreator zapyta o:
- **Kiedy:** np. `co poniedziałek o 8:00` (lub cron `0 8 * * 1`)
- **Co zrobić:** prompt (patrz niżej)
- **Repozytorium:** GitHub URL projektu (agent klonuje stamtąd kod)

### Prompt dla rutyny

```
Wykonaj pełny audyt SEO zgodnie z instrukcjami z .claude/commands/seo-audit.md.
Działaj autonomicznie, nie pytaj o potwierdzenie.
```

Krótki prompt wystarczy, bo `seo-audit.md` zawiera wszystko: URL, format nazwy pliku z datą, auto-commit i push.

---

## Krok 4 — Zweryfikuj działanie

Po uruchomieniu rutyny możesz przetestować bez czekania na cron — z poziomu https://claude.ai/code/routines kliknij "Run now". Lub uruchom audyt lokalnie:

```
/seo-audit
```

Jeśli `git push` się powiedzie → rutyna też zadziała. Hook lokalny `on-git-push.sh` **nie odpali się dla rutyny** (agent działa zdalnie), ale push do GitHub jest potwierdzeniem.

---

## Krok 5 — Obserwuj archiwum raportów

Po pierwszym automatycznym audycie poproś Claude'a o porównanie:

```
Porównaj reports/ntfy-pl-2026-05-19.md i ntfy-pl-2026-05-26.md.
Powiedz, które problemy SEO zostały naprawione, które się pogorszyły,
a które są nowe. Skup się na zmianach.
```

---

## Zarządzanie rutynami

Wszystko widoczne na **https://claude.ai/code/routines**:
- Historia uruchomień i logi
- Edycja harmonogramu lub promptu
- Ręczne uruchomienie (test bez czekania)
- Pauza / usunięcie

---

## Częste problemy

| Problem | Przyczyna | Rozwiązanie |
|---------|-----------|-------------|
| Agent commituje, ale push failuje | Brak `Bash(git push *)` w allowliście | Dodaj do `permissions.allow` |
| Raport bez daty | `seo-audit.md` używa stałej nazwy | Użyj `$(date)` lub wywiedź datę z kontekstu |
| Agent nie wie, co audytować | Brak `$AUDIT_URL` | Sprawdź `env.AUDIT_URL` w `settings.json` |
| Hook lokalny nie wysyła powiadomienia | Agent działa zdalnie | Hook lokalny NIE odpala się dla rutyn — push do GitHub jest potwierdzeniem |

---

## Podsumowanie

```
Co poniedziałek 8:00 (serwery Anthropic)
        │
        ├── Klonuje repo z GitHub
        ├── Wczytuje CLAUDE.md + settings.json
        ├── Uruchamia /seo-audit
        ├── Zapisuje reports/ntfy-pl-YYYY-MM-DD.md
        └── git add → git commit → git push
                    │
                  GitHub aktualizuje repo
                  (powiadomienie w aplikacji Git na telefonie)
```

Kluczowa lekcja: agent rutynowy musi działać samodzielnie bez założeń kontekstowych — to wymusza pisanie kompletnych instrukcji w komendach slash.
