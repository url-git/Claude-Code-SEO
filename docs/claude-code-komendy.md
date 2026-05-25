# Ściągawka: Komendy Claude Code

## Komendy wbudowane

**`/add-dir`**
Dodaje dodatkowy katalog roboczy do bieżącej sesji. Przydatne gdy projekt jest rozrzucony po kilku folderach — Claude widzi pliki z obu lokalizacji bez przełączania. Bez tej komendy Claude operuje tylko w katalogu, z którego uruchomiłeś sesję.

**`/advisor`**
Konsultuje mocniejszy model (np. Opus) w kluczowych momentach decyzyjnych, gdy bieżący model ma wątpliwości. W praktyce dostajesz "drugą opinię" bez ręcznego przełączania modelu. Szczególnie przydatne przy architektonicznych wyborach lub trudnych bugach.

**`/agents`**
Wyświetla i zarządza uruchomionymi agentami w tle. Możesz sprawdzić status, zatrzymać lub wznowić agenta bez otwierania nowej sesji. Przydatne gdy odpaliłeś kilka równoległych subagentów i chcesz śledzić ich postęp.

**`/autofix-pr`**
Automatycznie naprawia problemy wykryte w pull requeście — błędy CI, uwagi reviewerów, linting. Claude analizuje komentarze i wprowadza poprawki bez Twojej ingerencji. Oszczędza czas na mechanicznych poprawkach, które normalnie wymagają kilku rund review.

**`/background`**
Przenosi sesję Claude do tła, zwalniając terminal do innych zadań. Długie operacje (np. audyt 50 podstron) mogą działać równolegle, gdy piszesz kod w tym samym oknie. Sesję wznowisz przez `/resume`.

**`/branch`**
Tworzy rozgałęzienie bieżącej rozmowy — możesz eksperymentować z alternatywnym podejściem bez utraty głównego wątku. Jeśli eksperyment nie wyjdzie, wracasz do punktu rozgałęzienia. Przydatne przy refaktorach, gdzie chcesz porównać dwa podejścia.

**`/btw`**
Pozwala zadać szybkie pytanie poboczne bez przerywania głównego zadania. Claude odpowiada i wraca do tego, co robił wcześniej. Idealne gdy coś Cię zaciekawi w połowie dużego zadania, a nie chcesz tracić kontekstu.

**`/chrome`**
Konfiguruje integrację Claude z przeglądarką Chrome (funkcja beta). Daje Claude dostęp do aktywnej zakładki — możesz prosić o analizę strony bez kopiowania treści. Na razie ograniczona funkcjonalność, warta obserwowania.

**`/clear`**
Rozpoczyna nową sesję z całkowicie pustym kontekstem — Claude nie pamięta poprzedniej rozmowy. Przydatne gdy kontekst się zapełnił i chcesz świeżego startu bez bagażu poprzednich instrukcji. Poprzednią sesję możesz wznowić przez `/resume`.

**`/color`**
Zmienia kolor paska promptu w terminalu. Pozwala wizualnie odróżnić kilka równoległych sesji Claude Code otwartych w różnych oknach. Drobna, ale przydatna personalizacja przy intensywnej pracy wielosesyjnej.

**`/compact`**
Podsumowuje dotychczasową rozmowę i zastępuje ją skrótem, zwalniając miejsce w oknie kontekstu. Gdy sesja trwa długo i zbliżasz się do limitu, Claude zaczyna "zapominać" starsze wiadomości — `/compact` kontroluje, co zostaje. Dzięki temu długie sesje nie degradują jakości odpowiedzi.

**`/config`**
Otwiera interaktywny panel konfiguracji Claude Code — model, motyw, ustawienia zachowania. Zamiast ręcznie edytować `settings.json`, masz GUI z podglądem dostępnych opcji. Dobry punkt startowy przed pierwszą konfiguracją projektu.

**`/context`**
Wizualizuje, ile okna kontekstu już zużyłeś i co zajmuje najwięcej miejsca. Pomaga decydować, kiedy użyć `/compact` albo `/clear` zanim Claude zacznie tracić wcześniejsze instrukcje. Szczególnie ważne przy długich sesjach z dużymi plikami.

**`/copy`**
Kopiuje ostatnią odpowiedź Claude do schowka systemowego. `/copy N` skopiuje N-tą odpowiedź od końca, gdy chcesz wcześniejszy fragment. Oszczędza ręczne zaznaczanie tekstu w terminalu.

**`/desktop`**
Przenosi bieżącą sesję z terminala do aplikacji Claude Desktop z graficznym interfejsem. Przydatne gdy zacząłeś w CLI, ale wolisz dokończyć w wygodniejszym środowisku. Kontekst rozmowy jest zachowany.

**`/diff`**
Wyświetla niezatwierdzone zmiany w plikach oraz diffy wprowadzone w poszczególnych turach rozmowy. Pozwala szybko zobaczyć, co Claude zmodyfikował w tej sesji bez wychodzenia do `git diff`. Przydatne do weryfikacji przed commitem.

**`/exit`**
Kończy sesję Claude Code i zamyka proces. Jeśli są niezapisane zmiany, Claude ostrzeże przed wyjściem. Odpowiednik `Ctrl+D` — używaj gdy chcesz jawnie zakończyć pracę.

**`/fast`**
Włącza tryb Fast — Opus z szybszym generowaniem odpowiedzi. Dostajesz moc Opusa bez długiego czekania, kosztem nieco wyższej ceny. Przydatne gdy zależy Ci na czasie, a zadanie wymaga najlepszego modelu.

**`/feedback`**
Otwiera formularz do wysłania opinii o Claude Code bezpośrednio do Anthropic. Możesz zgłosić buga, zaproponować funkcję lub opisać nieoczekiwane zachowanie. Bezpośredni kanał wpływu na rozwój narzędzia.

**`/fix`**
Naprawia błędy w pliku lub zadaniu wskazanym w kontekście. Claude analizuje błąd, identyfikuje przyczynę i wprowadza poprawkę bez Twojego opisywania co jest nie tak. Szybszy niż kopiowanie błędu i pytanie "co z tym zrobić".

**`/help`**
Wyświetla pomoc i listę dostępnych komend z krótkimi opisami. Punkt startowy gdy nie pamiętasz nazwy komendy. Zawiera też skróty klawiszowe i wskazówki do dokumentacji.

**`/history`**
Pokazuje historię poprzednich rozmów z możliwością wznowienia. Możesz wrócić do sesji sprzed kilku dni bez szukania w plikach. Przydatne gdy zacząłeś coś tydzień temu i chcesz kontynuować.

**`/ide`**
Konfiguruje integrację Claude Code z VS Code lub JetBrains. Po podłączeniu Claude widzi aktywny plik w edytorze, kursor i zaznaczony tekst bez kopiowania. Eliminuje kontekstowe przeskoki między terminalem a edytorem.

**`/init`**
Generuje plik `CLAUDE.md` na podstawie analizy projektu. Claude skanuje strukturę katalogów, `package.json`, pliki konfiguracyjne i tworzy instrukcje dla przyszłych sesji. Dobry punkt startowy dla nowego repo — zamiast pisać CLAUDE.md ręcznie.

**`/install-github-app`**
Instaluje aplikację GitHub dla Claude Code w Twoim repozytorium. Po instalacji Claude może działać jako bot komentujący PR-y i Issues bezpośrednio na GitHubie. Przydatne do automatycznego review kodu bez otwierania terminala.

**`/login` / `/logout`**
Loguje lub wylogowuje z konta Anthropic w Claude Code. Potrzebne przy pierwszym uruchomieniu lub przy przełączaniu między kontami (np. prywatne i firmowe). Bez zalogowania Claude nie ma dostępu do API.

**`/mcp`**
Wyświetla i zarządza podłączonymi serwerami MCP (Model Context Protocol). Możesz sprawdzić które serwery są aktywne, dodać nowy lub odłączyć istniejący. W tym projekcie MCP Playwright jest sercem audytów SEO — tutaj widzisz czy jest podłączony.

**`/memory`**
Wyświetla aktywne pliki pamięci pogrupowane wg zakresu (user / project / local) i pozwala edytować wybrany. Możesz zobaczyć co Claude "pamięta" o Tobie i projekcie oraz ręcznie skorygować nieaktualne wpisy. Bezpośrednia kontrola nad tym, co przetrwa między sesjami.

**`/model`**
Zmienia model AI w trakcie sesji bez restartowania. Możesz zacząć na Haiku (szybko i tanio) do eksploracji, a przełączyć na Opus do finałowej implementacji. Zmiana jest natychmiastowa i nie usuwa kontekstu rozmowy.

**`/new`**
Rozpoczyna nową rozmowę w tej samej sesji terminala. Inaczej niż `/clear` — poprzednia rozmowa zostaje w historii i można do niej wrócić przez `/history`. Dobry do oddzielania tematycznie różnych zadań bez zamykania terminala.

**`/onboard`**
Przeprowadza onboarding projektu — Claude analizuje repo i generuje podsumowanie dla nowego członka zespołu. Dostajesz przegląd architektury, kluczowych plików i konwencji bez czytania całego kodu. Przydatne też dla siebie po dłuższej przerwie od projektu.

**`/open`**
Otwiera plik lub zasób w kontekście sesji. Zamiast wklejać ścieżkę do pliku w wiadomości, `/open` ładuje go bezpośrednio do kontekstu. Skraca czas na nawigację gdy wiesz dokładnie co chcesz pokazać Claude.

**`/permissions`**
Wyświetla i zarządza uprawnieniami Claude Code — co może wykonywać bez pytania, a co wymaga zgody. Możesz dodawać lub usuwać wpisy z allowlisty bezpośrednio z terminala. Alternatywa dla ręcznej edycji `settings.json`.

**`/plan`**
Przełącza Claude w tryb planowania — tylko analiza i propozycja kroków, bez modyfikowania plików. Dostajesz szczegółowy plan implementacji który możesz zatwierdzić lub odrzucić przed pierwszą zmianą w kodzie. Chroni przed impulsywnym "no to rób" przy dużych refaktorach.

**`/pr-comments`**
Pobiera komentarze z GitHub Pull Request i wprowadza je do kontekstu sesji. Claude może od razu zaproponować poprawki adresujące każdy komentarz reviewera. Eliminuje ręczne kopiowanie uwag z GitHuba do terminala.

**`/release-notes`**
Generuje informacje o wydaniu na podstawie commitów i zmian w gałęzi. Zamiast pisać changelog ręcznie, dostajesz gotowy draft w formacie Markdown. Przydatne przed każdym tagiem wersji.

**`/resume`**
Wznawia poprzednią sesję z zachowanym kontekstem rozmowy. Możesz zamknąć terminal, wrócić następnego dnia i kontynuować dokładnie od miejsca, gdzie skończyłeś. Działa razem z `/background` — sesja w tle czeka na wznowienie.

**`/review`**
Przeprowadza recenzję kodu w bieżącym PR lub gałęzi. Claude analizuje diff, szuka bugów, problemów bezpieczeństwa i stylistycznych odchyleń od konwencji projektu. Możesz dostać listę uwag zanim wyślesz PR do ludzkiego reviewera.

**`/run`**
Uruchamia komendę lub skrypt w kontekście sesji z przekazaniem wyniku do Claude. Claude widzi output i może od razu zareagować na błędy bez kopiowania ich z terminala. Skraca pętlę: uruchom → błąd → napraw.

**`/schedule`**
Tworzy zaplanowane rutyny działające na serwerach Anthropic według harmonogramu cron. Agent wykonuje się o wyznaczonej godzinie bez Twojego udziału — np. audyt SEO co poniedziałek o 03:00 z raportem gotowym rano. Chmurowe wykonanie, więc działa nawet gdy Twój komputer jest wyłączony.

**`/session`**
Zarządza sesjami — lista aktywnych, przełączanie, usuwanie. Gdy masz kilka równoległych sesji (np. frontend i backend osobno), tu widzisz wszystkie i możesz się między nimi przełączać. Porządek w pracy wielosesyjnej.

**`/settings`**
Otwiera plik `settings.json` do edycji bezpośrednio z sesji. Możesz zmienić uprawnienia, hooki, zmienne środowiskowe bez szukania pliku w systemie. Zmiany wchodzą w życie po restarcie sesji.

**`/share`**
Tworzy link do udostępnienia bieżącej sesji innej osobie. Rozmówca widzi historię rozmowy i może kontynuować od tego miejsca. Przydatne do przekazania kontekstu współpracownikowi lub do debugowania razem z kimś zdalnie.

**`/status`**
Wyświetla status bieżącej sesji — aktywne zadania, zużycie kontekstu, podłączone serwery MCP. Szybki przegląd "co się dzieje" bez przełączania widoków. Przydatne gdy Claude pracuje w tle i chcesz sprawdzić postęp.

**`/statusline`**
Konfiguruje pasek statusu wyświetlany w terminalu podczas sesji. Możesz wybrać co pokazuje — model, zużycie tokenów, aktywne zadania. Personalizacja widoku pod własny workflow.

**`/summarize`**
Podsumowuje bieżącą sesję — co zostało zrobione, jakich narzędzi użyto, co warto zapamiętać. W tym projekcie to własna komenda z `.claude/commands/summarize.md`, dostosowana do kontekstu nauki Claude Code. Dobry rytuał zamykający każdą sesję roboczą.

**`/terminal-setup`**
Konfiguruje terminal pod Claude Code — fonty, kolory, integrację z powłoką. Przeprowadza przez instalację zależności potrzebnych do pełnej funkcjonalności. Jednorazowe ustawienie, które poprawia codzienne doświadczenie pracy.

**`/theme`**
Zmienia motyw kolorystyczny interfejsu Claude Code. Dostępne motywy jasny, ciemny i kilka wariantów. Czysto estetyczna preferencja, ale wpływa na komfort długich sesji.

**`/todos`**
Wyświetla listę zadań przypisanych do bieżącej sesji — zaplanowane kroki, otwarte punkty, ukończone elementy. Claude sam aktualizuje listę w trakcie pracy, więc widzisz co zostało do zrobienia. Alternatywa dla ręcznego śledzenia postępu w notatniku.

**`/ultrareview`**
Uruchamia wieloagentowy przegląd kodu całej gałęzi lub konkretnego PR na GitHubie. Kilka agentów równolegle analizuje różne aspekty: bezpieczeństwo, wydajność, testy, styl. Dostajesz kompleksowy raport, który normalnie wymagałby kilku specjalistycznych reviewerów.

**`/update`**
Aktualizuje Claude Code do najnowszej wersji. Jedna komenda zamiast `npm install -g` z ręcznym szukaniem nazwy pakietu. Warto uruchamiać regularnie — nowe wersje często dodają istotne komendy i poprawiają stabilność.

**`/vim`**
Włącza tryb edycji Vim w polu promptu. Możesz nawigować i edytować długie wieloliniowe prompty skrótami Vim bez wychodzenia z Claude Code. Dla użytkowników Vim eliminuje frustrację ze zwykłego edytora liniowego.

**`/voice`**
Włącza sterowanie głosowe — możesz dyktować prompty zamiast pisać. Przydatne przy długich opisach zadań lub gdy masz zajęte ręce. Funkcjonalność zależy od systemu operacyjnego i dostępności mikrofonu.

---

## Komendy projektu (własne / skille)

**`/seo-audit`**
Przeprowadza pełny audyt SEO strony ntfy.pl przez przeglądarkę Playwright — sprawdza meta tagi, nagłówki, linki, szybkość i dostępność. Wynik zapisuje jako raport Markdown w folderze `reports/` z datą w nazwie pliku. To główna komenda tego projektu nauki.

**`/audit-subpages`**
Uruchamia równoległe audyty wielu podstron ntfy.pl przez osobnych subagentów działających jednocześnie. Zamiast audytować strony kolejno (wolno), kilku agentów pracuje równolegle — audyt 10 podstron trwa tyle co jedna. Wyniki trafiają do osobnych plików raportów.

**`/compare-reports`**
Porównuje dwa raporty SEO z folderu `reports/` i wskazuje co się poprawiło, co się pogorszyło i co nie zmieniło. Pozwala śledzić efekty optymalizacji między sesjami bez ręcznego zestawiania plików. Dobry rytuał po każdej rundzie poprawek SEO.

**`/claude-api`**
Pomaga budować i debugować aplikacje korzystające z Claude API — konfiguracja klienta, prompt caching, obsługa błędów, optymalizacja kosztów. Uwzględnia best practices Anthropic, w tym automatyczne cachowanie promptów. Używaj gdy piszesz skrypty Python wołające API bezpośrednio.

**`/security-review`**
Przeprowadza przegląd bezpieczeństwa zmian w bieżącej gałęzi — szuka podatności OWASP, wycieku sekretów, niebezpiecznych wzorców. Dostajesz listę konkretnych problemów z sugestią poprawki dla każdego. Warto uruchomić przed każdym PR dotyczącym autentykacji lub obsługi danych użytkownika.

**`/update-config`**
Konfiguruje plik `settings.json` — dodaje uprawnienia, ustawia hooki, zmienne środowiskowe, tryb uprawnień. Zamiast ręcznie edytować JSON i zgadywać składnię, opisujesz co chcesz osiągnąć, a Claude wprowadza zmiany. Niezastąpione przy konfiguracji hooków i allowlisty uprawnień.

**`/keybindings-help`**
Pomaga skonfigurować własne skróty klawiszowe w `~/.claude/keybindings.json`. Możesz przypisać dowolne komendy do skrótów lub stworzyć chord bindings (sekwencje klawiszy). Dla osób które dużo pracują z Claude Code — własne skróty znacznie przyspieszają workflow.

**`/fewer-permission-prompts`**
Analizuje transkrypty sesji i na ich podstawie buduje allowlistę uprawnień dopasowaną do Twojego workflow. Zamiast ręcznie dodawać każde nowe narzędzie do `settings.json`, komenda robi to automatycznie na podstawie tego, czego faktycznie używasz. Przydatne po kilku sesjach gdy wiesz już jakich narzędzi potrzebujesz.

**`/loop`**
Uruchamia prompt lub komendę cyklicznie w określonych odstępach czasu. Możesz monitorować status deployu co 5 minut albo uruchamiać audyt SEO co godzinę bez ręcznego wpisywania. Działa w tej samej sesji — w przeciwieństwie do `/schedule`, które działa w chmurze.

---

## Skróty klawiszowe

| Skrót | Działanie |
|---|---|
| `Ctrl+C` | Przerwij zadanie |
| `Ctrl+L` | Wyczyść ekran |
| `Tab` | Autouzupełnianie |
| `↑ / ↓` | Historia komend |
| `Shift+Enter` | Nowa linia bez wysyłania |
| `!<komenda>` | Uruchom komendę powłoki (np. `!git status`) |
| `←` (w pustym prompcie) | Panel agentów |
