local mod_id = "v_hobby_shop_arachnei"
local mod_name = "Hobby Shop"
local mod_version = "1.0"
local mod_author = "arachnei"

local function voucherEffect(center_table)
    if center_table.name == 'Hobby Shop' then 
    end
end

local old_shop_reroll_func = nil

local function card_shop_reroll_func(e)
    stop_use()
    sendDebugMessage("modded reroll")
    G.CONTROLLER.locks.shop_reroll = true
    if G.CONTROLLER:save_cardarea_focus('shop_jokers') then G.CONTROLLER.interrupt.focus = true end
    if G.GAME.current_round.reroll_cost > 0 then
        inc_career_stat('c_shop_dollars_spent', G.GAME.current_round.reroll_cost)
        inc_career_stat('c_shop_rerolls', 1)
        ease_dollars(-G.GAME.current_round.reroll_cost)
    end
    G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
        local final_free = G.GAME.current_round.free_rerolls > 0
        G.GAME.current_round.free_rerolls = math.max(G.GAME.current_round.free_rerolls - 1, 0)
        G.GAME.round_scores.times_rerolled.amt = G.GAME.round_scores.times_rerolled.amt + 1

        calculate_reroll_cost(final_free)
        for i = #G.shop_jokers.cards, 1, -1 do
            local c = G.shop_jokers:remove_card(G.shop_jokers.cards[i])
            c:remove()
            c = nil
        end

        --save_run()

        play_sound('coin2')
        play_sound('other1')

        for i = 1, G.GAME.shop.joker_max - #G.shop_jokers.cards do
            local new_shop_card = create_card_for_shop(G.shop_jokers)
            G.shop_jokers:emplace(new_shop_card)
            new_shop_card:juice_up()
        end 
----------------------------------------
        -- modded code start --
        if G.GAME.used_vouchers.v_hobby_shop_arachnei then
            for i=1, 2 do --check both booster pack slots
                G.GAME.current_round.used_packs = G.GAME.current_round.used_packs or {}
                if G.GAME.current_round.used_packs[i] == "USED" then
                    G.GAME.current_round.used_packs[i] = get_pack('shop_pack').key --if a slot is used, mark the slot with a new pack key
                elseif string.sub(G.GAME.current_round.used_packs[i], 1, 1) == "p" then
                    G.GAME.current_round.used_packs[i] = "EXISTS"   --if a slot is populated, mark it as populated
                elseif not G.GAME.current_round.used_packs[i] then
                    G.GAME.current_round.used_packs[i] = get_pack('shop_pack').key --failsafe
                end
                
                if G.GAME.current_round.used_packs[i] ~= 'USED' and G.GAME.current_round.used_packs[i] ~= 'EXISTS' then 
                    local card = Card(G.shop_booster.T.x + G.shop_booster.T.w/2,
                    G.shop_booster.T.y, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS[G.GAME.current_round.used_packs[i]], {bypass_discovery_center = true, bypass_discovery_ui = true})
                    create_shop_card_ui(card, 'Booster', G.shop_booster)
                    card.ability.booster_pos = i
                    card:start_materialize()
                    G.shop_booster:emplace(card)
                end
            end
        end
        -- modded code end --
--------------------------------------
    return true end}))
    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
        G.E_MANAGER:add_event(Event({func = function()
            G.CONTROLLER.interrupt.focus = false
            G.CONTROLLER.locks.shop_reroll = false
            G.CONTROLLER:recall_cardarea_focus('shop_jokers')
            for i = 1, #G.jokers.cards do
                G.jokers.cards[i]:calculate_joker({ reroll_shop = true })
            end
        return true end}))
    return true end}))
    G.E_MANAGER:add_event(Event({func = function()
        save_run(); 
    return true end}))
end

table.insert(mods, {
    mod_id = mod_id,
    name = mod_name,
    version = mod_version,
    author = mod_author,
    enabled = true,
    on_enable = function()
        centerHook.addVoucher(self,
            "v_hobby_shop_arachnei",
            "Hobby Shop",
            voucherEffect,
            nil,
            true,
            true,
            true,
            10,
            {x=0, y=0},
            {},
            nil,
            { "Shop rerolls also restock", "purchased {C:attention}Booster Pack{}" },
            true,
            "assets", 
            "card shop.png", 
            {px=71, py=95}
        )
        old_shop_reroll_func = G.FUNCS.reroll_shop
        G.FUNCS.reroll_shop = card_shop_reroll_func
    end,
    on_disable = function()
        G.FUNCS.reroll_shop = old_shop_reroll_func
        centerHook.removeVoucher(self, "v_hobby_shop_arachnei")
    end,
})
