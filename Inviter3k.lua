-- Inviter3k.lua
local ADDON_NAME = ...
local eventFrame = CreateFrame("Frame")

-- Register events
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGOUT")

-- ==============================
-- SavedVariables initialization
-- ==============================
local function InitDatabase()
    Inviter3kDB = Inviter3kDB or {}
end

eventFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        InitDatabase()
        print("|cff33ff99Inviter3k:|r Loaded! Use /inviter3k for options.")
    elseif event == "PLAYER_LOGOUT" then
        -- Optional: save or cleanup before logout
    end
end)

-- ==============================
-- Utility functions
-- ==============================
local function AddBattleTag(accountName)
    for _, name in ipairs(Inviter3kDB) do
        if name == accountName then
            print("Already added:", accountName)
            return
        end
    end
    table.insert(Inviter3kDB, accountName)
    print("Added:", accountName, "to the invite list.")
end

local function RemoveBattleTag(accountName)
    for i, name in ipairs(Inviter3kDB) do
        if name == accountName then
            table.remove(Inviter3kDB, i)
            print("Removed:", accountName)
            return
        end
    end
    print(accountName, "not found in the list.")
end

local function ListBattleTag()
    if not Inviter3kDB or #Inviter3kDB == 0 then
        print("Invite list is empty.")
        return
    end
    print("Current Invite List:")
    for i, name in ipairs(Inviter3kDB) do
        print(i, name)
    end
end

-- ==============================
-- Invite all friends in the list
-- ==============================
local function InviteAllOnList()
    local numOfFriends = BNGetNumFriends() -- Correct WoW API
    if numOfFriends == 0 then
        print("No Battle.net friends found.")
        return
    end

    for i = 1, numOfFriends do
        local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
        if accountInfo and accountInfo.accountName then
            local games = accountInfo.gameAccountInfo
            if games and type(games) == "table" then
                for _, gameInfo in ipairs(games) do
                    if gameInfo and gameInfo.isOnline and gameInfo.clientProgram == "WoW" then
                        for _, target in ipairs(Inviter3kDB) do
                            if accountInfo.accountName == target then
                                BNInviteFriend(gameInfo.gameAccountID)
                                print("Invited:", accountInfo.accountName)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- ==============================
-- Slash Commands
-- ==============================
SLASH_INVITER3K1 = "/inviter3k"
SLASH_INVITER3K2 = "/inv3k"
SLASH_INVITER3K3 = "/i3k"

SlashCmdList["INVITER3K"] = function(msg)
    msg = msg or ""
    local cmd, arg = msg:match("^(%S*)%s*(.-)$")
    cmd = cmd:lower()

    if cmd == "add" and arg ~= "" then
        AddBattleTag(arg)

    elseif cmd == "remove" and arg ~= "" then
        RemoveBattleTag(arg)

    elseif cmd == "list" then
        ListBattleTag()

    elseif cmd == "inv" or cmd == "" then
        InviteAllOnList()

    elseif cmd == "reset" then
        Inviter3kDB = {}
        print("Invite list has been reset.")

    else
        print("|cff33ff99Inviter3k Commands:|r")
        print("  /inviter3k add <BattleTag>")
        print("  /inviter3k remove <BattleTag>")
        print("  /inviter3k list")
        print("  /inviter3k inv")
        print("  /inviter3k reset")
    end
end