-- core.lua
local ADDON_NAME = ...
local addon = {}
_G[ADDON_NAME] = addon

-- constants
addon.DEFAULT_GROUP = "All"
addon.INVITE_DELAY = 1.0

-- shared UI object placeholder (set in gui.lua)
addon.gui = nil

-- shared state placeholders
addon.selectedGroup = nil
addon.selectedMemberIndex = nil
addon.selectedGroupButton = nil

-- event frame (used by other modules)
addon.eventFrame = CreateFrame("Frame")

-- basic helpers
function addon.trim(s)
    if not s then return s end
    return (tostring(s):gsub("^%s+", ""):gsub("%s+$", ""))
end

function addon.normalizeTag(tag)
    if not tag then return nil end
    local t = addon.trim(tag)
    if t == "" then return nil end
    return t
end

-- tiny protected pcall wrapper for prints (avoid nil errors)
function addon.safePrint(...)
    local ok, res = pcall(print, ...)
    return ok, res
end
