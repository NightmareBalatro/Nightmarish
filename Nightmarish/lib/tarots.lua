local M = {}

function M.install(ctx)
  local hooks = ctx.hooks
  local TAROT_PATCHES = ctx.patches.tarots

  local function apply_tarot_patch_to_center(center, patch)
    if not (center and type(center) == "table" and patch and type(patch) == "table") then return end
    if patch.config then
      center.config = center.config or {}
      for k, v in pairs(patch.config) do
        center.config[k] = v
      end
    end
  end

  local function apply_tarot_patch_to_card(card, patch)
    if not (card and card.ability and type(card.ability) == "table") then return end
    if not (card.ability.consumeable and type(card.ability.consumeable) == "table") then return end
    if patch.config then
      for k, v in pairs(patch.config) do
        card.ability.consumeable[k] = v
      end
    end
  end

  local function apply_all_tarot_center_patches()
    if not (G and G.P_CENTERS) then return false end
    for tarot_id, patch in pairs(TAROT_PATCHES) do
      if G.P_CENTERS[tarot_id] then
        apply_tarot_patch_to_center(G.P_CENTERS[tarot_id], patch)
      end
    end
    return true
  end

  hooks.on_run_start(function()
    apply_all_tarot_center_patches()
  end)

  hooks.on_card_set_ability(function(card)
    local ckey = card and card.config and card.config.center and card.config.center.key
    local tpatch = ckey and TAROT_PATCHES and TAROT_PATCHES[ckey]
    if tpatch and card.ability and card.ability.consumeable and card.ability.consumeable.set == "Tarot" then
      apply_tarot_patch_to_card(card, tpatch)
    end
  end)

  hooks.on_card_load(function(card)
    local ckey = card and card.config and card.config.center and card.config.center.key
    local tpatch = ckey and TAROT_PATCHES and TAROT_PATCHES[ckey]
    if tpatch and card.ability and card.ability.consumeable and card.ability.consumeable.set == "Tarot" then
      apply_tarot_patch_to_card(card, tpatch)
    end
  end)

  for tarot_id, patch in pairs(TAROT_PATCHES) do
    SMODS.Consumable:take_ownership(tarot_id, {
      inject = function(self)
        SMODS.Consumable.inject(self)

        apply_tarot_patch_to_center(self, patch)

        if G and G.P_CENTERS and G.P_CENTERS[tarot_id] then
          apply_tarot_patch_to_center(G.P_CENTERS[tarot_id], patch)
        end
      end
    })
  end
end

return M
