# STEEL/FAIRY AND TYPING CHARTS v1.2.2

A configurable type modernization and type-chart mod for **Gen1Recomp**.

Internal mod ID: `steel_typing`.

> **ANY CHANGES REQUIRE SAVE AND RESTART.**

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

## OFF means no-op

Every option that offers **OFF** follows the same rule:

**OFF does not restore Vanilla and does not overwrite another mod. It performs no change for that option.**

This matters especially with **Crystal 251**. For example, if Crystal already supplies its Gen II Ghost/Psychic, Bug/Poison, Ice/Fire, Steel or Dark behavior, selecting OFF leaves Crystal's value untouched.

Where a selector also offers **Vanilla**, Vanilla is an explicit request to write the original Gen I relationship. It is intentionally different from OFF.

## Crystal 251 compatibility

Crystal 251 is an optional dependency and loads before this mod. This mod then becomes the final layer for the features the player enables here.

Crystal can continue to own:

- its 251-Pokémon content;
- native Johto data;
- Steel and Dark records;
- its wider battle overhaul.

This mod safely patches the merged records afterward rather than duplicate-registering Crystal's Steel or Dark types.

When a type toggle is OFF, Crystal-owned content of that type is not removed. For example, **STEEL TYPE: OFF** does not strip Steel from Crystal's Magnemite/Magneton or other Crystal content.

## Generation VI Fairy Pokémon

With **FAIRY TYPE: ON**, every affected Gen I/II species that exists in the merged Pokédex is changed from its pre-Fairy typing to its Generation VI+ typing.

### Generation I

- Clefairy: Normal -> Fairy
- Clefable: Normal -> Fairy
- Jigglypuff: Normal -> Normal/Fairy
- Wigglytuff: Normal -> Normal/Fairy
- Mr. Mime: Psychic -> Psychic/Fairy

### Generation II / Crystal 251

- Cleffa: Normal -> Fairy
- Igglybuff: Normal -> Normal/Fairy
- Togepi: Normal -> Fairy
- Togetic: Normal/Flying -> Fairy/Flying
- Marill: Water -> Water/Fairy
- Azumarill: Water -> Water/Fairy
- Snubbull: Normal -> Fairy
- Granbull: Normal -> Fairy

The mod only applies a species conversion when the current typing matches the supported pre-Fairy baseline or is already correct. An unrelated custom typing supplied by another mod is not blindly destroyed.

## Fairy move typing

When the following Gen II moves exist, **FAIRY TYPE: ON** changes them from Normal to Fairy:

- Charm
- Moonlight
- Sweet Kiss

With Crystal 251 v0.9.19, the same change is also mirrored into Crystal's exported `crystalMoves` runtime table so Crystal-specific battle systems and the merged move registry agree on the move type.

When FAIRY TYPE is ON, these canonical move IDs are authoritative: if an earlier mod gave Charm, Moonlight or Sweet Kiss another type, this mod changes them to Fairy. Missing moves are not created.

## Steel move typing

Generation II introduced Steel together with its first Steel-type moves; no Generation I move was retroactively converted to Steel. When the following moves exist, **STEEL TYPE: ON** explicitly enforces their Steel typing:

- Iron Tail
- Metal Claw
- Steel Wing
- Snap Trap (Grass in Generation VIII -> Steel from Generation IX)

The first three are the Steel moves available in Generation II/Crystal. No Generation I move was retroactively changed to Steel. Snap Trap is included as forward-compatible historical retyping support if a later content mod provides it.

In standalone Gen I these moves normally do not exist, so nothing is added. With Crystal 251 the three Generation II moves already arrive as Steel, but this mod still applies final authority to both the merged move registry and Crystal's exported runtime move table. If another earlier mod changed one of these move IDs to another type, STEEL TYPE ON changes it back to Steel.

## Complete Fairy type chart

When Fairy is enabled, this mod explicitly writes the complete Fairy attack and defense matrix, including neutral **1x** rows. That makes this mod authoritative over an earlier Fairy implementation instead of only supplying the non-neutral exceptions.

### Fairy attacking

- **2x:** Fighting, Dragon, Dark
- **1/2x:** Fire, Poison, Steel
- **1x:** every other available standard type

### Fairy defending

- **2x damage from:** Poison, Steel
- **1/2x damage from:** Fighting, Bug, Dark
- **0x damage from:** Dragon
- **1x damage from:** every other available standard type

Steel and Dark interactions are written whenever those types exist in the merged registry, including when Crystal owns them.

## Dark type in standalone Gen I

**DARK TYPE** no longer depends on Crystal 251.

When enabled without Crystal, the mod creates Dark as a normal Gen1Recomp type with its proper type chart and Gen II-style type category (`special`).

The original Gen I move **Bite** is changed from Normal to Dark. Bite is the only Generation I move that became Dark when Generation II introduced the type.

Crystal already imports its native Generation II Dark moves. This mod does not recreate Crystal moves that do not exist in standalone Gen I.

### Dark attacking

- **2x:** Psychic, Ghost
- **1/2x:** Fighting, Dark
- **1x:** other Gen I types
- **1/2x vs Steel in Gen II mode**
- **1x vs Steel in Gen VI mode**
- **1/2x vs Fairy when Fairy exists**

### Dark defending

- **2x damage from:** Fighting, Bug, Fairy
- **1/2x damage from:** Ghost, Dark
- **0x damage from:** Psychic
- **1x damage from:** other standard types

## Historical type-chart controls

### Ghost -> Psychic

- **OFF:** do nothing
- **Vanilla:** 0x
- **GEN II:** 2x

### Bug / Poison

- **OFF:** do nothing
- **Vanilla:** Bug -> Poison 2x and Poison -> Bug 2x
- **GEN II:** Bug -> Poison 1/2x and Poison -> Bug 1x

### Ice -> Fire

- **OFF:** do nothing
- **Vanilla:** 1x
- **GEN II:** 1/2x

### Ghost -> Steel

- **OFF:** do nothing
- **GEN II:** 1/2x
- **GEN VI:** 1x

### Dark -> Steel

- **OFF:** do nothing
- **GEN II:** 1/2x
- **GEN VI:** 1x

## Implementation notes

All Pokémon, move and type-chart changes use Gen1Recomp API 2 content registries. Existing records are patched rather than replaced when only one field needs to change.

The manifest declares `CRYSTAL_251` as an optional dependency and uses priority `120`, ensuring Crystal is already available when this compatibility layer runs.

The PRESET UI uses the existing narrow `ManagerState:setOption` integration so a preset can synchronize its eight component settings. Gameplay data itself remains registry-driven.

Both players should use the same configuration for link/online battles.
