local M = {}

function M.install(ctx)
  local util = ctx.util
  local hooks = ctx.hooks
  local PLANET_PATCHES = ctx.patches.planets

  local PLANET_TO_HAND = {
    c_pluto    = "High Card",
    c_mercury  = "Pair",
    c_uranus   = "Two Pair",
    c_venus    = "Three of a Kind",
    c_saturn   = "Straight",
    c_jupiter  = "Flush",
    c_earth    = "Full House",
    c_mars     = "Four of a Kind",
    c_neptune  = "Straight Flush",
    c_planet_x = "Five of a Kind",
    c_ceres    = "Flush House",
    c_eris     = "Flush Five",
  }

  local function apply_planet_hand_patches()
    if not (G and G.GAME and G.GAME.hands) then return false end

    for planet_id, patch in pairs(PLANET_PATCHES) do
      -- IMPORTANT: Black Hole only levels hands; do NOT overwrite per-level gains globally
      if planet_id ~= "c_black_hole" then
        local hand = PLANET_TO_HAND[planet_id]
        if hand and G.GAME.hands[hand] and type(G.GAME.hands[hand]) == "table" then
          local chips = util.tonum(patch.chips, nil)
          local mult  = util.tonum(patch.mult, nil)

          if chips ~= nil then
            G.GAME.hands[hand].l_chips   = chips
            G.GAME.hands[hand].chip_mod  = chips
            G.GAME.hands[hand].chips_mod = chips
          end
          if mult ~= nil then
            G.GAME.hands[hand].l_mult    = mult
            G.GAME.hands[hand].mult_mod  = mult
            G.GAME.hands[hand].mults_mod = mult
          end

          -- Patch defaults/prototypes too (guards against rebuilds)
          if G.P_HANDS and G.P_HANDS[hand] and type(G.P_HANDS[hand]) == "table" then
            if chips ~= nil then
              G.P_HANDS[hand].l_chips   = chips
              G.P_HANDS[hand].chip_mod  = chips
              G.P_HANDS[hand].chips_mod = chips
            end
            if mult ~= nil then
              G.P_HANDS[hand].l_mult    = mult
              G.P_HANDS[hand].mult_mod  = mult
              G.P_HANDS[hand].mults_mod = mult
            end
          end
        end
      end
    end

    return true
  end

  -- Apply after run start
  hooks.on_run_start(function()
    apply_planet_hand_patches()
  end)

  -- Re-apply right before using a Planet card (guards against later resets)
  hooks.on_pre_use_consumeable(function(card)
    if card and card.ability and card.ability.consumeable and card.ability.consumeable.set == "Planet" then
      apply_planet_hand_patches()
    end
  end)

  -- Leave Tooltips unchanged
  local function planet_patch_for(card)
    local key = card and card.config and card.config.center and card.config.center.key
    return key and PLANET_PATCHES[key]
  end

  local function planet_hand_name(card)
    local ht = card and card.ability and card.ability.consumeable and card.ability.consumeable.hand_type
    return ht or "Poker Hand"
  end

  local function is_black_hole(card)
    local key = card and card.config and card.config.center and card.config.center.key
    return key == "c_black_hole"
  end

  for planet_id, _ in pairs(PLANET_PATCHES) do
    SMODS.Consumable:take_ownership(planet_id, {
      loc_txt = {
        text = (planet_id == "c_black_hole") and {
          "Level up {C:attention}all Poker Hands{}",
          "{C:blue}+#1#{} Chips and {C:red}+#2#{} Mult"
        } or {
          "Level up {C:attention}#3#{}",
          "{C:blue}+#1#{} Chips and {C:red}+#2#{} Mult"
        }
      },

      loc_vars = function(self, info_queue, card)
        local patch = planet_patch_for(card) or { chips = 0, mult = 0 }
        local chips = util.tonum(patch.chips, 0)
        local mult  = util.tonum(patch.mult, 0)

        if is_black_hole(card) then
          return { vars = { chips, mult } }
        else
          return { vars = { chips, mult, planet_hand_name(card) } }
        end
      end
    })
  end
end

return M
