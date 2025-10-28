--- STEAMODDED HEADER
--- MOD_NAME: Quick Restart
--- MOD_ID: quick_restart
--- MOD_AUTHOR: [arachnei]
--- MOD_DESCRIPTION: Rerolls Ante 1 tags by clicking F2
----------------------------------------------
------------MOD CODE -------------------------

function G.FUNCS.reroll_tags()
    G.GAME.round_resets.blind_tags.Small = get_next_tag_key()
    G.GAME.round_resets.blind_tags.Big = get_next_tag_key()

    --get rid of old blind select boxes
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            G.blind_select.alignment.offset.y = 40
            G.blind_select.alignment.offset.x = 0
            return true
        end
    }))
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            G.blind_select:remove()
            G.blind_prompt_box:remove()
            G.blind_select = nil
            delay(0.2)
            return true
        end
    }))
    --create new blind select boxes
    G.E_MANAGER:add_event(Event({
        func = function()
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    play_sound('cancel')
                    G.blind_select = UIBox {
                        definition = create_UIBox_blind_select(),
                        config = { align = "bmi", offset = { x = 0, y = G.ROOM.T.y + 29 }, major = G.hand, bond = 'Weak' }
                    }
                    G.blind_select.alignment.offset.y = 0.8 - (G.hand.T.y - G.jokers.T.y) +
                        G.blind_select.T.h
                    G.ROOM.jiggle = G.ROOM.jiggle + 3
                    G.blind_select.alignment.offset.x = 0
                    G.CONTROLLER.lock_input = false
                    for i = 1, #G.GAME.tags do
                        G.GAME.tags[i]:apply_to_run({ type = 'immediate' })
                    end
                    for i = 1, #G.GAME.tags do
                        if G.GAME.tags[i]:apply_to_run({ type = 'new_blind_choice' }) then break end
                    end
                    return true
                end
            })); return true
        end
    }))
end
local ref = love.keypressed
function love.keypressed(key)
    ref(key)
    if key == 'f2' and G.STATE == G.STATES.BLIND_SELECT and G.GAME.round_resets.blind_tags and G.blind_select and G.GAME.round_resets.ante == 1 and G.GAME.round_resets.blind_states.Small == 'Select' then
        G.FUNCS.reroll_tags()
    end
end
----------------------------------------------
------------MOD CODE END----------------------