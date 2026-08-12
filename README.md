# STEEL/FAIRY AND TYPING CHARTS v2.0.0

A configurable type modernization and historical type-chart mod for **Gen1Recomp**.

Internal mod ID: `steel_typing`.

> **ANY CHANGES REQUIRE SAVE AND RESTART.**

> **Supported games:** Pokémon Red, Blue, Yellow, and Gold. Gold support is generation-aware: native Generation II Steel/Dark mechanics are preserved rather than recreated.

## How the mod behaves by game

### Red / Blue / Yellow

The existing v1.2.2 behavior is preserved. Depending on the selected settings, the mod can add or enforce:

- Steel;
- Dark;
- Fairy;
- Generation II type-chart corrections;
- Generation VI Fairy and Steel relationship changes.

### Pokémon Gold

Gold already contains native Generation II mechanics, including:

- Steel;
- Dark;
- Electric/Steel Magnemite and Magneton;
- Dark-type Bite;
- the Generation II type chart.

This mod therefore **does not recreate or replace Gold's native Steel/Dark type records**. On Gold it acts as a modernization/configuration layer above the native data, primarily adding Fairy and optional Generation VI chart behavior.

## Presets

- **VANILLA**
- **GEN II (STEEL+DARK)**
- **GEN VI (STEEL+DARK+FAIRY)**
- **CUSTOM**

Selecting a built-in preset updates every component option. Manually changing any component switches PRESET to **CUSTOM**.

| Option | VANILLA | GEN II | GEN VI |
|---|---:|---:|---:|
| STEEL TYPE | OFF | ON | ON |
| DARK TYPE | OFF | ON | ON |
| FAIRY TYPE | OFF | OFF | ON |
| GHOST VS STEEL FIX | OFF | GEN II | GEN VI |
| DARK VS STEEL FIX | OFF | GEN II | GEN VI |
| GHOST VS PSYCHIC FIX | Vanilla | GEN II | GEN II |
| BUG VS POISON FIX | Vanilla | GEN II | GEN II |
| ICE VS FIRE FIX | Vanilla | GEN II | GEN II |

**Default preset: GEN VI (STEEL+DARK+FAIRY).**

The stored option matrix is shared by all games. Its **effective meaning is generation-aware**.

### VANILLA on Gold

**VANILLA means the vanilla mechanics of the game currently running.**

- Red / Blue / Yellow: original Generation I relationships.
- Gold: native Generation II relationships.

Therefore VANILLA on Gold never removes Steel/Dark, changes Bite back to Normal, changes Magnemite back to pure Electric, or restores Generation I type-chart bugs.

### GEN II on Gold

On a clean Gold installation, GEN II is intentionally very close to native Gold. Its value is that it explicitly enforces the selected canonical Generation II relationships if an earlier mod changed them.

### GEN VI on Gold

This is the main Gold modernization preset:

- native Gold Steel remains native;
- native Gold Dark remains native;
- Fairy is added;
- affected Gen I/II Pokémon receive Generation VI Fairy typings;
- Charm, Moonlight and Sweet Kiss become Fairy;
- Ghost -> Steel becomes 1x;
- Dark -> Steel becomes 1x;
- the remaining selected historical corrections stay at Generation II values.

## OFF means strict no-op

Every option that offers **OFF** follows the same rule:

**OFF writes nothing for that option.**

It does not restore Vanilla and it does not overwrite another mod.

This is especially important on Gold:

- **STEEL TYPE: OFF** does **not** remove Gold's native Steel;
- **DARK TYPE: OFF** does **not** remove Gold's native Dark;
- Magnemite/Magneton remain Electric/Steel;
- Bite remains Dark;
- native Gold Steel moves and matchups remain available.

Where a selector also offers **Vanilla**, Vanilla is an explicit request to restore the native relationship of the **currently running game**. It is intentionally different from OFF.

## Generation VI Fairy Pokémon

With **FAIRY TYPE: ON**, the mod converts supported pre-Fairy typings to their Generation VI+ typings.

### Generation I

- Clefairy: Normal -> Fairy
- Clefable: Normal -> Fairy
- Jigglypuff: Normal -> Normal/Fairy
- Wigglytuff: Normal -> Normal/Fairy
- Mr. Mime: Psychic -> Psychic/Fairy

### Generation II

- Cleffa: Normal -> Fairy
- Igglybuff: Normal -> Normal/Fairy
- Togepi: Normal -> Fairy
- Togetic: Normal/Flying -> Fairy/Flying
- Marill: Water -> Water/Fairy
- Azumarill: Water -> Water/Fairy
- Snubbull: Normal -> Fairy
- Granbull: Normal -> Fairy

On Gold these species are patched directly in the native Gold Pokémon registry; **Crystal 251 is not required**.

The mod only applies a species conversion when the current typing matches a supported pre-Fairy baseline or is already correct. If another mod supplied an unrelated custom typing, the record is left unchanged and a warning is logged.

## Fairy move typing

With **FAIRY TYPE: ON**:

- Charm -> Fairy
- Moonlight -> Fairy
- Sweet Kiss -> Fairy

Only the move's `type` field is changed. Their status category and effects are left untouched.

On the Gen 1 + Crystal 251 path, enabled Fairy changes are also mirrored into Crystal's exported runtime move table so the Crystal battle route stays synchronized. **That mirror is never used on Gold.**

## Steel move typing

With **STEEL TYPE: ON**, the mod authoritatively enforces Steel on existing canonical Steel move records:

- Iron Tail
- Metal Claw
- Steel Wing
- Snap Trap, if another content mod supplies it

Missing moves are never created. Gold's native Steel type record itself is never reconstructed or replaced.

## Dark / Bite

On Red / Blue / Yellow, **DARK TYPE: ON** can add Dark as a normal Gen1Recomp type and changes Bite from Normal to Dark.

On Gold, Dark and Bite are already native. DARK TYPE ON may explicitly restore supported canonical relationships after an earlier mod, but it does not recreate the Dark type record.

Bite keeps an ownership guard: if another mod gave Bite an unrelated custom type, this mod does not blindly overwrite it.

## Complete Fairy type chart

When Fairy is enabled, the mod writes the complete canonical Fairy attack/defense matrix for the standard types.

### Fairy attacking

- **2x:** Fighting, Dragon, Dark
- **1/2x:** Fire, Poison, Steel
- **1x:** other standard types

### Fairy defending

- **2x damage from:** Poison, Steel
- **1/2x damage from:** Fighting, Bug, Dark
- **0x damage from:** Dragon
- **1x damage from:** other standard types

Gold also carries native technical/legacy type records `BIRD` and `CURSE_TYPE`; Fairy is explicitly neutral to those two. Arbitrary third-party custom types are not assigned a Fairy relationship automatically.

## Historical type-chart controls

### Ghost -> Psychic

- **OFF:** do nothing
- **Vanilla:** Gen I = 0x; Gold = 2x
- **GEN II:** 2x

### Bug / Poison

- **OFF:** do nothing
- **Vanilla:** Gen I = Bug -> Poison 2x and Poison -> Bug 2x; Gold = 1/2x and 1x
- **GEN II:** Bug -> Poison 1/2x and Poison -> Bug 1x

### Ice -> Fire

- **OFF:** do nothing
- **Vanilla:** Gen I = 1x; Gold = 1/2x
- **GEN II:** 1/2x

### Ghost -> Steel

- **OFF:** do nothing
- **GEN II:** 1/2x
- **GEN VI:** 1x

### Dark -> Steel

- **OFF:** do nothing
- **GEN II:** 1/2x
- **GEN VI:** 1x

## Crystal 251 compatibility

`CRYSTAL_251` remains an optional dependency for the **Gen 1** path.

On Red / Blue / Yellow, Crystal 251 may provide Johto content, Steel/Dark records and a parallel runtime move table. This mod keeps the existing v1.2.2 interoperability behavior there.

On Gold, Crystal 251 is **not** a content source. Gold already owns its 251 Pokémon, native Steel/Dark and Generation II type chart, so the Crystal move mirror and Crystal content bridge are deliberately disabled for the Gold policy.

## Diagnostics / public exports

Existing v1.2.2 exports keep their meaning, especially `mod.exports.config`, which remains the requested/persisted settings view.

The Gold port adds diagnostic exports without changing the old contract:

- `mod.exports.generation`
- `mod.exports.effectiveConfig`
- `mod.exports.nativeTypes`
- `mod.exports.compatibility.crystal251Relevant`

These distinguish requested settings from native/effective generation behavior.

## Implementation notes

Pokémon, move and type-chart gameplay changes use Gen1Recomp API 2 content registries. Gold generation detection comes from runtime/game identity, never from detecting whether Steel or Dark happens to exist.

The PRESET UI retains the existing narrow `ManagerState:setOption` integration because the current public `mod.options` surface provides definition/read access but not aggregate writes.

The manifest intentionally has **no engine-version allow-list**. A future Gen1Recomp version is not rejected merely because its version number changed; compatibility is handled by actual behavior/testing instead.

`affects_link = true` remains enabled because typing and type-chart changes affect battle mechanics. Both players should use the same configuration for link/online battles.
