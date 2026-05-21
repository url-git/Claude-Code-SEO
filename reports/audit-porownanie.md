# Porównanie SEO — ntfy.pl
Data: 2026-05-21
Audytowane podstrony: `/` · `/rabat` · `/diety-z-wyborem/longevity`

---

## Tabela porównawcza

| Element SEO | / (strona główna) | /rabat | /diety-z-wyborem/longevity |
|-------------|-------------------|--------|---------------------------|
| **HTTP status** | ✅ 200 | ✅ 200 | ✅ 200 |
| **HTTPS / HSTS** | ✅ | ✅ | ✅ |
| **CDN (Cloudflare)** | ✅ | ✅ | ✅ |
| **Cache** | ⚠️ BYPASS | ⚠️ BYPASS | ⚠️ BYPASS |
| **Robots.txt** | ✅ crawlowalny | ✅ crawlowalny | ✅ crawlowalny |
| **W sitemapie** | ✅ page-sitemap | ✅ page-sitemap | ✅ diet-sitemap |
| **Canonical** | ❌ BRAK | ❌ BRAK | ❌ BRAK |
| **Meta robots** | ✅ index,follow | ✅ index,follow | ✅ index,follow |
| **Title** | ⚠️ 74 zn. (za długi) | ⚠️ 34 zn. (za krótki) | ⚠️ 43 zn. (za krótki) |
| **Meta description** | ✅ 142 zn. | ❌ BRAK | ⚠️ 166 zn. (za długa) |
| **H1** | ❌ BRAK | ❌ BRAK | ✅ "Longevity" |
| **H2** | 11 | 1 | 8 |
| **og:title** | ⚠️ "Strona główna" | ⚠️ "Kody rabatowe" | ⚠️ "Longevity" |
| **og:description** | ✅ | ❌ BRAK | ✅ |
| **og:image** | ✅ | ❌ BRAK | ❌ BRAK |
| **Twitter Card** | ⚠️ niekompletny | ⚠️ niekompletny | ⚠️ niekompletny |
| **Obrazki bez alt** | ⚠️ 5 | ⚠️ 12 | ⚠️ 7 |
| **Puste alt=""** | 16 | 8 | 4 |
| **Linki wewnętrzne** | 54 | ~25 | 61 |
| **Linki zewnętrzne** | 5 | 10 | 5 |
| **Schema WebPage** | ✅ | ✅ | ✅ |
| **Schema FAQPage** | ✅ | ❌ | ❌ |
| **Schema BreadcrumbList** | ❌ | ✅ | ❌ |
| **Schema Offer** | ❌ | ❌ | ❌ |

---

## Problemy wspólne dla wszystkich podstron

### 1. Brak canonical (KRYTYCZNE)
Żadna z trzech stron nie ma tagu `<link rel="canonical">`. Yoast SEO Premium jest zainstalowany — wymaga weryfikacji konfiguracji wtyczki. Brak canonical to ryzyko duplikacji treści i rozproszenia link equity.

**Akcja:** Sprawdź w Yoast → SEO → Search Appearance czy canonical jest włączony globalnie. Dla każdej strony ustaw canonical ręcznie w edytorze (panel Yoast → Advanced).

### 2. Cache BYPASS (WAŻNE)
Wszystkie trzy strony mają `X-Cache-Status: BYPASS` — Cloudflare nie serwuje ich z cache. Może to oznaczać cookies sesyjne lub ustawienia WordPress, które wymuszają dynamiczne generowanie.

**Akcja:** Sprawdź Cloudflare → Caching → Configuration. Rozważ Page Rules wymuszające cache dla podstron bez personalizacji.

### 3. Niekompletne Twitter Card (ŚREDNIE)
Tylko `twitter:card: summary_large_image` bez title/description/image. Udostępnienie w X/Twitter wyświetli pustą kartę.

**Akcja:** W Yoast → Social → Twitter włącz wypełnianie Twitter tags osobno lub połącz z OG tags.

---

## Najpoważniejsze problemy per strona

### Strona główna (/)
- **H1 = brak** — krytyczny brak na stronie głównej; Google ma trudności z określeniem głównego tematu
- **og:title = "Strona główna"** — placeholder, który trafia do wszystkich udostępnień

### /rabat
- **Meta description = brak** — Google będzie generować własny snippet
- **H1 = brak** — strona konwersyjna bez H1 traci ranking potential
- **og:image = brak** — strona z kodami rabatowymi bez zdjęcia w social media

### /diety-z-wyborem/longevity
- **og:image = brak** — strona produktowa bez zdjęcia w OG to stracona szansa na kliknięcia
- **Title zbyt krótki** — 43 znaki; można dodać więcej słów kluczowych

---

## Priorytety naprawy (kolejność)

| Prio | Akcja | Strony | Wpływ |
|------|-------|--------|-------|
| 1 | Dodaj canonical przez Yoast | Wszystkie | Wysoki |
| 2 | Dodaj H1 z keyword | /, /rabat | Wysoki |
| 3 | Dodaj meta description | /rabat | Wysoki |
| 4 | Dodaj og:image | /rabat, /longevity | Średni |
| 5 | Popraw og:title (usunąć placeholder) | /, /rabat, /longevity | Średni |
| 6 | Wyrównaj title do 50–60 znaków | /rabat, /longevity | Średni |
| 7 | Uzupełnij Twitter Card | Wszystkie | Niski |
| 8 | Dodaj alt do obrazków bez atrybutu | Wszystkie | Niski |
| 9 | Sprawdź konfigurację cache Cloudflare | Wszystkie | Niski |
| 10 | Dodaj schema Offer dla /rabat | /rabat | Niski |

---

## Mocne strony serwisu

- ✅ Cloudflare CDN + HTTPS + HSTS — solidna infrastruktura bezpieczeństwa
- ✅ Rozbudowana sitemap (7 map, kategorie: strony, blog, diety, produkty, lokalizacje)
- ✅ robots.txt poprawny, brak blokad
- ✅ Schema FAQPage na stronie głównej (szansa na rich results w Google)
- ✅ Schema BreadcrumbList na /rabat
- ✅ Obrazki w formacie WebP z lazy loading
- ✅ Yoast SEO Premium zainstalowany (możliwości są — trzeba je aktywować)

---

*Raporty szczegółowe:*
- [audit-home.md](audit-home.md) — strona główna
- [audit-rabat.md](audit-rabat.md) — /rabat
- [audit-longevity.md](audit-longevity.md) — /diety-z-wyborem/longevity
