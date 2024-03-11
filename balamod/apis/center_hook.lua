--[[
    an attempt at making a hook for adding centers
    (card back, joker, voucher, booster pack, editions, card type,
    consumable cards)
]]

local patched_can_use_consumeable = false
local patched_use_consumeable = false
local patched_spectral_collection = false
local patched_joker_effects = false
local patched_tarot_collection = false
local patched_sprite_logic = false
local mod_id = "center_hook_arachnei"
local mod_name = "Center Hook"
local mod_version = "0.6"
local mod_author = "arachnei"

--get rid of debug messages if user doesnt have devtools
if (sendDebugMessage == nil) then
    sendDebugMessage = function(_) end
end
function initCenterHook()
    local centerHook = {}

    local sets = {
        "Joker",    --done
        "Tarot",    --done
        "Planet",
        "Spectral", --done
        "Voucher",
        "Back",     --not planned
        "Enhanced", --unsure
        "Edition",  --unsure
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
        "config",           --check readme "Useful Documentation" section
        "enhancement_gate", --str: (Optional) defines card enhancements that are required in the deck before the joker is offered (im unsure if you can put multiple)
        "no_pool_flag",     --str: (Optional) defines flags that will remove this joker from the pool (ex: gros_michel_extinct)
        "yes_pool_flag",    --str: (Optional) defines flags that will add this joker to the pool (ex: gros_michel_extinct)
        "unlock_condition"  --check readme "Useful Documentation" section
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

    --tables of various functions
    centerHook.consumeableEffects = {}
    centerHook.canUseConsumeable = {}
    centerHook.jokerEffects = {}

    --keep track of added centers for removing
    centerHook.jokers = {}
    centerHook.tarots = {}
    centerHook.spectrals = {}

    --[[
        remove given joker from the game

        inputs:
            id: string
        returns:
            nil
    ]]
    function centerHook:removeJoker(id)
        table.remove(G.P_CENTER_POOLS["Joker"], centerHook.jokers[id].pool_indices[1])
        G.P_CENTERS[id] = nil
        G.localization.descriptions.Joker[id] = nil
        table.remove(centerHook.jokerEffects, centerHook.jokers[id].use_indices[1])
        G.ASSET_ATLAS[id] = nil
        centerHook.jokers[id] = nil
    end

    --[[
        add joker card, as well as given parameters, to the game

        params:
            id: string
            name: string
            use_effect: function
            order: int
            discovered: bool
            cost: int
            pos: {x:int, y:int} or nil
            effect: string
            config: table (Read Useful Documentation in the readme for help)
            desc: table of strings
            rarity: int, 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
            blueprint_compat: bool
            eternal_compat: bool
            no_pool_flag: strings
            yes_pool_flag: strings
            unlock_condition: table (Read Useful Documentation in the readme for help)

        returns:
            newJoker: the joker card table
            newJokerText: the joker card text table
    ]]
    function centerHook:addJoker(id, name, use_effect, order, unlocked, discovered, cost, pos, effect, config, desc, rarity, blueprint_compat, eternal_compat, no_pool_flag, yes_pool_flag, unlock_condition, alerted, sprite_path, sprite_name, sprite_size)
        --defaults
        id = id or "j_Joker_Placeholder" .. #G.P_CENTER_POOLS["Joker"] + 1
        name = name or "Joker Placeholder"
        use_effect = use_effect or function(_) end
        order = order or #G.P_CENTER_POOLS["Joker"] + 1
        unlocked = unlocked or true
        discovered = discovered or true
        cost = cost or 4
        pos = pos or { x = 9, y = 9 } --blank joker sprite
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
        alerted = alerted or true
        sprite_path = sprite_path or nil
        sprite_name = sprite_name or nil
        sprite_size = sprite_size or {px=71, py=95}
        local modded_sprite = nil
        if sprite_path and sprite_name then
            modded_sprite = true
        else
            modded_sprite = false
        end

        --joker object
        local newJoker = {
            order = order,
            discovered = discovered,
            cost = cost,
            consumeable = false,
            name = name,
            pos = pos,
            set = "Joker",
            effect = "",
            cost_mult = 1.0,
            config = config,
            key = id, 
            rarity = rarity, 
            unlocked = unlocked,
            blueprint_compat = blueprint_compat,
            eternal_compat = eternal_compat,
            no_pool_flag = no_pool_flag,
            yes_pool_flag = yes_pool_flag,
            unlock_condition = unlock_condition,
            alerted = alerted,
            modded_sprite = modded_sprite
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

        --add joker sprite to sprite atlas
        if sprite_name and sprite_path then
            actual_sprite_path = sprite_path.."/"..G.SETTINGS.GRAPHICS.texture_scaling.."x/"..sprite_name
            G.ASSET_ATLAS[id] = {}
            G.ASSET_ATLAS[id].name = id
            G.ASSET_ATLAS[id].image = love.graphics.newImage(actual_sprite_path, {mipmaps = true, dpiscale = G.SETTINGS.GRAPHICS.texture_scaling})
            G.ASSET_ATLAS[id].px = sprite_size.px
            G.ASSET_ATLAS[id].py = sprite_size.py
        else
            sendDebugMessage("Sprite not defined or incorrectly defined for "..tostring(id))
        end

        table.insert(centerHook.jokerEffects, use_effect)
        table.insert(centerHook.jokers, {name=name, id=id})
        centerHook.jokers[id] = {
            pool_indices={#G.P_CENTER_POOLS["Joker"]}, 
            use_indices={#centerHook.jokerEffects},
        }
        return newJoker, newJokerText
    end

    --[[
        remove given tarot from the game

        params:
            id: string
        return:
            nil
    ]]
    function centerHook:removeTarot(id)
        table.remove(G.P_CENTER_POOLS["Tarot"], centerHook.tarots[id].pool_indices[1])
        table.remove(G.P_CENTER_POOLS["Tarot_Planet"], centerHook.tarots[id].pool_indices[2])
        table.remove(G.P_CENTER_POOLS["Consumeables"], centerHook.tarots[id].pool_indices[3])
        G.P_CENTERS[id] = nil
        G.localization.descriptions.Tarot[id] = nil
        table.remove(centerHook.consumeableEffects, centerHook.tarots[id].use_indices[1])
        table.remove(centerHook.canUseConsumeable, centerHook.tarots[id].use_indices[2])
        G.ASSET_ATLAS[id] = nil
        centerHook.tarots[id] = nil
    end

    --[[
        add tarot, as well as given parameters, to the games

        params:
            id: string
            name: string
            use_effect: function
            use_condition: function
            order: int
            discovered: bool
            cost: int
            pos: {x:int, y:int}
            config: table
            desc: table of strings
            alerted: bool
        returns:
            newTarot: the tarot card table
            newTarotText: the tarot card text table
    ]]
    function centerHook:addTarot(id, name, use_effect, use_condition, order, discovered, cost, pos, config, desc, alerted, sprite_path, sprite_name, sprite_size)
        id = id or "c_tarot_placeholder" .. #G.P_CENTER_POOLS["Tarot"] + 1
        name = name or "Tarot Placeholder"
        use_effect = use_effect or function(_) end
        use_condition = use_condition or function(_) end
        order = order or #G.P_CENTER_POOLS["Tarot"] + 1
        discovered = discovered or true
        cost = cost or 3
        pos = pos or {x=6, y=2} -- blank tarot sprite
        config = config or {}
        desc = desc or {""}
        alerted = alerted or true
        sprite_path = sprite_path or nil
        sprite_name = sprite_name or nil
        sprite_size = sprite_size or {px=71, py=95}
        local modded_sprite = nil
        if sprite_path and sprite_name then
            modded_sprite = true
        else
            modded_sprite = false
        end

        local newTarot = {
            order = order,
            discovered = discovered,
            cost = cost,
            consumeable = true,
            name = name,
            pos = pos,
            set = "Tarot",
            effect = "",
            cost_mult = 1.0,
            config = config,
            alerted = alerted,
            key = id,
            modded_sprite = modded_sprite
        }

        --add tarot to all the game tables
        table.insert(G.P_CENTER_POOLS["Tarot"], newTarot)
        table.insert(G.P_CENTER_POOLS["Tarot_Planet"], newTarot)
        table.insert(G.P_CENTER_POOLS["Consumeables"], newTarot)
        G.P_CENTERS[id] = newTarot

        --add name + description to localization tables
        local newTarotText = {name=name, text=desc, text_parsed={}, name_parsed={}}
        for _, line in ipairs(desc) do
            newTarotText.text_parsed[#newTarotText.text_parsed+1] = loc_parse_string(line)
        end
        for _, line in ipairs(type(newTarotText.name) == 'table' and newTarotText.name or {newTarot.name}) do
            newTarotText.name_parsed[#newTarotText.name_parsed+1] = loc_parse_string(line)
        end
        G.localization.descriptions.Tarot[id] = newTarotText

        table.insert(centerHook.consumeableEffects, use_effect)
        table.insert(centerHook.canUseConsumeable, use_condition)

        --add tarot sprite to sprite atlas
        if sprite_name and sprite_path then
            actual_sprite_path = sprite_path.."/"..G.SETTINGS.GRAPHICS.texture_scaling.."x/"..sprite_name
            G.ASSET_ATLAS[id] = {}
            G.ASSET_ATLAS[id].name = id
            G.ASSET_ATLAS[id].image = love.graphics.newImage(actual_sprite_path, {mipmaps = true, dpiscale = G.SETTINGS.GRAPHICS.texture_scaling})
            G.ASSET_ATLAS[id].px = sprite_size.px
            G.ASSET_ATLAS[id].py = sprite_size.py
        else
            sendDebugMessage("Sprite not defined or incorrectly defined for "..tostring(id))
        end

        --save indices to centerhook for removal
        centerHook.tarots[id] = {
            pool_indices={#G.P_CENTER_POOLS["Tarot"], #G.P_CENTER_POOLS["Tarot_Planet"], #G.P_CENTER_POOLS["Consumeables"]}, 
            use_indices={#centerHook.consumeableEffects, #centerHook.canUseConsumeable}
        }

        return newTarot, newTarotText
    end

    --[[VERY WIP
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
    ]]

    --[[
        remove given spectral card from the game

        params:
            id: string
        returns:
            nil
    ]]
    function centerHook:removeSpectral(id)
        table.remove(G.P_CENTER_POOLS["Spectral"], centerHook.spectrals[id].pool_indices[1])
        table.remove(G.P_CENTER_POOLS["Consumeables"], centerHook.spectrals[id].pool_indices[2])
        G.P_CENTERS[id] = nil
        G.localization.descriptions.Spectral[id] = nil
        table.remove(centerHook.consumeableEffects, centerHook.spectrals[id].use_indices[1])
        table.remove(centerHook.canUseConsumeable, centerHook.spectrals[id].use_indices[2])
        G.ASSET_ATLAS[id] = nil
        centerHook.spectrals[id] = nil
    end

    --[[
        add given spectral card, and given parameters, to the game

        params:
            id: string
            name: string
            effect: function
            use_condition: function
            order: int
            discovered: bool
            cost: int
            pos: {x:int, y:int} or nil 
            config: table
            desc: table of strings
        returns:
            newSpectral: the spectral card table
            newSpectralText: the spectral card text table
    ]]
    function centerHook:addSpectral(id, name, effect, use_condition, order, discovered, cost, pos, config, desc, alerted, sprite_path, sprite_name, sprite_size)
        --defaults
        id = id or "c_spec_placeholder" .. #G.P_CENTER_POOLS["Spectral"] + 1
        name = name or "Spectral Placeholder"
        use_condition = use_condition or function(_) end
        order = order or #G.P_CENTER_POOLS["Spectral"] + 1
        discovered = discovered or true
        cost = cost or 4
        pos = pos or { x = 5, y = 2 } --blank spectral sprite
        config = config or {}
        desc = desc or {"Placeholder"}
        alerted = alerted or true
        sprite_path = sprite_path or nil
        sprite_name = sprite_name or nil
        sprite_size = sprite_size or {px=71, py=95}
        local modded_sprite = nil
        if sprite_path and sprite_name then
            modded_sprite = true
        else
            modded_sprite = false
        end

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
            key = id,
            effect = "",
            alerted = alerted,
            modded_sprite = modded_sprite
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

        --add joker sprite to sprite atlas
        if sprite_name and sprite_path and sprite_size.px and sprite_size.py then
            actual_sprite_path = sprite_path.."/"..G.SETTINGS.GRAPHICS.texture_scaling.."x/"..sprite_name
            G.ASSET_ATLAS[id] = {}
            G.ASSET_ATLAS[id].name = id
            G.ASSET_ATLAS[id].image = love.graphics.newImage(actual_sprite_path, {mipmaps = true, dpiscale = G.SETTINGS.GRAPHICS.texture_scaling})
            G.ASSET_ATLAS[id].px = sprite_size.px
            G.ASSET_ATLAS[id].py = sprite_size.py
        else
            sendDebugMessage("Sprite not defined or incorrectly defined for "..tostring(id))
        end

        --add use effect + use conditions
        table.insert(centerHook.consumeableEffects, effect)
        table.insert(centerHook.canUseConsumeable, use_condition)

        --save indices to centerhook for removal
        centerHook.spectrals[id] = {
            pool_indices = {#G.P_CENTER_POOLS["Spectral"], #G.P_CENTER_POOLS["Consumeables"]},
            use_indices = {#centerHook.consumeableEffects, #centerHook.canUseConsumeable}
        }

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
            if key_name == "right" then
                
            end
        end,
        on_post_update = function()

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

            --fix the tarot collection tab to properly add new pages when needed
            if not patched_tarot_collection then
                local to_replace = "math.floor"
                local replacement = "math.ceil"
                local fun_name = "create_UIBox_your_collection_tarots"
                local file_name = "functions/UI_definitions.lua"
                inject(file_name, fun_name, to_replace, replacement)
                inject(file_name, fun_name, to_replace, replacement)
                patched_tarot_collection = true
            end

            --add modded use_consumable effects to the game
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
                
                patched_use_consumeable = true
            end

            --add modded can_use_consumeable conditions to the game
            if not patched_can_use_consumeable then
                local replacement = [[return false end
                for _, condition in ipairs(centerHook.canUseConsumeable) do
                    if condition(self) then
                        return condition(self)
                    end
                end]]
                local to_replace = [[return false end]]
                local fun_name = "Card:can_use_consumeable"
                local file_name = "card.lua"
                inject(file_name, fun_name, to_replace, replacement)
                patched_can_use_consumeable = true
            end

            --add modded joker effects to the game
            if not patched_joker_effects then
                local to_replace = "if context.open_booster then"
                local replacement = [[
            for i, effect in ipairs(centerHook.jokerEffects) do
                local temp_effect = effect(self, context)
                if temp_effect then
                    return temp_effect
                end
            end
            if context.open_booster then]]
                local fun_name = "Card:calculate_joker"
                local file_name = "card.lua"
                inject(file_name, fun_name, to_replace, replacement)
                patched_joker_effects = true
            end

            if not patched_sprite_logic then
                local fun_name = "Card:set_sprites"
                local file_name = "card.lua"
                local to_replace = "self.children.center.states.hover = self.states.hover"
                local replacement = [[if _center.modded_sprite then
                    self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS[_center.key], _center.pos)
                end
            self.children.center.states.hover = self.states.hover
            ]]
                inject(file_name, fun_name, to_replace, replacement)
                patched_sprite_logic = true
            end
        end
    }
)
