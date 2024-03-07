mod_id = "c_bezos"
mod_name = "Bezos"
mod_version = "1.0"
mod_author = "arachnei"
patched = false

--[[
    you could also define this as an anonymous function in the table.insert call
    some info on this: you need the if statement since this function is going to be
    run in card.use_consumeable. i mostly copied this from 'The Hermit' and 'Temperance'
    so im not exactly sure what most of event's parameters do. it looks like most
    consumeables use trigger = 'after' though.
]]
function consumeableEffect(card) 
    if card.ability.name == "Bezos" then
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            play_sound('timpani')
            ease_dollars(100, true)
            return true end }))
        delay(0.6)
    end
end



table.insert(mods,
{
    mod_id = mod_id,
    name = mod_name,
    version = mod_version,
    author = mod_author,
    enabled = true,
    on_post_update = function()
        if not patched then
            centerHook.addSpectral(self, "c_bezos", "Bezos", nil, true, 4, nil, nil, nil, {"Gain $100"})
            
            --add the consumable effect to the game
            table.insert(centerHook.consumeableEffects, consumeableEffect)

            --add the consumable activation conditions to the game
            --there's probably a way to do it like consumeableEffect but i dunno for now
            local file_name = "card.lua"
            local to_replace = [[if self.ability.name == 'The Hermit' or self.ability.consumeable.hand_type or self.ability.name == 'Temperance' or self.ability.name == 'Black Hole' then]]
            local replacement = [[if self.ability.name == 'The Hermit' or self.ability.consumeable.hand_type or self.ability.name == 'Temperance' or self.ability.name == 'Black Hole' or self.ability.name == 'Bezos' then]]
            local fun_name = "Card:can_use_consumeable"
            inject(file_name, fun_name, to_replace, replacement)

            patched = true
        end
    end
})