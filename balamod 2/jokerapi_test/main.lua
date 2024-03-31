-- main.lua
local jokerapi = require("jokerapi")
local function jokerEffect(card, context)
    if card.ability.name == "The Jonkler" and context.cardarea == G.jokers and not context.before and not context.after then
        return {
            message = localize{type='variable', key='a_xmult', vars = {card.ability.extra.Xmult}},
            Xmult_mod = card.ability.extra.Xmult
        }
    end
end
local function on_enable()
    jokerapi.add_joker({
        id = 'j_jonkler_arachnei',
        name = "The Jonkler",
        joker_effect = jokerEffect,
        unlocked = true,
        discovered = true,
        cost = 6,
        config = {extra={Xmult = 1.8}},
        desc = {"{C:red}X1.8{} Mult", "{C:inactive}is he stupid?"},
        rarity = 3,
        blueprint_compat = true,
        eternal_compat = true,
        alerted = true,
        mod_id = "jokerapi_test"
    })
end

return {
    on_enable = on_enable,
}