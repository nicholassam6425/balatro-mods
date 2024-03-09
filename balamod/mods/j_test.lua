local mod_id = "j_test_arachnei"
local mod_name = "Test Joker"
local mod_version = "1.0"
local mod_author = "arachnei"
local patched = false

--[[
    this function will be run in this loop:
    for i, effect in ipairs(centerHook.jokerEffects) do
        if effect(self, context) then
            return effect(self, context)
        end
    end
]]
local function jokerEffect(card, context)
    if card.ability.name == 'Test Joker' and context.individual and context.cardarea == G.play then 
        return {
            mult = card.ability.mult,
            card = card
        }
    end
end
table.insert(mods,
{
    mod_id = mod_id,
    name = mod_name,
    version = mod_version,
    author = mod_author,
    enabled = true,
    on_enable = function()
        centerHook.addJoker(self, 'j_test_arachnei', 'Test Joker', jokerEffect, nil, true, true, 1, nil, nil, {mult = 1}, {"Played cards", "gain {C:red}+1{} Mult"}, 1, true, true, nil, nil, nil, true)
    end
})