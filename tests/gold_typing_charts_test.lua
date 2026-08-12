-- Gold/Generation II contract tests for STEEL/FAIRY AND TYPING CHARTS v2.0.0.
-- Covers the generation-aware Gen 1 + Gold behavior contract.
-- Run from the mod directory: texlua tests/gold_typing_charts_test.lua

local function deepcopy(v)
  if type(v) ~= "table" then return v end
  local out = {}
  for k, x in pairs(v) do out[k] = deepcopy(x) end
  return out
end

local function deepEqual(a, b)
  if type(a) ~= type(b) then return false end
  if type(a) ~= "table" then return a == b end
  for k, v in pairs(a) do if not deepEqual(v, b[k]) then return false end end
  for k in pairs(b) do if a[k] == nil then return false end end
  return true
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

local GOLD_TYPE_CHART = {}
local physical = {
  NORMAL=true, FIGHTING=true, FLYING=true, POISON=true, GROUND=true,
  ROCK=true, BUG=true, GHOST=true, STEEL=true, BIRD=true,
}
local typeOrder = {
  "NORMAL", "FIGHTING", "FLYING", "POISON", "GROUND", "ROCK", "BUG",
  "GHOST", "FIRE", "WATER", "GRASS", "ELECTRIC", "PSYCHIC_TYPE", "ICE",
  "DRAGON", "STEEL", "DARK", "BIRD", "CURSE_TYPE",
}
for i, id in ipairs(typeOrder) do
  GOLD_TYPE_CHART[id] = {
    name = id == "PSYCHIC_TYPE" and "PSYCHIC" or id,
    category = physical[id] and "physical" or "special",
    index = 100 + i, -- sentinel native metadata: the mod must preserve it
    nativeTag = "gold:" .. id,
  }
end

-- Native Generation II relationships relevant to this mod.
GOLD_TYPE_CHART["GHOST>PSYCHIC_TYPE"] = { multiplier = 20 }
GOLD_TYPE_CHART["BUG>POISON"] = { multiplier = 5 }
GOLD_TYPE_CHART["POISON>BUG"] = { multiplier = 10 }
GOLD_TYPE_CHART["ICE>FIRE"] = { multiplier = 5 }
GOLD_TYPE_CHART["GHOST>STEEL"] = { multiplier = 5 }
GOLD_TYPE_CHART["DARK>STEEL"] = { multiplier = 5 }
GOLD_TYPE_CHART["NORMAL>STEEL"] = { multiplier = 5 }
GOLD_TYPE_CHART["FIRE>STEEL"] = { multiplier = 20 }
GOLD_TYPE_CHART["STEEL>ICE"] = { multiplier = 20 }
GOLD_TYPE_CHART["DARK>PSYCHIC_TYPE"] = { multiplier = 20 }
GOLD_TYPE_CHART["DARK>GHOST"] = { multiplier = 20 }
GOLD_TYPE_CHART["DARK>FIGHTING"] = { multiplier = 5 }
GOLD_TYPE_CHART["DARK>DARK"] = { multiplier = 5 }
GOLD_TYPE_CHART["FIGHTING>DARK"] = { multiplier = 20 }
GOLD_TYPE_CHART["BUG>DARK"] = { multiplier = 20 }
GOLD_TYPE_CHART["GHOST>DARK"] = { multiplier = 5 }
GOLD_TYPE_CHART["PSYCHIC_TYPE>DARK"] = { multiplier = 0 }

local GOLD_POKEMON = {
  MAGNEMITE = { types = { "ELECTRIC", "STEEL" } },
  MAGNETON = { types = { "ELECTRIC", "STEEL" } },
  CLEFAIRY = { types = { "NORMAL" } },
  CLEFABLE = { types = { "NORMAL" } },
  JIGGLYPUFF = { types = { "NORMAL" } },
  WIGGLYTUFF = { types = { "NORMAL" } },
  MR_MIME = { types = { "PSYCHIC_TYPE" } },
  CLEFFA = { types = { "NORMAL" } },
  IGGLYBUFF = { types = { "NORMAL" } },
  TOGEPI = { types = { "NORMAL" } },
  TOGETIC = { types = { "NORMAL", "FLYING" } },
  MARILL = { types = { "WATER" } },
  AZUMARILL = { types = { "WATER" } },
  SNUBBULL = { types = { "NORMAL" } },
  GRANBULL = { types = { "NORMAL" } },
}

local GOLD_MOVES = {
  BITE = { type = "DARK", category = "special", effect = "FLINCH" },
  IRON_TAIL = { type = "STEEL", category = "physical", effect = "DEF_DOWN" },
  METAL_CLAW = { type = "STEEL", category = "physical", effect = "ATK_UP" },
  STEEL_WING = { type = "STEEL", category = "physical", effect = "DEF_UP" },
  CHARM = { type = "NORMAL", category = "status", effect = "ATK_DOWN_2" },
  MOONLIGHT = { type = "NORMAL", category = "status", effect = "HEAL" },
  SWEET_KISS = { type = "NORMAL", category = "status", effect = "CONFUSE" },
}

local CRYSTAL_MIRROR = deepcopy(GOLD_MOVES)
CRYSTAL_MIRROR.CHARM.type = "NORMAL"
CRYSTAL_MIRROR.MOONLIGHT.type = "NORMAL"
CRYSTAL_MIRROR.SWEET_KISS.type = "NORMAL"

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
package.preload["src.core.GameVersion"] = function()
  return { generation = function() return 2 end }
end

local function makeMod(values, seedMutator, withCrystalHandle)
  local defined
  values = deepcopy(values or {})
  local chart = deepcopy(GOLD_TYPE_CHART)
  local pokemon = deepcopy(GOLD_POKEMON)
  local moves = deepcopy(GOLD_MOVES)
  if seedMutator then seedMutator(chart, pokemon, moves) end

  local crystalHandle = withCrystalHandle and {
    id = "CRYSTAL_251", version = "0.9.19",
    exports = { crystalMoves = deepcopy(CRYSTAL_MIRROR) },
  } or nil
  local warnings, infos = {}, {}
  local function capture(dst, fmt, ...)
    dst[#dst + 1] = select("#", ...) > 0 and string.format(fmt, ...) or tostring(fmt)
  end

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
    log = {
      info = function(_, fmt, ...) capture(infos, fmt, ...) end,
      warn = function(_, fmt, ...) capture(warnings, fmt, ...) end,
    },
    exports = {},
    find = function(id)
      if crystalHandle and id == "CRYSTAL_251" then return crystalHandle end
      return nil
    end,
  }
  mod._warnings, mod._infos, mod._testCrystalHandle = warnings, infos, crystalHandle
  return mod, function() return defined end
end

local function run(values, seedMutator, withCrystalHandle)
  if ManagerState.__typingChartsPresetSyncOriginal then
    ManagerState.setOption = ManagerState.__typingChartsPresetSyncOriginal
  end
  ManagerState.__typingChartsPresetSyncInstalled = nil
  ManagerState.__typingChartsPresetSyncOriginal = nil
  local mod, getDefined = makeMod(values, seedMutator, withCrystalHandle)
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
local function hasWarning(mod, needle)
  for _, text in ipairs(mod._warnings) do if text:find(needle, 1, true) then return true end end
  return false
end

local FAIRY_TARGETS = {
  CLEFAIRY={"FAIRY"}, CLEFABLE={"FAIRY"},
  JIGGLYPUFF={"NORMAL","FAIRY"}, WIGGLYTUFF={"NORMAL","FAIRY"},
  MR_MIME={"PSYCHIC_TYPE","FAIRY"}, CLEFFA={"FAIRY"},
  IGGLYBUFF={"NORMAL","FAIRY"}, TOGEPI={"FAIRY"},
  TOGETIC={"FAIRY","FLYING"}, MARILL={"WATER","FAIRY"},
  AZUMARILL={"WATER","FAIRY"}, SNUBBULL={"FAIRY"}, GRANBULL={"FAIRY"},
}

-- GOLD VANILLA: native Gen II remains intact; no Fairy and no Gen I rollback.
do
  local steelBefore = deepcopy(GOLD_TYPE_CHART.STEEL)
  local darkBefore = deepcopy(GOLD_TYPE_CHART.DARK)
  local mod = run({ preset = "vanilla" })
  assert(mod.exports.generation == 2)
  assert(mod.exports.effectiveConfig.gamePolicy == "gold-native")
  assert(mod.exports.config.steel == false and mod.exports.config.dark == false)
  assert(mod.exports.nativeTypes.steel == true and mod.exports.nativeTypes.dark == true)
  assert(deepEqual(mod.content.type_chart:get("STEEL"), steelBefore))
  assert(deepEqual(mod.content.type_chart:get("DARK"), darkBefore))
  assert(mod.content.type_chart:get("FAIRY") == nil)
  assertTyping(mod, "MAGNEMITE", { "ELECTRIC", "STEEL" })
  assertTyping(mod, "MAGNETON", { "ELECTRIC", "STEEL" })
  assertMoveType(mod, "BITE", "DARK")
  assertMatchup(mod, "GHOST>PSYCHIC_TYPE", 20)
  assertMatchup(mod, "BUG>POISON", 5)
  assertMatchup(mod, "POISON>BUG", 10)
  assertMatchup(mod, "ICE>FIRE", 5)
  assertMatchup(mod, "GHOST>STEEL", 5)
  assertMatchup(mod, "DARK>STEEL", 5)
end

-- GOLD GEN II: explicit authority over canonical Gen II rules, but native type
-- records (indexes/category/custom metadata) are not reconstructed or patched.
do
  local steelBefore, darkBefore
  local mod = run({ preset = "gen2" }, function(chart, pokemon, moves)
    steelBefore = deepcopy(chart.STEEL)
    darkBefore = deepcopy(chart.DARK)
    chart["GHOST>STEEL"] = { multiplier = 10 }
    chart["DARK>STEEL"] = { multiplier = 10 }
    moves.IRON_TAIL.type = "NORMAL"
    moves.METAL_CLAW.type = "BUG"
    moves.STEEL_WING.type = "FLYING"
    moves.BITE.type = "NORMAL" -- expected-source guard may restore canonical Bite
  end)
  assert(deepEqual(mod.content.type_chart:get("STEEL"), steelBefore))
  assert(deepEqual(mod.content.type_chart:get("DARK"), darkBefore))
  assert(mod.content.type_chart:get("FAIRY") == nil)
  assertMatchup(mod, "GHOST>STEEL", 5)
  assertMatchup(mod, "DARK>STEEL", 5)
  assertMoveType(mod, "IRON_TAIL", "STEEL")
  assertMoveType(mod, "METAL_CLAW", "STEEL")
  assertMoveType(mod, "STEEL_WING", "STEEL")
  assertMoveType(mod, "BITE", "DARK")
end

-- GOLD GEN VI: native Steel/Dark survive untouched while Fairy and modern
-- Ghost/Dark-vs-Steel relationships are layered above the native dataset.
do
  local nativeSteel = deepcopy(GOLD_TYPE_CHART.STEEL)
  local nativeDark = deepcopy(GOLD_TYPE_CHART.DARK)
  local mod = run({ preset = "gen6" })
  assert(deepEqual(mod.content.type_chart:get("STEEL"), nativeSteel))
  assert(deepEqual(mod.content.type_chart:get("DARK"), nativeDark))
  local fairy = assert(mod.content.type_chart:get("FAIRY"))
  assert(fairy.category == "special")
  assertMatchup(mod, "GHOST>STEEL", 10)
  assertMatchup(mod, "DARK>STEEL", 10)
  assertMatchup(mod, "FAIRY>FIGHTING", 20)
  assertMatchup(mod, "FAIRY>DRAGON", 20)
  assertMatchup(mod, "FAIRY>DARK", 20)
  assertMatchup(mod, "FAIRY>FIRE", 5)
  assertMatchup(mod, "FAIRY>POISON", 5)
  assertMatchup(mod, "FAIRY>STEEL", 5)
  assertMatchup(mod, "POISON>FAIRY", 20)
  assertMatchup(mod, "STEEL>FAIRY", 20)
  assertMatchup(mod, "FIGHTING>FAIRY", 5)
  assertMatchup(mod, "BUG>FAIRY", 5)
  assertMatchup(mod, "DARK>FAIRY", 5)
  assertMatchup(mod, "DRAGON>FAIRY", 0)
  -- Known Gold technical types are deliberately neutral to Fairy.
  assertMatchup(mod, "FAIRY>BIRD", 10)
  assertMatchup(mod, "BIRD>FAIRY", 10)
  assertMatchup(mod, "FAIRY>CURSE_TYPE", 10)
  assertMatchup(mod, "CURSE_TYPE>FAIRY", 10)
  for id, target in pairs(FAIRY_TARGETS) do assertTyping(mod, id, target) end
  for _, id in ipairs({ "CHARM", "MOONLIGHT", "SWEET_KISS" }) do
    assertMoveType(mod, id, "FAIRY")
    assert(mod.content.moves:get(id).category == "status", id .. " category changed")
  end
end

-- GOLD CUSTOM: requested Steel/Dark OFF is a no-op, so native types remain and
-- Fairy still interacts with them as part of its complete canonical chart.
do
  local steelBefore = deepcopy(GOLD_TYPE_CHART.STEEL)
  local darkBefore = deepcopy(GOLD_TYPE_CHART.DARK)
  local mod = run({ preset="custom", steel_type=false, dark_type=false, fairy_type=true,
    ghost_vs_steel="off", dark_vs_steel="off", ghost_vs_psychic="off",
    bug_vs_poison="off", ice_vs_fire="off" })
  assert(deepEqual(mod.content.type_chart:get("STEEL"), steelBefore))
  assert(deepEqual(mod.content.type_chart:get("DARK"), darkBefore))
  assertMatchup(mod, "FAIRY>DARK", 20)
  assertMatchup(mod, "DARK>FAIRY", 5)
  assertMatchup(mod, "FAIRY>STEEL", 5)
  assertMatchup(mod, "STEEL>FAIRY", 20)
  assertMoveType(mod, "BITE", "DARK")
  assertMoveType(mod, "IRON_TAIL", "STEEL")
end

-- Gold explicit Vanilla selectors restore native Gold relationships, not Gen I.
do
  local mod = run({ preset="custom", steel_type=false, dark_type=false, fairy_type=false,
    ghost_vs_steel="off", dark_vs_steel="off", ghost_vs_psychic="vanilla",
    bug_vs_poison="vanilla", ice_vs_fire="vanilla" }, function(chart)
      chart["GHOST>PSYCHIC_TYPE"] = { multiplier=0 }
      chart["BUG>POISON"] = { multiplier=20 }
      chart["POISON>BUG"] = { multiplier=20 }
      chart["ICE>FIRE"] = { multiplier=10 }
    end)
  assertMatchup(mod, "GHOST>PSYCHIC_TYPE", 20)
  assertMatchup(mod, "BUG>POISON", 5)
  assertMatchup(mod, "POISON>BUG", 10)
  assertMatchup(mod, "ICE>FIRE", 5)
end

-- Every OFF control is a strict no-op over deliberately non-native upstream
-- values. This is the stacking contract, including Steel/Dark toggles.
do
  local mod = run({ preset="custom", steel_type=false, dark_type=false, fairy_type=false,
    ghost_vs_steel="off", dark_vs_steel="off", ghost_vs_psychic="off",
    bug_vs_poison="off", ice_vs_fire="off" }, function(chart, pokemon, moves)
      chart["GHOST>PSYCHIC_TYPE"] = { multiplier=7 }
      chart["BUG>POISON"] = { multiplier=8 }
      chart["POISON>BUG"] = { multiplier=9 }
      chart["ICE>FIRE"] = { multiplier=11 }
      chart["GHOST>STEEL"] = { multiplier=12 }
      chart["DARK>STEEL"] = { multiplier=13 }
      moves.BITE.type = "GHOST"
      moves.IRON_TAIL.type = "NORMAL"
      pokemon.MAGNEMITE.types = { "ELECTRIC", "STEEL" }
    end)
  assertMatchup(mod, "GHOST>PSYCHIC_TYPE", 7)
  assertMatchup(mod, "BUG>POISON", 8)
  assertMatchup(mod, "POISON>BUG", 9)
  assertMatchup(mod, "ICE>FIRE", 11)
  assertMatchup(mod, "GHOST>STEEL", 12)
  assertMatchup(mod, "DARK>STEEL", 13)
  assertMoveType(mod, "BITE", "GHOST")
  assertMoveType(mod, "IRON_TAIL", "NORMAL")
end

-- Fairy species ownership guard: unrelated custom typing must survive.
do
  local mod = run({ preset="custom", steel_type=false, dark_type=false, fairy_type=true,
    ghost_vs_steel="off", dark_vs_steel="off", ghost_vs_psychic="off",
    bug_vs_poison="off", ice_vs_fire="off" }, function(_, pokemon)
      pokemon.TOGETIC.types = { "WATER", "FLYING" }
    end)
  assertTyping(mod, "TOGETIC", { "WATER", "FLYING" })
  assert(hasWarning(mod, "TOGETIC has typing WATER/FLYING"))
end

-- Bite retains its expected-source guard on Gold: unrelated custom typing is
-- not overwritten just because DARK TYPE is enabled.
do
  local mod = run({ preset="custom", steel_type=false, dark_type=true, fairy_type=false,
    ghost_vs_steel="off", dark_vs_steel="off", ghost_vs_psychic="off",
    bug_vs_poison="off", ice_vs_fire="off" }, function(_, _, moves)
      moves.BITE.type = "GHOST"
    end)
  assertMoveType(mod, "BITE", "GHOST")
  assert(hasWarning(mod, "BITE has move type GHOST"))
end

-- Missing Snap Trap stays missing; this mod only retypes an existing record.
do
  local mod = run({ preset="gen2" })
  assert(mod.content.moves:get("SNAP_TRAP") == nil)
end

-- Gold must not use Crystal 251's parallel move mirror even if a handle is
-- technically visible. Native Gold registries are the only content authority.
do
  local mod = run({ preset="gen6" }, nil, true)
  assert(mod.exports.compatibility.crystal251 == true)
  assert(mod.exports.compatibility.crystal251Relevant == false)
  assertMoveType(mod, "CHARM", "FAIRY")
  assert(mod._testCrystalHandle.exports.crystalMoves.CHARM.type == "NORMAL")
  assert(mod._testCrystalHandle.exports.crystalMoves.MOONLIGHT.type == "NORMAL")
  assert(mod._testCrystalHandle.exports.crystalMoves.SWEET_KISS.type == "NORMAL")
end

-- If a supposedly Gold fixture has no native Steel/Dark record, refuse to
-- manufacture one. This catches accidental reuse of the Gen 1 ensureType path.
do
  local mod = run({ preset="gen2" }, function(chart)
    chart.STEEL = nil
    chart.DARK = nil
  end)
  assert(mod.content.type_chart:get("STEEL") == nil)
  assert(mod.content.type_chart:get("DARK") == nil)
  assert(hasWarning(mod, "Gold native STEEL record is missing"))
  assert(hasWarning(mod, "Gold native DARK record is missing"))
end

print("STEEL/FAIRY AND TYPING CHARTS Gold/Gen 2 contract tests: PASS")
