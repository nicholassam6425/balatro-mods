local mod_id = "c_humanity"
local mod_name = "Humanity"
local mod_version = "1.0"
local mod_author = "arachnei"

local function consumeableEffect(card) 
    if card.ability.name == "Humanity" then
        for key, value in pairs(card.ability.consumeable) do
            sendDebugMessage(tostring(key).." : "..tostring(value))
        end
        --make the tarot card do a little animation
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
            return true end }))

        --flip highlighted cards (i'll be honest i have no clue what percent is for)
        for i=1, #G.hand.highlighted do
            local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
        end
        delay(0.2)
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1, func = function()
            --find average rank
            local rank_avg = 0
            for i=1, #G.hand.highlighted do
                local card_rank = G.hand.highlighted[i].base.id == 14 and 1 or G.hand.highlighted[i].base.id
                rank_avg = rank_avg + card_rank
            end
            rank_avg = math.floor(rank_avg / #G.hand.highlighted)

            --set new ranks
            local rank_name = nil
            if rank_avg < 10 then rank_name = tostring(rank_avg)
            elseif rank_avg == 10 then rank_name = 'T'
            elseif rank_avg == 11 then rank_name = 'J'
            elseif rank_avg == 12 then rank_name = 'Q'
            elseif rank_avg == 13 then rank_name = 'K'
            elseif rank_avg == 14 then rank_name = 'A'
            else return false end
            for i=1, #G.hand.highlighted do
                G.hand.highlighted[i]:set_base(G.P_CARDS[string.sub(G.hand.highlighted[i].base.suit, 1, 1)..'_'..rank_name])
            end
        return true end}))
        --flip and unhighlight cards
        for i=1, #G.hand.highlighted do
            local percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('tarot2', percent, 0.6);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
        delay(0.5)
    end
end

local function consumeableCondition(card)
    if G.STATE == G.STATES.SELECTING_HAND or G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.PLANET_PACK then
        if card.ability.name == "Humanity" and #G.hand.highlighted <= card.ability.consumeable.max_highlighted and #G.hand.highlighted >= 1 then 
            return true
        end
    else return false end
end

table.insert(mods, {
    mod_id = mod_id,
    name = mod_name,
    version = mod_version,
    author = mod_author,
    enabled = true,
    on_enable = function()
        local newTarot, tarotText = centerHook:addTarot(
            "c_humanity_arachnei",  --id
            "Humanity",             --name
            consumeableEffect,      --effect
            consumeableCondition,   --effect condition
            nil,                    --order
            true,                   --discovered
            3,                      --cost
            {x=0,y=0},                    --sprite position
            {max_highlighted = 3},  --config
            {"Select up to {C:attention}3{}", "cards. Set their rank", "to their average"}, --description text
            true,                   --collection alert
            "assets",               --sprite path
            "humanity tarot.png",   --sprite name
            {px=71, py=95}          --sprite size
        )                    
    end,
    on_disable = function()
        centerHook.removeTarot(self, "c_humanity_arachnei")
    end
})