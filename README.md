# arachnei's balatro mods

requires [UwUdev's Balamod mod loader](https://github.com/UwUDev/balamod/tree/master) OR [Steamo's Steamodded mod loader](https://github.com/Steamopollys/Steamodded/tree/main) depending on which folder you download from

- [Mods & APIs](#modsapis)
    - [Center Hook](#center-hook)
    - [Quick Restart](#quick-restart)
    - [Bezos](#bezos)
    - [Test Joker](#test-joker)
    - [Humanity](#humanity)
- [Useful Documentation](#useful-documentation)
    - ['Cheating' in a Joker](#cheating-in-a-joker)
    - [Contexts](#contexts)
    - [Unlock Conditions](#unlock-conditions)
    - [Joker.config](#jokerconfig)

# Mods/APIs

## Center Hook (apis/center_hook.lua)
| Balamod | Steamodded |
| ------- | ---------- |
| ✔️ | ❌ |

An api/hook to add center cards (card back, joker, voucher, booster pack, editions, card type, consumable cards) to the game.

**DOES NOT** add the functionality of the card, just adds the card and necessary data to all the places it needs to be. 

See mods/c_bezos.lua for an example of how to implement a consumeable card.

See mods/j_test.lua for an example of how to implement a joker card.

## Quick Restart (mods/quickrestart.lua)
| Balamod | Steamodded |
| ------- | ---------- |
| ✔️ | ✔️ |

Quickly reroll ante 1 tags by clicking f2.

**DOES NOT** work on any ante other than ante 1 by default. 

You may remove the ante 1 restriction for your own installation if you wish.

![](https://github.com/nicholassam6425/balatro-mods/blob/main/readme%20assets/quickrestartexample.gif)

## Bezos (mods/c_bezos.lua)
| Balamod | Steamodded |
| ------- | ---------- |
| ✔️ | ❌ |

An example spectral card that gives you $100 on use.

![](https://github.com/nicholassam6425/balatro-mods/blob/main/readme%20assets/bezosexample.PNG)

## Test Joker (mods/j_test.lua)
| Balamod | Steamodded |
| ------- | ---------- |
| ✔️ | ❌ |

An example joker card that gives all played cards +1 mult

![](https://github.com/nicholassam6425/balatro-mods/blob/main/readme%20assets/j_testexample.gif)

## Humanity (mods/c_humanity.lua)
| Balamod | Steamodded |
| ------- | ---------- |
| ✔️ | ❌ |

An example tarot card that averages the ranks of selected cards

![](https://github.com/nicholassam6425/balatro-mods/blob/main/readme%20assets/c_humanityexample.gif)

# Useful Documentation

## 'Cheating' in a joker
Useful for debugging a specific joker

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

## Contexts
Used in Card:calculate_joker. Defines what event is happening during the game.

Example usage in [Test Joker](#test-joker).
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

i.e Misprint's config is {extra = {max = 23, min = 0}}. The following are variables in config that are NOT in extra. (70% of the time these variables just get put in extra anyways lmfao)

- `mult`: int: multiplier additive bonus
- `extra`: table: put anything else you want in here
- `t_mult`: int: multiplier additive bonus when a certain hand type is played
- `t_chips`: int: the chips additive bonus when a certain hand type is played
- `type`: str: the hand type for t_mult or t_chips to apply ('Pair', 'Three of a Kind', 'Four of a Kind', 'Straight', 'Flush')
- `Xmult`: float: multiplier multiplicative bonus
- `h_size`: int: Juggler's bonus to hand size (can be negative)
- `d_size`: int: Drunkard's bonus to discards (maybe can be negative)