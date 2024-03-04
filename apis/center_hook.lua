--[[
    an attempt at making a hook for adding centers
    (card back, joker, voucher, booster pack, editions, card type,
    consumable cards)
]]

patched_use_consumeable = false
patched_spectral_collection = false
mod_id = "center_hook"
mod_name = "Center Hook"
mod_version = "0.3"
mod_author = "arachnei"

--get rid of debug messages if user doesnt have devtools
if (sendDebugMessage == nil) then
    sendDebugMessage = function(_)
    end
end
function initCenterHook()
    local centerHook = {}

    local c_base = {
        max = 500,
        freq = 1,
        line = 'base',
        name = "Default Base",
        pos = { x = 1, y = 0 },
        set = "Default",
        label =
        'Base Card',
        effect = "Base",
        cost_mult = 1.0,
        config = {}
    }

    local sets = {
        "Joker",
        "Tarot",
        "Planet",
        "Spectral",
        "Voucher",
        "Back",
        "Enhanced",
        "Edition",
        "Booster",
    }

    local jokerData = {
        "order",            --int: the order it appears in collection
        "unlocked",         --bool: unlocked or not
        "discovered",       --bool: discovered or not
        "blueprint_compat", --bool: blueprint can copy or not
        "eternal_compat",   --bool: can be eternal or not
        "rarity",           --int(1-4): rarity
        "cost",             --int: shop cost
        "name",             --str: name
        "pos",              --{x:int, y:int}: defines position of its card image in the sprite sheet
        "set",              --str("Joker"): type of center
        "effect",           --str: (Optional) 1-5 word description of effect
        "cost_mult",        --float(1.0): idk
        "config",
        --[[
            config is a table that contains any data (usually numerical)
            that you want in your card. i.e Misprint's config is
            {extra = {max = 23, min = 0}}. The following are variables
            in config that are NOT in extra.
            (70% of the time these variables just get put in extra anyways lmfao)

            mult: int: multiplier additive bonus
            extra: table: put anything that isnt in this list in here
            t_mult: int: multiplier additive bonus when a certain hand type is played
            t_chips: int: the chips additive bonus when a certain hand type is played
            type: str: the hand type for t_mult or t_chips to apply ('Pair', 'Three of a Kind', 'Four of a Kind', 'Straight', 'Flush')
            Xmult: float: multiplier multiplicative bonus
            h_size: int: Juggler's bonus to hand size (can be negative)
            d_size: int: Drunkard's bonus to discards (maybe can be negative)

        ]]
        "enhancement_gate", --str: (Optional) defines card enhancements that are required in the deck before the joker is offered (im unsure if you can put multiple)
        "no_pool_flag",     --str: (Optional) defines flags that will remove this joker from the pool (ex: gros_michel_extinct)
        "yes_pool_flag",    --str: (Optional) defines flags that will add this joker to the pool (ex: gros_michel_extinct)
        "unlock_condition"
        --[[
            defines the unlock requirement of the joker.
            type: type of condition
                "modify_jokers": add enhancements to jokers (Bootstraps)
                    extra:
                        "polychrome": bool: check for polychrome modifiers
                        "count": int: number of modifiers to look for
                "c_cards_sold": sell centers (Burnt Joker)
                    extra: int: number of centers sold
                "discover_amount": discover cards in the following collections (Astronomer, Cartomancer)
                    "planet_count": how many planets
                    "tarot_count": how many tarots
                "modify_deck": modify playing cards (Driver's License, Glass Joker, Onyx Agate, Arrowhead, Bloodstone, Rough Gem, Smeared Joker)
                    extra:
                        count: int: how many modified playing cards
                        tally: str: 'total', all modification types
                        enhancement: str: 'Glass Card' 'Wild Card', type of modification
                        e_key: str: 'm_glass' 'm_wild', the P_CENTER key of the modification
                        suit: str: Suit of cards in the deck
                "play_all_hearts": play all heart cards in your deck in 1 round (Shoot the Moon)
                "money":  have a certain amount of money (Sateillite)
                    extra: int: amount of money
                "discard_custom": discard a certain hand type (unsure how to define) (Brainstorm, Hit the Road)
                "win_custom": win while doing a certain thing (unsure how to define) (Invisible Joker, Blueprint)
                "chip_score": play a hand that gives a certain amount of chips (Stuntman, The Idol, Oops! All 6s)
                    "chips": int: the amount of chips to have to unlock
                "win_no_hand": win without playing a certain hand type (The Duo, The Trio, The Family, The Order, The Tribe)
                    extra: str: define the hand type that was not played: 'Pair', 'Three of a Kind', 'Four of a Kind', 'Straight', 'Flush'
                "hand_contents": play a certain hand (Seeing Double, Golden Ticket)
                    extra: str: the hand: 'four 7 of Clubs' 'Gold'(5 gold cards)
                "win": win within a certain number of rounds (Merry Andy, Wee Joker)
                    n_rounds: int: the amount of rounds to win before
                "ante_up": reach a certain ante (Flower Pot, Showman)
                    ante: int: the ante to reach
                "round_win": win in 1 round with no discards(Matador)
                    extra: 'High Card', adds condition of certain hand type (Hanging Chad)
                    extra: int: win in 1 round this many times (this might allow discards) (Troubadour)
                "continue_game": Continue a saved run from the main menu (Throwback)
                "double_gold": Have a gold seal on a gold card (Certificate)
                "c_jokers_sold": Sell jokers (Swashbuckler)
                    extra: int: how many jokers
                "c_face_cards_played": play face cards (Sock and Buskin)
                    extra: int: how many face cards
                "c_hands_played": play hands (Acrobat)
                    extra: int: how many hands
                "c_losses": lose runs (Mr. Bones)
                    extra: int: how many runs
        ]]
    }
    local tarotData = {
        "order",
        "discovered",
        "cost",
        "consumeable",
        "name",
        "pos",
        "set",
        "effect",
        "cost_mult",
        "config"
    }
    local voucherData = {
        "order",
        "discovered",
        "unlocked",
        "available",
        "cost",
        "name",
        "pos",
        "set",
        "config"
    }
    local backData = {
        "name",
        "stake",
        "unlocked",
        "order",
        "pos",
        "set",
        "config",
        "discovered",
        "unlock_condition",
        "omit"
    }

    centerHook.consumeableEffects = {}

    function centerHook:addJoker(id, name, order, unlocked, discovered, cost, pos, effect, config, desc, rarity, blueprint_compat, eternal_compat, no_pool_flag, yes_pool_flag, unlock_condition)
        --defaults
        id = id or "j_Joker_Placeholder" .. #G.P_CENTER_POOLS["Joker"] + 1
        name = name or "Joker Placeholder"
        order = order or #G.P_CENTER_POOLS["Joker"] + 1
        discovered = discovered or true
        cost = cost or 4
        pos = pos or { x = 9, y = 9 } --default joker sprite
        effect = effect or ""
        config = config or {}
        desc = desc or {"Placeholder"}
        rarity = rarity or 1
        unlocked = unlocked or true
        blueprint_compat = blueprint_compat or false
        eternal_compat = eternal_compat or false
        no_pool_flag = no_pool_flag or nil
        yes_pool_flag = yes_pool_flag or nil
        unlock_condition = unlock_condition or nil
        
        --joker object
        local newJoker = {
            order = order,
            discovered = discovered,
            cost = cost,
            consumeable = false,
            name = name,
            pos = pos,
            set = "Joker",
            config = config,
            key = id, 
            rarity = rarity, 
            unlocked = unlocked,
            blueprint_compat = blueprint_compat,
            eternal_compat = eternal_compat,
            no_pool_flag = no_pool_flag,
            yes_pool_flag = yes_pool_flag,
            unlock_condition = unlock_condition
        }
    
        --add it to all the game tables
        table.insert(G.P_CENTER_POOLS["Joker"], newJoker)
        G.P_CENTERS[id] = newJoker
    
        --add name + description to the localization object
        local newJokerText = {name=name, text=desc, text_parsed={}, name_parsed={}}
        for _, line in ipairs(desc) do
            newJokerText.text_parsed[#newJokerText.text_parsed+1] = loc_parse_string(line)
        end
        for _, line in ipairs(type(newJokerText.name) == 'table' and newJokerText.name or {newJoker.name}) do
            newJokerText.name_parsed[#newJokerText.name_parsed+1] = loc_parse_string(line)
        end
        G.localization.descriptions.Joker[id] = newJokerText

        return newJoker, newJokerText
    end

    --VERY WIP
    function centerHook:addPlanet(id, name, order, discovered, cost, freq, cost_mult, config)
        id = id or "c_pl_placeholder"
        name = name or "Planet Placeholder"
        order = order or #G.P_CENTER_POOLS["Planet"] + 1
        discovered = discovered or true
        cost = cost or 3
        freq = freq or 1
        cost_mult = cost_mult or 1.0
        config = config or {}
        local newPlanet = {
            order = order,
            discovered = discovered,
            cost = cost,
            consumeable = true,
            freq = freq,
            name = name,
            pos = { x = 7, y = 2 }, --blank planet sprite
            set = "Planet",
            effect = "Hand Upgrade",
            cost_mult = cost_mult,
            config = config
        }
        newPlanet.key = id
        table.insert(G.P_CENTER_POOLS['Planet'], newPlanet)
        table.insert(G.P_CENTER_POOLS['Consumeables'], newPlanet)
        table.insert(G.P_CENTER_POOLS['Tarot_Planet'], newPlanet)
        return
    end
    --[[
        THINGS YOU MUST DO: 
        code inject if the card is consumeable AND its condition to be consumable in Card.can_use_consumeable() in card.lua
        code inject the card effects into Card.use_consumeable() in card.lua

        param:
            id: string
            name: string
            order: nil or int
            discovered: bool
            cost: int
            pos: {x, y} or nil (for blank sprite)
            effect: string
            config: table
            desc: table of strings

        returns:
        newSpectral: the spectral card table
        newSpectralText: the spectral card text
    ]]
    function centerHook:addSpectral(id, name, order, discovered, cost, pos, effect, config, desc)
        --defaults
        id = id or "c_spec_placeholder" .. #G.P_CENTER_POOLS["Spectral"] + 1
        name = name or "Spectral Placeholder"
        order = order or #G.P_CENTER_POOLS["Spectral"] + 1
        discovered = discovered or true
        cost = cost or 4
        pos = pos or { x = 5, y = 2 } --blank spectral sprite
        effect = effect or ""
        config = config or {}
        desc = desc or {"Placeholder"}

        --spectral object
        local newSpectral = {
            order = order,
            discovered = discovered,
            cost = cost,
            consumeable = true,
            name = name,
            pos = pos,
            set = "Spectral",
            config = config,
            key = id
        }

        --add it to all the game tables
        table.insert(G.P_CENTER_POOLS["Spectral"], newSpectral)
        table.insert(G.P_CENTER_POOLS["Consumeables"], newSpectral)
        G.P_CENTERS[id] = newSpectral

        --add name + description to the localization object
        local newSpectralText = {name=name, text=desc, text_parsed={}, name_parsed={}}
        for _, line in ipairs(desc) do
            newSpectralText.text_parsed[#newSpectralText.text_parsed+1] = loc_parse_string(line)
        end
        for _, line in ipairs(type(newSpectralText.name) == 'table' and newSpectralText.name or {newSpectral.name}) do
            newSpectralText.name_parsed[#newSpectralText.name_parsed+1] = loc_parse_string(line)
        end
        G.localization.descriptions.Spectral[id] = newSpectralText

        return newSpectral, newSpectralText
    end

    return centerHook
end

centerHook = initCenterHook()

table.insert(mods,
    {
        mod_id = mod_id,
        name = mod_name,
        version = mod_version,
        author = mod_author,
        enabled = true,
        on_key_pressed = function(key_name)
            if key_name == 'left' then
                G.update_spectral_pack(nil)
            end
        end,
        on_enable = function()

            --fix the spectral collection tab being all around terrible
            if not patched_spectral_collection then
                local to_replace = "math.floor"
                local replacement = "math.ceil"
                local fun_name = "create_UIBox_your_collection_spectrals"
                local file_name = "functions/UI_definitions.lua"
                inject(file_name, fun_name, to_replace, replacement)
                

                to_replace = "(math.floor"
                replacement = "(math.ceil"
                inject(file_name, fun_name, to_replace, replacement)
                
                local to_replace = "G.P_CENTER_POOLS.Tarot"
                local replacement = "G.P_CENTER_POOLS.Spectral"
                inject(file_name, fun_name, to_replace, replacement)

                patched_spectral_collection = true
            end

            --add modded use_consumable table to the game
            if not patched_use_consumeable then
                local replacement = [[local used_tarot = copier or self
                for _, effect in ipairs(centerHook.consumeableEffects) do
                    effect(self)
                end
                ]]
                local to_replace = [[local used_tarot = copier or self]]
                local fun_name = "Card:use_consumeable"
                local file_name = "card.lua"
                inject(file_name, fun_name, to_replace, replacement)
            end
        end
    }
)
