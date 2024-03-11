local mod_id = "j_jokers_arachnei"
local mod_name = "Jokers"
local mod_version = "1.0"
local mod_author = "arachnei"

--[[
    this function will be run in this loop:
    for i, effect in ipairs(centerHook.jokerEffects) do
        if effect(self, context) then
            return effect(self, context)
        end
    end
]]
local function jokerEffect(card, context)
    if card.ability.name == 'Jokers' and context.individual and context.cardarea == G.play then 
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
        centerHook.addJoker(self, 
            'j_jokers_arachnei',  --id
            'Jokers',       --name
            jokerEffect,        --effect function
            nil,                --order
            true,               --unlocked
            true,               --discovered
            1,                  --cost
            {x=0, y=0},                --sprite position
            nil,                --internal effect description
            {mult = 2},         --config
            {"Played cards", "gain {C:red}+2{} Mult"}, --description text
            1,                  --rarity
            true,               --blueprint compatibility
            true,               --eternal compatibility
            nil,                --exclusion pool flag
            nil,                --inclusion pool flag
            nil,                --unlock condition
            true,               --collection alert
            "assets",           --sprite path
            "Jokers.png",   --sprite name
            {px=71, py=95}      --sprite size
        )
    end,
    on_disable = function()
        centerHook.removeJoker(self, "j_jokers_arachnei")
    end
})