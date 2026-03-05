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
