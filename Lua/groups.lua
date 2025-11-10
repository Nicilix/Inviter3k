-- groups.lua
local ADDON_NAME = ...
local addon = _G[ADDON_NAME]

local function containsInsensitive(tbl, val)
    if not tbl or not val then return false, nil end
    local low = string.lower(val)
    for i, v in ipairs(tbl) do
        if string.lower(v) == low then
            return true, i
        end
    end
    return false, nil
end

function addon.GetGroups()
    local names = {}
    for name in pairs(Inviter3kDB.groups) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

function addon.CreateGroup(name)
    name = name and addon.trim(name) or nil
    if not name or name == "" then return false, "invalid" end
    if Inviter3kDB.groups[name] then return false, "exists" end
    Inviter3kDB.groups[name] = {}
    return true
end


function addon.RenameGroup(oldName, newName)
    if not oldName or not newName then return false, "invalid" end
    oldName = addon.trim(oldName)
    newName = addon.trim(newName)
    if not oldName or not newName or oldName == "" or newName == "" then return false, "invalid" end
    if not Inviter3kDB.groups[oldName] then return false, "nogroup" end
    if Inviter3kDB.groups[newName] then return false, "exists" end

    -- move members table to new key
    Inviter3kDB.groups[newName] = Inviter3kDB.groups[oldName]
    Inviter3kDB.groups[oldName] = nil

    -- update addon state: selectedGroup and selectedGroupButton text
    if addon.selectedGroup == oldName then
        addon.selectedGroup = newName
    end

    -- update the UI label if needed (caller refreshGroupList will update buttons)
    return true
end


function addon.DeleteGroup(name)
    if not Inviter3kDB.groups[name] then return false end
    Inviter3kDB.groups[name] = nil
    return true
end

function addon.GetGroupMembers(group)
    return Inviter3kDB.groups[group] or {}
end

function addon.AddMemberToGroup(groupName, tag)
    groupName = groupName and addon.trim(groupName) or nil
    tag = tag and addon.normalizeTag(tag) or nil

    if not groupName or not Inviter3kDB.groups[groupName] then
        return false, "nogroup"
    end
    if not tag or tag == "" then
        return false, "invalid"
    end

    local members = Inviter3kDB.groups[groupName]
    -- ensure members is an array-like table
    if not members then
        members = {}
        Inviter3kDB.groups[groupName] = members
    end

    -- duplicate check
    for _, v in ipairs(members) do
        if v == tag then return false, "exists" end
    end

    tinsert(members, tag)
    return true
end


function addon.RemoveMemberFromGroup(group, identifier)
    local members = Inviter3kDB.groups[group]
    if not members then return false end
    if type(identifier) == "number" then
        if identifier < 1 or identifier > #members then return false end
        table.remove(members, identifier)
        return true
    else
        for i, v in ipairs(members) do
            if string.lower(v) == string.lower(tostring(identifier)) then
                table.remove(members, i)
                return true
            end
        end
        return false
    end
end
