# merkaba – mobile layout

Library mapping: **libraryMerkabaId (existing merkabaCollection; screen lib/features/library/presentation/library_merkaba_guide.dart)**  
Source: `src/x1.jpg`  
Mockup: `mockup_merkaba.png`

> Original shows back arrow (left) and home icon (right) (UI chrome). Use the app's own AppBar/back button.

## Section order

1. **eyebrow** — Eyebrow, 11 uppercase white, centered  
   `HIKARU SANCTUARY`
2. **title** — Title, 26-28 serif uppercase gold, centered  
   `THE MERKABA`
3. **tagline** — Tagline 12 uppercase turquoise  
   `ACTIVATION • BALANCE • COHERENCE`
4. **image** — Full-width image `assets/hero_merkaba.webp` (rounded 12, max height ~300)
5. **card** — Bordered card: heading, vector icon, text/bullets  
   `The Merkaba is a sacred geometric field of light that represents the u`
6. **heading** — Section heading gold + gold divider  
   `BENEFITS`
7. **rows** — Vertical list of row-cards (thumb/icon left 90px, label+desc right): icon lotus, icon triangle, icon spiral, icon circles, icon star
8. **heading** — Section heading gold + gold divider  
   `THE FOUR ELEMENTS`
9. **cards** — Cards (4) as **2-column grid**: img element_fire.webp → FIRE, img element_water.webp → WATER, img element_air.webp → AIR, img element_earth.webp → EARTH
10. **heading** — Section heading gold + gold divider  
   `HOW IT WORKS`
11. **paragraph** — Body paragraph  
   `The Merkaba is created by the counter-rotating fields of two tetrahedr`
12. **image** — Full-width image `assets/how_it_works_figure.webp` (rounded 12, max height ~300)
13. **heading** — Section heading gold + gold divider  
   `PRACTICE`
14. **numbered** — Numbered list (gold outlined circle number)
15. **heading** — Section heading gold + gold divider / sub: NOTE: differs from the app session mudras (see conflicts)  
   `THE FIVE MUDRAS`
16. **cards** — Cards (5) as **horizontal scroll, card width ~130**: img mudra_gyan.webp → GYAN, img mudra_apana.webp → APANA, img mudra_prana.webp → PRANA, img mudra_dhyana.webp → DHYANA, img mudra_anjali.webp → ANJALI
17. **heading** — Section heading gold + gold divider  
   `BREATHING 4 – 4 – 6`
18. **numbered** — Numbered list (gold outlined circle number)
19. **card** — Bordered card: heading, image `assets/video_thumb.webp`, text/bullets  
   `5 MIN VIDEO
Breath, mudras and visualization to activate your Merkaba.`

## Global tokens
- Reference frame: 390x844 (iPhone 14), vertical scroll (`CustomScrollView`/`ListView`), horizontal padding 20, section spacing 24.
- Colors: bg `#0A0B17`, gold `#CAA16A` (titles, icons, borders 1px @ 40-60% opacity), turquoise `#2FBFB0` (taglines/accents), indigo `#8FA6D4` (subtitles), text `#FFFFFF` (body 85-90% opacity).
- Typography: serif (e.g. Cormorant Garamond / Cinzel for titles). Title 26-28 uppercase gold letterSpacing 1.5; section heading 17 uppercase gold; subtitle 12 uppercase indigo letterSpacing 2; body 14/1.45 white; card label 12 bold gold; card desc 11-12 white.
- Cards: radius 10-12, fill `#16182C` @ 70%, gold hairline border.
- Icons (`icon:` names in content.json) were drawn line-art gold in a circle: rebuild as vector (Material/Lucide/custom SVG) inside a 34-40px gold outlined circle. Brand logo 光 + "HIKARU LIFT": reuse the app's existing logo asset.
- Images: `assets/` (WebP, native crop resolution — display with BoxFit.cover, rounded 12; circle crops with ClipOval). Optional subtle gold glow behind hero.
- Do not render text as images; all text comes from content.json.

## Conflicts / notes
- MUDRAS: infographic lists Gyan, Apana, Prana, Dhyana, Anjali; app Merkaba session (lib/l10n/app_localizations_*.dart) uses Gyan, Vayu, Lotus, Akash, Anjali. Transcribed verbatim; client must decide which set is correct.
- "GUIDED MERKABA ACTIVATION" card: tappable, navigates to the existing Merkaba guided session.