-----------------------------------
-- Loxley Gathering System (LGS)
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
local LGS = {}

-----------------------------------
-- Definitions
-----------------------------------
-- Rates
LGS.GUARANTEED  = 1000 -- 100%
LGS.VERY_COMMON =  240 --  24%
LGS.COMMON      =  150 --  15%
LGS.UNCOMMON    =  100 --  10%
LGS.RARE        =   50 --   5%
LGS.VERY_RARE   =   10 --   1%
LGS.SUPER_RARE  =    5 -- 0.5%
LGS.ULTRA_RARE  =    1 -- 0.1%

local settings =
{
    dialog =
    {
        check = "%s is possible here if you have a %s.",
        full  = "You cannot carry any more items. Your inventory is full.",
    },

    vars =
    {
        NEXT_TRADE = "[HELM]Next_Trade",
        LOCAL_USES = "[HELM]Uses",
    },

    spawnRate =
    {
        minimum = 2, -- Minimum number of points to spawn
        rate    = 1, -- Number of additional points to spawn per 10
    },
}

local types =
{
    [xi.helmType.HARVESTING] =
    {
        name         = "Harvesting",
        point        = "Harvest. Point",
        tool         = "sickle",
        toolID       = xi.item.SICKLE,
        look         = 2422,
        animationID  = xi.emote.HARVESTING,
        mod          = xi.mod.HARVESTING_RESULT,
        settingRate  = xi.settings.main.HARVESTING_RATE,
        settingBreak = xi.settings.main.HARVESTING_BREAK_CHANCE,
        unable       = "You are unable to harvest anything.",
        success      = "You successfully harvest %s!",
        process      = "You harvest %s, but your %s breaks.", -- Intentional
        breaks       = "Your %s breaks!",
    },

    [xi.helmType.EXCAVATION] =
    {
        name         = "Excavation",
        point        = "Excav. Point",
        tool         = "pickaxe",
        toolID       = xi.item.PICKAXE,
        look         = 2424,
        animationID  = xi.emote.EXCAVATION,
        mod          = xi.mod.EXCAVATION_RESULT,
        settingRate  = xi.settings.main.EXCAVATION_RATE,
        settingBreak = xi.settings.main.EXCAVATION_BREAK_CHANCE,
        unable       = "You are unable to mine anything.",
        success      = "You successfully dig up %s!",
        process      = "You dig up %s, but your %s breaks in the process.",
        breaks       = "Your %s breaks!",
    },

    [xi.helmType.LOGGING] =
    {
        name         = "Logging",
        point        = "Logging Point",
        tool         = "hatchet",
        toolID       = xi.item.HATCHET,
        look         = 2423,
        animationID  = xi.emote.LOGGING,
        mod          = xi.mod.LOGGING_RESULT,
        settingRate  = xi.settings.main.LOGGING_RATE,
        settingBreak = xi.settings.main.LOGGING_BREAK_CHANCE,
        unable       = "You are unable to log anything.",
        success      = "You successfully cut off %s!",
        process      = "You cut off %s, but your %s breaks in the process.",
        breaks       = "Your %s breaks!",
    },

    [xi.helmType.MINING] =
    {
        name         = "Mining",
        point        = "Mining Point",
        tool         = "pickaxe",
        toolID       = xi.item.PICKAXE,
        look         = 2424,
        animationID  = xi.emote.EXCAVATION,
        mod          = xi.mod.MINING_RESULT,
        settingRate  = xi.settings.main.MINING_RATE,
        settingBreak = xi.settings.main.MINING_BREAK_CHANCE,
        unable       = "You are unable to mine anything.",
        success      = "You successfully dig up %s!",
        process      = "You dig up %s, but your %s breaks in the process.",
        breaks       = "Your %s breaks!",
    },
}

-----------------------------------
-- Utilities
-----------------------------------
local function doesToolBreak(player, helmType)
    local roll  = math.random(1, 100)

    if helmType.mod ~= nil then
        roll = roll + (player:getMod(helmType.mod) / 10)
    end

    if roll <= helmType.settingBreak then
        player:tradeComplete()
        return true
    end

    return false
end

local function doMove(npc, x, y, z)
    return function(entity)
        entity:setPos(x, y, z, 0)
    end
end

local function movePoint(npc, points, respawn)
    local point    = points[math.random(1, #points)]
    local duration = 30

    if respawn ~= nil then
        duration = respawn
    end

    npc:hideNPC(duration)
    npc:queue(3000, doMove(npc, unpack(point)))
end

local function isLocked(player, helmArea)
    if helmArea.info.var == nil then
        return false
    end

    if type(helmArea.info.var) == "table" then
        if player:getCharVar(helmArea.info.var[1]) >= helmArea.info.var[2] then
            return false
        end
    elseif player:getCharVar(helmArea.info.var) > 0 then
        return false
    end

    player:printToPlayer(string.format(
        "You have not unlocked the ability to perform %s in the current area.",
        types[helmArea.info.type].name), xi.msg.channel.SYSTEM_3)

    return true
end

local function handleBreak(player, item, helmType)
    -- Tool broke, found item
    if item.id ~= 0 then
        player:printToPlayer(string.format(
            helmType.process,
            item.name,
            helmType.tool
        ), xi.msg.channel.NS_SAY)

    -- Tool broke, found nothing
    else
        player:printToPlayer(string.format(
            helmType.breaks,
            helmType.tool
        ), xi.msg.channel.NS_SAY)
    end
end

local function handleResult(player, item, helmArea)
    local helmType = types[helmArea.info.type]
    local breaks   = doesToolBreak(player, helmType)

    if breaks then
        handleBreak(player, item, helmType)
    end

    if item.id ~= 0 then
        if not breaks then
            player:printToPlayer(string.format(helmType.success, item.name), xi.msg.channel.NS_SAY)
        end

        player:addItem(item.id)

        if helmArea.onResult ~= nil then
            helmArea.onResult(player, helmArea.info.type, item.id)
        end

        return true
    end

    if not breaks then
        player:printToPlayer(helmType.unable, xi.msg.channel.NS_SAY)
    end

    return false
end

local function handleUses(npc, points, respawn)
    local uses = (npc:getLocalVar(settings.vars.LOCAL_USES) - 1) % 4
    npc:setLocalVar(settings.vars.LOCAL_USES, uses)

    if uses == 0 then
        movePoint(npc, points, respawn)
    end
end

local function pickItem(player, helmArea)
    local helmType = types[helmArea.info.type]
    local result   = { rate = 0, id = 0, name = "" }

    if helmArea.foundNothing ~= nil then
        if helmArea.foundNothing(player, helmType.settingRate) then
            return result
        end
    elseif math.random(100) > helmType.settingRate then
        return result
    end

    local poolTotal = 0

    for _, itemInfo in pairs(helmArea.items) do
        poolTotal = poolTotal + itemInfo.rate
    end

    local pick = math.random(1, poolTotal)
    local sum = 0

    for _, itemInfo in pairs(helmArea.items) do
        sum = sum + itemInfo.rate

        if sum >= pick then
            result = itemInfo
            break
        end
    end

    if helmArea.conditional ~= nil then
        for itemID, conditions in pairs(helmArea.conditional) do
            if result.id == itemID then
                local updated = conditions.replacement[conditions.condition()]
                return { rate = result.rate, id = updated.id, name = updated.name }
            end
        end
    end

    return result
end

local vowel = set{ "a","e","i","o","u" }

local function getItemName(itemID, areaName)
    local result  = "unknown"
    local itemObj = GetItemByID(itemID)

    if itemObj == nil then
        print("[LGS] Unknown item {} defined for {}", itemID, helmArea)
        return result
    end

    result = string.gsub(itemObj:getName(), "_", " ")

    if vowel[string.sub(result, 1, 1)] then
        return "an " .. result
    else
        return "a " .. result
    end
end

-----------------------------------
-- NPC Functions
-----------------------------------
local function onTrigger(player, npc, helmArea)
    if isLocked(player, helmArea) then
        return
    end

    local helmType = types[helmArea.info.type]

    player:printToPlayer(string.format(
        settings.dialog.check,
        helmType.name,
        helmType.tool
    ), xi.msg.channel.NS_SAY)
end

local function onTrade(player, npc, trade, helmArea)
    -- Check if player meets the requirements (If set)
    if isLocked(player, helmArea) then
        return
    end

    local helmType   = types[helmArea.info.type]
    local zoneId     = player:getZoneID()
    local nextTrade  = player:getLocalVar(settings.vars.NEXT_TRADE)
    local validTrade = trade:hasItemQty(helmType.toolID, 1) and trade:getItemCount() == 1

    -- HELM should remove invisible
    player:delStatusEffect(xi.effect.INVISIBLE)

    if not validTrade then
        onTrigger(player, npc, helmArea)
        return
    end

    if os.time() < nextTrade then
        player:messageBasic(xi.msg.basic.WAIT_LONGER, 0, 0)
        return
    end

    -- This animation can be seen by other players but not by the source player
    player:sendEmote(npc, helmType.animationID, xi.emoteMode.MOTION)

    -- This animation can be seen by the source player only
    -- Requires: self_emote.cpp
    if player.selfEmote ~= nil then
        player:selfEmote(npc, helmType.animationID, xi.emoteMode.MOTION)
    end

    if player:getFreeSlotsCount() == 0 then
        player:printToPlayer(settings.dialog.full, xi.msg.channel.NS_SAY)
        return
    end

    local item = pickItem(player, helmArea)

    -- Allow 3 seconds for animation
    player:timer(3000, function(playerArg)
        if handleResult(playerArg, item, helmArea) then
            handleUses(npc, helmArea.points, helmArea.respawn)
            player:triggerRoeEvent(xi.roeTrigger.HELM_SUCCESS, { ['skillType'] = helmArea.info.type })
        end
    end)

    player:setLocalVar(settings.vars.NEXT_TRADE, os.time() + 3)
end

-----------------------------------
-- External Functions
-----------------------------------
LGS.add = function(sourceModule, helmArea)
    sourceModule:addOverride(fmt("xi.zones.{}.Zone.onInitialize", helmArea.info.zone), function(zone)
        super(zone)

        -- Convert items into a nicely indexed table
        for index, _ in pairs(helmArea.items) do
            helmArea.items[index] =
            {
                rate = helmArea.items[index][1],
                id   = helmArea.items[index][2],
                name = helmArea.items[index][3],
            }

            if helmArea.items[index] == nil then
                print(fmt("[LGS] An item in {} does not have a valid item ID", helmArea.info.zone))
            end

            -- Perform item name lookup if required
            if helmArea.items[index].name == nil then
                helmArea.items[index].name = getItemName(helmArea.items[index].id, helmArea.info.zone)
            end
        end

       -- Convert conditional items into a nicely indexed table
        if helmArea.conditional ~= nil then
            for itemID, _ in pairs(helmArea.conditional) do
                for conditionID, conditionInfo in pairs(helmArea.conditional[itemID].replacement) do
                    -- If conditionals are as defined pure item IDs, convert it to a table
                    if type(helmArea.conditional[itemID].replacement[conditionID]) == "number" then
                        helmArea.conditional[itemID].replacement[conditionID] = { helmArea.conditional[itemID].replacement[conditionID] }
                    end

                    local itemInfo = helmArea.conditional[itemID].replacement[conditionID]

                    if itemInfo.id == nil then
                        helmArea.conditional[itemID].replacement[conditionID] =
                        {
                            id   = itemInfo[1],
                            name = itemInfo[2],
                        }

                        if itemInfo[1] == nil then
                            print(fmt("[LGS] A conditional item in {} does not have a valid item ID {}", helmArea.info.zone, conditionInfo))
                        end
                    end

                    -- Perform item name lookup if required
                    if helmArea.conditional[itemID].replacement[conditionID].name == nil then
                        helmArea.conditional[itemID].replacement[conditionID].name = getItemName(
                            helmArea.conditional[itemID].replacement[conditionID].id,
                            helmArea.info.zone
                        )
                    end
                end
            end
        end

        -- Create gathering points
        local zoneId = zone:getID()
        local total = #helmArea.points
        local spawn = math.ceil((total / 10) * settings.spawnRate.rate) + settings.spawnRate.minimum

        for index = 1, spawn do
            local dynamicPoint = zone:insertDynamicEntity({
                name      = types[helmArea.info.type].point,
                objtype   = xi.objType.NPC,
                look      = types[helmArea.info.type].look,
                x         = helmArea.points[index][1],
                y         = helmArea.points[index][2],
                z         = helmArea.points[index][3],
                rotation  = 0,
                widescan  = 0,

                onTrigger = function(player, npc)
                    onTrigger(player, npc, helmArea)
                end,

                onTrade   = function(player, npc, trade)
                    onTrade(player, npc, trade, helmArea)
                end,
            })

            -- Shuffle gathering points
            movePoint(dynamicPoint, helmArea.points, helmArea.respawn)
        end
    end)
end

return LGS
