local M = {}

function M.install(ctx)
  local util = ctx.util
  local hooks = ctx.hooks
  local JOKER_PATCHES = ctx.patches.jokers
  ctx.ownership_overrides = ctx.ownership_overrides or {}

  local function apply_patch_to_center(center, patch)
    if not center or type(center) ~= "table" then return end
    for k, v in pairs(patch) do
      if k ~= "config" then center[k] = v end
    end
    if patch.config then
      center.config = center.config or {}
      center.config = util.deep_merge(center.config, patch.config)
    end
  end

  local function apply_patch_to_card(card, patch)
    if not card or not card.ability or type(card.ability) ~= "table" then return end
    if patch.config then
      card.ability = util.deep_merge(card.ability, patch.config)
    end
    if (patch.cost ~= nil or patch.cost_mult ~= nil) and card.set_cost then
      card:set_cost()
    end
    if patch.rarity ~= nil and card.set_rarity then
      card:set_rarity()
    end
  end

  -- runtime sync via hooks
  hooks.on_card_set_ability(function(card)
    local key = card and card.config and card.config.center and card.config.center.key
    local patch = key and JOKER_PATCHES[key]
    if patch then apply_patch_to_card(card, patch) end
  end)

  hooks.on_card_load(function(card)
    local key = card and card.config and card.config.center and card.config.center.key
    local patch = key and JOKER_PATCHES[key]
    if patch then apply_patch_to_card(card, patch) end
  end)

  -- ownership loop
  for joker_id, patch in pairs(JOKER_PATCHES) do
    local ownership = {
      inject = function(self)
        SMODS.Joker.inject(self)

        if patch.config then
          self.config = self.config or {}
          self.config = util.deep_merge(self.config, patch.config)
        end

        for k, v in pairs(patch) do
          if k ~= "config" then self[k] = v end
        end

        if G and G.P_CENTERS and G.P_CENTERS[joker_id] then
          apply_patch_to_center(G.P_CENTERS[joker_id], patch)
        end
      end
    }

    -- Legendary gating for rarity == 4
    if patch.rarity == 4 then
      ownership.in_pool = function(self, args)
        local forced =
          (args and args.legendary) or
          (args and args.force_legendary) or
          (args and args.forced) or
          (args and args.force) or
          (args and args.source == "legendary") or
          (args and args.source == "soul") or
          (args and args.soul)
        if forced then return true end
        return false
      end
    end

    -- Apply optional per-joker overrides (Stencil/Raised Fist etc.)
    local override = ctx.ownership_overrides[joker_id]
    if override then override(ownership) end

    SMODS.Joker:take_ownership(joker_id, ownership)
  end
end

return M
