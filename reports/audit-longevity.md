# Audyt SEO — ntfy.pl/diety-z-wyborem/longevity
Data: 2026-05-21
URL: https://ntfy.pl/diety-z-wyborem/longevity

## Executive Summary

Podstrona diety Longevity jest dobrze zoptymalizowana pod kątem treści i ma poprawny H1. Główne braki to brak canonical, za krótki title, brak og:image oraz zbyt długa meta description.

**Top 5 problemów:**
1. ❌ Brak tagu canonical — ryzyko duplikacji treści
2. ⚠️ Title zbyt krótki — 43 znaki (optimum 50–60), stracona przestrzeń reklamowa
3. ❌ Brak og:image — udostępnianie w mediach społecznościowych bez zdjęcia
4. ⚠️ Meta description zbyt długa — 166 znaków (limit ~160), zostanie ucięta
5. ⚠️ 11 obrazków z problemami alt (7 bez atrybutu, 4 z pustym alt="")

---

## Technical SEO

### Robots.txt
✅ Poprawny. `User-agent: * / Disallow:` — cały serwis crawlowalny.

### Sitemap
✅ URL `https://ntfy.pl/diety-z-wyborem/longevity` jest w `diet-sitemap.xml`. Strona jest prawidłowo zgłoszona do Google.

### HTTPS & Nagłówki HTTP
✅ HTTP/2 200, certyfikat Cloudflare, HSTS (`max-age=31536000; includeSubDomains`).
⚠️ `X-Cache-Status: BYPASS` — strona nie jest cachowana (jak reszta serwisu).

### Canonical
❌ BRAK. Brak tagu `<link rel="canonical">` — analogiczny problem jak na stronie głównej. Konfiguracja Yoast wymaga weryfikacji.

### Meta Robots
✅ `index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1` — poprawny.

---

## On-Page SEO

### Title Tag
- Treść: "Dieta pudełkowa Longevity - Nice To Fit You"
- Długość: 43 znaki
- Ocena: ⚠️ Za krótki (optimum 50–60). Proponowane: "Dieta Longevity — catering pudełkowy dla długowieczności | NTFY" (62 znaki)

### Meta Description
- Treść: "Odkryj dietę pudełkową Longevity, która wspiera regenerację organizmu i młody wygląd. Postaw na antyoksydanty oraz kwasy omega-3 w codziennym menu od Nice To Fit You!"
- Długość: 166 znaków
- Ocena: ⚠️ Nieznacznie za długa (limit ~160). Utnij do: "Odkryj dietę Longevity, która wspiera regenerację i młody wygląd. Antyoksydanty i omega-3 w codziennym menu. Zamów catering od Nice To Fit You!" (145 znaków)

### Nagłówki
- H1: ✅ 1 — "Longevity" (krótki, ale obecny)
- H2: 8 — "Droga do długowieczności i witalności", "Czy wiesz, że…", "Menu", "na najbliższe dni", "Co zyskujesz", "z dietą longevity?"
- H3: 0
- Ocena: H1 obecny — dobrze. Warto rozważyć rozbudowanie H1 o keyword "dieta pudełkowa". H2 "Menu" + "na najbliższe dni" to prawdopodobnie dwa fragmenty jednego nagłówka — sprawdzić w HTML.

### Open Graph

| Tag | Wartość | Ocena |
|-----|---------|-------|
| og:title | "Longevity" | ⚠️ Za krótki, brak marki i kontekstu |
| og:type | "article" | ✅ |
| og:url | "https://ntfy.pl/diety-z-wyborem/longevity" | ✅ |
| og:locale | "pl_PL" | ✅ |
| og:site_name | "Nice To Fit You" | ✅ |
| og:description | (treść meta desc) | ✅ |
| og:image | ❌ BRAK | ❌ Brak zdjęcia — udostępnianie bez grafiki |

**Twitter Card** — tylko `twitter:card: summary_large_image`. Brak `twitter:title`, `twitter:description`, `twitter:image`.

### Obrazki i Alt teksty
- Łączna liczba `<img>`: 114
- Bez atrybutu alt: ⚠️ 7
- Z pustym alt="": 4 (prawdopodobnie dekoracyjne — akceptowalne)
- Format: prawdopodobnie WebP (jak reszta serwisu)
- Ocena: Dodaj opisowy alt do 7 obrazków bez atrybutu — szczególnie do zdjęć posiłków.

### Linki
- Wewnętrzne (unikalne): 61
- Zewnętrzne (unikalne): 5
- Ocena: ✅ Dobra gęstość linków wewnętrznych. Warto sprawdzić anchory linków do tej strony z innych podstron.

### Schema Markup
- ✅ `WebPage` — daty publikacji/modyfikacji
- ❌ Brak `BreadcrumbList` — hierarchia diety w nawigacji nie jest oznakowana strukturalnie
- ❌ Brak `NutritionInformation` lub dedykowanego schematu dla diety — missed opportunity dla rich results

---

## Priorytetyzowany plan działania

**Krytyczne — zrób natychmiast:**
1. Dodaj canonical `<link rel="canonical" href="https://ntfy.pl/diety-z-wyborem/longevity" />` przez Yoast
2. Dodaj og:image (zdjęcie dania longevity, min. 1200×630px) w ustawieniach strony w Yoast

**Wysokie — w ciągu tygodnia:**
3. Rozbuduj title do 55–62 znaków (dodaj "catering" lub "dla długowieczności")
4. Skróć meta description do max 158 znaków
5. Dodaj alt do 7 obrazków bez atrybutu (szczególnie zdjęcia posiłków)
6. Rozbuduj og:title: "Dieta Longevity — catering pudełkowy | Nice To Fit You"

**Quick wins:**
7. Dodaj `twitter:title`, `twitter:description`, `twitter:image` w Yoast
8. Rozważ rozbudowanie H1 z "Longevity" na "Dieta pudełkowa Longevity"

**Długoterminowe:**
9. Dodaj schema `BreadcrumbList` (Home → Diety z wyborem → Longevity)
10. Rozważ schema dla diety (składniki odżywcze, właściwości) — unikalne rich results
11. Zbuduj linki wewnętrzne z artykułów blogowych o długowieczności do tej strony
