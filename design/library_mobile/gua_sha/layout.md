# gua_sha – mobile layout

Library mapping: **'gua_sha' — recommended NEW LibraryCollection (alt: sub-page of ritualsCollection). Overlaps with rituals/The Hikaru Ritual (origin of Gua Sha, Qi, tool edges, 4 crystals).**  
Source: `src/x2.jpg`  
Mockup: `mockup_gua_sha.png`

> Original shows back arrow and home icon (UI chrome). Use the app's own AppBar/back button.

## Section order

1. **eyebrow** — Eyebrow, 11 uppercase white, centered  
   `HIKARU SANCTUARY`
2. **title** — Title, 26-28 serif uppercase gold, centered  
   `GUA SHA`
3. **tagline** — Tagline 12 uppercase turquoise  
   `HISTORY • BENEFITS • HIKARU LIFT SCULPT`
4. **image** — Full-width image `assets/hero_tray.webp` (rounded 12, max height ~300)
5. **card** — Bordered card: heading, vector icon, text/bullets  
   `Gua sha is a traditional healing technique from Ancient China, with a `
6. **card** — Bordered card: heading, vector icon, text/bullets  
   `Today, facial gua sha is embraced worldwide as a natural, non-invasive`
7. **card** — Bordered card: heading, vector icon, text/bullets  
   `A modern evolution of this ancient practice, the Hikaru Lift Sculpt is`
8. **heading** — Section heading gold + gold divider  
   `KEY BENEFITS`
9. **cards** — Cards (6) as **2-column grid**: icon waves → IMPROVES CIRCULATION, icon drop → SUPPORTS LYMPHATIC DRAINAGE, icon lotus → RELAXES FACIAL TENSION, icon sparkle → ENHANCES SKIN RADIANCE, icon arrows_up → CONTOURS AND LIFTS, icon triangle → BALANCES ENERGY FLOW
10. **heading** — Section heading gold + gold divider  
   `THE HIKARU LIFT SCULPT`
11. **image** — Full-width image `assets/tool_sculpt_labeled.webp` (rounded 12, max height ~300)
12. **rows** — Vertical list of row-cards (thumb/icon left 90px, label+desc right): icon edge, icon edge, icon edge, icon edge
13. **heading** — Section heading gold + gold divider  
   `HOW TO USE`
14. **image** — Full-width image `assets/how_to_face.webp` (max height 200)
15. **numbered** — Numbered list (gold outlined circle number)
16. **heading** — Section heading gold + gold divider  
   `ENHANCE YOUR RITUAL WITH THE FOUR HIKARU CRYSTALS`
17. **cards** — Cards (4) as **2-column grid**: img crystal_white_quartz.webp → WHITE QUARTZ, img crystal_jade.webp → JADE, img crystal_obsidian.webp → OBSIDIAN, img crystal_red_jasper.webp → RED JASPER

## Global tokens
- Reference frame: 390x844 (iPhone 14), vertical scroll (`CustomScrollView`/`ListView`), horizontal padding 20, section spacing 24.
- Colors: bg `#0A0B17`, gold `#CAA16A` (titles, icons, borders 1px @ 40-60% opacity), turquoise `#2FBFB0` (taglines/accents), indigo `#8FA6D4` (subtitles), text `#FFFFFF` (body 85-90% opacity).
- Typography: serif (e.g. Cormorant Garamond / Cinzel for titles). Title 26-28 uppercase gold letterSpacing 1.5; section heading 17 uppercase gold; subtitle 12 uppercase indigo letterSpacing 2; body 14/1.45 white; card label 12 bold gold; card desc 11-12 white.
- Cards: radius 10-12, fill `#16182C` @ 70%, gold hairline border.
- Icons (`icon:` names in content.json) were drawn line-art gold in a circle: rebuild as vector (Material/Lucide/custom SVG) inside a 34-40px gold outlined circle. Brand logo 光 + "HIKARU LIFT": reuse the app's existing logo asset.
- Images: `assets/` (WebP, native crop resolution — display with BoxFit.cover, rounded 12; circle crops with ClipOval). Optional subtle gold glow behind hero.
- Do not render text as images; all text comes from content.json.

## Conflicts / notes
- Overlap with rituals (The Hikaru Ritual): both cover Gua Sha origin, tool parts and the 4 crystals.
- Tool part names differ: here Smooth Edge / Curved Edge / Precision Tip / Rounded Tail; in The Hikaru Ritual: Tail / Wave Side / Soft Side. Product name here "Hikaru Lift Sculpt".
- Crystal keywords differ from crystal pages (e.g. Red Jasper STRENGTH here vs Temple of Vitality; Obsidian PROTECTION).
- "Follow the guided sequence in the app (5–15 minutes)" — needs a real app link/target.