---
name: summarize
description: Podsumuj sesję Claude Code — co zostało zrobione, jakich narzędzi użyto, czego się nauczyłem. Używaj gdy użytkownik mówi "podsumuj", "co zrobiliśmy", "zapisz sesję", "co się zmieniło".
---

# Podsumuj sesję

Wygeneruj zwięzłe podsumowanie bieżącej sesji Claude Code. Pisz po polsku. Skup się na faktach — co zostało zrobione, a nie jak.

## Format podsumowania

Użyj dokładnie tej struktury:

---

## Sesja — [data w formacie YYYY-MM-DD]

### Co zostało zrobione
Wypunktowana lista najważniejszych zmian wprowadzonych w tej sesji. Każdy punkt to jedna logiczna zmiana (nie jeden plik). Pisz czasem przeszłym, zwięźle.

### Zmienione pliki
Tabela z kolumnami: Plik | Typ zmiany | Opis

Typ zmiany to jedno słowo: `dodano` / `zmieniono` / `usunięto`.

### Użyte narzędzia Claude Code
Wypunktowana lista narzędzi i funkcji Claude Code, które pojawiły się w tej sesji (np. Bash, Edit, Read, Write, MCP Playwright, hooki, komendy slash, agenci). Przy każdym — jedno zdanie co konkretnie zrobiono.

### Czego się nauczyłem
Wypunktowana lista wniosków i nowych koncepcji z tej sesji. Skup się na tym, co było nieoczywiste lub zaskakujące — nie przepisuj dokumentacji. Jeśli coś nie zadziałało i zostało naprawione, wpisz też przyczynę błędu.

### Następne kroki
Maksymalnie 3 punkty — co warto zrobić w kolejnej sesji, jeśli wynika to z bieżącej pracy. Zostaw puste jeśli nic nie wynika.

---

Po wygenerowaniu podsumowania zaproponuj zapisanie go do pliku `reports/session-[data].md`.
