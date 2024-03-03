mod_id = "c_bezos"
mod_name = "Bezos"
mod_version = "1.0"
mod_author = "arachnei"
patched = false
centerHook = initCenterHook()
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
            
            local replacement = [[local used_tarot = copier or self
            
            if self.ability.name == "Bezos" then
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    play_sound('timpani')
                    ease_dollars(100, true)
                    return true end }))
                delay(0.6)
            end
            ]]
            local to_replace = [[local used_tarot = copier or self]]
            local fun_name = "Card:use_consumeable"
            local file_name = "card.lua"
            inject(file_name, fun_name, to_replace, replacement)

            local to_replace = [[if self.ability.name == 'The Hermit' or self.ability.consumeable.hand_type or self.ability.name == 'Temperance' or self.ability.name == 'Black Hole' then]]
            local replacement = [[sendDebugMessage(self)
            if self.ability.name == 'The Hermit' or self.ability.consumeable.hand_type or self.ability.name == 'Temperance' or self.ability.name == 'Black Hole' or self.ability.name == 'Bezos' then]]
            local fun_name = "Card:can_use_consumeable"
            inject(file_name, fun_name, to_replace, replacement)

            patched = true
        end
    end
})