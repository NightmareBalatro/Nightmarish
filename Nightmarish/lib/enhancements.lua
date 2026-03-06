local M = {}

function M.install(ctx)
  local hooks = ctx.hooks
  local ENHANCEMENT_PATCHES = ctx.patches.enhancements

  local function apply_enhancement_patch_to_center(center, patch)
    if not (center and type(center) == "table" and patch and type(patch) == "table") then return end
    if patch.config then
      center.config = center.config or {}
      for k, v in pairs(patch.config) do
        center.config[k] = v

        -- Glass alias guards
        if k == "Xmult" then
          center.config.x_mult = v
          center.config.xmult  = v
        end

        -- Lucky alias guards
        if k == "mult" then
          center.config.bonus_mult = v
          center.config.m_mult     = v
        end
        if k == "p_dollars" then
          center.config.odds         = v
          center.config.payout_odds  = v
          center.config.dollars_odds = v
        end
      end
    end
  end

  local function apply_enhancement_patch_to_card(card, patch)
    if not (card and card.ability and type(card.ability) == "table" and patch and type(patch) == "table") then return end
    if patch.config then
      for k, v in pairs(patch.config) do
        card.ability[k] = v

        if k == "Xmult" then
          card.ability.x_mult = v
          card.ability.xmult  = v
        end

        if k == "mult" then
          card.ability.bonus_mult = v
          card.ability.m_mult     = v
        end
        if k == "p_dollars" then
          card.ability.odds         = v
          card.ability.payout_odds  = v
          card.ability.dollars_odds = v
        end
      end
    end
  end

  local function apply_all_enhancement_center_patches()
    if not (G and G.P_CENTERS) then return false end
    for enh_id, patch in pairs(ENHANCEMENT_PATCHES) do
      if G.P_CENTERS[enh_id] then
        apply_enhancement_patch_to_center(G.P_CENTERS[enh_id], patch)
      end
    end
    return true
  end

  hooks.on_run_start(function()
    apply_all_enhancement_center_patches()
  end)

  hooks.on_card_set_ability(function(card)
    local ckey = card and card.config and card.config.center and card.config.center.key
    local epatch = ckey and ENHANCEMENT_PATCHES and ENHANCEMENT_PATCHES[ckey]
    if epatch then
      apply_enhancement_patch_to_card(card, epatch)
    end
  end)

  hooks.on_card_load(function(card)
    local ckey = card and card.config and card.config.center and card.config.center.key
    local epatch = ckey and ENHANCEMENT_PATCHES and ENHANCEMENT_PATCHES[ckey]
    if epatch then
      apply_enhancement_patch_to_card(card, epatch)
    end
  end)

  -- Patch prototypes/centers via take_ownership
  -- DOES NOT override "loc_txt"
  for enh_id, patch in pairs(ENHANCEMENT_PATCHES) do
    SMODS.Enhancement:take_ownership(enh_id, {
      inject = function(self)
        SMODS.Enhancement.inject(self)

        apply_enhancement_patch_to_center(self, patch)

        if G and G.P_CENTERS and G.P_CENTERS[enh_id] then
          apply_enhancement_patch_to_center(G.P_CENTERS[enh_id], patch)
        end
      end
    })
  end
end

return M
