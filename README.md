# arachnei's balatro mods

requires [UwUdev's Balamod mod loader](https://github.com/UwUDev/balamod/tree/master) OR [Steamo's Steamodded mod loader](https://github.com/Steamopollys/Steamodded/tree/main) depending on which folder you download from

- [Mods & APIs](#modsapis)
    - [Center Hook](#center-hook-apiscenter_hooklua)
    - [Quick Restart](#quick-restart-modsquickrestartlua)
    - [Bezos](#bezos-modsc_bezoslua)
    - [Jokers](#jokers-modsj_jokerslua)
    - [Humanity](#humanity-modsc_humanitylua)
    - [sols](#sols-modsj_solslua)
    - [Ganymede](#ganymede-modsc_ganymedelua)
    - [Jonkler](#the-jonkler-modsj_jonklerlua)
    - [Hobby Shop](#hobby-shop-modsv_hobby_shoplua)
    - [Coupon Book](#coupon-book-modsp_coupon_booklua)
- [Useful Documentation](#useful-documentation)
    - ['Cheating' in a card](#cheating-in-a-card)
    - [Contexts](#contexts)
    - [Unlock Conditions](#unlock-conditions)
    - [Joker.config](#jokerconfig)

# Mods/APIs

## Center Hook (apis/center_hook.lua)
| Balamod | Steamodded |
| ------- | ---------- |
| ✔️ | ❌ |

An api/hook to add center cards (joker, voucher, booster pack, consumable cards) to the game.

See mods/c_bezos.lua or mods/c_humanity.lua for an example of how to implement a consumeable card.

See mods/j_jokers.lua or mods/j_sols.lua for an example of how to implement a joker card.

See mods/v_card_shop.lua for an example of how to implement a voucher card.

For a rundown of methods & parameters, check out [Center Hook Documentation](#center-hook-documentation)

## Quick Restart (mods/quickrestart.lua)
| Balamod | Steamodded |
| ------- | ---------- |
| ✔️ | ✔️ |

Quickly reroll ante 1 tags by clicking f2.

**DOES NOT** work on any ante other than ante 1 by default. 

You may remove the ante 1 restriction for your own installation if you wish.

![](https://github.com/nicholassam6425/balatro-mods/blob/main/misc%20assets/quickrestartexample.gif)

## Bezos (mods/c_bezos.lua)
| Balamod | Steamodded |
| ------- | ---------- |
| ✔️ | ❌ |

> [!WARNING]
> **REQUIRES** [Center Hook](#center-hook-apiscenter_hooklua)

An example spectral card that gives you $100 on use.

![](https://github.com/nicholassam6425/balatro-mods/blob/main/misc%20assets/c_bezos.gif)

## Jokers (mods/j_jokers.lua)
| Balamod | Steamodded |
| ------- | ---------- |
| ✔️ | ❌ |

> [!WARNING]
> **REQUIRES** [Center Hook](#center-hook-apiscenter_hooklua)

An example joker card that gives all played cards +2 mult

![](https://github.com/nicholassam6425/balatro-mods/blob/main/misc%20assets/j_jokers.gif)

## Humanity (mods/c_humanity.lua)
| Balamod | Steamodded |
| ------- | ---------- |
| ✔️ | ❌ |

> [!WARNING]
> **REQUIRES** [Center Hook](#center-hook-apiscenter_hooklua)

An example tarot card that averages the ranks of selected cards

![](https://github.com/nicholassam6425/balatro-mods/blob/main/misc%20assets/c_humanity.gif)

## sols (mods/j_sols.lua)
| Balamod | Steamodded |
| ------- | ---------- |
| ✔️ | ❌ |

> [!WARNING]
> **REQUIRES** [Center Hook](#center-hook-apiscenter_hooklua)

A joker card that gives you X4 mult if you play at least 4 cards that contain any sequence in DISASTERMODE (5776578588). The cards must be in the correct order (i.e 5776 will work, but 5677 will not)

![](https://cdn.7tv.app/emote/65a0e58ef9aa9eab719671c6/4x.webp)

![](https://github.com/nicholassam6425/balatro-mods/blob/main/misc%20assets/new_j_sols.gif)

## Ganymede (mods/c_ganymede.lua)
| Balamod | Steamodded |
| ------- | ---------- |
| ✔️ | ❌ |

> [!WARNING]
> **REQUIRES** [Center Hook](#center-hook-apiscenter_hooklua)

A planet card that levels up all hands that contain flushes

![](https://github.com/nicholassam6425/balatro-mods/blob/main/misc%20assets/c_ganymede.gif)

## The Jonkler (mods/j_jonkler.lua)
| Balamod | Steamodded |
| ------- | ---------- |
| ✔️ | ❌ |

> **REQUIRES** [Center Hook](#center-hook-apiscenter_hooklua)

A simple joker card that gives X1.8 mult. 

![](https://github.com/nicholassam6425/balatro-mods/blob/main/misc%20assets/the%20jonkler.PNG)

## Hobby Shop (mods/v_hobby_shop.lua)
| Balamod | Steamodded |
| ------- | ---------- |
| ✔️ | ❌ |

> [!WARNING]
> **INCOMPATIBLE** with any mod that affects shop reroll logic

> [!WARNING]
> **REQUIRES** [Center Hook](#center-hook-apiscenter_hooklua)

A voucher card that allows you to refresh purchased booster packs

![](https://github.com/nicholassam6425/balatro-mods/blob/main/misc%20assets/v_card_shop.gif)

## Coupon Book (mods/p_coupon_book.lua)
| Balamod | Steamodded |
| ------- | ---------- |
| ✔️ | ❌ |

> [!WARNING]
> **REQUIRES** [Center Hook](#center-hook-apiscenter_hooklua)

A booster pack that allows you to redeem 1 of 2 vouchers

![](https://github.com/nicholassam6425/balatro-mods/blob/main/misc%20assets/p_coupon_book.gif)

# Useful Documentation

## 'Cheating' in a card
Useful for debugging a specific card

Add a specific joker to your deck
```lua
local joker_id = "j_example_id"
local c1 = create_card("Joker", G.jokers, nil, 1, true, false, joker_id, nil)
c1.area = G.jokers
G.E_MANAGER:add_event(Event({
    trigger = 'after',
    delay = 0.1,
    func = function()
    c1.area:remove_card(c1)
    c1:add_to_deck()
    G.jokers:emplace(c1)

    G.CONTROLLER:save_cardarea_focus('jokers')
    G.CONTROLLER:recall_cardarea_focus('jokers')
    return true
    end
}))
```

Add a specific consumeable to your consumeables area
```lua
local c_id = "c_example_id"
local c_set = "Tarot" -- "Spectral", "Planet", etc
local c1 = create_card(c_set, G.consumeables, nil, 1, true, false, c_id, nil)
c1.area = G.consumeables
G.E_MANAGER:add_event(Event({
    trigger = 'after',
    delay = 0.1,
    func = function()
    c1.area:remove_card(c1)
    c1:add_to_deck()
    G.consumeables:emplace(c1)

    G.CONTROLLER:save_cardarea_focus('jokers')
    G.CONTROLLER:recall_cardarea_focus('jokers')
    return true
    end
}))
```

## Contexts
Used in Card:calculate_joker. Defines what event is happening during the game.
- `context.open_booster` (hallucination)
- `context.buying_card` ()
- `context.selling_self` (luchador, diet cola, invisible joker)
- `context.selling_card` (campfire)
- `context.reroll_shop` (flash card)
- `context.ending shop` (perkeo)
- `context.skip_blind` (throwback)
- `context.skipping_booster` (red card)
- `context.playing_card_added` (hologram)
- `context.first_hand_drawn` (certificate, dna, trading card, chicot, madness, burglar, riff-raff, cartomancer, ceremonial dagger, marble joker)
- `context.destroying_card` (sixth sense)
- `context.cards_destroyed` (caino, glass joker)
- `context.remove_playing_cards` (caino, glass joker)
- `context.using_consumeable` (glass joker{hanged man only}, fortune teller, constellation)
- `context.debuffed_hand` (matador)
- `context.pre_discard` (burnt joker)
- `context.discard` (ramen, trading card, castle, mail-in rebate, hit the road, green joker, yorick, faceless joker)
- `context.end_of_round` (campfire, rocket, turtle bean, invisible joker, popcorn, egg, gift card, hit the road, gros michel, cavendish, mr. bones)
- `context.individual` (I THINK this is used for scoring a card)
    - `context.repetition` (I THINK used for repetitions) (mime, sock and buskin, hanging chad, dusk, seltzer, hack)
    - `context.cardarea` (used to compare to G.hand (hand cards), G.play (cards in play), G.jokers (jokers))
        - `G.hand` (mime, shoot the moon, baron, reserved parking, raised fist)
        - `G.play` (hiker, lucky cat, wee joker, photograph, the idol, scary face, smiley face, golden ticket, scholar, walkie talkie, business card, fibonacci, even steven, odd todd, suit mult, rough gem, onyx agate, arrowhead, bloodstone, ancient joker, triboulet, sock and buskin, hanging chad, dusk, seltzer, hack)
        - `G.joker`
            - `context.before` (activate this BEFORE scoring this hand) (spare trousers, space joker, square joker, runner, midas mask, vampire, to do list, DNA, ride the bus, obelisk, green joker)
            - `context.after` (activate this AFTER scoring this hand) (ice cream, seltzer)
            - `else` {neither `context.before` nor `context.after`} (if your joker gives a bonus when scored, define it here) (loyalty card, seeing double, half joker, abstract joker, acrobat, mystic summit, misprint, banner, stuntman, matador, supernova, ceremonial dagger, 8 ball, vagabond, superposition, seance, flower pot, wee joker, castle, blue joker, erosion, square joker, runner, ice cream, stone joker, steel joker, bull, driver's license, blackboard, joker stencil, swashbuckler, joker, spare trousers, ride the bus, flash card, popcorn, green joker, fortune teller, gros michel, cavendish, red card, card sharp, bootstraps, caino, yorick)
- `context.game_over` (mr. bones)
- `context.other_card` (to reference the current card in scoring)
- `context.other_joker` (to reference the current joker in scoring) (baseball card)

## Unlock Conditions
Pre-defined joker unlock conditions. *OPTIONAL*. Only use these if you want your joker to have an unlock condition.

All the `"strings"` are unlock 'types', the sub-points are what goes along with the unlock type.

Example: `{unlock_condition = {type = 'modify_jokers', extra = {polychrome = true, count = 2}}}`
- `"modify_jokers"`: add enhancements to jokers (Bootstraps)
    - `extra`:
        - `"polychrome"`: bool: check for polychrome modifiers
        - `"count"`: int: number of modifiers to look for
- `"c_cards_sold"`: sell centers (Burnt Joker)
    - `extra`: int: number of centers sold
- `"discover_amount"`: discover cards in the following collections (Astronomer, Cartomancer)
    - `"planet_count"`: how many planets
    - `"tarot_count"`: how many tarots
- `"modify_deck"`: modify playing cards (Driver's License, Glass Joker, Onyx Agate, Arrowhead, Bloodstone, Rough Gem, Smeared Joker)
    - `extra`:
        - `count`: int: how many modified playing cards
        - `tally`: str: 'total', all modification types
        - `enhancement`: str: 'Glass Card' 'Wild Card', type of modification
        - `e_key`: str: 'm_glass' 'm_wild', the P_CENTER key of the modification
        - `suit`: str: Suit of cards in the deck
- `"play_all_hearts"`: play all heart cards in your deck in 1 round (Shoot the Moon)
- `"money"`:  have a certain amount of money (Sateillite)
    - `extra`: int: amount of money
- `"discard_custom"`: discard a certain hand type (unsure how to define) (Brainstorm, Hit the Road)
- `"win_custom"`: win while doing a certain thing (unsure how to define) (Invisible Joker, Blueprint)
- `"chip_score"`: play a hand that gives a certain amount of chips (Stuntman, The Idol, Oops! All 6s)
    - `chips`: int: the amount of chips to have to unlock
- `"win_no_hand"`: win without playing a certain hand type (The Duo, The Trio, The Family, The Order, The Tribe)
    - `extra`: str: define the hand type that was not played: 'Pair', 'Three of a Kind', 'Four of a Kind', 'Straight', 'Flush'
- `"hand_contents"`: play a certain hand (Seeing Double, Golden Ticket)
    - `extra`: str: the hand: 'four 7 of Clubs' 'Gold'(5 gold cards)
- `"win`": win within a certain number of rounds (Merry Andy, Wee Joker)
    - `n_rounds`: int: the amount of rounds to win before
- `"ante_up"`: reach a certain ante (Flower Pot, Showman)
    - `ante`: int: the ante to reach
- `"round_win"`: win in 1 round with no discards(Matador)
    - `extra`: 'High Card', adds condition of certain hand type (Hanging Chad)
    - `extra`: int: win in 1 round this many times (this might allow discards) (Troubadour)
- `"continue_game"`: Continue a saved run from the main menu (Throwback)
- `"double_gold"`: Have a gold seal on a gold card (Certificate)
- `"c_jokers_sold"`: Sell jokers (Swashbuckler)
    - `extra`: int: how many jokers
- `"c_face_cards_played"`: play face cards (Sock and Buskin)
    - `extra`: int: how many face cards
- `"c_hands_played"`: play hands (Acrobat)
    - `extra`: int: how many hands
- `"c_losses"`: lose runs (Mr. Bones)
    - `extra`: int: how many runs

## Joker.config
Commonly used to store numerical values of your joker, such as bonus mult. (Using config is optional, **I THINK**)

i.e Misprint's config is `{extra = {max = 23, min = 0}}`. The following are variables in config that are NOT in extra. 

Personally, I would suggest using `config.extra` almost every time. It's more intuitive to use, and sometimes using the keys listed below sometimes just... dont get loaded into `card.ability` correctly. Worse case, you can use `card.config.center.config` to directly access the table that gets loaded into `card.ability`, but messing with these may end up changing values on copies of the card. 

- `mult`: int: multiplier additive bonus
- `extra`: table: put anything else you want in here
- `t_mult`: int: multiplier additive bonus when a certain hand type is played
- `t_chips`: int: the chips additive bonus when a certain hand type is played
- `type`: str: the hand type for t_mult or t_chips to apply ('Pair', 'Three of a Kind', 'Four of a Kind', 'Straight', 'Flush')
- `Xmult`: float: multiplier multiplicative bonus
- `h_size`: int: Juggler's bonus to hand size (can be negative)
- `d_size`: int: Drunkard's bonus to discards (maybe can be negative)

## Center Hook Documentation
List of methods, their parameters, and what they return

- centerHook.addJoker
    adds a joker card to the game
    - parameters:
        - id (string): the internal name of the joker card (i.e "j_jokers_arachnei")
            - I'd suggest adding a unique modifier to your id, like how I add my name to the end of the id to avoid easily avoidable mod conflicts.
        - name (string): the actual name of the joker card (i.e "Jokers")
            - This is used both for the display name of the card, as well as for how the game knows which 'card' is currently being calculated. I may separate these two values in the future to avoid mod conflicts
        - use_effect (function): a function that describes how the joker works
            - You must pass **THE FUNCTION**, not the result. The function **MUST** take `(card, context)` as input. Higher up in this readme is documentation on contexts, I'll be writing one for card functions soon. I'll also be writing a different section on what a joker card should return from `Card:calculate_joker`
        - order (int): a number that describes which order to show jokers in the collection
            - This one you can leave as `nil` if you're unsure. By doing so, it'll load jokers in by mod loading order.
        - unlocked (bool): a boolean that describes if a joker is unlocked or not (true = unlocked)
            - I haven't tested anything with this yet. I think it currently works in the back end, but it'll display the card sprite in the collection if you set it to locked
        - discovered (bool): a boolean that describes if a joker is discovered or not (true = discovered)
            - I also haven't tested anything with this. Same hypothesis as unlocked
        - cost (int): a number that describes the cost of the joker
        - pos (table: {x=int, y=int}): a table that describes the sprite position in the sprite sheet
            - If you don't have a sprite, use `nil`, it'll use a placeholder sprite. x and y start at 0 in the top left. If you use individual sprites like I do, your pos will always be `{x=0,y=0}`
        - effect (string): an *internal* description of the card effect
            - I don't think this actually does anything for jokers. I usually leave this as `nil`, which sets it to an empty string. If you find anything, lmk
        - config (table): a table that contains values that get loaded into `card.ability`
            - See [Joker.config](#jokerconfig).
        - desc (table of strings): a table of strings that contains the actual description of the card
            - I'll write a separate section of description formatting soon. For now: `{C:attention}text{}` for cards, `{C:red}text{}` for mult, and `{C:chips}text{}` for chips. You can find all the game's descriptions in the localization folder of the decompiled game
        - rarity (int): a number that describes the joker's rarity
            - 1 for Common, 2 for Uncommon, 3 for Rare, 4 for Legendary. Does not support any other rarities as of right now.
        - blueprint_compat (bool): for if blueprint/brainstorm will show as incompatible or not
            - This only visually makes blueprint/brainstorm show as incompatible. You have to include `not context.blueprint` in your joker's conditions if you want it to actually not be copied
        - eternal_compat (bool): for if this joker can be eternal or not
            - I haven't tested this at all. If your joker has a sell/destroy related ability consider this paramater
        - no_pool_flag (string): if this flag exists, the joker will not show up in game
            - This is used for Gros Michel. I also haven't tested this either. Try looking at Gros Michel's portion in `Card:calculate_joker` for some guidance
        - yes_pool_flag (string): if this flag doesn't exist, this joker will not show up in game
            - Used for Cavendish. Also haven't tested this. Try looking at Gros Michel's portion in `Card:calculate_joker` for guidance
        - unlock_condition (table): A table defining unlock conditions for the joker
            - See [Unlock Conditions](#unlock-conditions)
        - alerted (bool): Defines if the joker will have an alert or not in the collection
            - Thank you HeyImKyu for finding this. 
        - sprite_path (string)
        - sprite_name (string)
        - sprite_size (table {px=int, py=int})
            > [!WARNING]
            > You **MUST** have 1x and 2x folders in your `sprite_path` folder. 
            - If your sprites are located in `Roaming/Balatro/assets/1x` or `Roaming/Balatro/assets/2x`, then your `sprite_path` will simply be `"assets"`. I'll look at making this more flexible in the future.
    - returns:
        - newJoker (table): the table that defines that card that gets loaded into the game
        - newJokerText (table): the table that holds all the card text data
- centerHook.removeJoker
    remove a **modded** joker from the game
    - parameters:
        - id (string): the id you used to add the joker to the game
    - returns:
        - nothing
- centerHook.addTarot & centerHook.addSpectral
    adds a tarot/spectral card to the game

    (yeah they're pretty much the same)
    - parameters:
        - id (string): the internal name of the consumeable card (i.e "c_humanity_arachnei")
            - I'd suggest adding a unique modifier to your id, like how I add my name to the end of the id to avoid easily avoidable mod conflicts.
         - name (string): the actual name of the consumeable card (i.e "Jokers")
            - This is used both for the display name of the card, as well as for how the game knows which 'card' is currently being used. I may separate these two values in the future to avoid mod conflicts
        - use_effect (function): the function that describes what happens when the card is used
            - This function does not need a `return` inside of it. All operations done in this should be using the game's event manager to time the animations of the effect. For guidance, look at either my `mods/c_humanity.lua` or the vanilla cards in the decompiled source code.
        - use_condition (function): the function that defines the use conditions of the card
            - This function must return `true` when the card is available to be used. For guidance, look at either my `mods/c_humanity.lua` or the vanilla cards in the decompiled source code.
        - order (int): a number that the game uses to order the cards in the collection tab
            - If you're unsure what to put here, leave it as `nil`. It will add it to the end of the collection.
        - discovered (bool): defines whether or not the card is discovered in the collection or not
            - I haven't tested this. I think it functionally works, but visually will not use the undiscovered card sprite in the collection.
        - cost (int): the cost of the card
        - pos (table: {x=int, y=int}): defines the position of the card's sprite in the spritesheet
            - If left as `nil`, it will use a blank sprite. x and y start from 0, in the top left of the sprite sheet.
        - config (table): a table of numerical values used in the card
            - Usually stored in `card.ability.consumeable`
        - desc (table of strings): the displayed description text of the card
            - I'll write a separate section of description formatting soon. For now: `{C:attention}text{}` for cards, `{C:red}text{}` for mult, and `{C:chips}text{}` for chips. You can find all the game's descriptions in the localization folder of the decompiled game
        - alerted (bool): Defines if the joker will have an alert or not in the collection
            - Thank you HeyImKyu for finding this. 
        - sprite_path (string)
        - sprite_name (string)
        - sprite_size (table {px=int, py=int})
            > [!WARNING]
            > You **MUST** have 1x and 2x folders in your `sprite_path` folder. 
            - If your sprites are located in `Roaming/Balatro/assets/1x` or `Roaming/Balatro/assets/2x`, then your `sprite_path` will simply be `"assets"`. I'll look at making this more flexible in the future.
    - returns:
        - newTarot (table): the table that defines that card that gets loaded into the game
        - newTarotText (table): the table that holds all the card text data
- centerHook.removeTarot & centerHook.removeSpectral
    remove a **modded** tarot/spectral from the game
    - parameters:
        - id (string): the id you used to add the tarot to the game
    - returns:
        - nothing
