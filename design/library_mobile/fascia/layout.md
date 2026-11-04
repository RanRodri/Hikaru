# fascia – mobile layout

Library mapping: **'fascia' (NEW LibraryCollection)**  
Source: `src/adjunto (2).png`  
Mockup: `mockup_fascia.png`

## Section order

1. **brand** — Brand header (logo + wordmark), centered  
   `HIKARU LIFT`
2. **title** — Title, 26-28 serif uppercase gold, centered  
   `THE FASCIA`
3. **subtitle** — Subtitle 12 uppercase indigo  
   `THE LIVING MATRIX THAT SHAPES YOU`
4. **image** — Full-width image `assets/hero_face.webp` (rounded 12, max height ~300)
5. **paragraph** — Body paragraph (italic)  
   `A dynamic, intelligent network that connects your skin, muscles, and o`
6. **cards** — Cards (5) as **horizontal scroll, card width ~130**: icon lotus → SUPPORTS STRUCTURE & TONE, icon waves → FACILITATES CIRCULATION & DETOX, icon flower → CONNECTS EMOTIONS & BODY, icon bolt → RELEASES TENSION & TRAUMA, icon infinity → RESTORES ELASTICITY & VITALITY
7. **card** — Bordered card: heading, image `assets/fascia_fibers.webp`, text/bullets  
   `Fascia can hold the imprint of unprocessed emotions, chronic stress, a`
8. **heading** — Section heading gold + gold divider  
   `WHEN FASCIA BECOMES RESTRICTED`
9. **checklist** — Check list (gold check icon)
10. **heading** — Section heading gold + gold divider / sub: A MODERN DRIVER OF FACIAL CHANGE  
   `THE “TECH NECK” EFFECT`
11. **image** — Full-width image `assets/tech_neck.webp` (rounded 12, max height ~300)
12. **paragraph** — Body paragraph  
   `The repeated forward head position from phones, computers, and screens`
13. **bullets** — Bullet list (gold dot)
14. **heading** — Section heading gold + gold divider  
   `THE DOUBLE CHIN CONNECTION`
15. **cards** — Cards (2) as **2-column grid**: img chin_congested.webp → CONGESTED FASCIA, img chin_released.webp → RELEASED FASCIA
16. **heading** — Section heading gold + gold divider / sub: RELEASE • REALIGN • LIFT  
   `THE HIKARU RITUAL`
17. **image** — Full-width image `assets/tool_photo.webp` (rounded 12, max height ~300)
18. **paragraph** — Body paragraph (italic)  
   `A holistic ritual that works with fascia, meridians, lymphatic flow, a`
19. **rows** — Vertical list of row-cards (thumb/icon left 90px, label+desc right): icon face, icon waves, icon jaw, icon lotus, icon sparkle

## Global tokens
- Reference frame: 390x844 (iPhone 14), vertical scroll (`CustomScrollView`/`ListView`), horizontal padding 20, section spacing 24.
- Colors: bg `#0A0B17`, gold `#CAA16A` (titles, icons, borders 1px @ 40-60% opacity), turquoise `#2FBFB0` (taglines/accents), indigo `#8FA6D4` (subtitles), text `#FFFFFF` (body 85-90% opacity).
- Typography: serif (e.g. Cormorant Garamond / Cinzel for titles). Title 26-28 uppercase gold letterSpacing 1.5; section heading 17 uppercase gold; subtitle 12 uppercase indigo letterSpacing 2; body 14/1.45 white; card label 12 bold gold; card desc 11-12 white.
- Cards: radius 10-12, fill `#16182C` @ 70%, gold hairline border.
- Icons (`icon:` names in content.json) were drawn line-art gold in a circle: rebuild as vector (Material/Lucide/custom SVG) inside a 34-40px gold outlined circle. Brand logo 光 + "HIKARU LIFT": reuse the app's existing logo asset.
- Images: `assets/` (WebP, native crop resolution — display with BoxFit.cover, rounded 12; circle crops with ClipOval). Optional subtle gold glow behind hero.
- Do not render text as images; all text comes from content.json.
