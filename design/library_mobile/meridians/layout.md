# meridians – mobile layout

Library mapping: **'meridians' (NEW LibraryCollection)**  
Source: `src/adjunto (3).png`  
Mockup: `mockup_meridians.png`

> Original shows back arrow and "01 / 04" progress (UI chrome, not content). Use the app's own AppBar/back button.

## Section order

1. **brand** — Brand header (logo + wordmark), centered  
   `HIKARU LIFT`
2. **eyebrow** — Eyebrow, 11 uppercase white, centered  
   `TRADITIONAL CHINESE MEDICINE`
3. **title** — Title, 26-28 serif uppercase gold, centered  
   `MERIDIANS & ENERGY FLOW`
4. **tagline** — Tagline 12 uppercase turquoise  
   `RELEASE • RESTORE • REJUVENATE`
5. **paragraph** — Body paragraph (italic)  
   `Balance the flow of Qi to support facial harmony, healthy skin, and lo`
6. **image** — Full-width image `assets/hero_face.webp` (rounded 12, max height ~300)
7. **card** — Bordered card: heading, image `assets/body_meridians.webp`, text/bullets  
   `A network of energy channels that circulates Qi (vital energy) through`
8. **heading** — Section heading gold + gold divider  
   `THE 12 MAIN MERIDIANS`
9. **cards** — Cards (6) as **horizontal scroll, card width ~130**: icon lungs → LUNG (LU), icon intestine → LARGE INTESTINE (LI), icon stomach → STOMACH (ST), icon heart → HEART (HT), icon kidney → KIDNEY (KI), icon liver → LIVER (LR)
10. **paragraph** — Body paragraph  
   `Regulate organ function, detoxify, reduce inflammation and support lon`
11. **heading** — Section heading gold + gold divider / sub: FOR FACIAL PARALYSIS, SKIN HEALTH & LIFT  
   `KEY FACIAL MERIDIANS & POINTS`
12. **image** — Full-width image `assets/face_points_map.webp` (rounded 12, max height ~300)
13. **rows** — Vertical list of row-cards (thumb/icon left 90px, label+desc right): icon lotus, icon waves, icon waves, icon sparkle, icon leaf
14. **card** — Bordered card: heading, image `assets/acupuncture.webp`, text/bullets  
   `Activate specific points along the meridians to release blockages, res`
15. **card** — Bordered card: heading, image `assets/qi_flow.webp`, text/bullets  
   `WHEN Qi IS BLOCKED`
16. **card** — Bordered card: heading, image `assets/icon_hourglass.webp`, text/bullets  
   `A free and balanced flow of Qi and blood nourishes the skin, strengthe`
17. **cta** — Gold pill button, full width minus 40, height 48, dark text  
   `EXPLORE THE MERIDIANS MAP →`

## Global tokens
- Reference frame: 390x844 (iPhone 14), vertical scroll (`CustomScrollView`/`ListView`), horizontal padding 20, section spacing 24.
- Colors: bg `#0A0B17`, gold `#CAA16A` (titles, icons, borders 1px @ 40-60% opacity), turquoise `#2FBFB0` (taglines/accents), indigo `#8FA6D4` (subtitles), text `#FFFFFF` (body 85-90% opacity).
- Typography: serif (e.g. Cormorant Garamond / Cinzel for titles). Title 26-28 uppercase gold letterSpacing 1.5; section heading 17 uppercase gold; subtitle 12 uppercase indigo letterSpacing 2; body 14/1.45 white; card label 12 bold gold; card desc 11-12 white.
- Cards: radius 10-12, fill `#16182C` @ 70%, gold hairline border.
- Icons (`icon:` names in content.json) were drawn line-art gold in a circle: rebuild as vector (Material/Lucide/custom SVG) inside a 34-40px gold outlined circle. Brand logo 光 + "HIKARU LIFT": reuse the app's existing logo asset.
- Images: `assets/` (WebP, native crop resolution — display with BoxFit.cover, rounded 12; circle crops with ClipOval). Optional subtle gold glow behind hero.
- Do not render text as images; all text comes from content.json.
