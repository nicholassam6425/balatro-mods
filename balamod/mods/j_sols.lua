local mod_id = "j_sols_arachnei"
local mod_name = "sols Joker"
local mod_version = "1.0"
local mod_author = "arachnei"

local function jokerEffect(card, context)
    if card.ability.name == "sols" and context.cardarea == G.jokers and not context.before and not context.after and not context.open_booster and not context.buying_card and not context.selling_self and not context.selling_card and not context.ending_shop and not context.skip_blind and not context.skipping_booster and not context.playing_card_added and not context.destroying_card and not context.cards_destroyed and not context.remove_playing_cards and not context.using_consumeable and not context.debuffed_hand and not context.end_of_round and not context.individual and not context.game_over and not context.other_card and not context.other_joker and not context.discard and not context.pre_discard then
        local eights = 0
        for i = 1, #context.scoring_hand do
            if context.scoring_hand[i].base.id == 8 then eights = eights + 1 end
        end
        if eights >= 1 then
            for i, v in pairs(card.config.center.config) do
                sendDebugMessage(tostring(i).." : ".. tostring(v))
            end
            return {
                message = localize{type='variable', key='a_xmult', vars = {card.config.center.config.Xmult}},
                Xmult_mod = card.config.center.config.Xmult
            }
        end
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
            'j_sols_arachnei',  --id
            'sols',       --name
            jokerEffect,        --effect function
            nil,                --order
            true,               --unlocked
            true,               --discovered
            6,                  --cost
            {x=0,y=0},          --sprite position
            nil,                --internal effect description
            {Xmult = 2},         --config
            {"{C:red}X2{} Mult if played", "hand contains", "an {C:attention}8{}"}, --description text
            3,                  --rarity
            true,               --blueprint compatibility
            true,               --eternal compatibility
            nil,                --exclusion pool flag
            nil,                --inclusion pool flag
            nil,                --unlock condition
            true,               --collection alert
            "assets",           --sprite path
            "sols joker.png",   --sprite name
            {px=71, py=95}      --sprite size
        )
    end,
    on_disable = function()
        centerHook.removeJoker(self, "j_sols_arachnei")
    end
})