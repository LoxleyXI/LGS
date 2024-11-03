-----------------------------------
-- (Mining) Beadeaux
-- Example file for the Loxley Gathering System (LGS)
-----------------------------------
-- Copyright (c) 2024 LoxleyXI
--
-- https://github.com/LoxleyXI/LGS
-----------------------------------
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see http://www.gnu.org/licenses/
-----------------------------------
local lgs = require("modules/catseyexi/lua/lib/LGS")
-----------------------------------
local m = Module:new("example_mining_beadeaux")
-----------------------------------
lgs.add(m, {
    info =
    {
        -- (Required)
        zone = "Beadeaux",
        type = xi.helmType.MINING,

        -- (Optional)
        -- Character variable to unlock gathering in the area
        -- Anything greater than 0 is considered unlocked
        -- var  = "[HELM]Beadeaux",

        -- (Optional)
        -- Define a respawn time in seconds (Default: 30s)
        -- respawn = 120,
    },

    -- (Required)
    items =
    {
        { lgs.VERY_COMMON, xi.item.CHUNK_OF_COPPER_ORE    }, -- 24%
        { lgs.COMMON,      xi.item.CHUNK_OF_TIN_ORE       }, -- 15%
        { lgs.COMMON,      xi.item.CHUNK_OF_ZINC_ORE      }, -- 15%
        { lgs.UNCOMMON,    xi.item.CHUNK_OF_SILVER_ORE    }, -- 10%
        { lgs.RARE,        xi.item.CHUNK_OF_GOLD_ORE      }, --  5%
        { lgs.RARE,        xi.item.CHUNK_OF_DARKSTEEL_ORE }, --  5%
        { lgs.VERY_RARE,   xi.item.CHUNK_OF_PLATINUM_ORE  }, --  1%
        { lgs.VERY_RARE,   xi.item.RED_ROCK               }, --  1%
    },

    -- (Required)
    points =
    {
        {  -31.729, 11.502, 82.062 }, -- !pos -31.729 11.502 82.062
        {  -56.690, 21.627, 88.468 }, -- !pos -56.690 21.627 88.468
        {  -46.114, 23.399, 63.150 }, -- !pos -46.114 23.399 63.150
        {  -72.526, 23.481, 57.238 }, -- !pos -72.526 23.481 57.238
        { -102.883, 23.384, 73.767 }, -- !pos -102.883 23.384 73.767
        { -102.989, 23.536, 33.238 }, -- !pos -102.989 23.536 33.238
        {  -87.046, 22.711, 16.795 }, -- !pos -87.046 22.711 16.795
        { -113.429, 23.442, 17.107 }, -- !pos -113.429 23.442 17.107
    },

    -- (Optional)
    -- This will replace any specified items with a result based on the return value of the condition function
    conditional =
    {
        [xi.item.RED_ROCK] =
        {
            condition   = VanadielDayElement,
            replacement =
            {
                [xi.element.FIRE]    = xi.item.RED_ROCK,
                [xi.element.ICE]     = xi.item.TRANSLUCENT_ROCK,
                [xi.element.WIND]    = xi.item.GREEN_ROCK,
                [xi.element.EARTH]   = xi.item.YELLOW_ROCK,
                [xi.element.THUNDER] = xi.item.PURPLE_ROCK,
                [xi.element.WATER]   = xi.item.BLUE_ROCK,
                [xi.element.LIGHT]   = xi.item.WHITE_ROCK,
                [xi.element.DARK]    = xi.item.BLACK_ROCK,
            },
        },
    },

    -- (Optional)
    -- An optional function called when the player successfully obtains a result
    -- onResult = function(helmType, itemID)
        -- Call another function such as a custom quest, skillup system, etc.
    -- end,

    -- (Optional)
    -- An optional function can override the default "found nothing" roll
    -- foundNothing = function(player, settingRate)
        -- Calculate roll based on custom modifier, skill system, etc.
        -- return true or false
    -- end,
})

return m
