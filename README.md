# Loxley Gathering System (LGS)

## Overview
The Loxley Gathering System (LGS) is a module for the [LandSandBoat](https://github.com/LandSandBoat/server) FFXI server emulator. It allows server operators to easily create their own custom [Gathering (HELM)](https://www.bg-wiki.com/ffxi/Category:Gathering) locations in any game area. The system provides an authentic experience and is actively in use by multiple prominent FFXI server projects.

## Setup
* `LGS.lua` must be located inside `modules/` but does not need to be loaded by `init.txt`
* Each new area must include a reference to `LGS.lua`, for example `local lgs = require('modules/lib/LGS')`
* Initialise your area using `lgs.add()` by following the examples provided in this repository
* * You can create a list of points by using the `!pos` [command](https://github.com/LandSandBoat/server/blob/base/scripts/commands/pos.lua) in game
* * Check that your item is included in [LSB's item enums](https://github.com/LandSandBoat/server/blob/base/scripts/enum/item.lua) or use the item ID
* Ensure `self_emote.cpp` is included in your modules and [clear the CMake cache](https://github.com/LandSandBoat/server/wiki/Module-Guide#cpp-modules) before [rebuilding the C++](https://github.com/LandSandBoat/server/wiki/Quick-Start-Guide) (Required for animations)

## Simple Example
```lua
-----------------------------------
local lgs = require("modules/lib/LGS")
-----------------------------------
local m = Module:new("example_mining_beadeaux")
-----------------------------------
lgs.add(m, {
    info =
    {
        zone = "Beadeaux",
        type = xi.helmType.MINING,
    },

    items =
    {
        { lgs.VERY_COMMON, xi.item.CHUNK_OF_COPPER_ORE    }, -- 24%
        { lgs.COMMON,      xi.item.CHUNK_OF_TIN_ORE       }, -- 15%
        { lgs.COMMON,      xi.item.CHUNK_OF_ZINC_ORE      }, -- 15%
        { lgs.UNCOMMON,    xi.item.CHUNK_OF_SILVER_ORE    }, -- 10%
        { lgs.RARE,        xi.item.CHUNK_OF_GOLD_ORE      }, --  5%
        { lgs.RARE,        xi.item.CHUNK_OF_DARKSTEEL_ORE }, --  5%
        { lgs.VERY_RARE,   xi.item.CHUNK_OF_PLATINUM_ORE  }, --  1%
    },

    points =
    {
        {  -31.729, 11.502, 82.062 }, -- !pos  -31.729 11.502 82.062
        {  -56.690, 21.627, 88.468 }, -- !pos  -56.690 21.627 88.468
        {  -46.114, 23.399, 63.150 }, -- !pos  -46.114 23.399 63.150
        {  -72.526, 23.481, 57.238 }, -- !pos  -72.526 23.481 57.238
        { -102.883, 23.384, 73.767 }, -- !pos -102.883 23.384 73.767
        { -102.989, 23.536, 33.238 }, -- !pos -102.989 23.536 33.238
        {  -87.046, 22.711, 16.795 }, -- !pos  -87.046 22.711 16.795
        { -113.429, 23.442, 17.107 }, -- !pos -113.429 23.442 17.107
    },
})

return m
```

## Advanced

### Conditional Items
You can define conditional items by simply including the `conditional` section in `lgs.add`. In the following example, `xi.item.RED_ROCK` will be replaced by a coloured rock corresponding to the current day's element. Any function can be evaluated here.
```lua
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
```

### Handling Results
You can define a custom function that will be called when the player obtains a result. This can be used for example, to grant skill ups in a custom skill system or completions of a custom quest objective. helmType is an enum corresponding to [xi.helmType](https://github.com/LandSandBoat/server/blob/base/scripts/enum/helm_type.lua).
```lua
onResult = function(player, helmType, itemID)
    -- Your code here
end,
```

### Finding Nothing
You can override the default calculation for finding "nothing" in gathering results. For example, to use a custom modifier or skill system. The default rate is passed for convenience.
```lua
foundNothing = function(player, settingRate)
    -- Your code here
    return false
end,
```

### Unlocking Areas
It's possible to lock your new area behind a quest or other condition tied to a character variable, simply specify it in the info section. Any non-zero value (eg. 1) will be considered unlocked.
```lua
info =
{
    -- ...
    var  = "[HELM]Beadeaux",
}
```

You can also specify a minimum required variable value by providing a table instead. For example, this could be used to create a skill based system.
```lua
info =
{
    -- ...
    var  = { "[SKILL]Mining", 15 },
}
```

### Respawn Time
The default respawn time for gathering points is set to 30 seconds but you can adjust this for each area by specifying a time in seconds.
```lua
info =
{
    -- ...
    respawn = 120, -- 2 minutes
}
```

## History
I've developed a few iterations of this module and there are well over a dozen new areas actively being used on live servers today, so you can rest assured that this system is well tried and tested.

* The first version was developed by me for [HorizonXI](https://horizonxi.com/) in 2022
* The second version was developed by me for [Crystal Warrior](https://www.catseyexi.com/cw) on [CatsEyeXI](https://www.catseyexi.com/) in 2023
(Where it was also rewritten several times and extended to support many new features)
* This final version was developed by me in 2024 to give it a permanent home and make it more accessible to the community

## Final Note
If you found this module useful for your server, please provide a link back to it!

~ Loxley ~
