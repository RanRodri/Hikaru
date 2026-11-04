# rituals – mobile layout

Library mapping: **libraryRitualsId (ritualsCollection, existing)**  
Source: `src/adjunto.png (duplicate: none in zip)`  
Mockup: `mockup_rituals.png`

## Section order

1. **brand** — Brand header (logo + wordmark), centered  
   `HIKARU LIFT®`
2. **title** — Title, 26-28 serif uppercase gold, centered  
   `THE HIKARU RITUAL`
3. **subtitle** — Subtitle 12 uppercase indigo  
   `AN ANCESTRAL BEAUTY TECHNOLOGY FOR LONGEVITY`
4. **image** — Full-width image `assets/hero_face.webp` (rounded 12, max height ~300)
5. **paragraph** — Body paragraph  
   `A modern evolution of the ancient Gua Sha, uniting Traditional Chinese`
6. **card** — Bordered card: heading, image `assets/origin_sage.webp`, text/bullets  
   `An ancient Chinese therapy with roots in Traditional Chinese Medicine,`
7. **card** — Bordered card: heading, image `assets/kanji_gua_sha.webp`, text/bullets  
   `A PILLAR OF CHINESE MEDICINE`
8. **card** — Bordered card: heading, image `assets/icon_torii.webp`, text/bullets  
   `More than a beauty tool, Gua Sha is a holistic ritual of prevention, l`
9. **heading** — Section heading gold + gold divider / sub: THE NEXT EVOLUTION  
   `HIKARU LIFT®`
10. **image** — Full-width image `assets/tool_photo.webp` (rounded 12, max height ~300)
11. **paragraph** — Body paragraph  
   `A precision sculpting tool and ritual system that elevates the traditi`
12. **heading** — Section heading gold + gold divider / sub: FOR FACE & BODY  
   `A MULTI-FUNCTIONAL DESIGN`
13. **rows** — Vertical list of row-cards (thumb/icon left 90px, label+desc right): tool_tail.webp, tool_wave.webp, tool_soft.webp
14. **heading** — Section heading gold + gold divider / sub: WITH FREQUENCY COMPOSITIONS BY MAESTRO JORGE ALFANO  
   `4 INTERCHANGEABLE CRYSTALS`
15. **cards** — Cards (4) as **2-column grid**: img crystal_obsidian.webp → OBSIDIAN, img crystal_quartz.webp → QUARTZ, img crystal_jade.webp → JADE, img crystal_red_jasper.webp → RED JASPER
16. **card** — Bordered card: heading, image `assets/cymatics.webp`, text/bullets  
   `Original frequency compositions by renowned [UNCERTAIN] musician Jorge`
17. **heading** — Section heading gold + gold divider / sub: THAT ACTIVATES ALL YOUR SENSES  
   `A MULTI-SENSORY RITUAL`
18. **cards** — Cards (7) as **horizontal scroll, card width ~130**: icon eye → SIGHT, icon ear → SOUND, icon hand → TOUCH, icon waves → SCENT, icon gem → CRYSTALS, icon lungs → BREATH, icon lotus → INTENTION
19. **image** — Full-width image `assets/benefits_face.webp` (rounded 12, max height ~300)
20. **heading** — Section heading gold + gold divider  
   `KEY BENEFITS OF THE HIKARU RITUAL`
21. **checklist** — Check list (gold check icon)
22. **heading** — Section heading gold + gold divider  
   `LONGEVITY & YOUTHFUL VITALITY`
23. **cards** — Cards (7) as **2-column grid**: icon face → FIRMER, MORE ELASTIC SKIN, icon sparkle → NATURAL LIFT & DEFINITION, icon waves → HEALTHY CIRCULATION & DETOX, icon lotus → BALANCED ENERGY (QI), icon dna → CELLULAR REGENERATION & REPAIR, icon infinity → LONG-TERM SKIN HEALTH & LONGEVITY, icon sun → A MORE RADIANT, VITAL & YOUTHFUL LOOK

## Global tokens
- Reference frame: 390x844 (iPhone 14), vertical scroll (`CustomScrollView`/`ListView`), horizontal padding 20, section spacing 24.
- Colors: bg `#0A0B17`, gold `#CAA16A` (titles, icons, borders 1px @ 40-60% opacity), turquoise `#2FBFB0` (taglines/accents), indigo `#8FA6D4` (subtitles), text `#FFFFFF` (body 85-90% opacity).
- Typography: serif (e.g. Cormorant Garamond / Cinzel for titles). Title 26-28 uppercase gold letterSpacing 1.5; section heading 17 uppercase gold; subtitle 12 uppercase indigo letterSpacing 2; body 14/1.45 white; card label 12 bold gold; card desc 11-12 white.
- Cards: radius 10-12, fill `#16182C` @ 70%, gold hairline border.
- Icons (`icon:` names in content.json) were drawn line-art gold in a circle: rebuild as vector (Material/Lucide/custom SVG) inside a 34-40px gold outlined circle. Brand logo 光 + "HIKARU LIFT": reuse the app's existing logo asset.
- Images: `assets/` (WebP, native crop resolution — display with BoxFit.cover, rounded 12; circle crops with ClipOval). Optional subtle gold glow behind hero.
- Do not render text as images; all text comes from content.json.
