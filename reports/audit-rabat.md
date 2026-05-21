# Audyt SEO — ntfy.pl/rabat
Data: 2026-05-21 | URL: https://ntfy.pl/rabat

## Executive Summary

Strona `/rabat` (kody rabatowe cateringu dietetycznego Nice To Fit You) jest poprawnie zindeksowana i działa na solidnej infrastrukturze (Cloudflare, HTTPS, HTTP/2). Brakuje jej jednak kilku kluczowych elementów on-page SEO, które obniżają widoczność i CTR.

**Top 5 problemów:**
1. Brak meta description — Google generuje własny snippet
2. Brak tagu canonical — ryzyko duplikacji treści
3. Brak H1 — główny nagłówek to H2 ("Rabaty w NTFY")
4. Brak og:image i og:description — udostępnianie w social media bez obrazu
5. 12 obrazków bez atrybutu alt (w tym 2 duże obrazy parallax)

---

## Technical SEO

**Robots.txt** — OK. `User-agent: * / Disallow:` — brak blokad, sitemap wskazany poprawnie.

**Sitemap** — URL https://ntfy.pl/rabat JEST w `page-sitemap.xml`. Sitemap index zawiera 17 plików (strony, blog, diety, produkty, lokalizacje).

**HTTPS** — HTTP/2 200, certyfikat Cloudflare, HSTS (`max-age=31536000; includeSubDomains`). Brak przekierowań. Bardzo dobry stan.

**Canonical** — BRAK. Yoast SEO Premium jest zainstalowany, ale tag `<link rel="canonical">` nie jest generowany dla tej strony. Wymaga sprawdzenia w ustawieniach Yoast.

**Meta Robots** — `index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1` — poprawny.

**Cache** — `x-cache-status: BYPASS` — strona nie jest cachowana (prawdopodobnie przez personalizację treści per sesja użytkownika).

---

## On-Page SEO

### Title Tag
- Treść: "Kody rabatowe - Nice To Fit You"
- Długość: 34 znaki
- Ocena: ⚠️ Za krótki (optimum 50–60). Proponowane: "Kody rabatowe NTFY — zniżki do 25% na dietę | Nice To Fit You" (63 znaki)

### Meta Description
- Treść: BRAK
- Ocena: ❌ Krytyczny brak. Proponowane: "Aktualne kody rabatowe NTFY — skorzystaj ze zniżki do 25% na catering dietetyczny. Wpisz kod podczas zamawiania i zaoszczędź na diecie pudełkowej." (157 znaków)

### Nagłówki
- H1: ❌ BRAK
- H2: 1 — "Rabaty w NTFY"
- H3: 0
- Tytuły promocji (np. "Promocja dla Nowych Klientów") są renderowane jako klasy CSS `hy-heading-h6` w elementach `<p>`, nie jako znaczniki HTML `<h3>`
- Ocena: ❌ Brak H1 to poważny błąd. Nagłówki promocji powinny być semantycznymi tagami `<h3>`

### Open Graph

| Tag | Wartość | Ocena |
|-----|---------|-------|
| og:title | "Kody rabatowe" | ⚠️ Zbyt krótki, bez marki |
| og:type | "article" | ✅ OK |
| og:url | "https://ntfy.pl/rabat" | ✅ OK |
| og:locale | "pl_PL" | ✅ OK |
| og:site_name | "Nice To Fit You" | ✅ OK |
| og:description | BRAK | ❌ Krytyczny brak |
| og:image | BRAK | ❌ Krytyczny brak |

**Twitter Card** — `twitter:card: summary_large_image` — typ OK, ale brak title/description/image.

### Obrazki i Alt teksty
- Łączna liczba `<img>`: ~99 (z duplikatami lazy+noscript)
- Obrazki bez atrybutu `alt`: ⚠️ 12, w tym:
  - Ikony UI (strzałka rozwijania, ikona kopiowania kodu) — x8 — można `alt=""`
  - 2 duże obrazy parallax (tło kulinarne) — wymagają opisowego alt
  - Ikona krzyżyk powiadomień — x1
- Format: ✅ WebP z fallbackiem PNG
- Lazy loading: ✅ prawidłowa implementacja

### Linki
- Wewnętrzne (unikalne): ~25 — głównie nawigacyjne
- Zewnętrzne: 10 — Facebook (x3), YouTube (x3), Google Play (x2), App Store (x2)
- ⚠️ Brak linków kontekstowych z opisowymi anchorami do powiązanych stron blogowych

### Schema Markup (JSON-LD via Yoast)
- ✅ `WebPage` z datami publikacji/modyfikacji
- ✅ `BreadcrumbList` (Home → Kody rabatowe)
- ✅ `WebSite` z `SearchAction`
- ❌ BRAK: `Offer`/`SpecialOffer` dla poszczególnych kodów rabatowych

---

## Priorytetyzowany plan działania

**Krytyczne — zrób natychmiast:**
1. Dodaj meta description (~157 znaków z keyword + CTA)
2. Dodaj H1 z keyword ("Kody rabatowe NTFY — aktualne zniżki na catering dietetyczny")
3. Dodaj canonical `<link rel="canonical" href="https://ntfy.pl/rabat" />` przez Yoast

**Wysokie — w ciągu tygodnia:**
4. Dodaj og:image (baner 1200×630px) i og:description w Yoast
5. Dodaj alt do 2 dużych obrazów parallax i ikon kopiowania kodu
6. Dodaj schema `Offer` dla każdego kodu rabatowego

**Quick wins:**
7. Rozbuduj title do 55–60 znaków (dodaj "zniżki do 25%")
8. Dodaj 3-4 zdania wprowadzające przed listą kodów (kontekst + keyword)
9. Zmień og:title na "Kody rabatowe NTFY — zniżki na catering dietetyczny"

**Długoterminowe:**
10. Dodaj sekcję FAQ (warunki, jak używać kodów) — szansa na rich results
11. Zbuduj linki wewnętrzne z bloga do /rabat z anchor "kody rabatowe"
12. Monitoruj pozycje dla: "kody rabatowe catering", "kod rabatowy dieta pudełkowa", "NTFY rabat"
