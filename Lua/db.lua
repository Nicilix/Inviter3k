-- db.lua
local ADDON_NAME = ...
local addon = _G[ADDON_NAME]

function addon.InitDatabase()
    Inviter3kDB = Inviter3kDB or {}
    Inviter3kDB.minimap = Inviter3kDB.minimap or { minimapPos = 220, hide = false }

    if not Inviter3kDB.groups then
        Inviter3kDB.groups = {}
        if Inviter3kDB.tags and #Inviter3kDB.tags > 0 then
            Inviter3kDB.groups[addon.DEFAULT_GROUP] = {}
            for _, tag in ipairs(Inviter3kDB.tags) do
                table.insert(Inviter3kDB.groups[addon.DEFAULT_GROUP], tag)
            end
        else
            Inviter3kDB.groups[addon.DEFAULT_GROUP] = {}
        end
    end
end
