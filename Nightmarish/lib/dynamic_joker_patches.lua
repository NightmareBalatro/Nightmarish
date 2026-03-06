local M = {}

function M.install(ctx)
  local hooks = ctx.hooks
  ctx.ownership_overrides = ctx.ownership_overrides or {}

  -- Joker Stencil: scale computed Xmult
  local function is_stencil(card)
    return card and card.config and card.config.center and card.config.center.key == "j_stencil"
  end

  local function stencil_per_slot_from_card(card)
    if card and card.ability and card.ability.extra and type(card.ability.extra.per_slot) == "number" then
      return card.ability.extra.per_slot
    end
    return 1
  end

  local function scale_stencil_x(vanilla_x, per_slot)
    vanilla_x = tonumber(vanilla_x)
    if not vanilla_x then return nil end
    per_slot = tonumber(per_slot) or 1
    return 1 + (vanilla_x - 1) * per_slot
  end

  local function compute_vanilla_stencil_x_from_area()
    if not (G and G.jokers and G.jokers.cards and G.jokers.config) then return nil end
    local limit = tonumber(G.jokers.config.card_limit)
    if not limit then return nil end

    local stencils, total = 0, 0
    for _, c in ipairs(G.jokers.cards) do
      total = total + 1
      if c and c.config and c.config.center and c.config.center.key == "j_stencil" then
        stencils = stencils + 1
      end
    end

    local empty = limit - total
    if empty < 0 then empty = 0 end
    local effective_empty = empty + stencils
    if effective_empty < 1 then effective_empty = 1 end
    return effective_empty
  end

  local function rescale_stencil_return(card, ret)
    if not is_stencil(card) then return end
    if type(ret) ~= "table" then return end

    local per = stencil_per_slot_from_card(card)
    local vanilla_x = compute_vanilla_stencil_x_from_area()
    if not vanilla_x then
      vanilla_x = ret.xmult or ret.x_mult or ret.Xmult_mod or ret.x_mult_mod
    end

    local scaled = scale_stencil_x(vanilla_x, per)
    if not scaled then return end

    if ret.xmult ~= nil then ret.xmult = scaled end
    if ret.x_mult ~= nil then ret.x_mult = scaled end
    if ret.Xmult_mod ~= nil then ret.Xmult_mod = scaled end
    if ret.x_mult_mod ~= nil then ret.x_mult_mod = scaled end

    if card.ability then
      card.ability.x_mult = scaled
      card.ability._nightmarish_stencil_scaled = true
    end
  end

  -- Raised Fist: halve mult contribution
  local function is_raised_fist(card)
    return card and card.config and card.config.center and card.config.center.key == "j_raised_fist"
  end

  local function rescale_raised_fist_return(card, ret)
    if not is_raised_fist(card) then return end
    if type(ret) ~= "table" then return end
    local factor = 0.5
    if ret.mult_mod ~= nil then ret.mult_mod = ret.mult_mod * factor end
    if ret.mult ~= nil then ret.mult = ret.mult * factor end
    if ret.mult_add ~= nil then ret.mult_add = ret.mult_add * factor end
  end

  local function current_lowest_rank_in_hand()
    if not (G and G.hand and G.hand.cards) then return nil end
    local lowest = nil
    for _, c in ipairs(G.hand.cards) do
      local id = nil
      if c and c.get_id then
        id = c:get_id()
      elseif c and c.base and type(c.base.id) == "number" then
        id = c.base.id
      end
      if type(id) == "number" then
        if (not lowest) or id < lowest then lowest = id end
      end
    end
    return lowest
  end

  -- Register scoring hooks
  hooks.on_calculate_joker(function(card, r1, r2)
    rescale_stencil_return(card, r1)
    rescale_stencil_return(card, r2)
    rescale_raised_fist_return(card, r1)
    rescale_raised_fist_return(card, r2)
  end)

  -- Ownership overrides (tooltips)
  ctx.ownership_overrides["j_stencil"] = function(ownership)
    ownership.loc_txt = {
      name = "Joker Stencil",
      text = {
        "Each additional empty {C:attention}Joker{} slot",
        "adds {X:mult,C:white}X#2#{} Mult",
        "{C:inactive}(Joker Stencil counts as empty; minimum {X:mult,C:white}X1{C:inactive})",
        "{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)"
      }
    }
    ownership.loc_vars = function(self, info_queue, card)
      local per = stencil_per_slot_from_card(card)
      local vanilla_x = compute_vanilla_stencil_x_from_area()
      local current_x = vanilla_x and scale_stencil_x(vanilla_x, per)
        or (card and card.ability and (card.ability.x_mult or card.ability.xmult))
        or 1
      current_x = tonumber(current_x) or 1
      if card and card.ability then
        card.ability.x_mult = current_x
        card.ability._nightmarish_stencil_scaled = true
      end
      return { vars = { current_x, per } }
    end
  end

  ctx.ownership_overrides["j_raised_fist"] = function(ownership)
    ownership.loc_txt = {
      name = "Raised Fist",
      text = {
        "Adds {C:mult}+#1#{} Mult",
        "equal to the rank of the {C:attention}lowest{}",
        "card held in hand",
        "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult)"
      }
    }
    ownership.loc_vars = function(self, info_queue, card)
      return { vars = { tonumber(current_lowest_rank_in_hand()) or 0 } }
    end
  end
end

return M
