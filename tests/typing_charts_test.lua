-- Standalone contract tests for STEEL/FAIRY AND TYPING CHARTS v1.2.2.
-- Run from the mod directory: texlua tests/typing_charts_test.lua

local function deepcopy(v)
  if type(v) ~= "table" then return v end
  local out = {}
  for k, x in pairs(v) do out[k] = deepcopy(x) end
  return out
end

local Registry = {}
Registry.__index = Registry
function Registry.new(seed) return setmetatable({ data = deepcopy(seed or {}) }, Registry) end
function Registry:get(id) return self.data[id] end
function Registry:register(id, value)
  assert(self.data[id] == nil, "duplicate registry id: " .. id)
  self.data[id] = deepcopy(value)
end
function Registry:patch(id, patch)
  assert(self.data[id] ~= nil, "missing registry id: " .. id)
  local record = deepcopy(self.data[id])
  for k, v in pairs(patch) do record[k] = deepcopy(v) end
  self.data[id] = record
end

local GEN1_TYPES = {
  "NORMAL", "FIGHTING", "FLYING", "POISON", "GROUND", "ROCK", "BUG",
  "GHOST", "FIRE", "WATER", "GRASS", "ELECTRIC", "PSYCHIC_TYPE", "ICE",
  "DRAGON",
}

local VANILLA_POKEMON = {
  MAGNEMITE = { types = { "ELECTRIC" } },
  MAGNETON = { types = { "ELECTRIC" } },
  CLEFAIRY = { types = { "NORMAL" } },
  CLEFABLE = { types = { "NORMAL" } },
  JIGGLYPUFF = { types = { "NORMAL" } },
  WIGGLYTUFF = { types = { "NORMAL" } },
  MR_MIME = { types = { "PSYCHIC_TYPE" } },
}

local VANILLA_TYPE_CHART = {
  ["GHOST>PSYCHIC_TYPE"] = { multiplier = 0 },
  ["BUG>POISON"] = { multiplier = 20 },
  ["POISON>BUG"] = { multiplier = 20 },
  ["ICE>FIRE"] = { multiplier = 10 },
}

local VANILLA_MOVES = {
  BITE = { type = "NORMAL" },
}

local CRYSTAL_POKEMON = deepcopy(VANILLA_POKEMON)
CRYSTAL_POKEMON.MAGNEMITE.types = { "ELECTRIC", "STEEL" }
CRYSTAL_POKEMON.MAGNETON.types = { "ELECTRIC", "STEEL" }
CRYSTAL_POKEMON.CLEFFA = { types = { "NORMAL" } }
CRYSTAL_POKEMON.IGGLYBUFF = { types = { "NORMAL" } }
CRYSTAL_POKEMON.TOGEPI = { types = { "NORMAL" } }
CRYSTAL_POKEMON.TOGETIC = { types = { "NORMAL", "FLYING" } }
CRYSTAL_POKEMON.MARILL = { types = { "WATER" } }
CRYSTAL_POKEMON.AZUMARILL = { types = { "WATER" } }
CRYSTAL_POKEMON.SNUBBULL = { types = { "NORMAL" } }
CRYSTAL_POKEMON.GRANBULL = { types = { "NORMAL" } }

local CRYSTAL_TYPE_CHART = deepcopy(VANILLA_TYPE_CHART)
CRYSTAL_TYPE_CHART.STEEL = { name = "STEEL", category = "physical", index = 9 }
CRYSTAL_TYPE_CHART.DARK = { name = "DARK", category = "special", index = 27 }
CRYSTAL_TYPE_CHART["GHOST>PSYCHIC_TYPE"] = { multiplier = 20 }
CRYSTAL_TYPE_CHART["BUG>POISON"] = { multiplier = 5 }
CRYSTAL_TYPE_CHART["POISON>BUG"] = { multiplier = 10 }
CRYSTAL_TYPE_CHART["ICE>FIRE"] = { multiplier = 5 }
CRYSTAL_TYPE_CHART["GHOST>STEEL"] = { multiplier = 5 }
CRYSTAL_TYPE_CHART["DARK>STEEL"] = { multiplier = 5 }
CRYSTAL_TYPE_CHART["NORMAL>STEEL"] = { multiplier = 5 }
CRYSTAL_TYPE_CHART["FIRE>STEEL"] = { multiplier = 20 }
CRYSTAL_TYPE_CHART["STEEL>ICE"] = { multiplier = 20 }
CRYSTAL_TYPE_CHART["DARK>PSYCHIC_TYPE"] = { multiplier = 20 }
CRYSTAL_TYPE_CHART["DARK>GHOST"] = { multiplier = 20 }
CRYSTAL_TYPE_CHART["DARK>FIGHTING"] = { multiplier = 5 }
CRYSTAL_TYPE_CHART["DARK>DARK"] = { multiplier = 5 }
CRYSTAL_TYPE_CHART["FIGHTING>DARK"] = { multiplier = 20 }
CRYSTAL_TYPE_CHART["BUG>DARK"] = { multiplier = 20 }
CRYSTAL_TYPE_CHART["GHOST>DARK"] = { multiplier = 5 }
CRYSTAL_TYPE_CHART["PSYCHIC_TYPE>DARK"] = { multiplier = 0 }

local CRYSTAL_MOVES = deepcopy(VANILLA_MOVES)
CRYSTAL_MOVES.BITE.type = "DARK"
CRYSTAL_MOVES.CHARM = { type = "NORMAL", category = "status" }
CRYSTAL_MOVES.MOONLIGHT = { type = "NORMAL", category = "status" }
CRYSTAL_MOVES.SWEET_KISS = { type = "NORMAL", category = "status" }
CRYSTAL_MOVES.IRON_TAIL = { type = "STEEL", category = "physical" }
CRYSTAL_MOVES.METAL_CLAW = { type = "STEEL", category = "physical" }
CRYSTAL_MOVES.STEEL_WING = { type = "STEEL", category = "physical" }

local ManagerState = {}
function ManagerState:setOption(modId, key, value)
  self.values[modId] = self.values[modId] or {}
  self.values[modId][key] = value
  if self.game and self.game.mods then
    self.game.mods.modOptions = self.game.mods.modOptions or {}
    self.game.mods.modOptions[modId] = self.values[modId]
  end
end
package.preload["src.mods.ManagerState"] = function() return ManagerState end

local function makeMod(values, crystal, seedMutator)
  local defined
  values = deepcopy(values or {})
  local chart = deepcopy(crystal and CRYSTAL_TYPE_CHART or VANILLA_TYPE_CHART)
  local pokemon = deepcopy(crystal and CRYSTAL_POKEMON or VANILLA_POKEMON)
  local moves = deepcopy(crystal and CRYSTAL_MOVES or VANILLA_MOVES)
  if seedMutator then seedMutator(chart, pokemon, moves) end

  local crystalHandle = crystal and {
    id = "CRYSTAL_251",
    version = "0.9.19",
    exports = { crystalMoves = deepcopy(CRYSTAL_MOVES) },
  } or nil

  local mod = {
    content = {
      type_chart = Registry.new(chart),
      pokemon = Registry.new(pokemon),
      moves = Registry.new(moves),
    },
    options = {
      define = function(_, rows) defined = rows end,
      get = function(_, key)
        if values[key] ~= nil then return values[key] end
        for _, row in ipairs(defined or {}) do
          if row.key == key then return row.default end
        end
        return nil
      end,
    },
    log = { info = function() end, warn = function() end },
    exports = {},
    find = function(id)
      if crystal and id == "CRYSTAL_251" then return crystalHandle end
      return nil
    end,
  }
  mod._testCrystalHandle = crystalHandle
  return mod, function() return defined end
end

local function run(values, crystal, seedMutator)
  if ManagerState.__typingChartsPresetSyncOriginal then
    ManagerState.setOption = ManagerState.__typingChartsPresetSyncOriginal
  end
  ManagerState.__typingChartsPresetSyncInstalled = nil
  ManagerState.__typingChartsPresetSyncOriginal = nil

  local mod, getDefined = makeMod(values, crystal, seedMutator)
  local chunk = assert(loadfile("main.lua"))
  chunk()(mod)
  return mod, assert(getDefined())
end

local function assertTyping(mod, id, expected)
  local types = assert(mod.content.pokemon:get(id), "missing species " .. id).types
  assert(#types == #expected, id .. " type count")
  for i = 1, #expected do assert(types[i] == expected[i], id .. " type " .. i) end
end

local function assertMoveType(mod, id, expected)
  local move = assert(mod.content.moves:get(id), "missing move " .. id)
  assert(move.type == expected, id .. " move type: got " .. tostring(move.type))
end

local function assertMatchup(mod, id, multiplier)
  local row = assert(mod.content.type_chart:get(id), "missing " .. id)
  assert(row.multiplier == multiplier, id .. " multiplier: got " .. tostring(row.multiplier))
end

local function assertMissing(mod, id)
  assert(mod.content.type_chart:get(id) == nil, "unexpected registry row " .. id)
end

local function schemaRow(rows, key)
  for _, row in ipairs(rows) do if row.key == key then return row end end
  error("missing schema row " .. key)
end

local function choiceExists(row, value)
  for _, c in ipairs(row.choices or {}) do if c[2] == value then return true end end
  return false
end

local FAIRY_ATTACK = { FIGHTING=20, POISON=5, FIRE=5, DRAGON=20, DARK=20, STEEL=5 }
local FAIRY_DEFENSE = { FIGHTING=5, POISON=20, BUG=5, DRAGON=0, DARK=5, STEEL=20 }
local DARK_ATTACK = { FIGHTING=5, GHOST=20, PSYCHIC_TYPE=20, DARK=5, FAIRY=5 }
local DARK_DEFENSE = { FIGHTING=20, BUG=20, GHOST=5, PSYCHIC_TYPE=0, DARK=5, FAIRY=20, STEEL=10 }

local function assertCompleteFairy(mod, includeSteel, includeDark)
  for _, other in ipairs(GEN1_TYPES) do
    assertMatchup(mod, "FAIRY>" .. other, FAIRY_ATTACK[other] or 10)
    assertMatchup(mod, other .. ">FAIRY", FAIRY_DEFENSE[other] or 10)
  end
  assertMatchup(mod, "FAIRY>FAIRY", 10)
  if includeSteel then
    assertMatchup(mod, "FAIRY>STEEL", 5)
    assertMatchup(mod, "STEEL>FAIRY", 20)
  end
  if includeDark then
    assertMatchup(mod, "FAIRY>DARK", 20)
    assertMatchup(mod, "DARK>FAIRY", 5)
  end
end

local function assertCompleteDarkVsGen1(mod)
  for _, other in ipairs(GEN1_TYPES) do
    assertMatchup(mod, "DARK>" .. other, DARK_ATTACK[other] or 10)
    assertMatchup(mod, other .. ">DARK", DARK_DEFENSE[other] or 10)
  end
  assertMatchup(mod, "DARK>DARK", 5)
end

-- Standalone GEN VI default now includes Steel + Dark + Fairy.
do
  local mod, rows = run({}, false)
  assert(schemaRow(rows, "preset").default == "gen6")
  assert(schemaRow(rows, "steel_type").default == true)
  assert(schemaRow(rows, "dark_type").default == true)
  assert(schemaRow(rows, "fairy_type").default == true)
  assert(mod.content.type_chart:get("STEEL") ~= nil)
  assert(mod.content.type_chart:get("DARK") ~= nil)
  assert(mod.content.type_chart:get("DARK").category == "special")
  assert(mod.content.type_chart:get("FAIRY") ~= nil)
  assertMoveType(mod, "BITE", "DARK")
  assertCompleteDarkVsGen1(mod)
  assertMatchup(mod, "DARK>STEEL", 10)
  assertCompleteFairy(mod, true, true)
  assertMatchup(mod, "GHOST>PSYCHIC_TYPE", 20)
  assertMatchup(mod, "BUG>POISON", 5)
  assertMatchup(mod, "POISON>BUG", 10)
  assertMatchup(mod, "ICE>FIRE", 5)
  assertMatchup(mod, "GHOST>STEEL", 10)
  assertTyping(mod, "MAGNEMITE", { "ELECTRIC", "STEEL" })
  assertTyping(mod, "CLEFAIRY", { "FAIRY" })
end

-- Standalone GEN II also creates Dark and retypes Bite, while Fairy stays absent.
do
  local mod = run({ preset="gen2" }, false)
  assert(mod.content.type_chart:get("STEEL") ~= nil)
  assert(mod.content.type_chart:get("DARK") ~= nil)
  assert(mod.content.type_chart:get("FAIRY") == nil)
  assertMoveType(mod, "BITE", "DARK")
  assertCompleteDarkVsGen1(mod)
  assertMatchup(mod, "DARK>STEEL", 5)
  assertMatchup(mod, "GHOST>STEEL", 5)
end

-- Crystal 251 + GEN VI: preserve Crystal metadata, then modernize all relevant
-- Gen I/II species and the complete Fairy chart after Crystal.
do
  local mod = run({}, true)
  assert(mod.exports.compatibility.crystal251 == true)
  assert(mod.content.type_chart:get("STEEL").index == 9)
  assert(mod.content.type_chart:get("DARK").index == 27)
  assertCompleteFairy(mod, true, true)
  assertMatchup(mod, "GHOST>STEEL", 10)
  assertMatchup(mod, "DARK>STEEL", 10)
  assertMatchup(mod, "GHOST>PSYCHIC_TYPE", 20)
  assertMatchup(mod, "BUG>POISON", 5)
  assertMatchup(mod, "POISON>BUG", 10)
  assertMatchup(mod, "ICE>FIRE", 5)

  assertTyping(mod, "CLEFAIRY", { "FAIRY" })
  assertTyping(mod, "JIGGLYPUFF", { "NORMAL", "FAIRY" })
  assertTyping(mod, "MR_MIME", { "PSYCHIC_TYPE", "FAIRY" })
  assertTyping(mod, "CLEFFA", { "FAIRY" })
  assertTyping(mod, "IGGLYBUFF", { "NORMAL", "FAIRY" })
  assertTyping(mod, "TOGEPI", { "FAIRY" })
  assertTyping(mod, "TOGETIC", { "FAIRY", "FLYING" })
  assertTyping(mod, "MARILL", { "WATER", "FAIRY" })
  assertTyping(mod, "AZUMARILL", { "WATER", "FAIRY" })
  assertTyping(mod, "SNUBBULL", { "FAIRY" })
  assertTyping(mod, "GRANBULL", { "FAIRY" })

  assertMoveType(mod, "BITE", "DARK")
  assertMoveType(mod, "CHARM", "FAIRY")
  assertMoveType(mod, "MOONLIGHT", "FAIRY")
  assertMoveType(mod, "SWEET_KISS", "FAIRY")
  assertMoveType(mod, "IRON_TAIL", "STEEL")
  assertMoveType(mod, "METAL_CLAW", "STEEL")
  assertMoveType(mod, "STEEL_WING", "STEEL")
  assert(mod._testCrystalHandle.exports.crystalMoves.IRON_TAIL.type == "STEEL")
  assert(mod._testCrystalHandle.exports.crystalMoves.METAL_CLAW.type == "STEEL")
  assert(mod._testCrystalHandle.exports.crystalMoves.STEEL_WING.type == "STEEL")
  assert(mod._testCrystalHandle.exports.crystalMoves.CHARM.type == "FAIRY")
  assert(mod._testCrystalHandle.exports.crystalMoves.MOONLIGHT.type == "FAIRY")
  assert(mod._testCrystalHandle.exports.crystalMoves.SWEET_KISS.type == "FAIRY")
end

-- Fairy ON must overwrite even deliberately wrong upstream Fairy rows,
-- including rows that should be neutral 1x.
do
  local mod = run({ preset="custom", steel_type=false, dark_type=false, fairy_type=true,
    ghost_vs_steel="off", dark_vs_steel="off", ghost_vs_psychic="off",
    bug_vs_poison="off", ice_vs_fire="off" }, true,
    function(chart, pokemon, moves)
      chart.FAIRY = { name="FAIRY", category="physical", index=99 }
      chart["FAIRY>WATER"] = { multiplier=20 }
      chart["WATER>FAIRY"] = { multiplier=5 }
      chart["FAIRY>DARK"] = { multiplier=5 }
      chart["DARK>FAIRY"] = { multiplier=20 }
      chart["FAIRY>STEEL"] = { multiplier=20 }
      chart["STEEL>FAIRY"] = { multiplier=5 }
      moves.CHARM.type = "PSYCHIC_TYPE"
      moves.MOONLIGHT.type = "GRASS"
      moves.SWEET_KISS.type = "NORMAL"
    end)
  assert(mod.content.type_chart:get("FAIRY").index == 99) -- preserve metadata
  assertCompleteFairy(mod, true, true)
  assertMoveType(mod, "CHARM", "FAIRY")
  assertMoveType(mod, "MOONLIGHT", "FAIRY")
  assertMoveType(mod, "SWEET_KISS", "FAIRY")
end

-- STEEL TYPE ON has final authority over the canonical Generation II Steel
-- move ids supplied by Crystal or another earlier content mod.
do
  local mod = run({ preset="custom", steel_type=true, dark_type=false, fairy_type=false,
    ghost_vs_steel="off", dark_vs_steel="off", ghost_vs_psychic="off",
    bug_vs_poison="off", ice_vs_fire="off" }, true,
    function(chart, pokemon, moves)
      moves.IRON_TAIL.type = "NORMAL"
      moves.METAL_CLAW.type = "BUG"
      moves.STEEL_WING.type = "FLYING"
    end)
  assertMoveType(mod, "IRON_TAIL", "STEEL")
  assertMoveType(mod, "METAL_CLAW", "STEEL")
  assertMoveType(mod, "STEEL_WING", "STEEL")
  assert(mod._testCrystalHandle.exports.crystalMoves.IRON_TAIL.type == "STEEL")
  assert(mod._testCrystalHandle.exports.crystalMoves.METAL_CLAW.type == "STEEL")
  assert(mod._testCrystalHandle.exports.crystalMoves.STEEL_WING.type == "STEEL")
end

-- A later content mod can supply Snap Trap with its pre-Gen-IX Grass typing;
-- STEEL TYPE ON modernizes the existing record without creating the move.
do
  local mod = run({ preset="custom", steel_type=true, dark_type=false, fairy_type=false,
    ghost_vs_steel="off", dark_vs_steel="off", ghost_vs_psychic="off",
    bug_vs_poison="off", ice_vs_fire="off" }, false,
    function(chart, pokemon, moves)
      moves.SNAP_TRAP = { type="GRASS", category="physical" }
    end)
  assertMoveType(mod, "SNAP_TRAP", "STEEL")
end

-- OFF is also a move-typing no-op: intentionally wrong upstream Fairy/Steel
-- move types are left untouched when the corresponding type toggle is OFF.
do
  local mod = run({ preset="custom", steel_type=false, dark_type=false, fairy_type=false,
    ghost_vs_steel="off", dark_vs_steel="off", ghost_vs_psychic="off",
    bug_vs_poison="off", ice_vs_fire="off" }, true,
    function(chart, pokemon, moves)
      moves.CHARM.type = "PSYCHIC_TYPE"
      moves.IRON_TAIL.type = "NORMAL"
    end)
  assertMoveType(mod, "CHARM", "PSYCHIC_TYPE")
  assertMoveType(mod, "IRON_TAIL", "NORMAL")
end

-- Every OFF selector is a pure no-op over Crystal. It must not write Gen I
-- Vanilla values back over Crystal's native Gen II chart.
do
  local mod, rows = run({
    preset="custom", steel_type=false, dark_type=false, fairy_type=false,
    ghost_vs_steel="off", dark_vs_steel="off", ghost_vs_psychic="off",
    bug_vs_poison="off", ice_vs_fire="off",
  }, true)
  assert(choiceExists(schemaRow(rows, "ghost_vs_psychic"), "off"))
  assert(choiceExists(schemaRow(rows, "bug_vs_poison"), "off"))
  assert(choiceExists(schemaRow(rows, "ice_vs_fire"), "off"))
  assertMatchup(mod, "GHOST>PSYCHIC_TYPE", 20)
  assertMatchup(mod, "BUG>POISON", 5)
  assertMatchup(mod, "POISON>BUG", 10)
  assertMatchup(mod, "ICE>FIRE", 5)
  assertMatchup(mod, "GHOST>STEEL", 5)
  assertMatchup(mod, "DARK>STEEL", 5)
  assertTyping(mod, "MAGNEMITE", { "ELECTRIC", "STEEL" })
  assertTyping(mod, "TOGETIC", { "NORMAL", "FLYING" })
  assertMoveType(mod, "BITE", "DARK")
  assert(mod.content.type_chart:get("FAIRY") == nil)
  assert(mod._testCrystalHandle.exports.crystalMoves.CHARM.type == "NORMAL")
  assert(mod._testCrystalHandle.exports.crystalMoves.MOONLIGHT.type == "NORMAL")
  assert(mod._testCrystalHandle.exports.crystalMoves.SWEET_KISS.type == "NORMAL")
end

-- Explicit Vanilla is still available as a deliberate choice and remains
-- distinct from OFF/no-op.
do
  local mod = run({
    preset="custom", steel_type=false, dark_type=false, fairy_type=false,
    ghost_vs_steel="off", dark_vs_steel="off", ghost_vs_psychic="vanilla",
    bug_vs_poison="vanilla", ice_vs_fire="vanilla",
  }, true)
  assertMatchup(mod, "GHOST>PSYCHIC_TYPE", 0)
  assertMatchup(mod, "BUG>POISON", 20)
  assertMatchup(mod, "POISON>BUG", 20)
  assertMatchup(mod, "ICE>FIRE", 10)
  -- OFF Steel/Dark controls do not remove Crystal-owned types or typings.
  assert(mod.content.type_chart:get("STEEL") ~= nil)
  assert(mod.content.type_chart:get("DARK") ~= nil)
  assertTyping(mod, "MAGNEMITE", { "ELECTRIC", "STEEL" })
end

-- DARK TYPE OFF is also a no-op for an upstream Dark implementation; it must
-- not retype standalone Bite or rewrite upstream Dark chart rows.
do
  local mod = run({
    preset="custom", steel_type=false, dark_type=false, fairy_type=false,
    ghost_vs_steel="off", dark_vs_steel="off", ghost_vs_psychic="off",
    bug_vs_poison="off", ice_vs_fire="off",
  }, false, function(chart)
    chart.DARK = { name="DARK", category="physical", index=77 }
    chart["DARK>PSYCHIC_TYPE"] = { multiplier=5 }
  end)
  assert(mod.content.type_chart:get("DARK").category == "physical")
  assert(mod.content.type_chart:get("DARK").index == 77)
  assertMatchup(mod, "DARK>PSYCHIC_TYPE", 5)
  assertMoveType(mod, "BITE", "NORMAL")
end

-- Existing CUSTOM installs gain neither new Dark type nor Dark/Steel override
-- merely by updating from v1.1.0.
do
  local _, rows = run({
    preset="custom", steel_type=true, fairy_type=true,
    ghost_vs_steel="gen6", ghost_vs_psychic="gen2",
    bug_vs_poison="gen2", ice_vs_fire="gen2",
  }, false)
  assert(schemaRow(rows, "dark_type").default == false)
  assert(schemaRow(rows, "dark_vs_steel").default == "off")
end

-- Built-in preset migration does opt into Dark because Dark is part of both
-- the Gen II and Gen VI rulesets.
do
  local _, gen2Rows = run({ preset="gen2", steel_type=true, fairy_type=false,
    ghost_vs_steel="gen2", dark_vs_steel="gen2", ghost_vs_psychic="gen2",
    bug_vs_poison="gen2", ice_vs_fire="gen2" }, false)
  assert(schemaRow(gen2Rows, "dark_type").default == true)

  local _, vanillaRows = run({ preset="vanilla", steel_type=false, fairy_type=false,
    ghost_vs_steel="off", dark_vs_steel="off", ghost_vs_psychic="vanilla",
    bug_vs_poison="vanilla", ice_vs_fire="vanilla" }, false)
  assert(schemaRow(vanillaRows, "dark_type").default == false)
end

-- UI preset synchronization now includes DARK TYPE as the eighth component.
do
  local _, rows = run({}, false)
  local state = setmetatable({
    values = {},
    game = { mods = { modOptions = {}, optionSchemas = { steel_typing = rows } } },
  }, { __index = ManagerState })

  state:setOption("steel_typing", "preset", "gen2")
  local t = state.values.steel_typing
  assert(t.preset == "gen2")
  assert(t.steel_type == true and t.dark_type == true and t.fairy_type == false)
  assert(t.ghost_vs_steel == "gen2" and t.dark_vs_steel == "gen2")
  assert(t.ghost_vs_psychic == "gen2" and t.bug_vs_poison == "gen2" and t.ice_vs_fire == "gen2")

  state:setOption("steel_typing", "dark_type", false)
  assert(t.dark_type == false)
  assert(t.preset == "custom")
end

print("STEEL/FAIRY AND TYPING CHARTS v1.2.2 contract tests: PASS")
