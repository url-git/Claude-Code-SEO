# `/schedule` — automatyczne rutyny Claude Code

> **Ten feature jest uruchomiony w innym projekcie.**
> Działającym przykładem automatycznej rutyny jest projekt **Web-Scraping**
> (`~/Documents/dev/Web-Scraping`), gdzie agent scrape'uje tweety z X
> w poniedziałki, środy i piątki o 03:00 — bez udziału użytkownika
> i bez włączonego MacBooka. Poniższa dokumentacja opisuje mechanizm
> na podstawie tej właśnie konfiguracji.

---

## Czym jest rutyna (routine)

Rutyna to zaplanowany agent działający **w chmurze Anthropica**. W odróżnieniu od `/loop`, nie wymaga otwartej sesji ani włączonego komputera — agent startuje na serwerach Anthropic o ustalonej godzinie, klonuje Twoje repo z GitHub, wykonuje zadanie i wyłącza się.

| | `/loop` | `/schedule` (rutyna) |
|---|---|---|
| Wymaga otwartego terminala | ✅ | ❌ |
| Działa gdy Mac śpi | ❌ | ✅ |
| Pamięta historię rozmowy | ✅ | ❌ — startuje „na zimno" |
| Uruchamia się o konkretnej godzinie | ❌ | ✅ |
| Gdzie działa | Lokalnie | Serwery Anthropic |
| Zarządzanie | Ctrl+C | https://claude.ai/code/routines |

---

## Jak wygląda działająca rutyna — Web-Scraping

Projekt Web-Scraping ma skonfigurowaną rutynę chmurową:

| Pole | Wartość |
|------|---------|
| **Nazwa** | Twitter Scraper — Pn/Śr/Pt |
| **Harmonogram** | Poniedziałek, Środa, Piątek o 03:00 (czas Warszawy) |
| **Model** | claude-sonnet-4-6 |
| **Repozytorium** | github.com/url-git/Web-Scraping |
| **Zarządzanie** | https://claude.ai/code/routines |

### Pipeline krok po kroku

Każdego ranka o 03:00 dzieje się to bez żadnej interakcji:

```
03:00 Serwery Anthropic odpają agenta
  │
  ├── Klonuje repo z GitHub (tymczasowa kopia robocza)
  ├── Tworzy plik .env z tokenem Apify (token zapisany w konfiguracji rutyny)
  ├── Uruchamia scrape.py dla 8 fraz jednocześnie (scrape.py auto-instaluje brakujące pakiety)
  ├── Generuje raport po polsku (output/tweets-YYYY-MM-DD.md)
  ├── git add → git commit → git push
  │
  └── Kopia robocza usuwana po zakończeniu sesji
```

Po zakończeniu w repozytorium na GitHubie pojawia się nowy plik raportu — użytkownik czyta go z aplikacji Git na telefonie.

### Co jest gdzie przechowywane

| Zasób | Lokalizacja |
|-------|-------------|
| Kod projektu (`scrape.py`, `output/`) | GitHub |
| Konfiguracja rutyny i prompt agenta | Serwery Anthropic |
| Token Apify | Serwery Anthropic (w prompcie rutyny) |
| Plik `.env` | Tworzony przez agenta na czas sesji, potem usuwany |

Sekret API (token Apify) nigdy nie trafia do repozytorium — jest przechowywany w konfiguracji rutyny po stronie Anthropica i wstrzykiwany do agenta w momencie startu.

---

## Jak skonfigurować własną rutynę

### Krok 1 — Upewnij się, że prompt jest samodzielny

Agent startuje bez żadnego kontekstu z poprzednich sesji. Prompt rutyny musi zawierać:
- Dokładne instrukcje co zrobić
- URL repozytorium lub ścieżkę do komendy slash
- Wszelkie dane konfiguracyjne (tokeny, URL-e), których agent nie może sam znaleźć

W Web-Scraping prompt rutyny wygląda mniej więcej tak:
```
Uruchom /scrape zgodnie z instrukcjami w .claude/commands/scrape.md.
Token Apify: apify_api_XXXXX
Działaj autonomicznie, nie pytaj o potwierdzenie.
```

Krótki prompt jest możliwy dlatego, że `scrape.md` zawiera pełny workflow. Prompt rutyny tylko go wywołuje — ale token Apify musi być w prompcie, bo agent nie ma dostępu do lokalnego `.env`.

### Krok 2 — Uruchom kreator

W sesji Claude Code wpisz:

```
/schedule
```

Kreator zapyta o:
- **Kiedy** — godzina lub wyrażenie cron (`0 1 * * 1,3,5` = Pn/Śr/Pt o 01:00 UTC)
- **Co zrobić** — prompt agenta (patrz wyżej)
- **Repozytorium** — GitHub URL, z którego agent sklonuje kod

### Krok 3 — Zarządzanie

Wszystkie rutyny są widoczne na https://claude.ai/code/routines. Możesz tam:
- Zobaczyć historię uruchomień i logi
- Edytować harmonogram lub prompt
- Uruchomić ręcznie (test bez czekania na cron)
- Zatrzymać lub usunąć rutynę

---

## Kluczowe różnice względem lokalnego `/schedule`

Starsza wersja `/schedule` planowała zadania **lokalnie** (jak cron na Macu) — wymagała włączonego komputera o zaplanowanej godzinie. Rutyny chmurowe rozwiązują ten problem: agent działa na serwerach Anthropica niezależnie od stanu Twojego sprzętu.

Dla audytu SEO w tym projekcie oznaczałoby to:
- Co poniedziałek o 03:00 agent klonuje `Claude-Code-SEO` z GitHub
- Uruchamia `/seo-audit` (instrukcje z `.claude/commands/seo-audit.md`)
- Zapisuje raport do `reports/ntfy-pl-YYYY-MM-DD.md`
- Commituje i pushuje — hook `on-git-push.sh` na lokalnym Macu nie odpali (agent działa zdalnie), ale push do GitHub wystarczy jako potwierdzenie wykonania

---

## Czego potrzebujesz, żeby to zadziałało

1. **Repozytorium na GitHubie** — agent klonuje kod z GitHub, nie z lokalnego dysku
2. **Samodzielna komenda slash** — instrukcje muszą działać bez kontekstu sesji
3. **Sekret API w prompcie rutyny** — jeśli skrypt potrzebuje tokenu (np. Apify, klucz API), wpisz go bezpośrednio w prompcie rutyny na serwerach Anthropic — nie w repozytorium
4. **Uprawnienia git push** — agent musi móc pushować do repo (SSH key lub HTTPS token skonfigurowany w rutynie)

---

## Podsumowanie

```
Lokalna sesja              Rutyna chmurowa
──────────────             ───────────────
Mac musi być włączony      Mac może spać
Sesja musi być otwarta     Agent startuje autonomicznie
Dane lokalne dostępne      Tylko to, co w GitHub + prompt
Hooki lokalne działają     Hooki lokalne NIE działają
Ctrl+C zatrzymuje          Zarządzanie przez claude.ai/code/routines
```

Rutyny najlepiej sprawdzają się dla zadań cyklicznych, które:
- Mają dobrze zdefiniowany output (plik, commit, raport)
- Nie wymagają interakcji z użytkownikiem
- Działają na danych z repozytorium lub zewnętrznych API
