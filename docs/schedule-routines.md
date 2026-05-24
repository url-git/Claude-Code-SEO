# `/schedule` — automatyczne rutyny Claude Code

> **Ten feature jest uruchomiony w innym projekcie.**
> Działający przykład: projekt **Web-Scraping** (`~/Documents/dev/Web-Scraping`) — agent scrape'uje tweety z X w Pn/Śr/Pt o 03:00, bez udziału użytkownika i bez włączonego MacBooka.

---

## Czym jest rutyna

Zaplanowany agent działający **w chmurze Anthropica**. W odróżnieniu od `/loop`, nie wymaga otwartej sesji ani włączonego komputera — agent startuje na serwerach Anthropic, klonuje repo z GitHub, wykonuje zadanie, wyłącza się.

| | `/loop` | `/schedule` (rutyna) |
|---|---|---|
| Wymaga otwartego terminala | ✅ | ❌ |
| Działa gdy Mac śpi | ❌ | ✅ |
| Pamięta historię rozmowy | ✅ | ❌ — „na zimno" |
| Uruchamia się o godzinie | ❌ | ✅ |
| Gdzie działa | Lokalnie | Serwery Anthropic |
| Zarządzanie | Ctrl+C | claude.ai/code/routines |

---

## Działający przykład — Web-Scraping

| Pole | Wartość |
|------|---------|
| Nazwa | Twitter Scraper — Pn/Śr/Pt |
| Harmonogram | Pn/Śr/Pt o 03:00 (Warszawa) |
| Model | claude-sonnet-4-6 |
| Repo | github.com/url-git/Web-Scraping |

### Pipeline

```
03:00 Serwery Anthropic odpalają agenta
  ├── Klonuje repo z GitHub (tymczasowa kopia robocza)
  ├── Tworzy .env z tokenem Apify (z konfiguracji rutyny)
  ├── Uruchamia scrape.py dla 8 fraz równolegle
  ├── Generuje raport (output/tweets-YYYY-MM-DD.md)
  ├── git add → commit → push
  └── Kopia robocza usuwana
```

Użytkownik widzi nowy plik raportu w repo na telefonie.

### Gdzie co jest przechowywane

| Zasób | Lokalizacja |
|-------|-------------|
| Kod (`scrape.py`, `output/`) | GitHub |
| Konfiguracja rutyny + prompt | Serwery Anthropic |
| Token Apify | Serwery Anthropic (w prompcie rutyny) |
| `.env` | Tworzony przez agenta na czas sesji, potem usuwany |

Sekret API nigdy nie trafia do repo — jest w konfiguracji rutyny i wstrzykiwany do agenta przy starcie.

---

## Konfiguracja własnej rutyny

### Krok 1 — Prompt samodzielny

Agent startuje bez kontekstu z poprzednich sesji. Prompt musi zawierać:
- Dokładne instrukcje
- URL repo lub ścieżkę do komendy slash
- Wszelkie tokeny / dane konfiguracyjne, których agent nie znajdzie sam

Przykład z Web-Scraping:
```
Uruchom /scrape zgodnie z instrukcjami w .claude/commands/scrape.md.
Token Apify: apify_api_XXXXX
Działaj autonomicznie, nie pytaj o potwierdzenie.
```

Krótki prompt wystarcza, bo `scrape.md` zawiera pełny workflow. Token musi być w prompcie — agent nie ma dostępu do lokalnego `.env`.

### Krok 2 — Kreator

```
/schedule
```

Pyta o:
- **Kiedy** — godzina lub cron (`0 1 * * 1,3,5` = Pn/Śr/Pt 01:00 UTC)
- **Co zrobić** — prompt agenta
- **Repo** — GitHub URL do sklonowania

### Krok 3 — Zarządzanie

**https://claude.ai/code/routines**:
- Historia uruchomień i logi
- Edycja harmonogramu / promptu
- Ręczne uruchomienie (test bez czekania)
- Pauza / usunięcie

---

## Wymagania

1. **Repo na GitHubie** — agent klonuje stamtąd kod
2. **Samodzielna komenda slash** — instrukcje działają bez kontekstu sesji
3. **Sekret API w prompcie rutyny** — nie w repo
4. **Uprawnienia git push** — SSH key / HTTPS token skonfigurowany w rutynie

---

## Podsumowanie

```
Lokalna sesja              Rutyna chmurowa
──────────────             ───────────────
Mac musi być włączony      Mac może spać
Sesja musi być otwarta     Agent autonomiczny
Dane lokalne dostępne      Tylko GitHub + prompt
Hooki lokalne działają     Hooki lokalne NIE działają
Ctrl+C zatrzymuje          claude.ai/code/routines
```

Rutyny sprawdzają się dla zadań cyklicznych z dobrze zdefiniowanym outputem (plik, commit, raport), bez interakcji z użytkownikiem, na danych z repo lub zewnętrznych API.
