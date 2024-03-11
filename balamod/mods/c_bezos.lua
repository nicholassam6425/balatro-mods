--[[
    this spectral card gives the player $100 on use
]]

local mod_id = "c_bezos_arachnei"
local mod_name = "Bezos"
local mod_version = "1.0"
local mod_author = "arachnei"
local patched = false

--[[
    this function will be run in this loop:
    for _, effect in ipairs(centerHook.consumeableEffects) do
        effect(self)
    end
]]
local function consumeableEffect(card) 
    if card.ability.name == "Bezos" then
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            play_sound('timpani')
            ease_dollars(100, true)
            return true end }))
        delay(0.6)
    end
end

--[[
    this function will be run in this loop:
    for _, condition in ipairs(centerHook.canUseConsumeable) do
        if condition(self) then
            return condition(self)
        end
    end
]]
local function consumeableCondition(card)
    if card.ability.name == "Bezos" then
        return true
    else return false end
end
table.insert(mods,
{
    mod_id = mod_id,
    name = mod_name,
    version = mod_version,
    author = mod_author,
    enabled = true,
    --you can also forego the patched var and use on_enable instead, this one is just mildly easier to debug
    on_enable = function()
        local spectral, text = centerHook.addSpectral(self, "c_bezos", "Bezos", consumeableEffect, consumeableCondition, nil, true, 4, nil, nil, {"Gain $100"}, true)
    end,
    on_disable = function()
        centerHook.removeSpectral(self, "c_bezos")
    end
})