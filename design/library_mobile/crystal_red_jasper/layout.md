# crystal_red_jasper – mobile layout

Library mapping: **redJasper (existing)**  
Source: `src/adjunto (5).png + duplicate adjunto (7).png (lower res 505x741)`  
Mockup: `mockup_crystal_red_jasper.png`

> Original shows back arrow and "03 / 04" progress (UI chrome). Use the app's own AppBar/back button.

## Section order

1. **brand** — Brand header (logo + wordmark), centered  
   `HIKARU LIFT`
2. **eyebrow** — Eyebrow, 11 uppercase white, centered  
   `THE CRYSTAL SANCTUARY`
3. **title** — Title, 26-28 serif uppercase gold, centered  
   `RED JASPER`
4. **subtitle** — Subtitle 12 uppercase indigo  
   `TEMPLE OF VITALITY`
5. **heading** — Section heading gold + gold divider  
   `THE LIFE FORCE CRYSTAL`
6. **paragraph** — Body paragraph  
   `A powerful, earth-energizing crystal that activates vitality, enduranc`
7. **image** — Full-width image `assets/crystal_photo.webp` (rounded 12, max height ~300)
8. **cards** — Cards (4) as **2-column grid**: icon sun → VITALITY, icon lotus → STRENGTH, icon waves → CIRCULATION, icon sparkle → PRESENCE
9. **card** — Bordered card: heading, image `assets/flower_of_life.webp`, text/bullets  
   `A stabilizing, high-frequency crystal that energizes the body, enhance`
10. **card** — Bordered card: heading, vector icon, text/bullets  
   `Use Red Jasper when you want to increase your energy, motivation and p`
11. **cta** — Gold pill button, full width minus 40, height 48, dark text  
   `SELECT THIS CRYSTAL →`

## Global tokens
- Reference frame: 390x844 (iPhone 14), vertical scroll (`CustomScrollView`/`ListView`), horizontal padding 20, section spacing 24.
- Colors: bg `#0A0B17`, gold `#CAA16A` (titles, icons, borders 1px @ 40-60% opacity), turquoise `#2FBFB0` (taglines/accents), indigo `#8FA6D4` (subtitles), text `#FFFFFF` (body 85-90% opacity).
- Typography: serif (e.g. Cormorant Garamond / Cinzel for titles). Title 26-28 uppercase gold letterSpacing 1.5; section heading 17 uppercase gold; subtitle 12 uppercase indigo letterSpacing 2; body 14/1.45 white; card label 12 bold gold; card desc 11-12 white.
- Cards: radius 10-12, fill `#16182C` @ 70%, gold hairline border.
- Icons (`icon:` names in content.json) were drawn line-art gold in a circle: rebuild as vector (Material/Lucide/custom SVG) inside a 34-40px gold outlined circle. Brand logo 光 + "HIKARU LIFT": reuse the app's existing logo asset.
- Images: `assets/` (WebP, native crop resolution — display with BoxFit.cover, rounded 12; circle crops with ClipOval). Optional subtle gold glow behind hero.
- Do not render text as images; all text comes from content.json.
