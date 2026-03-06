
local util = assert(SMODS.load_file("lib/util.lua"))()

local JOKER_PATCHES       = util.load("patches/joker_patches.lua")
local PLANET_PATCHES      = util.load("patches/planet_patches.lua")
local ENHANCEMENT_PATCHES = util.load("patches/enhancement_patches.lua")
local EDITION_PATCHES     = util.load("patches/edition_patches.lua")
local TAROT_PATCHES       = util.load("patches/tarot_patches.lua")

-- A cat with no name
SMODS.Atlas { key = 'modicon', px = 34, py = 34, path = 'modicon.png' }

-- Hook dispatcher
local function make_hooks()
  local H = {
    run_start = {},
    pre_use_consumeable = {},
    card_set_ability = {},
    card_load = {},
    calculate_joker = {},
  }

  function H.on_run_start(fn) table.insert(H.run_start, fn) end
  function H.on_pre_use_consumeable(fn) table.insert(H.pre_use_consumeable, fn) end
  function H.on_card_set_ability(fn) table.insert(H.card_set_ability, fn) end
  function H.on_card_load(fn) table.insert(H.card_load, fn) end
  function H.on_calculate_joker(fn) table.insert(H.calculate_joker, fn) end

  function H.fire_run_start() for _, fn in ipairs(H.run_start) do fn() end end
  function H.fire_pre_use_consumeable(card) for _, fn in ipairs(H.pre_use_consumeable) do fn(card) end end
  function H.fire_card_set_ability(card) for _, fn in ipairs(H.card_set_ability) do fn(card) end end
  function H.fire_card_load(card) for _, fn in ipairs(H.card_load) do fn(card) end end
  function H.fire_calculate_joker(card, r1, r2) for _, fn in ipairs(H.calculate_joker) do fn(card, r1, r2) end end

  return H
end

local hooks = make_hooks()

-- Context for libs
local ctx = {
  util = util,
  patches = {
    jokers = JOKER_PATCHES,
    planets = PLANET_PATCHES,
    enhancements = ENHANCEMENT_PATCHES,
    editions = EDITION_PATCHES,
    tarots = TAROT_PATCHES,
  },
  hooks = hooks,
  -- used for tooltip overrides, etc.
  ownership_overrides = {},
}

assert(SMODS.load_file("lib/dynamic_joker_patches.lua"))().install(ctx)
assert(SMODS.load_file("lib/jokers.lua"))().install(ctx)
assert(SMODS.load_file("lib/planets.lua"))().install(ctx)
assert(SMODS.load_file("lib/enhancements.lua"))().install(ctx)
assert(SMODS.load_file("lib/editions.lua"))().install(ctx)
assert(SMODS.load_file("lib/tarots.lua"))().install(ctx)

-- Engine hook wrappers (single source of truth)
if Game and Game.start_run then
  local ref = Game.start_run
  function Game:start_run(...)
    local ret = ref(self, ...)
    hooks.fire_run_start()
    return ret
  end
end

if Card and Card.use_consumeable then
  local ref = Card.use_consumeable
  function Card:use_consumeable(area, copier, ...)
    hooks.fire_pre_use_consumeable(self)
    return ref(self, area, copier, ...)
  end
end

if Card and Card.set_ability then
  local ref = Card.set_ability
  function Card:set_ability(center, ...)
    ref(self, center, ...)
    hooks.fire_card_set_ability(self)
  end
end

if Card and Card.load then
  local ref = Card.load
  function Card:load(card_table, ...)
    ref(self, card_table, ...)
    hooks.fire_card_load(self)
  end
end

if Card and Card.calculate_joker then
  local ref = Card.calculate_joker
  function Card:calculate_joker(context, ...)
    local r1, r2, r3, r4 = ref(self, context, ...)
    hooks.fire_calculate_joker(self, r1, r2)
    return r1, r2, r3, r4
  end
end
