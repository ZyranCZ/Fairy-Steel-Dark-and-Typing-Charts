-- Cross-generation state + full preset synchronization regression tests.
-- Run from the mod directory: texlua tests/dual_generation_and_preset_test.lua

local function deepcopy(v)
  if type(v) ~= "table" then return v end
  local out = {}; for k, x in pairs(v) do out[k] = deepcopy(x) end; return out
end

local Registry = {}; Registry.__index = Registry
function Registry.new(seed) return setmetatable({ data=deepcopy(seed or {}) }, Registry) end
function Registry:get(id) return self.data[id] end
function Registry:register(id, value) assert(self.data[id] == nil); self.data[id]=deepcopy(value) end
function Registry:patch(id, patch)
  assert(self.data[id] ~= nil, "missing " .. id)
  local r=deepcopy(self.data[id]); for k,v in pairs(patch) do r[k]=deepcopy(v) end; self.data[id]=r
end

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
local CURRENT_GENERATION = 1
package.preload["src.core.GameVersion"] = function()
  return { generation = function() return CURRENT_GENERATION end }
end

local GEN1_CHART = {
  ["GHOST>PSYCHIC_TYPE"]={multiplier=0}, ["BUG>POISON"]={multiplier=20},
  ["POISON>BUG"]={multiplier=20}, ["ICE>FIRE"]={multiplier=10},
}
local GOLD_CHART = {
  STEEL={name="STEEL",category="physical",index=9},
  DARK={name="DARK",category="special",index=27},
  ["GHOST>PSYCHIC_TYPE"]={multiplier=20}, ["BUG>POISON"]={multiplier=5},
  ["POISON>BUG"]={multiplier=10}, ["ICE>FIRE"]={multiplier=5},
  ["GHOST>STEEL"]={multiplier=5}, ["DARK>STEEL"]={multiplier=5},
}

local function build(generation, values)
  CURRENT_GENERATION = generation
  local defined
  values = deepcopy(values or {})
  local mod = {
    content={
      type_chart=Registry.new(generation == 2 and GOLD_CHART or GEN1_CHART),
      pokemon=Registry.new({}), moves=Registry.new({}),
    },
    options={
      define=function(_,rows) defined=rows end,
      get=function(_,key)
        if values[key] ~= nil then return values[key] end
        for _,row in ipairs(defined or {}) do if row.key==key then return row.default end end
      end,
    },
    log={info=function() end,warn=function() end}, exports={}, find=function() return nil end,
  }
  assert(loadfile("main.lua"))()(mod)
  return mod, defined
end

local CUSTOM_VANILLA = {
  preset="custom", steel_type=false, dark_type=false, fairy_type=false,
  ghost_vs_steel="off", dark_vs_steel="off", ghost_vs_psychic="vanilla",
  bug_vs_poison="vanilla", ice_vs_fire="vanilla",
}
local function mult(mod,id) return assert(mod.content.type_chart:get(id),id).multiplier end

-- Sequential generation changes in one Lua process must not leak policy.
do
  local gold1 = build(2, CUSTOM_VANILLA)
  assert(gold1.exports.generation == 2)
  assert(mult(gold1,"GHOST>PSYCHIC_TYPE") == 20)
  assert(mult(gold1,"BUG>POISON") == 5 and mult(gold1,"POISON>BUG") == 10)
  assert(mult(gold1,"ICE>FIRE") == 5)

  local gen1 = build(1, CUSTOM_VANILLA)
  assert(gen1.exports.generation == 1)
  assert(mult(gen1,"GHOST>PSYCHIC_TYPE") == 0)
  assert(mult(gen1,"BUG>POISON") == 20 and mult(gen1,"POISON>BUG") == 20)
  assert(mult(gen1,"ICE>FIRE") == 10)

  local gold2 = build(2, CUSTOM_VANILLA)
  assert(gold2.exports.generation == 2)
  assert(mult(gold2,"GHOST>PSYCHIC_TYPE") == 20)
  assert(mult(gold2,"BUG>POISON") == 5 and mult(gold2,"POISON>BUG") == 10)
  assert(mult(gold2,"ICE>FIRE") == 5)
end

local function rowsByKey(rows)
  local out={}; for _,row in ipairs(rows) do out[row.key]=row end; return out
end
local EXPECT = {
  vanilla={steel_type=false,dark_type=false,fairy_type=false,ghost_vs_steel="off",dark_vs_steel="off",
           ghost_vs_psychic="vanilla",bug_vs_poison="vanilla",ice_vs_fire="vanilla"},
  gen2={steel_type=true,dark_type=true,fairy_type=false,ghost_vs_steel="gen2",dark_vs_steel="gen2",
        ghost_vs_psychic="gen2",bug_vs_poison="gen2",ice_vs_fire="gen2"},
  gen6={steel_type=true,dark_type=true,fairy_type=true,ghost_vs_steel="gen6",dark_vs_steel="gen6",
        ghost_vs_psychic="gen2",bug_vs_poison="gen2",ice_vs_fire="gen2"},
}
local COMPONENTS={"steel_type","dark_type","fairy_type","ghost_vs_steel","dark_vs_steel",
                  "ghost_vs_psychic","bug_vs_poison","ice_vs_fire"}

-- Full eight-component preset sync, same-value stability, reset-default style
-- writes, and CUSTOM preservation.
do
  local _, rows = build(1, {})
  local byKey=rowsByKey(rows)
  local state=setmetatable({values={},game={mods={modOptions={},optionSchemas={steel_typing=rows}}}}, {__index=ManagerState})

  for _,preset in ipairs({"vanilla","gen2","gen6"}) do
    state:setOption("steel_typing","preset",preset)
    local t=state.values.steel_typing
    assert(t.preset==preset)
    for _,key in ipairs(COMPONENTS) do assert(t[key]==EXPECT[preset][key], preset .. ":" .. key) end
  end

  -- Rewriting an already matching component is not customization.
  state:setOption("steel_typing","preset","gen6")
  state:setOption("steel_typing","fairy_type",true)
  assert(state.values.steel_typing.preset=="gen6")

  -- A real divergence becomes CUSTOM.
  state:setOption("steel_typing","dark_type",false)
  assert(state.values.steel_typing.preset=="custom")

  -- CUSTOM itself preserves current component values.
  local before=deepcopy(state.values.steel_typing)
  state:setOption("steel_typing","preset","custom")
  for _,key in ipairs(COMPONENTS) do assert(state.values.steel_typing[key]==before[key], "custom:"..key) end

  -- Reset-default style writes: selecting schema default establishes the full
  -- preset, then writing each component's identical default must retain it.
  state:setOption("steel_typing","preset",byKey.preset.default)
  for _,key in ipairs(COMPONENTS) do state:setOption("steel_typing",key,byKey[key].default) end
  assert(state.values.steel_typing.preset==byKey.preset.default)
  for _,key in ipairs(COMPONENTS) do
    assert(state.values.steel_typing[key]==EXPECT[byKey.preset.default][key], "reset:"..key)
  end
end

print("STEEL/FAIRY AND TYPING CHARTS dual-generation/preset tests: PASS")
