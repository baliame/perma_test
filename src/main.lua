SMODS.Atlas({key="ptestcards", path="cards.png", px = 71, py = 95, atlas_table="ASSET_ATLAS"}):register()

SMODS.Enhancement {
    key = "everything",
    loc_txt = {
        name = 'Everything',
        label = 'Everything',
        text = {
            '{C:chips}#1#{} extra chips',
            '{X:chips,C:white}X#2#{} chips',
            '{C:mult}#3#{} Mult',
            '{X:mult,C:white}X#4#{} Mult',
            '{C:chips}#5#{} chips when held',
            '{X:chips,C:white}X#6#{} chips when held',
            '{C:mult}#7#{} Mult when held',
            '{X:mult,C:white}X#8#{} Mult when held',
            '{C:money}#9#{} when scored',
            '{C:money}#10#{} if held at end of round',
        }
    },
    config = {
        chips = 1,
        x_chips = 2,
        mult = 3,
        x_mult = 4,
        h_chips = 5,
        h_x_chips = 6,
        h_mult = 7,
        h_x_mult = 8,
        p_dollars = 9,
        h_dollars = 10,
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {
            SMODS.signed(card.ability.chips),
            card.ability.x_chips,
            SMODS.signed(card.ability.mult),
            card.ability.x_mult,
            SMODS.signed(card.ability.h_chips),
            card.ability.h_x_chips,
            SMODS.signed(card.ability.h_mult),
            card.ability.h_x_mult,
            SMODS.signed_dollars(card.ability.p_dollars),
            SMODS.signed_dollars(card.ability.h_dollars),
        }}
    end,
    atlas = "ptestcards",
    pos = {x = 1, y = 0},
}

SMODS.Consumable {
    set = "Tarot",
    key = "make_everything",
    loc_txt = {
        name = "Make Everything",
        text = {"Convert selected cards into {C:attention}Everything{} cards"},
    },
    atlas = "ptestcards",
    pos = {x = 0, y = 0},
    config = {mod_conv = 'm_ptest_everything', min_highlighted = 1},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS['m_ptest_everything']
    end,
    can_use = function(self, card)
        return #G.hand.highlighted >= card.ability.consumeable.min_highlighted
    end,
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        for _, p_card in ipairs(G.hand.highlighted) do
            p_card:set_ability(card.ability.consumeable.mod_conv)
        end
        used_tarot:juice_up()
    end
}

function PermaFactory(perma_var)
    local ret = function(self, card, area, copier)
        local used_tarot = copier or card
        for _, p_card in ipairs(G.hand.highlighted) do
            p_card.ability[perma_var] = p_card.ability[perma_var] + card.ability.consumeable.value
        end
        used_tarot:juice_up()
    end
    return ret
end

local pair_names = {
    perma_bonus = "Chips",
    perma_x_chips = "XChips",
    perma_mult = "Mult",
    perma_x_mult = "XMult",
    perma_h_chips = "Hand Chips",
    perma_h_x_chips = "Hand XChips",
    perma_h_mult = "Hand Mult",
    perma_h_x_mult = "Hand XMult",
    perma_p_dollars = "Dollars",
    perma_h_dollars = "End of Round Dollars",
}

for key, name in pairs(pair_names) do
    SMODS.Consumable {
        set = "Tarot",
        key = "add_" .. key,
        loc_txt = {
            name = "Add Perma " .. name,
            text = {"Add {C:attention}+#1#{} permanent "..name.." to highlighted cards."},
        },
        atlas = "ptestcards",
        pos = {x = 0, y = 0},
        config = {value = string.find(key, '_x_') and 0.5 or 10, min_highlighted = 1},
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.consumeable.value}}
        end,
        can_use = function(self, card)
            return #G.hand.highlighted >= card.ability.consumeable.min_highlighted
        end,
        use = PermaFactory(key)
    }

    SMODS.Consumable {
        set = "Tarot",
        key = "subtract_" .. key,
        loc_txt = {
            name = "Subtract Perma " .. name,
            text = {"Add {C:attention}#1#{} permanent "..name.." to highlighted cards."},
        },
        atlas = "ptestcards",
        pos = {x = 0, y = 0},
        config = {value = string.find(key, '_x_') and -0.5 or -10, min_highlighted = 1},
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.consumeable.value}}
        end,
        can_use = function(self, card)
            return #G.hand.highlighted >= card.ability.consumeable.min_highlighted
        end,
        use = PermaFactory(key)
    }
end

SMODS.Consumable {
    set = "Tarot",
    key = "consumeable_slots",
    loc_txt = {
        name = "Add consumable slots",
        text = {"Adds a lot of consumable slots."},
    },
    atlas = "ptestcards",
    pos = {x = 0, y = 0},
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        G.consumeables.config.card_limit = 50
        used_tarot:juice_up()
    end
}

SMODS.Consumable {
    set = "Tarot",
    key = "evaluate_card",
    loc_txt = {
        name = "Evaluate Card",
        text = {"Print the evaluation of highlighted card as if played."},
    },
    atlas = "ptestcards",
    pos = {x = 0, y = 0},
    config = {highlighted = 1},
    can_use = function(self, card)
        return #G.hand.highlighted == card.ability.consumeable.highlighted
    end,
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        print(tprint(eval_card(G.hand.highlighted[1], {main_scoring = true, cardarea = G.play}), 0))
        used_tarot:juice_up()
    end
}

SMODS.Consumable {
    set = "Tarot",
    key = "evaluate_card_held",
    loc_txt = {
        name = "Evaluate Card",
        text = {"Print the evaluation of highlighted card as if held."},
    },
    atlas = "ptestcards",
    pos = {x = 0, y = 0},
    config = {highlighted = 1},
    can_use = function(self, card)
        return #G.hand.highlighted == card.ability.consumeable.highlighted
    end,
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        print(tprint(eval_card(G.hand.highlighted[1], {main_scoring = true, cardarea = G.hand}), 0))
        used_tarot:juice_up()
    end
}