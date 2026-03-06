return {
    -- Banana vanilla: config.extra = { odds = 4, mult = 15 }
    -- Make it score less (7 mult) AND the chance to be able to off itself 1 in 2
    -- Also, it is hilariously expensive now, costing 10 bucks
    j_gros_michel = {
        cost = 0,
        rarity = 4,
        config = { extra = { odds = 2, mult = 7 } }
    },

    -- Big Banana vanilla: config.extra = { odds = 1000, Xmult = 3 }
    -- Big Banana not so big anymore with only 2 XMult
    j_cavendish = {
        config = { extra = { Xmult = 2 } }
    },

    -- Bloodstone vanilla: config.extra = { odds = 3, Xmult = 2 }
    -- Make it rarer to hit: 1 in 6 instead of 1 in 3
    j_bloodstone = {
        config = { extra = { odds = 6 } }
        -- optionally also reduce reward:
        -- config = { extra = { odds = 6, Xmult = 1.75 } }
    },

    -- Mail-In Rebate vanilla: cost = 4, config.extra = 3 (dollars per matching discard)
    -- Make it cost more AND pay less
    j_mail = {
        cost = 7,
        config = { extra = 2 }
    },

    -- Space Joker vanilla: config.extra = 4 (odds)
    -- Make it less consistent: 1 in 8 instead of 1 in 4
    j_space = {
        config = { extra = 8 }
    },

    -- Business Card vanilla: config.extra = 2 (odds)
    -- Reduce proc chance: 1 in 4 instead of 1 in 2
    j_business = {
        config = { extra = 4 }
    },

    -- Joker Stencil vanilla: config = {}
    -- Nerf: each *additional* effective empty slot adds only 0.5 to the XMult (min X1).
    -- new_X = 1 + (vanilla_X - 1) * 0.5
    j_stencil = {
        config = { extra = { per_slot = 0.25 } }
    },

    j_joker = {
        cost = 4,
        rarity = 3,
        config = { mult = 1 }
    },

    j_greedy_joker = {
        config = { extra = { s_mult = 2 } }
    },

    j_wrathful_joker = {
        config = { extra = { s_mult = 2 } }
    },

    j_lusty_joker = {
        config = { extra = { s_mult = 2 } }
    },

    j_gluttenous_joker = {
        config = { extra = { s_mult = 2 } }
    },

    j_jolly = {
        config = { t_mult = 4 }
    },

    j_zany = {
        config = { t_mult = 6 }
    },

    j_mad = {
        config = { t_mult = 5 }
    },

    j_crazy = {
        config = { t_mult = 2 }
    },

    j_droll = {
        config = { t_mult = 5 }
    },

    j_sly = {
        config = { t_chips = 20 }
    },

    j_wily = {
        config = { t_chips = 40 }
    },

    j_clever = {
        config = { t_chips = 35 }
    },

    j_devious = {
        config = { t_chips = 40 }
    },

    j_crafty = {
        config = { t_chips = 35 }
    },


    j_half = {
        config = { extra = { mult = 10 } }
    },

    j_castle = {
        config = { extra = { chips = 0, chip_mod = 2 } }
    },

    j_four_fingers = {
        cost = 10,
        rarity = 3,
    },

    j_mime = {
        cost = 10,
        rarity = 3,
    },

    j_credit_card = {
        config = { extra = 10 }
    },

    j_ceremonial = {
        cost = 10,
        rarity = 3,
    },

    j_banner = {
        config = { extra = 20 }
    },

    j_mystic_summit = {
        config = { extra = { mult = 10 } }
    },

    j_marble = {
        cost = 10,
        rarity = 3,
    },

    j_loyalty_card = {
        config = { extra = {Xmult = 2.25, every = 7 } }
    },

    j_8_ball = {
        config = { extra = 8 }
    },

    j_misprint = {
        config = { extra = { max = 15, min = -3 } }
    },

    j_dusk = {
        cost = 10,
        rarity = 3,
    },

    j_raised_fist = {
        cost = 7,
        rarity = 2,
    },

    j_chaos = {
        cost = 6,
        rarity = 2,
    },


    j_fibonacci = {
        config = { extra = 5 }
    },

    j_steel_joker = {
        config = { extra = 0.075 }
    },

    j_scary_face = {
        config = { extra = 20 }
    },

    j_abstract = {
        config = { extra = 2 }
    },

    j_delayed_grat = {
        config = { extra = 1 }
    },

    j_hack = {
        cost = 8,
        rarity = 3,
    },

    j_pareidolia = {
        cost = 8,
    },

    j_even_steven = {
        config = { extra = 3 }
    },

    j_odd_todd = {
        config = { extra = 21 }
    },

    j_scholar = {
        config = { extra = { mult = 3, chips = 10 } }
    },

    j_supernova = {
        config = { extra = 0.5 }
    },

    j_ride_the_bus = {
        config = { extra = 0.5 }
    },


    j_egg = {
        config = { extra = 2 }
    },

    j_burglar = {
        config = { extra = 2 }
    },

    j_blackboard = {
        config = { extra = 2 }
    },

    j_runner = {
        config = { extra = { chips = 0, chip_mod = 10 } }
    },

    j_ice_cream = {
        config = { extra = { chips = 70, chip_mod = 10 } }
    },

    j_dna = {
        cost = 10,
    },

    j_splash = {
        rarity = 2,
        cost = 5,
    },

    j_blue_joker = {
        config = { extra = 1 }
    },

    j_sixth_sense = {
        cost = 9,
    },

    j_constellation = {
        config = { extra = 0.05, Xmult = 1 }
    },

    j_hiker = {
        config =  { extra = 3 }
    },

    j_faceless = {
        config = { extra = { dollars = 3, faces = 4 } }
    },

    j_green_joker = {
        config = {extra = { hand_add = 1, discard_sub = 2 } }
    },

    j_superposition = {
        cost = 6,
    },

    j_todo_list = {
        config = { extra = { dollars = 2, poker_hand = 'High Card' } }
    },


    j_card_sharp = {
        config = { extra = { Xmult = 2 } }
    },

    j_red_card = {
        config = { extra = 2 }
    },

    j_madness = {
        config = { extra = { chips = 0, chip_mod = 2 } }
    },

    j_square = {
        cost = 5,
        config = { extra = { chips = 0, chip_mod = 3 } }
    },

    j_seance = {
        config = { extra = { poker_hand = 'Royal Flush' } }
    },

    j_riff_raff = {
        config = { extra = 1 }
    },

    j_vampire = {
        config = { extra = 0.05, Xmult = 0.95 }
    },

    j_shortcut = {
        rarity = 3,
        cost = 9,
    },

    j_hologram = {
        config = { extra = 0.2, Xmult = 1 }
    },

    j_vagabond = {
        cost = 15
    },

    j_baron = {
        config = { extra = 1.15 }
    },

    j_cloud_9 = {
        cost = 9
    },

    j_rocket = {
        config = { extra = { dollars = 1, increase = 1 } }
    },

    j_obelisk = {
        config = { extra = 0.1, Xmult = 1 }
    },


    j_midas_mask = {
        rarity = 3,
        cost = 9
    },

    j_luchador = {
        rarity = 3,
        cost = 8
    },

    j_photograph = {
        config = { extra = 1.45 }
    },

    j_gift = {
        rarity = 3,
        cost = 9
    },

    j_turtle_bean = {
        config = { extra = { h_size = 4, h_mod = 2 } }
    },

    j_erosion = {
        config = { extra = 2 }
    },

    j_reserved_parking = {
        config = { extra = { odds = 4, dollars = 1} }
    },

    j_to_the_moon = {
        cost = 9
    },

    j_hallucination = {
        config = { extra = 4 }
    },

    j_fortune_teller = {
        config = { extra = 0.5 }
    },

    j_juggler = {
        rarity = 2,
        cost = 6,
    },

    j_drunkard = {
        rarity = 2,
        cost = 6,
    },

    j_stone = {
        config = { extra = 15 }
    },

    j_golden = {
        config = { extra = 2 }
    },


    j_lucky_cat = {
        config = { Xmult = 1, extra = 0.1 }
    },

    j_baseball = {
        config = { extra = 1.2 }
    },

    j_bull = {
        config = { extra = 1 }
    },

    j_diet_cola = {
        rarity = 3,
        cost = 8,
    },

    j_trading = {
        config = { extra = 1 }
    },

    j_flash = {
        config = { extra = 1, mult = 0 }
    },

    j_popcorn = {
        config = { mult = 15, extra = 3 }
    },

    j_trousers = {
        config = { extra = 1 }
    },

    j_ancient = {
        config = { extra = 1.2 }
    },

    j_ramen = {
        config = { Xmult = 2, extra = 0.05 }
    },

    j_walkie_talkie = {
        config = { extra = { chips = 8, mult = 2 } }
    },

    j_selzer = {
        config = { extra = 5 }
    },

    j_smiley = {
        config = { extra = 3 }
    },

    j_campfire = {
        config = { extra = 0.1 }
    },


    j_ticket = {
        rarity = 2,
        config = { extra = 2 }
    },

    j_mr_bones = {
        rarity = 3,
        cost = 8,
    },

    j_acrobat = {
        config = { extra = 2 }
    },

    j_sock_and_buskin = {
        rarity = 3,
        cost = 8,
    },

    j_swashbuckler = {
        config = { mult = 0.5 }
    },

    j_troubadour = {
        config = { extra = { h_size = 2, h_plays = -2 } }
    },

    j_certificate = {
        cost = 9
    },

    j_smeared = {
        cost = 10
    },

    j_throwback = {
        config = { extra = 0.15 }
    },

    j_hanging_chad = {
        rarity = 2,
        config = { extra = 1 }
    },

    j_rough_gem = {
        cost = 9
    },

    j_arrowhead = {
        config = { extra = 35 }
    },

    j_onyx_agate = {
        config = { extra = 5 }
    },

    j_glass = {
        config = { extra = 0.5, Xmult = 1 }
    },


    j_ring_master = {
        rarity = 3,
        cost = 7
    },

    j_flower_pot = {
        config = { extra = 2 }
    },

    j_wee = {
        config = { extra = { chips = 0, chip_mod = 5 } }
    },

    j_merry_andy = {
        config = { d_size = 2, h_size = -2 }
    },

    j_oops = {
        rarity = 3,
        cost = 6
    },

    j_idol = {
        config = { extra = 1.55 }
    },

    j_seeing_double = {
        config = { extra = 1.75 }
    },

    j_matador = {
        config = { extra = 5 }
    },

    j_hit_the_road = {
        config = { extra = 0.2 }
    },

    j_duo = {
        config = { Xmult = 1.5, type = 'Three of a Kind' }
    },

    j_trio = {
        config = { Xmult = 2, type = 'Four of a Kind' }
    },

    j_family = {
        config = { Xmult = 3, type = 'Five of a Kind' }
    },

    j_order = {
        config = { Xmult = 2.5, type = 'Straight Flush' }
    },

    j_tribe = {
        config = { Xmult = 1.5, type = 'Flush House' }
    },


    j_stuntman = {
        config = { extra = { h_size = 2, chip_mod = 175 } }
    },

    j_invisible = {
        config = { extra = 4 }
    },

    j_satellite = {
        cost = 8
    },

    j_shoot_the_moon = {
        config = { extra = 7 }
    },

    j_drivers_license = {
        config = { extra = 2.25 }
    },

    j_cartomancer = {
        cost = 10
    },

    j_astronomer = {
        cost = 10
    },

    j_burnt = {
        cost = 12,
    },

    j_bootstraps = {
        config = { extra = { mult = 1, dollars = 5 } }
    },

    j_caino = {
        cost = 0,
        config = { extra = 0.5 }
    },

    j_triboulet = {
        cost = 0,
        config = { extra = 1.75 }
    },

    j_yorick = {
        cost = 0,
        config = { extra = { xmult = 0.5, discards = 15 } }
    },

    j_perkeo = {
        cost = 0,
    },

    j_chicot = {
        cost = 0,
    },

    j_blueprint = {
        cost = 0,
        rarity = 4,
        config = { extra = { blueprint_compat = false } }
    },

    j_brainstorm = {
        cost = 0,
        rarity = 4,
        config = { extra = { blueprint_compat = false } }
    },
}
