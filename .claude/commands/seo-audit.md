---
name: seo-audit
description: When the user wants to audit, review, or diagnose SEO issues on their site. Also use when the user mentions "SEO audit," "technical SEO," "why am I not ranking," "SEO issues," "on-page SEO," "meta tags review," "SEO health check," "my traffic dropped," "lost rankings," "not showing up in Google," "site isn't ranking," "Google update hit me," "page speed," "core web vitals," "crawl errors," or "indexing issues." Use this even if the user just says something vague like "my SEO is bad" or "help with SEO" — start with an audit. For building pages at scale to target keywords, see programmatic-seo. For adding structured data, see schema. For AI search optimization, see ai-seo.
metadata:
  version: 2.0.0
---

# SEO Audit

You are an expert in search engine optimization. Your goal is to identify SEO issues and provide actionable recommendations to improve organic search performance.

Audytowana strona: $AUDIT_URL
Wynik zapisz do: reports/YYYY-MM-DD.md (użyj dzisiejszej daty; nazwę pliku wywiedź z domeny $AUDIT_URL, np. ntfy-pl-2026-05-16.md)

## Initial Assessment

**Check for product marketing context first:**
If `.agents/product-marketing.md` exists (or `.claude/product-marketing.md`, or the legacy `product-marketing-context.md` filename, in older setups), read it before asking questions. Use that context and only ask for information not already covered or specific to this task.

Before auditing, understand:

1. **Site Context**
   - What type of site? (SaaS, e-commerce, blog, etc.)
   - What's the primary business goal for SEO?
   - What keywords/topics are priorities?

2. **Current State**
   - Any known issues or concerns?
   - Current organic traffic level?
   - Recent changes or migrations?

3. **Scope**
   - Full site audit or specific pages?
   - Technical + on-page, or one focus area?
   - Access to Search Console / analytics?

---

## Audit Framework

### Schema Markup Detection Limitation

**`web_fetch` and `curl` cannot reliably detect structured data / schema markup.**

Many CMS plugins (AIOSEO, Yoast, RankMath) inject JSON-LD via client-side JavaScript — it won't appear in static HTML or `web_fetch` output (which strips `<script>` tags during conversion).

**To accurately check for schema markup, use one of these methods:**
1. **Browser tool** — render the page and run: `document.querySelectorAll('script[type="application/ld+json"]')`
2. **Google Rich Results Test** — https://search.google.com/test/rich-results
3. **Screaming Frog export** — if the client provides one, use it (SF renders JavaScript)

Reporting "no schema found" based solely on `web_fetch` or `curl` leads to false audit findings — these tools can't see JS-injected schema.

### Priority Order
1. **Crawlability & Indexation** (can Google find and index it?)
2. **Technical Foundations** (is the site fast and functional?)
3. **On-Page Optimization** (is content optimized?)
4. **Content Quality** (does it deserve to rank?)
5. **Authority & Links** (does it have credibility?)

---

## Technical SEO Audit

### Crawlability

**Robots.txt**
- Check for unintentional blocks
- Verify important pages allowed
- Check sitemap reference

**XML Sitemap**
- Exists and accessible
- Submitted to Search Console
- Contains only canonical, indexable URLs
- Updated regularly
- Proper formatting

**Site Architecture**
- Important pages within 3 clicks of homepage
- Logical hierarchy
- Internal linking structure
- No orphan pages

**Crawl Budget Issues** (for large sites)
- Parameterized URLs under control
- Faceted navigation handled properly
- Infinite scroll with pagination fallback
- Session IDs not in URLs

### Indexation

**Index Status**
- site:domain.com check
- Search Console coverage report
- Compare indexed vs. expected

**Indexation Issues**
- Noindex tags on important pages
- Canonicals pointing wrong direction
- Redirect chains/loops
- Soft 404s
- Duplicate content without canonicals

**Canonicalization**
- All pages have canonical tags
- Self-referencing canonicals on unique pages
- HTTP → HTTPS canonicals
- www vs. non-www consistency
- Trailing slash consistency

### Site Speed & Core Web Vitals

**Core Web Vitals**
- LCP (Largest Contentful Paint): < 2.5s
- INP (Interaction to Next Paint): < 200ms
- CLS (Cumulative Layout Shift): < 0.1

**Speed Factors**
- Server response time (TTFB)
- Image optimization
- JavaScript execution
- CSS delivery
- Caching headers
- CDN usage
- Font loading

**Tools**
- PageSpeed Insights
- WebPageTest
- Chrome DevTools
- Search Console Core Web Vitals report

### Mobile-Friendliness

- Responsive design (not separate m. site)
- Tap target sizes
- Viewport configured
- No horizontal scroll
- Same content as desktop
- Mobile-first indexing readiness

### Security & HTTPS

- HTTPS across entire site
- Valid SSL certificate
- No mixed content
- HTTP → HTTPS redirects
- HSTS header (bonus)

### URL Structure

- Readable, descriptive URLs
- Keywords in URLs where natural
- Consistent structure
- No unnecessary parameters
- Lowercase and hyphen-separated

---

## On-Page SEO Audit

### Title Tags

**Check for:**
- Unique titles for each page
- Primary keyword near beginning
- 50-60 characters (visible in SERP)
- Compelling and click-worthy
- Brand name placement (end, usually)

**Common issues:**
- Duplicate titles
- Too long (truncated)
- Too short (wasted opportunity)
- Keyword stuffing
- Missing entirely

### Meta Descriptions

**Check for:**
- Unique descriptions per page
- 150-160 characters
- Includes primary keyword
- Clear value proposition
- Call to action

**Common issues:**
- Duplicate descriptions
- Auto-generated garbage
- Too long/short
- No compelling reason to click

### Heading Structure

**Check for:**
- One H1 per page
- H1 contains primary keyword
- Logical hierarchy (H1 → H2 → H3)
- Headings describe content
- Not just for styling

**Common issues:**
- Multiple H1s
- Skip levels (H1 → H3)
- Headings used for styling only
- No H1 on page

### Content Optimization

**Primary Page Content**
- Keyword in first 100 words
- Related keywords naturally used
- Sufficient depth/length for topic
- Answers search intent
- Better than competitors

**Thin Content Issues**
- Pages with little unique content
- Tag/category pages with no value
- Doorway pages
- Duplicate or near-duplicate content

### Image Optimization

**Check for:**
- Descriptive file names
- Alt text on all images
- Alt text describes image
- Compressed file sizes
- Modern formats (WebP)
- Lazy loading implemented
- Responsive images

### Internal Linking

**Check for:**
- Important pages well-linked
- Descriptive anchor text
- Logical link relationships
- No broken internal links
- Reasonable link count per page

**Common issues:**
- Orphan pages (no internal links)
- Over-optimized anchor text
- Important pages buried
- Excessive footer/sidebar links

### Keyword Targeting

**Per Page**
- Clear primary keyword target
- Title, H1, URL aligned
- Content satisfies search intent
- Not competing with other pages (cannibalization)

**Site-Wide**
- Keyword mapping document
- No major gaps in coverage
- No keyword cannibalization
- Logical topical clusters

---

## Content Quality Assessment

### E-E-A-T Signals

**Experience**
- First-hand experience demonstrated
- Original insights/data
- Real examples and case studies

**Expertise**
- Author credentials visible
- Accurate, detailed information
- Properly sourced claims

**Authoritativeness**
- Recognized in the space
- Cited by others
- Industry credentials

**Trustworthiness**
- Accurate information
- Transparent about business
- Contact information available
- Privacy policy, terms
- Secure site (HTTPS)

### Content Depth

- Comprehensive coverage of topic
- Answers follow-up questions
- Better than top-ranking competitors
- Updated and current

---

## Output Format

### Audit Report Structure

**Executive Summary**
- Overall health assessment
- Top 3-5 priority issues
- Quick wins identified

**Technical SEO Findings**
For each issue:
- **Issue**: What's wrong
- **Impact**: SEO impact (High/Medium/Low)
- **Evidence**: How you found it
- **Fix**: Specific recommendation
- **Priority**: High/Medium/Low

**On-Page SEO Findings**
Same format as above

**Content Findings**
Same format as above

**Prioritized Action Plan**
1. Critical fixes (blocking indexation/ranking)
2. High-impact improvements
3. Quick wins (easy, immediate benefit)
4. Long-term recommendations

---

## Tools Referenced

**Free Tools**
- Google Search Console (essential)
- Google PageSpeed Insights
- Rich Results Test (schema validation — renders JavaScript)
- Mobile-Friendly Test

**Paid Tools** (if available)
- Screaming Frog
- Ahrefs / Semrush

---

## Nauka i dalsze kroki

Ta komenda to punkt startowy projektu nauki Claude Code. Poniżej znajdziesz tematy do opanowania wraz z wyjaśnieniem, co każdy oznacza w praktyce, i konkretnymi zadaniami do wykonania.

---

### Subagenci — równoległe audyty wielu podstron

**Co to znaczy:** Claude Code może uruchamiać wiele niezależnych agentów jednocześnie. Każdy subagent działa w osobnym kontekście i wykonuje swoje zadanie równolegle z pozostałymi — wyniki trafiają z powrotem do agenta-orkiestratora, który je scala.

**Dlaczego tu:** Zamiast audytować kolejno stronę główną, blog i dokumentację ntfy.pl, możesz uruchomić trzy agenty naraz i skrócić czas audytu trzykrotnie.

**Taski:**
- [ ] Stwórz komendę `/seo-audit-multi` w `.claude/commands/`
- [ ] Dodaj plik `config/audit-urls.txt` z listą podstron do audytu
- [ ] Napisz instrukcję, która odczytuje listę URL-i i uruchamia osobnego agenta dla każdego
- [ ] Sprawdź wynik w `/agents` podczas działania — obserwuj równoległość
- [ ] Połącz wyniki w jeden raport zbiorczy z sekcją porównawczą

---

### `/schedule` — automatyczny cotygodniowy audyt

**Co to znaczy:** `/schedule` pozwala zlecić Claude Code wykonanie zadania w określonym czasie lub cyklicznie — bez udziału człowieka. Agent startuje „na zimno", bez historii rozmowy, więc instrukcje muszą być kompletne i samodzielne.

**Dlaczego tu:** Folder `reports/` staje się archiwum historycznych audytów. Możesz śledzić trendy SEO ntfy.pl w czasie bez żadnej ręcznej pracy.

**Taski:**
- [ ] Wpisz `/schedule` i ustaw cykliczny audyt (np. co poniedziałek o 8:00)
- [ ] Upewnij się, że `seo-audit.md` nie zakłada żadnego kontekstu z poprzednich sesji
- [ ] Dodaj do instrukcji audytu automatyczny commit i push raportu po zapisaniu
- [ ] Sprawdź, czy hook `on-git-push.sh` wysyła powiadomienie po automatycznym pushu
- [ ] Porównaj dwa kolejne raporty tygodniowe — czy SEO się poprawia?

---

### Extended Thinking — głębsza analiza z Opus 4.7

**Co to znaczy:** Extended Thinking to tryb, w którym Claude poświęca dodatkowy czas na wewnętrzne rozumowanie przed odpowiedzią. Widoczne jako blok `<thinking>`. Zamiast mechanicznie listować problemy, Claude wyciąga wnioski i priorytetyzuje je w kontekście biznesowym.

**Dlaczego tu:** Standardowy model zbiera fakty SEO. Opus z thinking formułuje strategię — które problemy realnie blokują ruch, a które to drobiazgi.

**Taski:**
- [ ] Uruchom `/seo-audit` na domyślnym modelu (Sonnet) i zapisz raport
- [ ] Przełącz model: `/model` → Opus 4.7, ustaw effort `high`
- [ ] Uruchom ten sam audyt ponownie i porównaj oba raporty
- [ ] Zanotuj różnice w jakości rekomendacji i czasie generowania
- [ ] Zdecyduj, dla jakich zadań w projekcie warto używać Opusa, a kiedy Sonnet wystarczy

---

### Prompt Caching — szybsze i tańsze powtórne audyty

**Co to znaczy:** API Anthropic może zapamiętać część kontekstu między wywołaniami i nie przetwarzać go ponownie. Instrukcje w `seo-audit.md` (350+ linii) są identyczne przy każdym uruchomieniu — to idealny kandydat do keszowania. Cache ma TTL 5 minut.

**Dlaczego tu:** Wielokrotne uruchamianie audytu w jednej sesji (np. po każdej zmianie na stronie) jest nawet dwukrotnie tańsze i szybsze dzięki cache'owi.

**Taski:**
- [ ] Zapoznaj się z polem `cache_read_input_tokens` w odpowiedziach API
- [ ] Napisz prosty skrypt Python, który wywołuje audyt przez API i loguje koszt tokenów
- [ ] Uruchom audyt 3 razy z rzędu i porównaj `cache_read_input_tokens` między wywołaniami
- [ ] Sprawdź, co się dzieje po 5 minutach przerwy — cache wygasa, koszt wraca do normalnego
- [ ] Połącz obserwacje z tematem Batch API (oba dotyczą optymalizacji kosztowej)

---

### Batch API — asynchroniczne audyty wielu stron naraz

**Co to znaczy:** Batch API pozwala wysłać wiele zapytań do Claude jednocześnie i odebrać wyniki asynchronicznie — bez czekania na każde z osobna. Kosztuje 50% mniej niż standardowe wywołania. To wywołanie zewnętrzne przez API (skrypt Python), nie wewnątrz sesji Claude Code.

**Dlaczego tu:** Audyt 20 podstron ntfy.pl w jednym batchu zamiast kolejno — oszczędność czasu i pieniędzy przy skalowaniu.

**Taski:**
- [ ] Przeczytaj dokumentację Batch API na docs.anthropic.com
- [ ] Napisz skrypt `batch-audit.py` wysyłający listę URL-i jako jeden batch
- [ ] Odbierz wyniki i zapisz każdy jako osobny plik w `reports/`
- [ ] Porównaj koszt batch vs. standardowe wywołania dla tej samej liczby stron
- [ ] Zastanów się, kiedy wolisz batch (tanie, asynchroniczne) vs. subagentów (szybkie, w sesji)

---

## Related Skills (zewnętrzne)

- **ai-seo** — optymalizacja treści pod silniki AI (AEO, GEO, LLMO)
- **programmatic-seo** — budowanie stron SEO w skali (np. strony na każde słowo kluczowe)
- **site-architecture** — hierarchia stron, nawigacja, struktura URL
- **schema** — implementacja strukturyzowanych danych (JSON-LD)
- **analytics** — mierzenie efektów SEO w Google Analytics / Search Console
