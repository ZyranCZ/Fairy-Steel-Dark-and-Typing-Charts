# Changelog

## 2.0.1 - 2026-08-14

### Gen1Recomp v0.1.86 migration
- Migrated generation detection away from a direct `src.core.GameVersion` require to the public `mod.game` owner with a Gold-only registry capability fallback for headless loading.
- Replaced the process-global `ManagerState.setOption` class patch with the public `mod.options_changed` event and a narrowly isolated v0.1.86 option-store adapter.
- Preserved immediate eight-component PRESET synchronization, CUSTOM switching, reset-default stability, and the existing persisted option keys.
- Expanded the manifest target from the Gold version token to `gen2`, retaining Gold support while using the official generation target.
- Kept the engine version unpinned; compatibility is determined by the Mod API and runtime behavior rather than a hard engine allow-list.
- Added real v0.1.86 headless Loader coverage for Gen 1 and Gen 2 state=`loaded`, sandbox execution, registry effects, OFF behavior, and live preset synchronization.

## 2.0.0 - 2026-08-12

### Pokémon Gold / Generation II support
- Added official Pokémon Gold support while preserving the Red/Blue/Yellow v1.2.2 behavior path.
- The manifest now targets `games: ["gen1", "gold"]`; Gold is a first-class supported game.
- Gold treats Steel and Dark as native content: their type records are never recreated by this mod, preserving native indexes and metadata.
- STEEL TYPE OFF and DARK TYPE OFF remain strict no-ops and therefore never remove native Gold content.
- Explicit Vanilla selectors are generation-relative: on Gold they restore native Generation II Ghost/Psychic, Bug/Poison and Ice/Fire relationships instead of Generation I values.
- Crystal 251 runtime move mirroring remains restricted to Gen 1 and is never used as a Gold content source.

### Fairy modernization on Gold
- Added Fairy modernization for all 13 affected Gen I/II species in Gold's native Pokémon registry.
- Charm, Moonlight and Sweet Kiss become Fairy through the shared move registry while retaining their existing category/effect fields.
- Added the complete Fairy relationship matrix with native Gold Steel/Dark.
- Gold's technical `BIRD` and `CURSE_TYPE` records are explicitly neutral to Fairy; arbitrary third-party custom types remain untouched.
- Generation VI Ghost→Steel and Dark→Steel neutral relationships are available through the GEN VI preset.

### Compatibility and architecture
- Removed the hard `game_version` engine allow-list; future Gen1Recomp versions are not rejected only because their version number changed.
- Preserved `mod.exports.config` semantics and added generation/effective/native-type diagnostics.
- Gold uses the shared `type_chart`, `pokemon`, and `moves` registries rather than a battle-specific compatibility backend.
- Preserved strict OFF ownership behavior so earlier type-chart mods survive wherever this mod is explicitly set to OFF.
- Preserved Crystal 251 interoperability on Red/Blue/Yellow without making Crystal 251 a Gold dependency.

### Validation
- Preserved the original v1.2.2 Gen 1 contract test unchanged.
- Added dedicated Gold fixture coverage for VANILLA, GEN II, GEN VI, CUSTOM, OFF no-op, native type metadata preservation, ownership guards, Fairy species/moves/chart, missing Snap Trap, and Crystal-mirror isolation.
- Added sequential Gold → Gen 1 → Gold coverage and full preset synchronization checks to detect generation-state leakage.

## 1.2.2 - 2026-08-09

### Distribution
- Added native Gen1Recomp GitHub release update metadata.

## 1.2.1 - 2026-08-09

### Move typing authority
- FAIRY TYPE ON now treats Charm, Moonlight and Sweet Kiss as authoritative Fairy move IDs: an earlier non-Fairy type is overwritten instead of skipped.
- STEEL TYPE ON now explicitly enforces Steel typing for Iron Tail, Metal Claw and Steel Wing whenever those Generation II moves exist.
- Added forward-compatible Snap Trap retyping (Grass in Gen VIII -> Steel from Gen IX) when that move is supplied by another content mod.
- Steel move changes are mirrored into Crystal 251's exported `crystalMoves` runtime table just like Fairy move changes.
- Standalone Gen I does not invent Gen II Steel moves; absent move records are safely skipped.
- Added contract coverage for deliberately wrong upstream Fairy/Steel move typings and Crystal registry/runtime consistency.

## 1.2.0 - 2026-08-09

### Dark standalone support
- Added **DARK TYPE** as a full independent toggle.
- GEN II now means Steel + Dark; GEN VI now means Steel + Dark + Fairy.
- Dark can now be created without Crystal 251, using the complete relevant Dark type chart.
- Bite is changed from Normal to Dark when Dark is enabled. Bite is the only Gen I move that became Dark in Gen II.
- Existing CUSTOM installations migrate the new DARK TYPE toggle to OFF and DARK VS STEEL to OFF so updating cannot silently alter a hand-tuned setup.

### Authoritative Fairy compatibility
- Kept all eight affected Gen II species: Cleffa, Igglybuff, Togepi, Togetic, Marill, Azumarill, Snubbull and Granbull.
- Fairy now writes its complete attack/defense matrix, including explicit neutral 1x rows, so an earlier incorrect Fairy chart cannot leak through.
- Fairy relationships with Crystal-owned Steel and Dark are applied after Crystal.
- Charm, Moonlight and Sweet Kiss remain retyped to Fairy.
- With Crystal 251 v0.9.19, Fairy move-type changes are also mirrored into Crystal's exported `crystalMoves` runtime table.

### OFF semantics
- Added a real **OFF** choice to Ghost vs Psychic, Bug vs Poison and Ice vs Fire.
- OFF is now a strict no-op for every selector that offers it; it never writes a Vanilla value over Crystal or another earlier mod.
- Explicit **Vanilla** remains available where restoring the Gen I relationship is intentionally requested.

### Validation
- Expanded contract tests for standalone GEN II/VI, Crystal GEN VI, all affected Johto Fairy species, complete Fairy/Dark matrices, deliberately wrong upstream Fairy rows, Crystal runtime move mirroring, migration behavior and strict OFF/no-op behavior.

## 1.1.0 - 2026-08-09

### Crystal 251 compatibility
- Added `CRYSTAL_251` as an optional dependency and raised priority to 120 so Crystal loads first and this mod applies its supported choices afterward.
- Replaced duplicate Steel/Fairy registrations with registry-safe upserts, preserving Crystal-owned metadata such as Steel's index.
- Made Ghost/Psychic, Bug/Poison, Poison/Bug, and Ice/Fire selections authoritative, including explicit Vanilla restoration after Crystal's Gen II corrections.
- Added **DARK VS STEEL FIX** with OFF / GEN II / GEN VI choices. GEN VI removes both Ghost and Dark resistance from Steel when those types exist.
- Added Fairy/Dark matchups when Crystal's Dark type is present.
- Added Generation VI Fairy typings for Cleffa, Igglybuff, Togepi, Togetic, Marill, Azumarill, Snubbull, and Granbull in addition to the existing Kanto Fairy conversions.
- Added Generation VI Fairy move typing for Charm, Moonlight, and Sweet Kiss when those Crystal moves are present.

## 1.0.0 - 2026-08-08

### First public release
- Added PRESET choices: VANILLA, GEN II (STEEL), GEN VI (STEEL+FAIRY), CUSTOM.
- Added independent Steel and Fairy type toggles.
- Added Ghost vs Steel, Ghost vs Psychic, Bug vs Poison, and Ice vs Fire matchup controls.
- Added automatic PRESET synchronization; changing any component manually switches PRESET to CUSTOM.
- Added Steel typing for Magnemite and Magneton.
- Added Fairy typings for Clefairy, Clefable, Jigglypuff, Wigglytuff, and Mr. Mime.
- Added Gen II and Gen VI type-chart behavior for the supported fixes.
- Added prominent warning: ANY CHANGES REQUIRE SAVE AND RESTART.
