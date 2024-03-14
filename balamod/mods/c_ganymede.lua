local mod_id = "c_ganymede_arachnei"
local mod_name = "Ganymede"
local mod_version = "1.0"
local mod_author = "arachnei"

local function use_effect(card)
    if card.ability.name == "Ganymede" then
        -- upgrade these hands
        local hands = {"Flush", "Straight Flush", "Flush House", "Flush Five"}
        for _, v in ipairs(hands) do
            -- display hand value before level up
            update_hand_text(
                {sound = 'button', volume = 0.4, pitch = 0.8, delay = 0.1}, 
                {
                    handname=localize(v, 'poker_hands'),
                    chips = G.GAME.hands[v].chips, 
                    mult = G.GAME.hands[v].mult, 
                    level=G.GAME.hands[v].level
                }
            )
            -- level up the hand
            -- pass card to make tarot card do a little animation
            level_up_hand(card, v) 
            -- set hand back to no special state
            update_hand_text(
                {sound = 'button', volume = 0.4, pitch = 1.1, delay = 0}, 
                {mult = 0, chips = 0, handname = '', level = ''}
            )
        end
    end
end

local function use_condition(card)
    if card.ability.name == "Ganymede" then
        return true
    else return false end
end
table.insert(mods, {
    mod_id = mod_id,
    name = mod_name,
    version = mod_version,
    author = mod_author,
    enabled = true,
    on_enable = function()
        centerHook.addPlanet(self,
            "c_ganymede_arachnei",
            "Ganymede",
            use_effect,
            use_condition,
            nil,
            true,
            5,
            {x=0, y=0},
            {hand_type = 'Flush'}, -- put any hand type so that the loc_vars doesnt crash the game
            {
                "Level up all",
                "hands that contain",
                "a {C:attention}Flush"
            },
            true,
            "assets",
            "Ganymede.png",
            {px=71, py=95}
        )
    end,
    on_disable = function()
        centerHook.removePlanet("c_ganymede_arachnei")
})