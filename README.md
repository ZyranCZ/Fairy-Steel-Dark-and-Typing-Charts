# STEEL/FAIRY AND TYPING CHARTS

A configurable typing modernization mod for **Gen1Recomp**.

The mod allows you to keep the original Generation I type system, switch to selected Generation II changes, enable Generation VI-style Steel/Fairy typing, or create your own custom combination.

> **ANY CHANGES REQUIRE SAVE AND RESTART**

Typing and type-chart changes are applied when Gen1Recomp loads.
After changing any option, save your settings and restart the game.

**Check out my other mods:**<br>
* [Autofire A/B + Directional Keys Mod](https://github.com/ZyranCZ/autofire)<br>
* [Steel and/or Fairy and/or Typing Charts](https://github.com/ZyranCZ/Steel-and-or-Fairy-and-or-Typing-Charts)<br>
* [Move Category (PHYS/SPEC) Preview](https://github.com/ZyranCZ/Move-Category-Preview)<br>
* [Special Stat Split
](https://github.com/ZyranCZ/Special-Stat-Split/)<br>
* [Enemy HP Visible](https://github.com/ZyranCZ/Enemy-HP)
* [Can Always Escape](https://github.com/ZyranCZ/Can-Always-Escape)
* [Trainers Let You Choose Lead Pokemon](https://github.com/ZyranCZ/Trainers-Let-You-Choose-Lead-Pokemon)
* [Evolve in Battle](https://github.com/ZyranCZ/Evolve-in-Battle)
---

## Features

### Steel Type

Adds the **Steel type** and changes:

* **Magnemite** → Electric / Steel
* **Magneton** → Electric / Steel
<img width="809" height="753" alt="image" src="https://github.com/user-attachments/assets/9bd10700-72f0-45df-8da5-4e8da1c1cf0f" />

The Steel type chart depends on the selected configuration.

### Fairy Type

Optionally adds the **Fairy type** and changes:

* **Clefairy** → Fairy
* **Clefable** → Fairy
* **Jigglypuff** → Normal / Fairy
* **Wigglytuff** → Normal / Fairy
* **Mr. Mime** → Psychic / Fairy
<img width="809" height="753" alt="image" src="https://github.com/user-attachments/assets/3355ed44-22ff-48ed-81b2-d0d2d996a7ef" />

Fairy uses the Generation VI+ type relationships against the types available in Generation I.

---

# Presets

The mod provides four presets:

## VANILLA

Keeps the original Generation I typing system.

* Steel Type: OFF
* Fairy Type: OFF
* Ghost vs Steel Fix: OFF
* Ghost vs Psychic Fix: Vanilla
* Bug vs Poison Fix: Vanilla
* Ice vs Fire Fix: Vanilla

No Pokémon receive Steel or Fairy typing.

---

## GEN II (STEEL)

Applies the major type-system changes introduced with Generation II.

* Steel Type: ON
* Fairy Type: OFF
* Ghost vs Steel Fix: GEN II
* Ghost vs Psychic Fix: GEN II
* Bug vs Poison Fix: GEN II
* Ice vs Fire Fix: GEN II

Magnemite and Magneton become **Electric / Steel**.

Steel uses its original Generation II–V defensive relationships, including resistance to Ghost.
<img width="809" height="753" alt="image" src="https://github.com/user-attachments/assets/90d09e27-5048-49eb-b5f9-5a34b21818ea" />

---

## GEN VI (STEEL+FAIRY)

Applies the Steel/Fairy configuration based on Generation VI.

* Steel Type: ON
* Fairy Type: ON
* Ghost vs Steel Fix: GEN VI
* Ghost vs Psychic Fix: GEN II
* Bug vs Poison Fix: GEN II
* Ice vs Fire Fix: GEN II

Magnemite and Magneton become **Electric / Steel**.

Fairy typing is added to Clefairy, Clefable, Jigglypuff, Wigglytuff and Mr. Mime.

Unlike the Generation II Steel chart, **Steel no longer resists Ghost**.
<img width="809" height="753" alt="image" src="https://github.com/user-attachments/assets/96ebb9a4-134a-40d6-93a7-372cecda26f6" />

---

## CUSTOM
<img width="809" height="753" alt="image" src="https://github.com/user-attachments/assets/e76fe6bf-1acf-4908-b613-cf069c2adb1c" />

Allows every option to be configured independently.

If you manually change any individual setting while using one of the predefined presets, the preset automatically changes to:

**CUSTOM**
Selecting CUSTOM itself does not overwrite your current settings.

---

# Individual Options

## STEEL TYPE

**ON / OFF**

Controls whether the Steel type exists and whether:

* Magnemite becomes Electric / Steel
* Magneton becomes Electric / Steel

---

## FAIRY TYPE

**ON / OFF**

Controls whether the Fairy type exists and whether the following Pokémon receive their later-generation Fairy typing:

| Pokémon    | Typing          |
| ---------- | --------------- |
| Clefairy   | Fairy           |
| Clefable   | Fairy           |
| Jigglypuff | Normal / Fairy  |
| Wigglytuff | Normal / Fairy  |
| Mr. Mime   | Psychic / Fairy |

---

## GHOST VS STEEL FIX

Options:

* OFF
* GEN II
* GEN VI

### GEN II

Ghost-type attacks deal:

**½× damage to Steel**

This matches Steel's defensive typing from Generations II–V.

### GEN VI

Ghost-type attacks deal:

**1× damage to Steel**

Starting with Generation VI, Steel lost its resistance to Ghost.

---

## GHOST VS PSYCHIC FIX

Options:

* Vanilla
* GEN II

### Vanilla

Ghost → Psychic:

**0×**

This preserves the original Generation I behavior.

### GEN II

Ghost → Psychic:

**2×**

This matches Generation II and later.

---

## BUG VS POISON FIX

Options:

* Vanilla
* GEN II

### Vanilla

Generation I:

* Bug → Poison: **2×**
* Poison → Bug: **2×**

### GEN II

Generation II and later:

* Bug → Poison: **½×**
* Poison → Bug: **1×**

---

## ICE VS FIRE FIX

Options:

* Vanilla
* GEN II

### Vanilla

Ice → Fire:

**1×**

### GEN II

Ice → Fire:

**½×**

---

# Steel Type Chart

When Steel is enabled, it behaves as a proper type rather than simply being a label added to Pokémon.

This means dual-type interactions are calculated normally by the Gen1Recomp battle system.

For example, Electric / Steel Magnemite and Magneton can naturally receive combined multipliers such as:

* Ground → **4×**
* Fire → **2×**
* Fighting → **2×**
* Electric → **½×**
* Flying → **¼×**
* Poison → **0×**

The exact Ghost interaction depends on the selected **GHOST VS STEEL FIX** setting.

---

# Fairy Type Chart

When Fairy is enabled, it uses its Generation VI+ relationships against available Generation I types.

Defensively:

* Poison → Fairy: **2×**
* Steel → Fairy: **2×**
* Fighting → Fairy: **½×**
* Bug → Fairy: **½×**
* Dragon → Fairy: **0×**

Offensively:

* Fairy → Fighting: **2×**
* Fairy → Dragon: **2×**
* Fairy → Fire: **½×**
* Fairy → Poison: **½×**
* Fairy → Steel: **½×**

Because Dark does not exist in vanilla Generation I, Dark-type relationships are not added by this mod.

---

# Dual-Type Examples

The new typings interact normally with existing Generation I types.

### Jigglypuff / Wigglytuff

Normal / Fairy

Fighting normally deals 2× damage to Normal, while Fairy resists Fighting:

**2× × ½× = 1×**

So Fighting becomes neutral.

### Mr. Mime

Psychic / Fairy

Both Psychic and Fairy resist Fighting:

**½× × ½× = ¼×**

Mr. Mime therefore takes only quarter damage from Fighting-type attacks.

### Magnemite / Magneton

Electric / Steel

Both Electric and Steel are weak to Ground:

**2× × 2× = 4×**

---

# Important: Restart Required

Gen1Recomp loads Pokémon typing and type-chart registry changes during startup.

Because of this:

> **ANY CHANGES REQUIRE SAVE AND RESTART**

Changing an option updates the configuration immediately, but the actual Pokémon typing and battle type chart will only change after restarting Gen1Recomp.

---

# Compatibility

The mod uses Gen1Recomp's content registry system for Pokémon typings and type-chart relationships.

It is designed to avoid unnecessary changes to the battle engine itself.

The mod also avoids blindly replacing Pokémon typings when another mod has already modified the same species where possible.

As with any gameplay mod that changes Pokémon types or type effectiveness, conflicts may occur with other mods that modify the same Pokémon or type-chart entries.

---

# Version

**1.0.0**

First public release.

---

# Credits

Created for **Gen1Recomp**.

Gen1Recomp:
https://github.com/bryanthaboi/gen1recomp
