local M = {}

function M.install(ctx)
  local hooks = ctx.hooks
  local EDITION_PATCHES = ctx.patches.editions

  local function apply_edition_patch_to_center(center, patch)
    if not (center and type(center) == "table" and patch and type(patch) == "table") then return end
    if patch.config then
      center.config = center.config or {}
      for k, v in pairs(patch.config) do
        center.config[k] = v
        if k == "extra" then
          center.config.EXTRA = v
          center.config.value = v
        end
      end
    end
  end

  local function apply_edition_patch_to_card(card, patch)
    if not (card and card.ability and type(card.ability) == "table" and patch and type(patch) == "table") then return end
    card.ability.edition = card.ability.edition or {}
    if patch.config then
      for k, v in pairs(patch.config) do
        card.ability.edition[k] = v
        if k == "extra" then
          card.ability.edition.EXTRA = v
          card.ability.edition.value = v
          card.ability.EXTRA = v
          card.ability.value = v
        end
      end
    end
  end

  local function apply_all_edition_center_patches()
    if not (G and G.P_CENTERS) then return false end
    for ed_id, patch in pairs(EDITION_PATCHES) do
      if G.P_CENTERS[ed_id] then
        apply_edition_patch_to_center(G.P_CENTERS[ed_id], patch)
      end
    end
    return true
  end

  hooks.on_run_start(function()
    apply_all_edition_center_patches()
  end)

  local function sync_edition(card)
    if not card then return end
    local ed_key = (card.edition and card.edition.key)
      or (card.ability and card.ability.edition and card.ability.edition.key)

    local ed_patch = ed_key and EDITION_PATCHES and EDITION_PATCHES[ed_key]
    if ed_patch then
      apply_edition_patch_to_card(card, ed_patch)
    end
  end

  hooks.on_card_set_ability(function(card) sync_edition(card) end)
  hooks.on_card_load(function(card) sync_edition(card) end)

  for ed_id, patch in pairs(EDITION_PATCHES) do
    SMODS.Edition:take_ownership(ed_id, {
      inject = function(self)
        SMODS.Edition.inject(self)

        apply_edition_patch_to_center(self, patch)

        if G and G.P_CENTERS and G.P_CENTERS[ed_id] then
          apply_edition_patch_to_center(G.P_CENTERS[ed_id], patch)
        end
      end
    })
  end
end

return M
