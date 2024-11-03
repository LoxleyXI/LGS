/************************************************************************
* Self Emote
*
* Adds a new method to lua_baseentity (player:selfEmote)
* Required to produce animations for Loxley Gathering System
*************************************************************************
* Copyright (c) 2024 LoxleyXI
*
* https://github.com/LoxleyXI/LGS
*************************************************************************
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see http://www.gnu.org/licenses/
************************************************************************/
#include "map/utils/moduleutils.h"

#include "map/lua/lua_baseentity.h"
#include "map/packets/char_emotion.h"

class SelfEmoteModule : public CPPModule
{
    void OnInit() override
    {
        TracyZoneScoped;

        lua["CBaseEntity"]["selfEmote"] = [](CLuaBaseEntity* PLuaBaseEntity, CLuaBaseEntity* target, uint8 emID, uint8 emMode) -> void
        {
            TracyZoneScoped;

            CBaseEntity* PEntity = PLuaBaseEntity->GetBaseEntity();

            if (target)
            {
                auto* const PChar   = dynamic_cast<CCharEntity*>(PEntity);
                auto* const PTarget = target->GetBaseEntity();

                if (PChar && PTarget)
                {
                    const auto emoteID   = static_cast<Emote>(emID);
                    const auto emoteMode = static_cast<EmoteMode>(emMode);
                    PChar->pushPacket(new CCharEmotionPacket(PChar, PTarget->id, PTarget->targid, emoteID, emoteMode, 0));
                }
            }
        };
    }
};

REGISTER_CPP_MODULE(SelfEmoteModule);
