--[[

All joker patches live in the joker_patches file

]]--

local JOKER_PATCHES = assert(SMODS.load_file("joker_patches.lua"))()

--[[

Don't change anything below this, there should be no need to.
All the code below does, is to take the changes from JOKER_PATCHES
file and apply them at runtime.

]]--

-- modicon
SMODS.Atlas {
    key = 'modicon',
    px = 34,
    py = 34,
    path = 'modicon.png'
}

local function deep_merge(dst, src)
    if type(src) ~= "table" then return src end
    if type(dst) ~= "table" then dst = {} end

    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = deep_merge(dst[k], v)
        else
            dst[k] = v
        end
    end
    return dst
end

local function apply_patch_to_center(center, patch)
    if not center or type(center) ~= "table" then return end

    for k, v in pairs(patch) do
        if k ~= "config" then
            center[k] = v
        end
    end

    if patch.config then
        center.config = center.config or {}
        center.config = deep_merge(center.config, patch.config)
    end
end

local function apply_patch_to_card(card, patch)
    if not card or not card.ability or type(card.ability) ~= "table" then return end
    if patch.config then
        card.ability = deep_merge(card.ability, patch.config)
    end

    -- price change needs some extra love
    if (patch.cost ~= nil or patch.cost_mult ~= nil) and card.set_cost then
        card:set_cost()
    end

    -- rarity change needs some extra love
    if patch.rarity ~= nil and card.set_rarity then
        card:set_rarity()
    end
end

---------------------------------------------------------------------------
-- Joker Stencil special-case:
-- The game computes its XMult dynamically (not from config), so we rescale the
-- computed value everywhere it matters (scoring + UI vars).
---------------------------------------------------------------------------

local function is_stencil(card)
    return card
        and card.config
        and card.config.center
        and card.config.center.key == "j_stencil"
end

local function stencil_per_slot_from_card(card)
    if card and card.ability and card.ability.extra and type(card.ability.extra.per_slot) == "number" then
        return card.ability.extra.per_slot
    end
    return nil
end

local function scale_stencil_x(vanilla_x, per_slot)
    vanilla_x = tonumber(vanilla_x)
    if not vanilla_x then return nil end
    per_slot = tonumber(per_slot) or 1
    return 1 + (vanilla_x - 1) * per_slot
end

-- Best-effort: compute the *vanilla* stencil X from the current joker area.
-- (Stencil effectively counts only "non-stencil jokers" as occupying slots.)
local function compute_vanilla_stencil_x_from_area()
    if not (G and G.jokers and G.jokers.cards and G.jokers.config) then return nil end
    local limit = tonumber(G.jokers.config.card_limit)
    if not limit then return nil end

    local stencils = 0
    local total = 0

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

local function rescale_stencil_card(card)
    if not is_stencil(card) then return end
    if not card.ability then return end

    local per = stencil_per_slot_from_card(card) or 1

    -- Prefer computing from area (always "vanilla"), fallback to existing ability fields
    local vanilla_x = compute_vanilla_stencil_x_from_area()
        or card.ability.x_mult
        or card.ability.xmult
        or (card.ability.extra and (card.ability.extra.x_mult or card.ability.extra.xmult))

    local scaled = scale_stencil_x(vanilla_x, per)
    if scaled then
        card.ability.x_mult = scaled
        card.ability._nightmarish_stencil_scaled = true
    end
end

local function rescale_stencil_return(card, ret)
    if not is_stencil(card) then return end
    if type(ret) ~= "table" then return end

    local per = stencil_per_slot_from_card(card) or 1

    -- Prefer computing from area so we never double-scale
    local vanilla_x = compute_vanilla_stencil_x_from_area()
    if not vanilla_x then
        -- fallback: try read from return table
        vanilla_x = ret.xmult or ret.x_mult or ret.Xmult_mod or ret.x_mult_mod
    end

    local scaled = scale_stencil_x(vanilla_x, per)
    if not scaled then return end

    -- Write back to all relevant keys if present
    if ret.xmult ~= nil then ret.xmult = scaled end
    if ret.x_mult ~= nil then ret.x_mult = scaled end
    if ret.Xmult_mod ~= nil then ret.Xmult_mod = scaled end
    if ret.x_mult_mod ~= nil then ret.x_mult_mod = scaled end

    -- Keep UI consistent too
    if card.ability then
        card.ability.x_mult = scaled
        card.ability._nightmarish_stencil_scaled = true
    end
end

---------------------------------------------------------------------------
-- Joker Raised Fist special-case:
-- Vanilla gives 2x the mult of the lowest-ranked card in hand.
-- We want 1x instead => halve the returned mult contribution.
---------------------------------------------------------------------------

local function is_raised_fist(card)
    return card
        and card.config
        and card.config.center
        and card.config.center.key == "j_raised_fist"
end

local function rescale_raised_fist_return(card, ret)
    if not is_raised_fist(card) then return end
    if type(ret) ~= "table" then return end

    local factor = 0.5

    -- Common return fields for mult contributions
    if ret.mult_mod ~= nil then ret.mult_mod = ret.mult_mod * factor end
    if ret.mult ~= nil then ret.mult = ret.mult * factor end
    if ret.mult_add ~= nil then ret.mult_add = ret.mult_add * factor end

    -- Best-effort: keep any cached ability field consistent if present
    if card.ability and card.ability.mult then
        card.ability.mult = card.ability.mult * factor
    end
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
            if (not lowest) or id < lowest then
                lowest = id
            end
        end
    end

    return lowest
end

-- Runtime scoring needs some extra work, meh
if Card and Card.set_ability then
    local Card_set_ability_ref = Card.set_ability
    function Card:set_ability(center, ...)
        Card_set_ability_ref(self, center, ...)

        local key = nil
        if center and type(center) == "table" and center.key then
            key = center.key
        elseif self.config and self.config.center and self.config.center.key then
            key = self.config.center.key
        end

        local patch = key and JOKER_PATCHES[key]
        if patch then
            apply_patch_to_card(self, patch)
        end

        -- Stencil: keep ability value in sync for UI (best-effort)
        rescale_stencil_card(self)
    end
end

if Card and Card.load then
    local Card_load_ref = Card.load
    function Card:load(card_table, ...)
        Card_load_ref(self, card_table, ...)

        local key = self.config and self.config.center and self.config.center.key
        local patch = key and JOKER_PATCHES[key]
        if patch then
            apply_patch_to_card(self, patch)
        end

        -- Stencil: keep ability value in sync for UI (best-effort)
        rescale_stencil_card(self)
    end
end

-- CRITICAL: Ensure Stencil is rescaled during actual joker evaluation/scoring,
-- because its computed value changes as joker slots fill/empty.
if Card and Card.calculate_joker then
    local Card_calculate_joker_ref = Card.calculate_joker
    function Card:calculate_joker(context, ...)
        local r1, r2, r3, r4 = Card_calculate_joker_ref(self, context, ...)

        -- Some pipelines return multiple tables (e.g. main + post). We rescale both.
        rescale_stencil_return(self, r1)
        rescale_stencil_return(self, r2)

        -- Raised Fist: halve its mult contribution (2x -> 1x)
        rescale_raised_fist_return(self, r1)
        rescale_raised_fist_return(self, r2)

        return r1, r2, r3, r4
    end
end

for joker_id, patch in pairs(JOKER_PATCHES) do
    -- Keep the rest intact: only add loc_txt/loc_vars for j_stencil
    local ownership = {
        inject = function(self)
            SMODS.Joker.inject(self)

            if patch.config then
                self.config = self.config or {}
                self.config = deep_merge(self.config, patch.config)
            end
            for k, v in pairs(patch) do
                if k ~= "config" then
                    self[k] = v
                end
            end

            if G and G.P_CENTERS and G.P_CENTERS[joker_id] then
                apply_patch_to_center(G.P_CENTERS[joker_id], patch)
            end
        end
    }

    if patch.rarity == 4 then
        ownership.in_pool = function(self, args)
            -- Legendary/rarity=4 should not appear from any random pool (shop, packs, etc.)
            -- Only allow if some caller explicitly marks it as a forced/legendary spawn.
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

    if joker_id == "j_stencil" then
        -- Override tooltip text to reflect the stencil nerf
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
            local per = 0.5
            if card and card.ability and card.ability.extra and type(card.ability.extra.per_slot) == "number" then
                per = card.ability.extra.per_slot
            end

            -- Prefer computing from current joker area so the "Currently X" stays accurate
            local vanilla_x = compute_vanilla_stencil_x_from_area()
            local current_x = nil

            if vanilla_x then
                current_x = scale_stencil_x(vanilla_x, per)
            elseif card and card.ability then
                -- fallback: use whatever the card currently has (and scale if we haven't tagged it)
                local x = card.ability.x_mult or card.ability.xmult
                if x and not card.ability._nightmarish_stencil_scaled then
                    x = scale_stencil_x(x, per)
                end
                current_x = x
            end

            current_x = tonumber(current_x) or 1

            -- keep card state consistent if possible
            if card and card.ability then
                card.ability.x_mult = current_x
                card.ability._nightmarish_stencil_scaled = true
            end

            return { vars = { current_x, per } }
        end
    end

    if joker_id == "j_raised_fist" then
        -- Vanilla-like tooltip, but reflecting the nerf (2x -> 1x)
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
            -- With the nerf, Raised Fist gives 1x the lowest rank (not 2x).
            local lowest = current_lowest_rank_in_hand()
            local mult = tonumber(lowest) or 0
            return { vars = { mult } }
        end
    end

    SMODS.Joker:take_ownership(joker_id, ownership)
end
