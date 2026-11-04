# lymphatic – mobile layout

Library mapping: **'lymphatic' (NEW LibraryCollection)**  
Source: `src/adjunto (1).png`  
Mockup: `mockup_lymphatic.png`

## Section order

1. **brand** — Brand header (logo + wordmark), centered  
   `HIKARU LIFT`
2. **title** — Title, 26-28 serif uppercase gold, centered  
   `THE LYMPHATIC SYSTEM`
3. **tagline** — Tagline 12 uppercase turquoise  
   `DETOX • DEPUFF • RENEW`
4. **image** — Full-width image `assets/hero_face.webp` (rounded 12, max height ~300)
5. **paragraph** — Body paragraph (italic)  
   `A vital detox and defense network that moves fluid, removes waste, cal`
6. **cards** — Cards (5) as **horizontal scroll, card width ~130**: icon drop → REMOVES TOXINS & WASTE, icon waves → REDUCES PUFFINESS & FLUID RETENTION, icon lotus → CALMS INFLAMMATION & SENSITIVITY, icon sparkle → SUPPORTS IMMUNITY & SKIN HEALTH, icon infinity → ENHANCES RADIANCE & LONGEVITY
7. **card** — Bordered card: heading, image `assets/sluggish_head.webp`, text/bullets  
   `WHEN LYMPHATIC FLOW BECOMES SLUGGISH`
8. **card** — Bordered card: heading, image `assets/tool_photo.webp`, text/bullets  
   `A holistic ritual that combines intentional sculpting, gentle pressure`
9. **heading** — Section heading gold + gold divider  
   `LYMPHATIC MAP: FACE & NECK`
10. **image** — Full-width image `assets/map_face_neck.webp` (rounded 12, max height ~300)
11. **numbered** — Numbered list (gold outlined circle number)
12. **heading** — Section heading gold + gold divider  
   `LYMPHATIC MAP: BODY`
13. **image** — Full-width image `assets/map_body_figure.webp` (max height 200)
14. **rows** — Vertical list of row-cards (thumb/icon left 90px, label+desc right): body_neck_shoulders.webp, body_underarms.webp, body_abdomen.webp, body_groin.webp, body_legs.webp
15. **heading** — Section heading gold + gold divider / sub: FACE & BODY PROTOCOL  
   `THE HIKARU LYMPHATIC RITUAL`
16. **cards** — Cards (3) as **horizontal scroll, card width ~130**: img ritual_sculpt.webp → SCULPT & GUIDE, img ritual_drain.webp → DRAIN & RELEASE, img ritual_activate.webp → ACTIVATE & RENEW
17. **heading** — Section heading gold + gold divider  
   `VISIBLE & SENSORY RESULTS`
18. **cards** — Cards (5) as **2-column grid**: icon face → A LIGHTER, MORE DEFINED FACE & BODY, icon waves → LESS PUFFINESS (FACE, EYES & BODY), icon sparkle → CLEARER, MORE RADIANT SKIN, icon lotus → A CALMER, BALANCED SYSTEM, icon infinity → LONG-TERM SUPPORT FOR SKIN HEALTH & LONGEVITY

## Global tokens
- Reference frame: 390x844 (iPhone 14), vertical scroll (`CustomScrollView`/`ListView`), horizontal padding 20, section spacing 24.
- Colors: bg `#0A0B17`, gold `#CAA16A` (titles, icons, borders 1px @ 40-60% opacity), turquoise `#2FBFB0` (taglines/accents), indigo `#8FA6D4` (subtitles), text `#FFFFFF` (body 85-90% opacity).
- Typography: serif (e.g. Cormorant Garamond / Cinzel for titles). Title 26-28 uppercase gold letterSpacing 1.5; section heading 17 uppercase gold; subtitle 12 uppercase indigo letterSpacing 2; body 14/1.45 white; card label 12 bold gold; card desc 11-12 white.
- Cards: radius 10-12, fill `#16182C` @ 70%, gold hairline border.
- Icons (`icon:` names in content.json) were drawn line-art gold in a circle: rebuild as vector (Material/Lucide/custom SVG) inside a 34-40px gold outlined circle. Brand logo 光 + "HIKARU LIFT": reuse the app's existing logo asset.
- Images: `assets/` (WebP, native crop resolution — display with BoxFit.cover, rounded 12; circle crops with ClipOval). Optional subtle gold glow behind hero.
- Do not render text as images; all text comes from content.json.
