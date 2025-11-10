-- slash.lua
local ADDON_NAME = ...
local addon = _G[ADDON_NAME]

local function updateMinimapIcon()
    local dbicon = LibStub("LibDBIcon-1.0", true)
    if not dbicon then return end
    if Inviter3kDB.minimap.hide then
        dbicon:Hide("Inviter3k")
    else
        dbicon:Show("Inviter3k")
    end
end

local function printCmd(cmd, desc)
    addon.safePrint(string.format("|cffffff00%s|r - %s", cmd, desc))
end

SLASH_INVITER3KHELP1 = "/inviter3khelp"
SLASH_INVITER3KHELP2 = "/i3khelp"
SlashCmdList["INVITER3KHELP"] = function()
    addon.safePrint("Inviter3k commands:")
    printCmd("/inviter3k or /i3k", "Toggle the main GUI")
    printCmd("/invite3k or /i3kinvite", "Invite selected group (when GUI open) or use /invite3k <group> to invite a named group")
    printCmd("/invite3k <group>", "Invite a specific group by name or unique prefix (case-insensitive)")
    printCmd("/i3ktoggle or /inviter3ktoggle", "Toggle the minimap icon; accepts 'show' or 'hide'")
    printCmd("/inviter3khelp or /i3khelp", "Show this help list")
end

SLASH_INVITER3K1 = "/inviter3k"
SLASH_INVITER3K2 = "/i3k"
SlashCmdList["INVITER3K"] = function()
    if addon.gui and addon.gui:IsShown() then
        addon.gui:Hide()
    else
        addon.gui:Show()
    end
end

-- register slash commands
SLASH_INVITER3KINVITE1 = "/invite3k"
SLASH_INVITER3KINVITE2 = "/i3kinvite"

local function findGroupByName(query)
    if not query or query:match("^%s*$") then return nil end
    local norm = query:lower():gsub("^%s*(.-)%s*$","%1") -- trim + lower

    -- exact match first
    for _, name in ipairs(addon.GetGroups() or {}) do
        if name:lower() == norm then return name end
    end

    -- prefix match next (first match)
    for _, name in ipairs(addon.GetGroups() or {}) do
        if name:lower():find("^" .. norm, 1, true) then return name end
    end

    return nil
end

SlashCmdList["INVITER3KINVITE"] = function(msg)
    local arg = msg and msg:match("^%s*(.-)%s*$") or "" -- trim
    if arg == "" then
        -- no argument: invite currently selected group if any, otherwise list groups
        if addon.selectedGroup then
            addon.InviteGroup(addon.selectedGroup)
            return
        end
        local groups = addon.GetGroups() or {}
        if #groups == 0 then
            addon.safePrint("No groups available.")
            return
        end
        addon.safePrint("Available groups: " .. table.concat(groups, ", "))
        addon.safePrint("Usage: /invite3k <group name>  (or select a group in the UI and use the command without args)")
        return
    end

    local group = findGroupByName(arg)
    if not group then
        addon.safePrint("No matching group for:", arg)
        local groups = addon.GetGroups() or {}
        if #groups > 0 then
            addon.safePrint("Available groups: " .. table.concat(groups, ", "))
        end
        return
    end

    addon.InviteGroup(group)
end

SLASH_INVITER3KTOGGLEMAP1 = "/i3ktoggle"
SLASH_INVITER3KTOGGLEMAP2 = "/inviter3ktoggle"
SlashCmdList["INVITER3KTOGGLEMAP"] = function(msg)
    local cmd = msg and addon.trim(msg:lower()) or ""
    if cmd == "show" then
        Inviter3kDB.minimap.hide = false
    elseif cmd == "hide" then
        Inviter3kDB.minimap.hide = true
    else
        Inviter3kDB.minimap.hide = not Inviter3kDB.minimap.hide
    end
    updateMinimapIcon()
end

-- ADDON_LOADED handler to init DB and register LDB
addon.eventFrame:RegisterEvent("ADDON_LOADED")
addon.eventFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        addon.InitDatabase()

        local ldb = LibStub("LibDataBroker-1.1"):NewDataObject("Inviter3k", {
            type = "launcher",
            text = "Inviter3k",
            icon = "Interface\\AddOns\\Inviter3k\\icon.tga",
            OnClick = function(_, button)
                if addon.gui and addon.gui:IsShown() then
                    addon.gui:Hide()
                else
                    addon.gui:Show()
                end
            end,
        })

        LibStub("LibDBIcon-1.0"):Register("Inviter3k", ldb, Inviter3kDB.minimap)
        updateMinimapIcon()

        addon.safePrint("|cffffff00Inviter3k loaded.|r Type |cffffff00/i3khelp|r for list of commands.")
    end
end)
