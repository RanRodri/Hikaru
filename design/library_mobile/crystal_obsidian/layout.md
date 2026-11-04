# crystal_obsidian – mobile layout

Library mapping: **obsidian (existing)**  
Source: `src/adjunto (6).png`  
Mockup: `mockup_crystal_obsidian.png`

> Original shows back arrow and "02 / 04" progress (UI chrome). Use the app's own AppBar/back button.

## Section order

1. **brand** — Brand header (logo + wordmark), centered  
   `HIKARU LIFT`
2. **eyebrow** — Eyebrow, 11 uppercase white, centered  
   `THE CRYSTAL SANCTUARY`
3. **title** — Title, 26-28 serif uppercase gold, centered  
   `OBSIDIAN`
4. **subtitle** — Subtitle 12 uppercase indigo  
   `THE PSYCHIC GEM`
5. **tagline** — Tagline 12 uppercase turquoise  
   `Releases • Transforms • Renews`
6. **paragraph** — Body paragraph  
   `A powerful psychic crystal that brings to the surface and helps releas`
7. **image** — Full-width image `assets/crystal_photo.webp` (rounded 12, max height ~300)
8. **cards** — Cards (4) as **2-column grid**: icon lotus → EMOTIONAL RELEASE, icon spiral → TRAUMA TRANSFORMATION, icon stones → SKIN BALANCE, icon shield → PROTECTION & GROUNDING
9. **card** — Bordered card: heading, image `assets/flower_of_life.webp`, text/bullets  
   `Obsidian is a deep-clearing crystal that transforms what no longer ser`
10. **card** — Bordered card: heading, vector icon, text/bullets  
   `Use Obsidian when you want to release emotional weight, restore balanc`
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
