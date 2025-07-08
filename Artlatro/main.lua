--- STEAMODDED HEADER
--- MOD_NAME: Artlatro
--- MOD_ID: Artlatro
--- MOD_AUTHOR: [EricTheToon]
--- MOD_DESCRIPTION: A terribly coded mod to add Artfight users to Balatro.
--- BADGE_COLOUR: b7f24f
--- PREFIX: art
--- PRIORITY: -69420
--- DEPENDENCIES: [Steamodded>=0.9.8,]
--- VERSION: 1.0 Release
----------------------------------------------
------------MOD CODE-------------------------

--setup stuff
SMODS.optional_features.cardareas.unscored = true
SMODS.current_mod.optional_features = function()
    return {
        retrigger_joker = true,
		post_trigger = true,
    }
end

-- Artlatro logo
SMODS.Atlas{
	key = 'balatro',
    path = 'balatro.png',
    px = 332 ,
    py = 216 ,
    prefix_config = {key = false}
}

-- Artlatro Mod Icon
SMODS.Atlas({
    key = 'modicon',
    path = 'modicon.png',
    px = '34',
    py = '34'
})

-- Jokers atlas
SMODS.Atlas{
    key = 'Jokers', --atlas key
    path = 'Jokers.png', --atlas' path in (yourMod)/assets/1x or (yourMod)/assets/2x
    px = 71.1, --width of one card
    py = 95 -- height of one card
}

--balala artfighters real

--Darth Kalamali was here but boogerbox killed them rip


--Estro La Suli from KingThreshie
SMODS.Joker {
    key = 'Estro',
    loc_txt = {
        name = 'Estro La Suli',
        text = {
            "This Joker gains {C:mult}+#1#{} Mult",
            "per {C:attention}consecutive{} hand",
            "without a scoring {C:attention}Ace{} card",
            "{C:inactive}Currently {C:mult}+#2#{} {C:inactive}Mult",
        }
    },
    rarity = 1,
    pos = {x = 0, y = 1},
    atlas = 'Jokers',
    cost = 6,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    config = { extra = { mult_gain = 1, mult = 0 } },
    
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_gain, card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        -- Check if a hand was just scored
        if context.before and context.main_eval and not context.blueprint then
            local has_ace = false
            for _, c in ipairs(context.scoring_hand or {}) do
                if c:get_id() == 14 then
                    has_ace = true
                    break
                end
            end

            if has_ace then
                local last_mult = card.ability.extra.mult
                card.ability.extra.mult = 0
                if last_mult > 0 then
                    return {
                        message = localize('k_reset')
                    }
                end
            else
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
            end
        end

        -- Apply Joker mult
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}

--Midnight Sushi from Aft3rwards
SMODS.Joker {
    key = 'Midnight',
    loc_txt = {
        name = 'Midnight Sushi',
        text = {
            "{C:mult}+#1#{} Mult every time a {C:money}lucky card{} fails to trigger",
			"{C:inactive}Currently{} {C:mult}+#2#{} {C:inactive}Mult",
        }
    },
    rarity = 2,
    pos = {x = 3, y = 0},
    atlas = 'Jokers',
    cost = 6,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
	config = { extra = { Xmult_gain = 3, Xmult = 0 } },
	
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_lucky

        return { vars = { card.ability.extra.Xmult_gain, card.ability.extra.Xmult } }
    end,
	
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card.ability.name == 'Lucky Card' and not context.other_card.lucky_trigger and not context.blueprint then
            card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_gain
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.MULT,
                message_card = card
            }
        end
        if context.joker_main then
            return {
                mult = card.ability.extra.Xmult
            }
        end
    end,
	
    in_pool = function(self, args) --equivalent to `enhancement_gate = 'm_lucky'`
        for _, playing_card in ipairs(G.playing_cards or {}) do
            if SMODS.has_enhancement(playing_card, 'm_lucky') then
                return true
            end
        end
        return false
    end
}



--Fursona from Sowa
SMODS.Joker {
    key = 'Sowa',
    loc_txt = {
        name = 'Sowa',
        text = {
            "Gain {X:mult,C:white}X#1#{} Mult every time a {C:tarot}Tarot{} is used",
			"{C:green}#4# in #3#{} odds to be {C:mult}destroyed{} instead",
			"{C:inactive}Currently{} {X:mult,C:white}X#2#{} {C:inactive}Mult",
        }
    },
    rarity = 2,
    pos = {x = 3, y = 1},
    atlas = 'Jokers',
    cost = 7,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
	config = { extra = { Xmult_gain = 0.75, Xmult = 1, odds = 6 } },
	
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult_gain, card.ability.extra.Xmult, card.ability.extra.odds, G.GAME.probabilities.normal} }
    end,
	
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint and context.consumeable.ability.set == "Tarot" then
			if pseudorandom('Sowa') < G.GAME.probabilities.normal/card.ability.extra.odds then
				card:start_dissolve()
			else
				card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_gain
					return {
					message = localize('k_upgrade_ex'),
					colour = G.C.MULT,
					message_card = card
				}
			end
        end
        if context.joker_main then
            return {
                message = localize{type='variable', key='a_xmult', vars={card.ability.extra.Xmult}},
                Xmult_mod = card.ability.extra.Xmult,
            }
        end
    end,
	
    in_pool = function(self, args) --equivalent to `enhancement_gate = 'm_lucky'`
        for _, playing_card in ipairs(G.playing_cards or {}) do
            if SMODS.has_enhancement(playing_card, 'm_lucky') then
                return true
            end
        end
        return false
    end
}

--Tackle from rustytacklebox
SMODS.Joker{
    key = "Tackle",
    loc_txt = {
        name = "Tackle",
        text = {
            "Gain {X:mult,C:white}X1{} for every {C:attention}hand size{} above {C:attention}8{}",
            "{C:inactive}Currently {X:mult,C:white}X#1#{C:inactive} Mult",
        }
    },
    rarity = 3,
    atlas = "Jokers",
    pos = { x = 2, y = 1 },
    cost = 10,
    blueprint_compat = false,
    config = { 
        extra = {
            Xmult = 1,
        }
    },

    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.extra.Xmult,
            }
        }
    end,
	
	-- if handsize changes change the xmult (do not allow it to go below 1)
	update = function(self, card)
		--only update during a run (hand size does not exist before the run starts)
		if G.STAGE == G.STAGES.RUN then
			local value = G.hand.config.card_limit - 8 + 1
			card.ability.extra.Xmult = math.max(1, value)
		end
	end,

	
    calculate = function(self, card, context)
        if context.joker_main then
			return {
				message = localize{type='variable', key='a_xmult', vars={card.ability.extra.Xmult}},
                Xmult_mod = card.ability.extra.Xmult,
            } 
        end
    end
}

--Caine from Fuzznz
SMODS.Joker{
    key = "Caine",
    loc_txt = {
        name = "Caine",
        text = {
            "When {C:mult}red seal{} is {C:attention}played{} duplicate that card",
            "remove the {C:mult}red seal{} and make it a {C:money}gold{} card"
        }
    },
    rarity = 3,
    atlas = "Jokers",
    pos = { x = 0, y = 2 },
    soul_pos = { x = 1, y = 2 },
    cost = 10,
    blueprint_compat = false,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card and context.other_card.seal == 'Red' then
            local source_card = context.other_card

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
					local copy = copy_card(source_card)
                    -- Add to deck + place in hand
                    G.hand:emplace(copy)
                    copy:add_to_deck()
                    G.deck.config.card_limit = G.deck.config.card_limit + 1
                    table.insert(G.playing_cards, copy)
                    copy:start_materialize(nil, nil)

                    -- Remove red seal and apply gold effect
                    copy.seal = nil
                    copy:set_ability(G.P_CENTERS.m_gold)

                    -- Trigger any effects
                    playing_card_joker_effects({copy})

                    return true
                end
            }))
        end
    end
}





--Heknox Blatro from Lumimiwa
SMODS.Joker {
    key = 'Heknox',
    loc_txt = {
        name = 'Heknox Blatro',
        text = {
            "Wh3n {C:attention}Bl1nd $3l3ct3d{}",
            "{C:mult}D3$tr0y{} Th3 J0k3r T0 H1$ {C:attention}L3ft{}",
            "4dd 4 {C:attention}Th1rd{} 0f 1t$ $3ll V4lu3 T0 Th3 Xmult",
            "{C:inactive}Curr3ntly{} {X:mult,C:white}X#1#{} {C:inactive}Mult =)"
        }
    },
    config = {extra = {Xmult = 1}},
    rarity = 3,
    pos = {x = 2, y = 0},
    atlas = 'Jokers',
    cost = 8,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
	loc_vars = function(self, info_queue, card)
		return {vars = {card.ability.extra.Xmult}}
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local my_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then
                    my_pos = i
                    break
                end
            end
            if my_pos and G.jokers.cards[my_pos - 1] and not G.jokers.cards[my_pos - 1].ability.eternal and not G.jokers.cards[my_pos - 1].getting_sliced then
                local sliced_card = G.jokers.cards[my_pos - 1]
                sliced_card.getting_sliced = true -- Make sure to do this on destruction effects
                G.GAME.joker_buffer = G.GAME.joker_buffer - 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.GAME.joker_buffer = 0
                        card.ability.extra.Xmult = card.ability.extra.Xmult + sliced_card.sell_cost / 3
                        card:juice_up(0.8, 0.8)
                        sliced_card:start_dissolve({ HEX("57ecab") }, nil, 1.6)
                        play_sound('slice1', 0.96 + math.random() * 0.08)
                        return true
                    end
                }))
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.Mult,
                    card = card
                }
            end
        end
        if context.joker_main then
            return {
                Xmult = card.ability.extra.Xmult
            }
        end
    end
}


--Azkren from yuuxxii
SMODS.Consumable{
    key = 'Azkren',
    set = 'Spectral',
    atlas = 'Jokers',
    pos = {x = 4, y = 0},
    loc_txt = {
        name = 'Azkren',
        text = {
            'Steal {C:attention}#1#{} random {C:spectral}Spectral{} cards',
            '{C:inactive}(Must have room)',
        },
    },
    config = {
        extra = { cards = 2 },
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.cards}}
    end,

    can_use = function(self, card)
        -- Always usable
        return true
    end,

    use = function(self, card, area, copier)
        local max_steal = card.ability.extra.cards or 1
        local room = G.consumeables.config.card_limit - (#G.consumeables.cards + G.GAME.consumeable_buffer)
        local to_steal = math.min(max_steal, room)

        for i = 1, to_steal do
            local new_card = create_card('Spectral', G.consumeables)
			new_card:add_to_deck()
			G.consumeables:emplace(new_card)
        end
    end
}

--Silvia from Ellathefirefox
SMODS.Consumable{
    key = 'Silvia',
    set = 'Spectral',
    atlas = 'Jokers',
    pos = {x = 4, y = 1},
    loc_txt = {
        name = 'Silvia',
        text = {
            '{C:mult}Destroy{} all {C:attention}Jacks{} in the deck',
            'Permanently add {C:chips}+#1#{} Chips to played hands',
            'For each {C:attention}Jack{} destroyed',
        },
    },
    config = {
        extra = { chips_gain = 10, chips = 0 },
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.chips_gain, card.ability.extra.chips}}
    end,

    can_use = function(self, card)
        return true
    end,

    use = function(self, card, area, copier)
        local jacks_destroyed = 0
        if G.playing_cards then
            for _, c in ipairs(G.playing_cards) do
                if c:get_id() == 11 then
                    jacks_destroyed = jacks_destroyed + 1
                    c:start_dissolve()
                end
            end
        end
        if jacks_destroyed > 0 then
            local total_gain = jacks_destroyed * card.ability.extra.chips_gain
            card.ability.extra.chips = card.ability.extra.chips + total_gain

            local _card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, 'c_art_Silvia')
            _card:add_to_deck()
            G.vouchers:emplace(_card)
            _card.ability.extra.chips = card.ability.extra.chips
        end
    end,
	
	calculate = function(self, card, context)
        if context.joker_main then
			return {
                message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chips } },
                chip_mod = card.ability.extra.chips,
                colour = G.C.CHIPS
            }
        end
    end,
}


--Epic from redfoxlol
SMODS.Consumable{
    key = 'Epic',
    set = 'Tarot',
    atlas = 'Jokers',
    pos = {x = 1, y = 1},
    loc_txt = {
        name = 'Epic',
        text = {
            'Select up to {C:attention}#1#{} cards randomize their {C:attention}suits{}',
        },
    },
    config = {
        extra = {
            cards = 5,
        }
    },

    loc_vars = function(self, info_queue, center)
        if center and center.ability and center.ability.extra then
            return {vars = {center.ability.extra.cards}} 
        end
        return {vars = {}}
    end,

    can_use = function(self, card)
        return G and G.hand and G.hand.highlighted and card.ability and card.ability.extra and 
            card.ability.extra.cards and #G.hand.highlighted > 0 and #G.hand.highlighted <= card.ability.extra.cards
    end,

    use = function(self, card, area, copier)
        if G and G.hand and G.hand.highlighted and #G.hand.highlighted > 0 then
            for i = 1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1 * i,
                    func = function()
                        local target_card = G.hand.highlighted[i]

                        -- Flip before change
                        target_card:flip()
                        play_sound("tarot1", 1.0, 0.6)
                        target_card:juice_up(0.3, 0.3)

                        -- Unflip and apply random suit
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.3,
                            func = function()
                                target_card:flip()
                                
                                local suits = {"Hearts", "Diamonds", "Clubs", "Spades"}
                                local new_suit = suits[math.random(#suits)]
                                SMODS.change_base(target_card, new_suit)

                                play_sound("tarot2", 1.0, 0.6)
                                target_card:juice_up(0.3, 0.3)
                                return true
                            end
                        }))

                        return true
                    end
                }))
            end
        end
    end,
}

----------------------------------------------
------------EPIC CODE END----------------------

----------------------------------------------
------------FOSSIL SEAL CODE BEGIN----------------------

SMODS.Atlas{
    key = 'Jokers', --atlas key
    path = 'Jokers.png', --atlas' path in (yourMod)/assets/1x or (yourMod)/assets/2x
    px = 71.1, --width of one card
    py = 95 -- height of one card
}
SMODS.Seal {
	name = "Fossil Seal",
    key = 'Fossil',
    atlas = 'Jokers',
    pos = { x = 0, y = 0 },
    badge_colour = HEX("ba8c25"),
    loc_txt = {
		label = 'Fossil Seal',
        name = 'Fossil Seal',
        text = {
			'{C:mult}+10{} Mult if {C:attention}held{} in hand',
        }
    },
	
	calculate = function(self, card, context)
        if context.cardarea == G.hand and context.main_scoring then
			return {
				mult = 10,
				card = self,
			}
        end
	end
}
	
----------------------------------------------
------------FOSSIL SEAL CODE END----------------------

----------------------------------------------
------------CRYSTAL SEAL CODE END----------------------

SMODS.Seal {
	name = "Crystal Seal",
    key = 'Crystal',
    atlas = 'Jokers',
    pos = { x = 1, y = 0 },
    badge_colour = HEX("d35e88"),
    loc_txt = {
		label = 'Crystal Seal',
        name = 'Crystal Seal',
        text = {
			'Create a random {C:tarot}Tarot{} card when {C:attention}played{}',
			'{C:inactive}(Must have room)',
        }
    },
	
	calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring or context.cardarea == "unscored" and context.main_scoring then
			 if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
				local new_card = create_card('Tarot', G.consumeables)
				new_card:add_to_deck()
				G.consumeables:emplace(new_card)
			end
        end
	end
}
----------------------------------------------
------------CRYSTAL SEAL CODE END----------------------


----------------------------------------------
------------MOD CODE END----------------------
