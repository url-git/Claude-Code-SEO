# `/schedule` w Claude Code — automatyczny cotygodniowy audyt SEO

`/schedule` pozwala zlecić Claude Code wykonanie zadania w określonym czasie lub cyklicznie — bez udziału człowieka. Zaplanowany agent startuje jak cron: niezależnie od tego, czy masz otwartą sesję, czy nie.

## Jak różni się od `/loop` i sesji interaktywnej?

| | Sesja interaktywna | `/loop` | `/schedule` |
|---|---|---|---|
| Wymaga otwartej sesji | ✅ | ✅ | ❌ |
| Działa bez człowieka | ❌ | ❌ | ✅ |
| Pamięta historię rozmowy | ✅ | ✅ | ❌ |
| Uruchamia się o konkretnej godzinie | ❌ | ❌ | ✅ |
| Analogia | rozmowa | pętla w rozmowie | cron job |

Kluczowa różnica: **zaplanowany agent startuje „na zimno"** — nie ma żadnego kontekstu z poprzednich sesji. Instrukcje w komendzie muszą być kompletne i samodzielne.

---

## Dlaczego to ma sens dla audytu SEO?

Folder `reports/` staje się archiwum historycznych audytów z datą w nazwie:

```
reports/
├── ntfy-pl-2026-05-12.md
├── ntfy-pl-2026-05-19.md
├── ntfy-pl-2026-05-26.md   ← wygenerowany automatycznie
└── ntfy-pl-2026-06-02.md
```

Możesz śledzić trendy SEO ntfy.pl w czasie bez żadnej ręcznej pracy. Po każdym audycie hook `on-git-push.sh` wyśle powiadomienie macOS — dowiesz się, że job się wykonał.

---

## Krok 1 — Sprawdź, czy `seo-audit.md` jest samodzielny

Zaplanowany agent wczyta `CLAUDE.md` i `settings.json`, ale **nie będzie pamiętał żadnej poprzedniej rozmowy**. Komenda `/seo-audit` musi działać bez żadnych założeń kontekstowych.

Sprawdź, czy `seo-audit.md` zawiera:
- ✅ Pełny URL audytowanej strony (lub zmienną `$AUDIT_URL` z `settings.json`)
- ✅ Nazwę pliku wynikowego z datą (np. `reports/YYYY-MM-DD.md`)
- ✅ Instrukcję commitu i pushu po zapisaniu raportu

Aktualny stan `settings.json` w tym projekcie:
```json
{
  "env": {
    "AUDIT_URL": "https://ntfy.pl/"
  }
}
```

`$AUDIT_URL` jest wstrzykiwany automatycznie — komenda `/seo-audit` jest już samodzielna.

---

## Krok 2 — Dodaj instrukcję auto-commit do `seo-audit.md`

Zaplanowany agent po zapisaniu raportu musi sam go zacommitować i spushować — inaczej raport zostanie tylko lokalnie i nie dostaniesz powiadomienia przez hook.

Dodaj na końcu `.claude/commands/seo-audit.md` sekcję:

```markdown
## Automatyczny commit po audycie

Po zapisaniu raportu wykonaj:

1. `git add reports/`
2. `git commit -m "Automatyczny audyt SEO — [data]"`
3. `git push origin main`

Nie pytaj o potwierdzenie — wykonaj od razu.
```

Upewnij się też, że w `settings.json` jest uprawnienie do push:
```json
{
  "permissions": {
    "allow": [
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(git push *)"
    ]
  }
}
```

---

## Krok 3 — Uruchom `/schedule`

Wpisz w sesji Claude Code:

```
/schedule
```

Otworzy się kreator. Skonfiguruj:

- **Kiedy:** `co poniedziałek o 8:00` (lub własny cron, np. `0 8 * * 1`)
- **Co zrobić:** wklej prompt (patrz niżej)
- **Katalog projektu:** `/Users/p/Documents/dev/Claude-Code-SEO`

### Prompt dla zaplanowanego agenta

```
Wykonaj pełny audyt SEO zgodnie z instrukcjami z .claude/commands/seo-audit.md.
Działaj autonomicznie, nie pytaj o potwierdzenie.
```

Krótki prompt jest możliwy dlatego, że `seo-audit.md` zawiera już wszystko: URL (`$AUDIT_URL` z `settings.json`), format nazwy pliku z datą, instrukcję auto-commit i push. Jedna prawda w jednym miejscu — prompt tylko ją wywołuje.

---

## Krok 4 — Zweryfikuj działanie hoka

Hook `hooks/on-git-push.sh` wysyła powiadomienie macOS gdy Claude wykona `git push`. Po skonfigurowaniu `/schedule` możesz to sprawdzić bez czekania tygodnia — uruchom audyt ręcznie:

```
/seo-audit
```

Jeśli po zakończeniu pojawi się powiadomienie systemowe z tytułem "Claude Code — git push" — hook działa i automatyczny audyt też będzie działał.

Jeśli powiadomienia nie ma, sprawdź:

```bash
# Czy hook jest wykonywalny?
ls -la hooks/on-git-push.sh

# Czy settings.json wskazuje na hook?
cat .claude/settings.json | grep -A5 "PostToolUse"
```

---

## Krok 5 — Obserwuj archiwum raportów

Po pierwszym automatycznym audycie w `reports/` pojawi się nowy plik. Porównaj go z poprzednim:

```bash
# Diff między dwoma tygodniowymi raportami
diff reports/ntfy-pl-2026-05-19.md reports/ntfy-pl-2026-05-26.md
```

Lub poproś Claude'a:

```
Porównaj raporty reports/ntfy-pl-2026-05-19.md i reports/ntfy-pl-2026-05-26.md.
Powiedz, które problemy SEO zostały naprawione, które się pogorszyły,
a które są nowe. Skup się na zmianach, nie na powtarzaniu całego raportu.
```

---

## Zarządzanie zaplanowanymi audytami

```bash
# Lista aktywnych zadań
/schedule list

# Zatrzymanie konkretnego zadania
/schedule delete [id]

# Uruchomienie teraz (test bez czekania)
/schedule run [id]
```

---

## Częste problemy

| Problem | Przyczyna | Rozwiązanie |
|---------|-----------|-------------|
| Agent commituje, ale push failuje | Brak `Bash(git push *)` w allowliście | Dodaj do `permissions.allow` w `settings.json` |
| Raport zapisany, ale bez daty | `seo-audit.md` używa stałej nazwy | Upewnij się, że nazwa pliku zawiera `$(date)` lub wywiedź datę z kontekstu |
| Hook nie wysyła powiadomienia | Skrypt nie jest wykonywalny lub ścieżka zła | `chmod +x hooks/on-git-push.sh` i sprawdź matcher w `settings.json` |
| Agent nie wie, co audytować | Brak `$AUDIT_URL` lub URL w prompcie | Sprawdź `env.AUDIT_URL` w `settings.json` — lub wpisz URL bezpośrednio w prompcie |
| Job się nie uruchamia | Komputer uśpiony o 8:00 | Zmień godzinę lub użyj zdalnego schedulera (patrz niżej) |

### Uwaga o uśpieniu komputera

`/schedule` działa lokalnie — jeśli Mac jest uśpiony o zaplanowanej godzinie, job się nie wykona. Rozwiązania:
- Zmień godzinę na taką, gdy komputer jest aktywny
- Lub użyj zdalnego agenta przez `/schedule` w trybie cloud (jeśli dostępny na Twoim planie)

---

## Podsumowanie

```
Co poniedziałek 8:00
        │
        └── Agent startuje „na zimno"
            ├── Wczytuje CLAUDE.md + settings.json
            ├── Uruchamia /seo-audit (instrukcje z seo-audit.md)
            ├── Zapisuje reports/ntfy-pl-YYYY-MM-DD.md
            └── git add → git commit → git push
                                            │
                                   hook on-git-push.sh
                                            │
                               Powiadomienie macOS ✅
```

Kluczowa lekcja: zaplanowany agent musi działać samodzielnie bez żadnych założeń kontekstowych — to wymusza pisanie dobrych, kompletnych instrukcji w komendach slash.
