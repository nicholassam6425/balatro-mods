local mod_id = "j_jonkler_arachnei"
local mod_name = "The Jonkler"
local mod_version = "1.0"
local mod_author = "arachnei"

local function jokerEffect(card, context)
    if card.ability.name == "The Jonkler" and context.cardarea == G.jokers and not context.before and not context.after then
        return {
            message = localize{type='variable', key='a_xmult', vars = {card.ability.extra.Xmult}},
            Xmult_mod = card.ability.extra.Xmult
        }
    end
end
table.insert(mods, {
    mod_id = mod_id,
    name = mod_name,
    version = mod_version,
    author = mod_author,
    enabled = true,
    on_enable = function()
        centerHook.addJoker(self, 
            'j_jonkler_arachnei',  --id
            'The Jonkler',             --name
            jokerEffect,        --effect function
            nil,                --order
            true,               --unlocked
            true,               --discovered
            6,                  --cost
            {x=0,y=0},          --sprite position
            nil,                --internal effect description
            {extra={Xmult = 1.8}},         --config
            {"{C:red}X1.8{} Mult", "{C:inactive}is he stupid?"}, --description text
            3,                  --rarity
            true,               --blueprint compatibility
            true,               --eternal compatibility
            nil,                --exclusion pool flag
            nil,                --inclusion pool flag
            nil,                --unlock condition
            true,               --collection alert
            "assets",           --sprite path
            "the jonkler.png",   --sprite name
            {px=71, py=95}      --sprite size
        )
    end,
    on_disable = function()
        centerHook.removeJoker(self, "j_jonkler_arachnei")
    end,

})