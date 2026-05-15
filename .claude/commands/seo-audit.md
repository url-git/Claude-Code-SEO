Przeprowadź pełny audyt SEO strony $AUDIT_URL używając narzędzi Playwright MCP.

Kroki:
1. Otwórz $AUDIT_URL w przeglądarce
2. Pobierz i sprawdź:
   - Title tag (obecność, długość 50–60 znaków)
   - Meta description (obecność, długość 150–160 znaków)
   - Struktura nagłówków: H1 (dokładnie jeden?), H2, H3
   - Open Graph: og:title, og:description, og:image
   - Canonical URL
   - Alt text na wszystkich obrazkach (które go nie mają?)
   - HTTPS (czy strona ładuje się po HTTPS?)
   - Mobile viewport meta tag
   - Linki wewnętrzne i zewnętrzne (podaj liczby)
   - Schema.org / JSON-LD markup (czy jest?)
3. Osobno odwiedź $AUDIT_URL/robots.txt i $AUDIT_URL/sitemap.xml — sprawdź czy istnieją
4. Zrób screenshot strony głównej
5. Zapisz raport do pliku reports/ntfy-pl-YYYY-MM-DD.md (użyj dzisiejszej daty)

Format raportu: Markdown z tabelą wyników (status OK/UWAGA/BŁĄD dla każdego punktu) i sekcją z rekomendacjami.
