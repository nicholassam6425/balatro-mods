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
local patched_modded_planet_logic = false
local patched_planet_collection = false
local patched_voucher_effects = false
local patched_open_booster = false
local patched_booster_desc_ui = false
local mod_id = "center_hook_arachnei"
local mod_name = "Center Hook"
local mod_version = "0.9"
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
        "Planet",   --done
        "Spectral", --done
        "Voucher",  --done
        "Back",     --not planned
        "Enhanced", --unsure
        "Edition",  --unsure
        "Booster",  --wip
    }

    ----------------------
    -- helper functions --
    ----------------------
    local function addSprite(id, sprite_path, sprite_size)
        G.ASSET_ATLAS[id] = {}
        G.ASSET_ATLAS[id].name = id
        G.ASSET_ATLAS[id].image = love.graphics.newImage(sprite_path, {mipmaps = true, dpiscale = G.SETTINGS.GRAPHICS.texture_scaling})
        G.ASSET_ATLAS[id].px = sprite_size.px
        G.ASSET_ATLAS[id].py = sprite_size.py
    end

    --tables of various functions
    centerHook.consumeableEffects = {}
    centerHook.canUseConsumeable = {}
    centerHook.jokerEffects = {}
    centerHook.voucherEffects = {}
    centerHook.boosterEffects = {}

    --keep track of added centers for removing
    centerHook.jokers = {}
    centerHook.tarots = {}
    centerHook.spectrals = {}
    centerHook.planets = {}
    centerHook.vouchers = {}
    centerHook.boosters = {}

    --[[
        remove given modded joker from the game

        inputs:
            id: string
        returns:
            nil
    ]]
    function centerHook:removeJoker(id)
        local rarity = G.P_CENTERS[id].rarity
        G.P_CENTER_POOLS['Joker'][centerHook.jokers[id].pool_indices[1]] = nil
        G.P_JOKER_RARITY_POOLS[rarity][centerHook.jokers[id].pool_indices[2]] = nil
        G.P_CENTERS[id] = nil
        G.localization.descriptions.Joker[id] = nil
        centerHook.jokerEffects[centerHook.jokers[id].use_indices[1]] = nil
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
            pos: {x:int, y:int}
            effect: string
            config: table (Read Useful Documentation in the readme for help)
            desc: table of strings
            rarity: int, 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
            blueprint_compat: bool
            eternal_compat: bool
            no_pool_flag: strings
            yes_pool_flag: strings
            unlock_condition: table (Read Useful Documentation in the readme for help)
            alerted: bool
            sprite_path: string
            sprite_name: string
            sprite_size: {px:int, py:int}

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
        table.insert(G.P_JOKER_RARITY_POOLS[rarity], newJoker)
    
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
            local actual_sprite_path = sprite_path.."/"..G.SETTINGS.GRAPHICS.texture_scaling.."x/"..sprite_name
            addSprite(id, actual_sprite_path, sprite_size)
        else
            sendDebugMessage("Sprite not defined or incorrectly defined for "..tostring(id))
        end

        --add joker effect to game
        table.insert(centerHook.jokerEffects, use_effect)

        --save indices for removal
        centerHook.jokers[id] = {
            pool_indices={#G.P_CENTER_POOLS["Joker"], #G.P_JOKER_RARITY_POOLS[rarity]}, 
            use_indices={#centerHook.jokerEffects},
        }
        return newJoker, newJokerText
    end

    --[[
        remove given modded tarot from the game

        params:
            id: string
        return:
            nil
    ]]
    function centerHook:removeTarot(id)

        G.P_CENTER_POOLS["Tarot"][centerHook.tarots[id].pool_indices[1]] = nil
        G.P_CENTER_POOLS["Tarot_Planet"][centerHook.tarots[id].pool_indices[2]] = nil
        G.P_CENTER_POOLS["Consumeables"][centerHook.tarots[id].pool_indices[3]] = nil
        G.P_CENTERS[id] = nil
        G.localization.descriptions.Tarot[id] = nil
        centerHook.consumeableEffects[centerHook.tarots[id].use_indices[1]] = nil
        centerHook.canUseConsumeable[centerHook.tarots[id].use_indices[2]] = nil
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
            sprite_path: string
            sprite_name: string
            sprite_size: {px:int, py:int}
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
            local actual_sprite_path = sprite_path.."/"..G.SETTINGS.GRAPHICS.texture_scaling.."x/"..sprite_name
            addSprite(id, actual_sprite_path, sprite_size)
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

    --[[
        remove given modded planet from the game

        inputs:
            id: string
        returns:
            nil
    ]]
    function centerHook:removePlanet(id)
        G.P_CENTER_POOLS["Planet"][centerHook.planets[id].pool_indices[1]] = nil
        G.P_CENTER_POOLS["Tarot_Planet"][centerHook.planets[id].pool_indices[2]] = nil
        G.P_CENTER_POOLS["Consumeables"][centerHook.planets[id].pool_indices[3]] = nil
        G.P_CENTERS[id] = nil
        G.localization.descriptions.Planet[id] = nil
        centerHook.consumeableEffects[centerHook.planets[id].use_indices[1]] = nil
        centerHook.canUseConsumeable[centerHook.planets[id].use_indices[2]] = nil
        G.ASSET_ATLAS[id] = nil
        centerHook.planets[id] = nil
    end

    --[[
        add given planet card, and given parameters, to the game

        
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
            sprite_path: string
            sprite_name: string
            sprite_size: {px:int, py:int}
        returns:
            newPlanet: the planet card table
            newPlanetText: the planet card text table
    ]]
    function centerHook:addPlanet(id, name, use_effect, use_condition, order, discovered, cost, pos, config, desc, alerted, sprite_path, sprite_name, sprite_size)
        id = id or "c_pl_placeholder" .. #G.P_CENTER_POOLS["Planet"] + 1
        name = name or "Planet Placeholder"
        use_effect = use_effect or function(_) end
        use_condition = use_condition or function(_) end
        order = order or #G.P_CENTER_POOLS["Planet"] + 1
        discovered = discovered or true
        cost = cost or 3
        pos = pos or {x=7, y=2} -- blank planet sprite
        config = config or {}
        desc = desc or {""}
        alerted = alerted or true
        sprite_path = sprite_path or nil
        sprite_name = sprite_name or nil
        sprite_size = sprite_size or {px=71,py=95}
        local modded_sprite = nil
        if sprite_path and sprite_name then
            modded_sprite = true
        else
            modded_sprite = false
        end

        local newPlanet = {
            order = order,
            discovered = discovered,
            cost = cost,
            consumeable = true,
            name = name,
            pos = pos,
            set = "Planet",
            config = config,
            key = id,
            effect = "",
            alerted = alerted,
            modded_sprite = modded_sprite,
            modded = true
        }

        --add it to all the game tables
        table.insert(G.P_CENTER_POOLS["Planet"], newPlanet)
        table.insert(G.P_CENTER_POOLS["Tarot_Planet"], newPlanet)
        table.insert(G.P_CENTER_POOLS["Consumeables"], newPlanet)
        G.P_CENTERS[id] = newPlanet

        --add name + description to the localization object
        local newPlanetText = {name=name, text=desc, text_parsed={}, name_parsed={}}
        for _, line in ipairs(desc) do
            newPlanetText.text_parsed[#newPlanetText.text_parsed+1] = loc_parse_string(line)
        end
        for _, line in ipairs(type(newPlanetText.name) == 'table' and newPlanetText.name or {newPlanet.name}) do
            newPlanetText.name_parsed[#newPlanetText.name_parsed+1] = loc_parse_string(line)
        end
        G.localization.descriptions.Planet[id] = newPlanetText

        --add joker sprite to sprite atlas
        if sprite_name and sprite_path then
            local actual_sprite_path = sprite_path.."/"..G.SETTINGS.GRAPHICS.texture_scaling.."x/"..sprite_name
            addSprite(id, actual_sprite_path, sprite_size)
        else
            sendDebugMessage("Sprite not defined or incorrectly defined for "..tostring(id))
        end

        --add use effect + use conditions
        table.insert(centerHook.consumeableEffects, use_effect)
        table.insert(centerHook.canUseConsumeable, use_condition)

        --save indices to centerhook for removal
        centerHook.planets[id] = {
            pool_indices = {#G.P_CENTER_POOLS["Planet"], #G.P_CENTER_POOLS["Tarot_Planet"], #G.P_CENTER_POOLS["Consumeables"]},
            use_indices = {#centerHook.consumeableEffects, #centerHook.canUseConsumeable}
        }

        return newPlanet, newPlanetText
    end
    --[[
        remove given modded spectral card from the game

        params:
            id: string
        returns:
            nil
    ]]
    function centerHook:removeSpectral(id)
        G.P_CENTER_POOLS["Spectral"][centerHook.spectrals[id].pool_indices[1]] = nil
        G.P_CENTER_POOLS["Consumeables"][centerHook.spectrals[id].pool_indices[2]] = nil
        G.P_CENTERS[id] = nil
        G.localization.descriptions.Spectral[id] = nil
        centerHook.consumeableEffects[centerHook.spectrals[id].use_indices[1]] = nil
        centerHook.canUseConsumeable[centerHook.spectrals[id].use_indices[2]] = nil
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
            pos: {x:int, y:int}
            config: table
            desc: table of strings
            alerted: bool
            sprite_path: string
            sprite_name: string
            sprite_size: {px:int, py:int}
        returns:
            newSpectral: the spectral card table
            newSpectralText: the spectral card text table
    ]]
    function centerHook:addSpectral(id, name, use_effect, use_condition, order, discovered, cost, pos, config, desc, alerted, sprite_path, sprite_name, sprite_size)
        --defaults
        id = id or "c_spec_placeholder" .. #G.P_CENTER_POOLS["Spectral"] + 1
        name = name or "Spectral Placeholder"
        use_effect = use_effect or function(_) end
        use_condition = use_condition or function(_) return false end
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

        --add sprite to sprite atlas
        if sprite_name and sprite_path then
            local actual_sprite_path = sprite_path.."/"..G.SETTINGS.GRAPHICS.texture_scaling.."x/"..sprite_name
            addSprite(id, actual_sprite_path, sprite_size)
        else
            sendDebugMessage("Sprite not defined or incorrectly defined for "..tostring(id))
        end

        --add use effect + use conditions
        table.insert(centerHook.consumeableEffects, use_effect)
        table.insert(centerHook.canUseConsumeable, use_condition)

        --save indices to centerhook for removal
        centerHook.spectrals[id] = {
            pool_indices = {#G.P_CENTER_POOLS["Spectral"], #G.P_CENTER_POOLS["Consumeables"]},
            use_indices = {#centerHook.consumeableEffects, #centerHook.canUseConsumeable}
        }

        return newSpectral, newSpectralText
    end

    --[[
        remove given modded voucher from the game

        inputs:
            id: string
        returns:
            nil
    ]]
    function centerHook:removeVoucher(id)
        G.P_CENTER_POOLS["Voucher"][centerHook.vouchers[id].pool_indices[1]] = nil
        G.P_CENTERS[id] = nil
        G.localization.descriptions.Voucher[id] = nil
        centerHook.voucherEffects[centerHook.vouchers[id].use_indices[1]] = nil
        G.ASSET_ATLAS[id] = nil
        centerHook.vouchers[id] = nil
    end

    --[[
        add given voucher, and given parameters, to the game

        
        params:
            id: string
            name: string
            voucher_effect: function
            order: int
            discovered: bool
            cost: int
            pos: {x:int, y:int}
            config: table
            requires: table of strings
            desc: table of strings
            alerted: bool
            sprite_path: string
            sprite_name: string
            sprite_size: {px:int, py:int}
        returns:
            newVoucher: the voucher table
            newVoucherText: the voucher text table
    ]]
    function centerHook:addVoucher(id, name, voucher_effect, order, discovered, unlocked, available, cost, pos, config, requires, desc, alerted, sprite_path, sprite_name, sprite_size)
        id = id or "v_placeholder" .. #G.P_CENTER_POOLS["Voucher"] + 1
        name = name or "Voucher Placeholder"
        voucher_effect = voucher_effect or function(_) end
        order = order or #G.P_CENTER_POOLS["Voucher"] + 1
        discovered = discovered or true
        unlocked = unlocked or true
        available = available or true
        cost = cost or 10
        pos = pos or {x=8,y=2}
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

        local newVoucher = {
            order = order,
            discovered = discovered,
            unlocked = unlocked,
            available = available,
            cost = cost,
            name = name,
            pos = pos,
            set = "Voucher",
            config = config,
            requires = requires,
            key = id,
            effect = "",
            alerted = alerted,
            modded_sprite = modded_sprite
        }

        --add to game tables
        table.insert(G.P_CENTER_POOLS["Voucher"], newVoucher)
        G.P_CENTERS[id] = newVoucher
        
        --add name + description to the localization object
        local newVoucherText = {name=name, text=desc, text_parsed={}, name_parsed={}}
        for _, line in ipairs(desc) do
            newVoucherText.text_parsed[#newVoucherText.text_parsed+1] = loc_parse_string(line)
        end
        for _, line in ipairs(type(newVoucherText.name) == 'table' and newVoucherText.name or {newVoucher.name}) do
            newVoucherText.name_parsed[#newVoucherText.name_parsed+1] = loc_parse_string(line)
        end
        G.localization.descriptions.Voucher[id] = newVoucherText

        --add sprite to sprite atlas
        if sprite_name and sprite_path then
            local actual_sprite_path = sprite_path.."/"..G.SETTINGS.GRAPHICS.texture_scaling.."x/"..sprite_name
            addSprite(id, actual_sprite_path, sprite_size)
        else
            sendDebugMessage("Sprite not defined or incorrectly defined for "..tostring(id))
        end

        --add effect to effect table
        table.insert(centerHook.voucherEffects, voucher_effect)

        --save indices for removal
        centerHook.vouchers[id] = {
            pool_indices = {#G.P_CENTER_POOLS["Voucher"]},
            use_indices = {#centerHook.voucherEffects}
        }

        return newVoucher, newVoucherText
    end

    --[[
        remove given modded booster from the game

        inputs:
            id: string
        returns:
            nil
    ]]
    function centerHook:removeBooster(id)
        G.P_CENTER_POOLS["Booster"][centerHook.boosters[id].pool_indices[1]] = nil
        G.P_CENTERS[id] = nil
        G.localization.descriptions.Other[id] = nil
        centerHook.boosterEffects[centerHook.boosters[id].use_indices[1]] = nil
        G.ASSET_ATLAS[id] = nil
        centerHook.vouchers[id] = nil
    end

    --[[
        add given booster pack, and given parameters, to the game

        
        params:
            id: string
            name: string
            pack_contents: function
            order: int
            discovered: bool
            weight: float
            kind: string
            cost: int
            pos: {x:int, y:int}
            config: {extra:int, choose:int}
            desc: table of strings
            alerted: bool
            sprite_path: string
            sprite_name: string
            sprite_size: {px:int, py:int}
            selection_state: G.STATES.TAROT_PACK or G.STATES.PLANET_PACK or G.STATES.SPECTRAL_PACK or G.STATES.STANDARD_PACK or G.STATES.BUFFOON_PACK
        returns:
            newBooster: the booster pack table
            newBoosterText: the booster pack text table
    ]]
    function centerHook:addBooster(id, name, pack_contents, order, discovered, weight, kind, cost, pos, config, desc, alerted, sprite_path, sprite_name, sprite_size, selection_state)
        id = id or "p_placeholder" .. #G.P_CENTER_POOLS["Booster"] + 1
        name = name or "Placeholder Pack"
        pack_contents = pack_contents or function(_) end
        order = order or #G.P_CENTER_POOLS["Booster"] + 1
        discovered = discovered or true
        weight = weight or 1
        kind = kind or ""
        cost = cost or 4
        pos = pos or {x=0, y=5}
        config = config or {}
        desc = desc or {"Placeholder"}
        alerted = alerted or true
        sprite_path = sprite_path or nil
        sprite_name = sprite_name or nil
        sprite_size = sprite_size or nil
        selection_state = selection_state or G.STATES.TAROT_PACK
        if selection_state ~= G.STATES.TAROT_PACK and selection_state ~= G.STATES.PLANET_PACK and selection_state ~= G.STATES.SPECTRAL_PACK and selection_state ~= G.STATES.STANDARD_PACK and selection_state ~= G.STATES.BUFFOON_PACK then
            sendDebugMessage(id..": selection_state incorrectly defined")
        end

        local modded_sprite = nil
        if sprite_path and sprite_name then
            modded_sprite = true
        else
            modded_sprite = false
        end

        local newBooster = {
            name = name,
            order = order,
            discovered = discovered,
            weight = weight,
            kind = kind,
            cost = cost,
            pos = pos,
            atlas = "Booster",
            set = "Booster",
            config = config,
            desc = desc,
            alerted = alerted,
            modded_sprite = modded_sprite,
            key = id,
            modded = true,
            selection_state = selection_state
        }

        table.insert(G.P_CENTER_POOLS["Booster"], newBooster)
        G.P_CENTERS[id] = newBooster

        --add name + description to the localization object
        local newBoosterText = {name=name, text=desc, text_parsed={}, name_parsed={}}
        for _, line in ipairs(desc) do
            newBoosterText.text_parsed[#newBoosterText.text_parsed+1] = loc_parse_string(line)
        end
        for _, line in ipairs(type(newBoosterText.name) == 'table' and newBoosterText.name or {newBooster.name}) do
            newBoosterText.name_parsed[#newBoosterText.name_parsed+1] = loc_parse_string(line)
        end
        G.localization.descriptions.Other[id] = newBoosterText

        --add sprite to sprite atlas
        if sprite_name and sprite_path then
            local actual_sprite_path = sprite_path.."/"..G.SETTINGS.GRAPHICS.texture_scaling.."x/"..sprite_name
            addSprite(id, actual_sprite_path, sprite_size)
        else
            sendDebugMessage("Sprite not defined or incorrectly defined for "..tostring(id))
        end

        --add effect to centerhook table
        table.insert(centerHook.boosterEffects, pack_contents)

        --save indices for removal
        centerHook.boosters[id] = {
            pool_indices = {#G.P_CENTER_POOLS["Booster"]},
            use_indices = {#centerHook.boosterEffects}
        }

        return newBooster, newBoosterText
    end
    return centerHook
end

centerHook = initCenterHook()

-- define planet collection pages function
local function g_funcs_your_collection_planet_page(args)
    if not args or not args.cycle_config then return end
    for j = 1, #G.your_collection do
        for i = #G.your_collection[j].cards,1, -1 do
            local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
            c:remove()
            c = nil
        end
    end
    
    for j = 1, #G.your_collection do
        for i = 1, 6 do
            local center = G.P_CENTER_POOLS["Planet"][i+(j-1)*(6) + (12*(args.cycle_config.current_option - 1))]
            if not center then break end
            local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
            card:start_materialize(nil, i>1 or j>1)
            G.your_collection[j]:emplace(card)
        end
    end
    INIT_COLLECTION_CARD_ALERTS()
end

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

            --fix the spectral collection tab using wrong functions & keys
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

            --add modded sprites to the sprite loading logic
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

            --remove modded planets from using default planet logic 
            if not patched_modded_planet_logic then
                local fun_name = "Card:use_consumeable"
                local file_name = "card.lua"
                local to_replace = "if self.ability.consumeable.hand_type then"
                local replacement = [[if self.ability.consumeable.hand_type and not self.config.center.modded then]]
                inject(file_name, fun_name, to_replace, replacement)
                patched_modded_planet_logic = true
            end

            --add pages to planet collection page
            if not patched_planet_collection then
                G.FUNCS.your_collection_planet_page = g_funcs_your_collection_planet_page

                local fun_name = "create_UIBox_your_collection_planets"
                local file_name = "functions/UI_definitions.lua"
                local to_replace = "INIT_COLLECTION_CARD_ALERTS()"
                local replacement = [[local planet_options = {}
  for i = 1, math.ceil(#G.P_CENTER_POOLS.Planet/12) do
    table.insert(planet_options, localize('k_page').." "..tostring(i).."/"..tostring(math.ceil(#G.P_CENTER_POOLS.Planet/12)));
  end

  INIT_COLLECTION_CARD_ALERTS]]
                inject(file_name, fun_name, to_replace, replacement)

                local to_replace = "{n=G.UIT.R, config={align = \"cm\", padding = 0.7}, nodes={}},"
                local replacement = "{n=G.UIT.R, config={align = \"cm\", padding = 0}, nodes={create_option_cycle({options = planet_options, w = 4.5, cycle_shoulders = true, opt_callback = 'your_collection_planet_page', focus_args = {snap_to = true, nav = 'wide'},current_option = 1, colour = G.C.RED, no_pips = true})}},"
                inject(file_name, fun_name, to_replace, replacement)
                patched_planet_collection = true
            end

            --add modded voucher effects to buying voucher
            if not patched_voucher_effects then
                local fun_name = "Card:apply_to_run"
                local file_name = "card.lua"
                local replacement = [[    for _, effect in pairs(centerHook.voucherEffects) do
        effect(center_table)
    end]]
                injectTail(file_name, fun_name, replacement)
                patched_voucher_effects = true
            end

            --change opening booster packs to work with modded booster packs
            --also change voucher redeem to not cost money when taking a voucher from a booster pack
            if not patched_open_booster then
                local fun_name = "Card:open"
                local file_name = "card.lua"
                local to_replace = "card.T.x = self.T.x"
                local replacement = [[for _, pack_content in pairs(centerHook.boosterEffects) do
                            card = pack_content(self) or card
                        end
                        card.T.x = self.T.x]]
                inject(file_name, fun_name, to_replace, replacement)

                local to_replace = "G.GAME.pack_choices = self.config.center.config.choose or 1"
                local replacement = [[if self.config.center.modded then
            G.STATE = self.config.center.selection_state
            G.GAME.pack_size = self.ability.extra
        end
                
        G.GAME.pack_choices = self.config.center.config.choose or 1]]
                inject(file_name, fun_name, to_replace, replacement)

                local fun_name = "Card:redeem"
                local to_replace = [[ease_dollars%(%-self%.cost%)
        inc_career_stat%('c_shop_dollars_spent', self.cost%)
        inc_career_stat%('c_vouchers_bought', 1%)
        set_voucher_usage%(self%)
        check_for_unlock%(%{type = 'run_redeem'%}%)
        G.GAME.current_round.voucher = nil]]
                local replacement = [[if G.STATE ~= G.STATES.TAROT_PACK and G.STATE ~= G.STATES.PLANET_PACK and G.STATE ~= G.STATES.SPECTRAL_PACK and G.STATE ~= G.STATES.STANDARD_PACK and G.STATE ~= G.STATES.BUFFOON_PACK then
            ease_dollars(-self.cost)
            inc_career_stat('c_shop_dollars_spent', self.cost)
            G.GAME.current_round.voucher = nil
        end
        inc_career_stat('c_vouchers_bought', 1)
        set_voucher_usage(self)
        check_for_unlock({type = 'run_redeem'})]]
                inject(file_name, fun_name, to_replace, replacement)
                patched_open_booster = true
            end

            --change description to properly display modded booster pack descriptions
            if not patched_booster_desc_ui then
                local fun_name = "generate_card_ui"
                local file_name = "functions/common_events.lua"
                local to_replace = "local desc_override = 'p_arcana_normal'"
                local replacement = "local desc_override = _c.key"
                inject(file_name, fun_name, to_replace, replacement)
                patched_booster_desc_ui = true
            end
        end
    }
)
