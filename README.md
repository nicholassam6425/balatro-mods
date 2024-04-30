# arachnei's balatro mods

requires [UwUdev's Balamod mod loader](https://github.com/balamod/balamod/tree/master) OR [Steamo's Steamodded mod loader](https://github.com/Steamopollys/Steamodded/tree/main) depending on which folder you download from. 

> [!WARNING]
> ***STEAMODDED AND BALAMOD ARE NOT COMPATIBLE!!!!!!!!!!!!!!***
> [!WARNING]

i am begging you please stop asking why mods crash when you have both installed...

- [Mods & APIs](#modsapis)
    - [Fortune](#fortune-httpsgithubcomnicholassam6425balatro-fortune)
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
- [Installation Guide](#installation-guide)
    - [Windows](#windows)
    - [macOS](#macos)
    - [Linux](#linux)
- [Useful Documentation](#useful-documentation)

# Mods/APIs

## Fortune (https://github.com/nicholassam6425/balatro-fortune)
| Balamod | Steamodded |
| ------- | ---------- |
| ✔️ | ❌ |

A fortune-based mod pack with 6 Jokers, 1 Tarot and 1 Spectral.

[Info Page](https://nicholassam6425.github.io/balatro/arachnei_fortune/)

![](https://github.com/nicholassam6425/balatro-mods/blob/main/misc%20assets/fortune%20tree%20cashout.gif)

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

**Sprite name:** `bezos spectral.png`

An example spectral card that gives you $100 on use.

![](https://github.com/nicholassam6425/balatro-mods/blob/main/misc%20assets/c_bezos.gif)

## Jokers (mods/j_jokers.lua)
| Balamod | Steamodded |
| ------- | ---------- |
| ✔️ | ❌ |

> [!WARNING]
> **REQUIRES** [Center Hook](#center-hook-apiscenter_hooklua)

**Sprite name:** `Jokers.png`

An example joker card that gives all played cards +2 mult

![](https://github.com/nicholassam6425/balatro-mods/blob/main/misc%20assets/j_jokers.gif)

## Humanity (mods/c_humanity.lua)
| Balamod | Steamodded |
| ------- | ---------- |
| ✔️ | ❌ |

> [!WARNING]
> **REQUIRES** [Center Hook](#center-hook-apiscenter_hooklua)

**Sprite name:** `humanity tarot.png`

An example tarot card that averages the ranks of selected cards

![](https://github.com/nicholassam6425/balatro-mods/blob/main/misc%20assets/c_humanity.gif)

## sols (mods/j_sols.lua)
| Balamod | Steamodded |
| ------- | ---------- |
| ✔️ | ❌ |

> [!WARNING]
> **REQUIRES** [Center Hook](#center-hook-apiscenter_hooklua)

**Sprite name:** `sols joker.png`

A joker card that gives you X4 mult if you play at least 4 cards that contain any sequence in DISASTERMODE (5776578588). The cards must be in the correct order (i.e 5776 will work, but 5677 will not)

![](https://cdn.7tv.app/emote/65a0e58ef9aa9eab719671c6/4x.webp)

![](https://github.com/nicholassam6425/balatro-mods/blob/main/misc%20assets/new_j_sols.gif)

## Ganymede (mods/c_ganymede.lua)
| Balamod | Steamodded |
| ------- | ---------- |
| ✔️ | ❌ |

> [!WARNING]
> **REQUIRES** [Center Hook](#center-hook-apiscenter_hooklua)

**Sprite name:** `Ganymede.png`

A planet card that levels up all hands that contain flushes

![](https://github.com/nicholassam6425/balatro-mods/blob/main/misc%20assets/c_ganymede.gif)

## The Jonkler (mods/j_jonkler.lua)
| Balamod | Steamodded |
| ------- | ---------- |
| ✔️ | ❌ |

> **REQUIRES** [Center Hook](#center-hook-apiscenter_hooklua)

**Sprite name:** `the jonkler.png`

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

**Sprite name:** `card shop.png`

A voucher card that allows you to refresh purchased booster packs

![](https://github.com/nicholassam6425/balatro-mods/blob/main/misc%20assets/v_card_shop.gif)

## Coupon Book (mods/p_coupon_book.lua)
| Balamod | Steamodded |
| ------- | ---------- |
| ✔️ | ❌ |

> [!WARNING]
> **REQUIRES** [Center Hook](#center-hook-apiscenter_hooklua)

**Sprite name:** `coupon book.png`

**Art by: thatobserver** thank you!!!

A booster pack that allows you to redeem 1 of 2 vouchers

![](https://github.com/nicholassam6425/balatro-mods/blob/main/misc%20assets/p_coupon_book.gif)

# Installation Guide
## Balamod
### Windows
For example, if we wanted only the "Hobby Shop" Voucher
```
Roaming
|- Balatro
|  |- mods
|  |  |- v_hobby_shop.lua
|  |- assets
|  |  |- 1x
|  |  |  |- card shop.png
|  |  |- 2x
|  |  |  |- card shop.png
|  |- apis
|  |  |- center_hook.lua
```
### macOS
For example, if we wanted only the "Hobby Shop" Voucher
```
~/Library/Application Support
|- Balatro
|  |- mods
|  |  |- v_hobby_shop.lua
|  |- assets
|  |  |- 1x
|  |  |  |- card shop.png
|  |  |- 2x
|  |  |  |- card shop.png
|  |- apis
|  |  |- center_hook.lua
```
### Linux
For example, if we wanted only the "Hobby Shop" Voucher
```
~/.local/share
|- Balatro
|  |- mods
|  |  |- v_hobby_shop.lua
|  |- assets
|  |  |- 1x
|  |  |  |- card shop.png
|  |  |- 2x
|  |  |  |- card shop.png
|  |- apis
|  |  |- center_hook.lua
```
OR
```
$XDG_DATA_HOME
|- Balatro
|  |- mods
|  |  |- v_hobby_shop.lua
|  |- assets
|  |  |- 1x
|  |  |  |- card shop.png
|  |  |- 2x
|  |  |  |- card shop.png
|  |- apis
|  |  |- center_hook.lua
```
# Useful Documentation

Moved to the [wiki](https://github.com/nicholassam6425/balatro-mods/wiki)