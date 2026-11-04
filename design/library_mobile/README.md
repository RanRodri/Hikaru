# Hikaru Lift – Library mobile content pack
Each topic folder: `content.json` (verbatim text, sections in reading order, `typos_fixed`), `layout.md` (390x844 mobile spec), `assets/` (WebP crops), `mockup_<topic>.png` (reference only).
Mapping to `lib/features/library/domain/library_collection.dart`:
- rituals → existing `ritualsCollection` (libraryRitualsId)
- crystal_white_quartz / crystal_obsidian / crystal_red_jasper / crystal_jade → existing `crystalCollections` (whiteQuartz, obsidian, redJasper, jade). Jade = PLACEHOLDER (no infographic).
- meridians, lymphatic, fascia → NEW LibraryCollection ids 'meridians', 'lymphatic', 'fascia' (need new thumbnail images `assets/images/library_<id>.png`; can use assets/hero_face.webp crop).
Text marked [UNCERTAIN] in rituals/content.json must be confirmed by the client (see typos_fixed).
`src/` = original infographics. Scripts: crops.py, content.py, render.py, layout.py.
- merkaba → existing `merkabaCollection` (libraryMerkabaId), screen `library_merkaba_guide.dart`. CONFLICT: infographic mudras Gyan/Apana/Prana/Dhyana/Anjali vs app session Gyan/Vayu/Lotus/Akash/Anjali. "Guided Merkaba Activation" card → links to the existing Merkaba session.
- gua_sha → recommended NEW collection 'gua_sha' (overlaps with rituals; see gua_sha/layout.md conflicts).
