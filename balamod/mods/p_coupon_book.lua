local mod_id = "p_coupon_book_arachnei"
local mod_name = "Coupon Book"
local mod_version = "1.0"
local mod_author = "arachnei"

local function pack_contents(card)
    if card.ability.name:find('Coupon') then
        return create_card("Voucher", G.pack_cards, nil, nil, true, nil, nil, 'couponbook')
    end
end

table.insert(mods, {
    mod_id = mod_id,
    name = mod_name,
    version = mod_version,
    author = mod_author,
    enabled = true,
    on_enable = function()
        centerHook.addBooster(self,
            "p_coupon_book_arachnei",   --id
            "Coupon Book",              --name
            pack_contents,              --pack contents
            nil,                        --order
            true,                       --discovered
            0.2,                          --weight
            "Standard",                 --kind
            12,                         --cost
            {x=0,y=0},                  --pos
            {extra = 2, choose = 1},    --config
            {"Choose {C:attention}1{} of up to","{C:attention}2{} Vouchers to be", "redeemed immediately"},
            true,                       --alerted
            "assets",                   --sprite path
            "coupon book.png",          --sprite name
            {px=71, py=95},             --sprite size
            G.STATES.PLANET_PACK        --selection_state
        )
    end,
    on_disable = function()
        centerHook.removeBooster(self, "p_coupon_book_arachnei")
    end
})