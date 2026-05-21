# Audyt SEO — ntfy.pl (strona główna)
Data: 2026-05-21
URL: https://ntfy.pl/

## Executive Summary

Strona główna ntfy.pl działa na solidnej infrastrukturze (Cloudflare, HTTPS, HTTP/2), jest poprawnie zindeksowana i posiada rozbudowaną sitemapę. Jednak kilka krytycznych błędów on-page obniża potencjał w wynikach wyszukiwania.

**Top 5 problemów:**
1. ❌ Brak H1 — strona główna nie ma żadnego semantycznego nagłówka H1
2. ❌ Brak tagu canonical — ryzyko duplikacji (www/non-www, http/https)
3. ⚠️ Title zbyt długi — 74 znaki (limit ~60), zostanie ucięty w SERP
4. ⚠️ og:title = "Strona główna" — placeholder Yoast zamiast brandowego tytułu
5. ⚠️ 21 obrazków z problemami alt (5 bez atrybutu, 16 z pustym alt="")

---

## Technical SEO

### Robots.txt
✅ Poprawny. `User-agent: * / Disallow:` — cały serwis crawlowalny. Sitemap wskazany: `https://ntfy.pl/sitemap_index.xml`.

### Sitemap
✅ Rozbudowany sitemap index z 7 map (page, blog, diet, package, category, post, product). Ostatnia modyfikacja strony głównej: 2026-05-21.

### HTTPS & Nagłówki HTTP
✅ HTTP/2 200, certyfikat Cloudflare, HSTS (`max-age=31536000; includeSubDomains`).
⚠️ `X-Cache-Status: BYPASS` — strona główna nie jest cachowana przez Cloudflare. Może to podwyższać TTFB przy dużym ruchu.

### Canonical
❌ BRAK. Brak tagu `<link rel="canonical">` w statycznym HTML. Yoast SEO jest zainstalowany — wymaga sprawdzenia konfiguracji.

### Meta Robots
✅ `index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1` — poprawny.

---

## On-Page SEO

### Title Tag
- Treść: "Nice To Fit You - Dieta z wyborem menu - Wybieraj codziennie z 70 posiłków"
- Długość: 74 znaki
- Ocena: ⚠️ Za długi (limit ~60). Proponowane: "Nice To Fit You — dieta z wyborem menu | 10 diet pudełkowych" (61 znaków)

### Meta Description
- Treść: "Oferta składa się z 10 diet z wyborem menu: niski ig, sport, longevity, hashimoto, wege, keto, dla mam, bez nabiału, less gluten, flexitarian!"
- Długość: 142 znaki
- Ocena: ✅ Dobra długość (optimum 150–160). Zawiera słowa kluczowe i wymienia diety. Można by dodać CTA.

### Nagłówki
- H1: ❌ BRAK (0 tagów H1)
- H2: 11 — "Tydzień dobrych wyborów", "Nasza Oferta", "Twój wybór", "Menu", "na najbliższe dni", "Dlaczego warto"...
- H3: 1
- Ocena: ❌ Krytyczny brak H1. Pierwsze H2 ("Tydzień dobrych wyborów") nie zawiera głównego keywordu.

### Open Graph

| Tag | Wartość | Ocena |
|-----|---------|-------|
| og:title | "Strona główna" | ❌ Placeholder — nie wyświetla nazwy marki ani keywordu |
| og:type | "website" | ✅ |
| og:url | "https://ntfy.pl/" | ✅ |
| og:locale | "pl_PL" | ✅ |
| og:site_name | "Nice To Fit You" | ✅ |
| og:description | (treść meta desc) | ✅ |
| og:image | bg-cf7.jpg (2389×1480) | ✅ Obraz istnieje, właściwy rozmiar |

**Twitter Card** — tylko `twitter:card: summary_large_image`. Brak `twitter:title`, `twitter:description`, `twitter:image`.

### Obrazki i Alt teksty
- Łączna liczba `<img>`: 143
- Bez atrybutu alt: ⚠️ 5
- Z pustym alt="": ⚠️ 16 (prawdopodobnie obrazki dekoracyjne — to akceptowalne, jeśli są dekoracyjne)
- Ocena: Należy dodać opisowy alt do 5 obrazków bez atrybutu. Puste alt="" dla ikon/dekoracji są OK.

### Linki
- Wewnętrzne (unikalne ścieżki): 54
- Zewnętrzne (unikalne): 5
- Ocena: ✅ Dobra liczba linków wewnętrznych. Linki zewnętrzne — warto sprawdzić atrybuty rel.

### Schema Markup
- ✅ `WebPage` — daty publikacji/modyfikacji
- ✅ `FAQPage` — 3 pytania i odpowiedzi (szansa na rich results)
- ❌ Brak `Organization`/`LocalBusiness` — ważne dla brandingu w SERP
- ❌ Brak `BreadcrumbList` na stronie głównej

---

## Priorytetyzowany plan działania

**Krytyczne — zrób natychmiast:**
1. Dodaj H1 z głównym keywordem, np. "Dieta pudełkowa z wyborem menu — Nice To Fit You"
2. Dodaj canonical `<link rel="canonical" href="https://ntfy.pl/" />` przez Yoast
3. Zmień og:title z "Strona główna" na "Nice To Fit You — dieta z wyborem menu"

**Wysokie — w ciągu tygodnia:**
4. Skróć title do max 60 znaków
5. Dodaj alt do 5 obrazków bez atrybutu
6. Dodaj `twitter:title`, `twitter:description`, `twitter:image` w Yoast
7. Dodaj schema `Organization` lub `LocalBusiness`

**Quick wins:**
8. Sprawdź czy cache BYPASS jest zamierzony — jeśli nie, skonfiguruj Cloudflare Page Rules
9. Uzupełnij pierwszy H2 o keyword ("dieta z wyborem menu")

**Długoterminowe:**
10. Monitoruj FAQPage w Google Search Console — rich results mogą zwiększyć CTR
11. Rozważ dodanie schema `BreadcrumbList` na stronie głównej
