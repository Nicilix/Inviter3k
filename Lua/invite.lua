-- invite.lua
local ADDON_NAME = ...
local addon = _G[ADDON_NAME]

local inviteQueue = {}
local invitePending = false

local function forEachFriendAccount(callback)
    local num = BNGetNumFriends() or 0
    for i = 1, num do
        local info = C_BattleNet.GetFriendAccountInfo(i)
        if info then
            local ga = info.gameAccountInfo
            if ga then
                if ga.isOnline ~= nil then
                    pcall(callback, info, ga)
                else
                    for _, gameInfo in ipairs(ga) do
                        pcall(callback, info, gameInfo)
                    end
                end
            else
                pcall(callback, info, nil)
            end
        end
    end
end

local function isFriendOnlineByName(name)
    if not name then return false end
    local found = false
    forEachFriendAccount(function(info, gameInfo)
        if found then return end
        if info and info.accountName and string.lower(info.accountName) == string.lower(name) then
            if gameInfo and gameInfo.isOnline and gameInfo.clientProgram == "WoW" then
                found = true
            end
        end
    end)
    return found
end

addon.isFriendOnlineByName = isFriendOnlineByName

local function processQueue()
    if #inviteQueue == 0 then
        invitePending = false
        return
    end
    local item = table.remove(inviteQueue, 1)
    if item and item.id then
        pcall(function() BNInviteFriend(item.id) end)
        addon.safePrint("Invited:", item.name or ("ID " .. tostring(item.id)))
    end
    if #inviteQueue > 0 then
        C_Timer.After(addon.INVITE_DELAY, processQueue)
    else
        invitePending = false
    end
end

function addon.EnqueueInvite(gameAccountID, displayName)
    if not gameAccountID then return end
    table.insert(inviteQueue, { id = gameAccountID, name = displayName })
    if not invitePending then
        invitePending = true
        C_Timer.After(0.1, processQueue)
    end
end

function addon.InviteGroup(groupName)
    local members = Inviter3kDB.groups[groupName] or {}
    if not members or #members == 0 then
        addon.safePrint("Group is empty.")
        return
    end
    local lookup = {}
    for _, t in ipairs(members) do lookup[string.lower(t)] = true end

    local queued = 0
    forEachFriendAccount(function(info, gameInfo)
        if gameInfo and gameInfo.isOnline and gameInfo.clientProgram == "WoW" and info and info.battleTag then
            if lookup[string.lower(info.battleTag)] then
                addon.EnqueueInvite(gameInfo.gameAccountID, info.battleTag)
                queued = queued + 1
            end
        end
    end)

    if queued == 0 then
        addon.safePrint("No group members online.")
    else
        addon.safePrint("Queued", queued, "invites.")
    end
end
