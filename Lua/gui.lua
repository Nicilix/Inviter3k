-- gui.lua
local ADDON_NAME = ...
local addon = _G[ADDON_NAME]

-- Main frame
local gui = CreateFrame("Frame", "Inviter3kFrame", UIParent, "BasicFrameTemplateWithInset")
gui:SetSize(720,450)
gui:SetPoint("CENTER")
gui:SetMovable(true)
gui:EnableMouse(true)
gui:RegisterForDrag("LeftButton")
gui:SetScript("OnDragStart", gui.StartMoving)
gui:SetScript("OnDragStop", gui.StopMovingOrSizing)
gui:Hide()

addon.gui = gui

-- Title
gui.title = gui:CreateFontString(nil, "OVERLAY")
gui.title:SetFontObject("GameFontHighlight")
gui.title:SetPoint("LEFT", gui.TitleBg, "LEFT", 5, 0)
gui.title:SetText("Inviter3k Groups")

-- forward declarations for state-aware refreshers
local function refreshGroupList() end
local function refreshMemberList() end

-- helper to safely clear a frame we created previously
local function safeHideFrame(f)
    if f and f.Hide then
        f:Hide()
    end
end

-- Build panes dynamically (removes old panes and recreates)
local function buildPanes()
    -- defensive: hide any preexisting static panes named Groups or Members
    for i = 1, gui:GetNumChildren() do
        local c = select(i, gui:GetChildren())
        if c then
            local cc = c and select(1, c:GetChildren())
            if cc and cc.GetText then
                local txt = cc:GetText()
                if txt == "Groups" or txt == "Members" then
                    c:Hide()
                end
            end
        end
    end

    -- remove previous dynamic panes if any
    if addon.gui.leftPane then
        safeHideFrame(addon.gui.leftPane)
        addon.gui.leftPane = nil
    end
    if addon.gui.rightPane then
        safeHideFrame(addon.gui.rightPane)
        addon.gui.rightPane = nil
    end

    local guiW, guiH = gui:GetWidth() or 520, gui:GetHeight() or 450
    local padding, innerSpacing = 12, 8

    local leftW = math.floor(guiW * 0.38)
    local rightW = guiW - leftW - (padding * 2) - innerSpacing
    if rightW < 180 then
        leftW = 200
        rightW = guiW - leftW - (padding * 2) - innerSpacing
    end

    -- Reserve a bottom area height for the buttons and editbox
    local bottomReserve = 50

    -- Left pane
    local left = CreateFrame("Frame", nil, gui)
    left:ClearAllPoints(); left:SetPoint("TOPLEFT", gui, "TOPLEFT", padding, -40)
    left:SetSize(leftW, guiH - 110)
    left.title = left:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    left.title:SetPoint("TOPLEFT", left, "TOPLEFT", 0, 0)
    left.title:SetText("Groups")

    left.groupScroll = CreateFrame("ScrollFrame", nil, left, "UIPanelScrollFrameTemplate")
    left.groupScroll:ClearAllPoints()
    left.groupScroll:SetPoint("TOPLEFT", left, "TOPLEFT", 8, -28)
    left.groupScroll:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -8, bottomReserve)
    left.groupContent = CreateFrame("Frame", nil, left.groupScroll)
    left.groupContent:SetWidth(math.max(1, leftW - 20))
    left.groupContent:SetHeight(1)
    left.groupScroll:SetScrollChild(left.groupContent)
    left.groupButtons = {}

    local btnW, btnH = 86, 22
    left.newBtn = CreateFrame("Button", nil, left, "GameMenuButtonTemplate")
    left.newBtn:ClearAllPoints(); left.newBtn:SetSize(btnW, btnH)
    left.newBtn:SetPoint("BOTTOMLEFT", left, "BOTTOMLEFT", 6, 6)
    left.newBtn:SetText("New")
    left.deleteBtn = CreateFrame("Button", nil, left, "GameMenuButtonTemplate")
    left.deleteBtn:ClearAllPoints(); left.deleteBtn:SetSize(btnW, btnH)
    left.deleteBtn:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -6, 6)
    left.deleteBtn:SetText("Delete")
    left.renameBtn = CreateFrame("Button", nil, left, "GameMenuButtonTemplate")
    left.renameBtn:ClearAllPoints(); left.renameBtn:SetSize(btnW, btnH)
    left.renameBtn:SetPoint("BOTTOM", left, "BOTTOM", 0, 6)
    left.renameBtn:SetText("Rename")

    -- Right pane
    local right = CreateFrame("Frame", nil, gui)
    right:ClearAllPoints(); right:SetPoint("TOPRIGHT", gui, "TOPRIGHT", -padding, -40)
    right:SetSize(rightW, guiH - 110)
    right.title = right:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    right.title:SetPoint("TOPLEFT", right, "TOPLEFT", 0, 0)
    right.title:SetText("Members")
    right.groupLabel = right:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    right.groupLabel:SetPoint("TOPLEFT", right, "TOPLEFT", 0, -18)
    right.groupLabel:SetText("Selected group: None")

    right.memberScroll = CreateFrame("ScrollFrame", nil, right, "UIPanelScrollFrameTemplate")
    right.memberScroll:ClearAllPoints()
    right.memberScroll:SetPoint("TOPLEFT", right, "TOPLEFT", 6, -40)
    right.memberScroll:SetPoint("BOTTOMRIGHT", right, "BOTTOMRIGHT", -6, bottomReserve + 8)
    right.memberContent = CreateFrame("Frame", nil, right.memberScroll)
    right.memberContent:SetWidth(math.max(1, rightW - 20))
    right.memberContent:SetHeight(1)
    right.memberScroll:SetScrollChild(right.memberContent)
    right.memberButtons = {}

    right.addInput = CreateFrame("EditBox", nil, right, "InputBoxTemplate")
    right.addInput:ClearAllPoints(); right.addInput:SetSize(170, 24)
    right.addInput:SetPoint("BOTTOMLEFT", right, "BOTTOMLEFT", 6, bottomReserve + 6)
    right.addInput:SetAutoFocus(false)
    right.addInput:SetText("")
    addon.gui.editBox = right.addInput

    right.addBtn = CreateFrame("Button", nil, right, "GameMenuButtonTemplate")
    right.addBtn:ClearAllPoints(); right.addBtn:SetSize(80, 22)
    right.addBtn:SetPoint("LEFT", right.addInput, "RIGHT", 6, 0)
    right.addBtn:SetText("Add")
    right.removeBtn = CreateFrame("Button", nil, right, "GameMenuButtonTemplate")
    right.removeBtn:ClearAllPoints(); right.removeBtn:SetSize(120, 22)
    right.removeBtn:SetPoint("BOTTOMLEFT", right, "BOTTOMLEFT", 6, 6)
    right.removeBtn:SetText("Remove Selected")
    right.inviteBtn = CreateFrame("Button", nil, right, "GameMenuButtonTemplate")
    right.inviteBtn:ClearAllPoints(); right.inviteBtn:SetSize(120, 22)
    right.inviteBtn:SetPoint("BOTTOMRIGHT", right, "BOTTOMRIGHT", -6, 6)
    right.inviteBtn:SetText("Invite Group")



    -- store panes
    addon.gui.leftPane = left
    addon.gui.rightPane = right

    -- attach handlers (preserve original behavior)
    left.newBtn:SetScript("OnClick", function()
        StaticPopup_Show("INVITER3K_CREATE_GROUP")
    end)

    left.renameBtn:SetScript("OnClick", function()
        if not addon.selectedGroup then addon.safePrint("No group selected.") return end
        StaticPopup_Show("INVITER3K_RENAME_GROUP", addon.selectedGroup, nil, addon.selectedGroup)
    end)

    left.deleteBtn:SetScript("OnClick", function()
        if not addon.selectedGroup then addon.safePrint("No group selected.") return end
        StaticPopup_Show("INVITER3K_DELETE_GROUP", addon.selectedGroup, nil, addon.selectedGroup)
    end)

    right.addBtn:SetScript("OnClick", function()
        if not addon.selectedGroup then addon.safePrint("No group selected.") return end
        local tag = right.addInput:GetText()
        local ok, reason = addon.AddMemberToGroup(addon.selectedGroup, tag)
        if ok then
            right.addInput:SetText("")
            refreshMemberList()
            addon.safePrint("Added:", addon.normalizeTag(tag), "to", addon.selectedGroup)
        else
            if reason == "exists" then
                addon.safePrint("Already in group:", tag)
            elseif reason == "invalid" then
                addon.safePrint("Invalid BattleTag.")
            else
                addon.safePrint("Add member failed:", reason)
            end
        end
    end)

    right.removeBtn:SetScript("OnClick", function()
        if not addon.selectedGroup then addon.safePrint("No group selected.") return end
        if not addon.selectedMemberIndex then addon.safePrint("No member selected.") return end
        StaticPopup_Show("INVITER3K_REMOVE_MEMBER", addon.GetGroupMembers(addon.selectedGroup)[addon.selectedMemberIndex], nil, { group = addon.selectedGroup, index = addon.selectedMemberIndex })
    end)

    right.inviteBtn:SetScript("OnClick", function()
        if not addon.selectedGroup then addon.safePrint("No group selected.") return end
        addon.InviteGroup(addon.selectedGroup)
    end)
end

-- refresh functions that operate on panes inside addon.gui
-- refresh functions that operate on panes inside addon.gui
function refreshGroupList()
    local left = addon.gui.leftPane
    local right = addon.gui.rightPane
    if not left or not right then return end

    -- Hide old buttons
    for _, btn in ipairs(left.groupButtons) do btn:Hide() end

    local yOffset = 0
    local groups = addon.GetGroups()
    for i, name in ipairs(groups) do
        local btn = left.groupButtons[i]
        if not btn then
            btn = CreateFrame("Button", nil, left.groupContent, "GameMenuButtonTemplate")
            btn:ClearAllPoints()
            local btnWidth = (left.groupScroll and left.groupScroll:GetWidth()) or (left:GetWidth() and left:GetWidth() - 14) or 120
            btn:SetSize(math.max(1, btnWidth - 8), 20)
            btn:SetPoint("TOPLEFT", left.groupContent, "TOPLEFT", 8, -yOffset)
            btn:SetNormalFontObject("GameFontNormal")
            btn:SetHighlightFontObject("GameFontHighlight")

            btn:SetScript("OnClick", function(self)
                -- update selection
                addon.selectedGroup = name
                addon.selectedMemberIndex = nil
                if addon.selectedGroupButton then addon.selectedGroupButton:UnlockHighlight() end
                addon.selectedGroupButton = self
                self:LockHighlight()
                right.groupLabel:SetText("Selected group: " .. name)
                refreshMemberList()
            end)

            left.groupButtons[i] = btn
        end

        btn:SetText(name)
        if name == addon.DEFAULT_GROUP then
            btn:GetFontString():SetTextColor(0.8, 0.8, 1)
        else
            btn:GetFontString():SetTextColor(1, 1, 1)
        end

        -- highlight if this is the selected group
        if addon.selectedGroup == name then
            btn:LockHighlight()
            addon.selectedGroupButton = btn
            right.groupLabel:SetText("Selected group: " .. name)
        else
            btn:UnlockHighlight()
        end

        btn:Show()
        yOffset = yOffset + 22
    end

    left.groupContent:SetHeight(math.max(yOffset, 1))

    -- clear selection if invalid
    if addon.selectedGroup and not Inviter3kDB.groups[addon.selectedGroup] then
        addon.selectedGroup = nil
        if addon.selectedGroupButton then addon.selectedGroupButton:UnlockHighlight() end
        addon.selectedGroupButton = nil
        right.groupLabel:SetText("Selected group: None")
    end

    -- refresh members if valid group
    if addon.selectedGroup then
        refreshMemberList()
    else
        right.groupLabel:SetText("Selected group: None")
        addon.selectedMemberIndex = nil
        refreshMemberList()
    end
end
function refreshMemberList()
    local left = addon.gui.leftPane
    local right = addon.gui.rightPane
    if not left or not right then return end

    -- Hide old buttons
    for _, btn in ipairs(right.memberButtons) do btn:Hide() end

    if not addon.selectedGroup then
        right.groupLabel:SetText("Selected group: None")
        right.addInput:Disable()
        right.addBtn:Disable()
        right.inviteBtn:Disable()
        right.removeBtn:Disable()
        right.memberContent:SetHeight(1)
        addon.selectedMemberIndex = nil
        return
    end

    right.addInput:Enable()
    right.addBtn:Enable()
    right.inviteBtn:Enable()
    right.removeBtn:Enable()
    right.groupLabel:SetText("Selected group: " .. addon.selectedGroup)

    local members = addon.GetGroupMembers(addon.selectedGroup)
    local yOffset = 0

    -- clear selection if index is out of range
    if addon.selectedMemberIndex and (addon.selectedMemberIndex < 1 or addon.selectedMemberIndex > #members) then
        if right.memberButtons[addon.selectedMemberIndex] then
            right.memberButtons[addon.selectedMemberIndex]:UnlockHighlight()
        end
        addon.selectedMemberIndex = nil
    end

    for i, name in ipairs(members) do
        local btn = right.memberButtons[i]
        if not btn then
            btn = CreateFrame("Button", nil, right.memberContent, "GameMenuButtonTemplate")
            btn:SetNormalFontObject("GameFontNormal")
            btn:SetHighlightFontObject("GameFontHighlight")

            btn:SetScript("OnClick", function(self)
                -- toggle selection
                if addon.selectedMemberIndex == i then
                    addon.selectedMemberIndex = nil
                    self:UnlockHighlight()
                else
                    if right.memberButtons[addon.selectedMemberIndex] then
                        right.memberButtons[addon.selectedMemberIndex]:UnlockHighlight()
                    end
                    addon.selectedMemberIndex = i
                    self:LockHighlight()
                end
            end)

            right.memberButtons[i] = btn
        end

        -- Always reposition and resize, even if reusing
        btn:ClearAllPoints()
        local btnWidth = (right.memberScroll and right.memberScroll:GetWidth()) or (right:GetWidth() and right:GetWidth() - 14) or 120
        btn:SetSize(math.max(1, btnWidth - 8), 20)
        btn:SetPoint("TOPLEFT", right.memberContent, "TOPLEFT", 8, -yOffset)

        btn:SetText(name)
        if addon.isFriendOnlineByName(name) then
            btn:GetFontString():SetTextColor(1, 1, 1)
        else
            btn:GetFontString():SetTextColor(0.6, 0.6, 0.6)
        end

        btn:Show()
        yOffset = yOffset + 22
    end

    right.memberContent:SetHeight(math.max(yOffset, 1))
end



-- StaticPopup dialogs (kept as in original)
StaticPopupDialogs["INVITER3K_CREATE_GROUP"] = {
    text = "Enter new group name:",
    button1 = "Create",
    button2 = "Cancel",
    hasEditBox = 1,
    maxLetters = 64,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnShow = function(self)
        if self.editBox then
            self.editBox:SetText("")
            self.editBox:SetFocus()
        end
    end,
    OnAccept = function(self)
        local edit = self.editBox
        if not edit then
            local name = self:GetName()
            if name and _G[name .. "EditBox"] then
                edit = _G[name .. "EditBox"]
            end
        end

        local text = ""
        if edit then
            local ok, t = pcall(function() return edit:GetText() end)
            if ok and t then text = t end
        end

        local name = addon.trim(text)
        local ok, reason = addon.CreateGroup(name)
        if ok then
            -- auto-select the new group
            addon.selectedGroup = name
            addon.selectedGroupButton = nil
            addon.selectedMemberIndex = nil
            refreshGroupList()
            addon.safePrint("Group created and selected:", name)
        else
            if reason == "exists" then
                addon.safePrint("Group already exists:", name)
            else
                addon.safePrint("Invalid group name.")
            end
        end
    end,
}


StaticPopupDialogs["INVITER3K_RENAME_GROUP"] = {
    text = "Rename group '%s' to:",
    button1 = "Rename",
    button2 = "Cancel",
    hasEditBox = 1,
    maxLetters = 64,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnShow = function(self)
        if self.editBox then
            local oldName = self.data
            self.editBox:SetText(oldName or "")
            self.editBox:SetFocus()
            self.editBox:HighlightText()
        else
            local fname = self:GetName()
            if fname and _G[fname .. "EditBox"] then
                local oldName = self.data
                _G[fname .. "EditBox"]:SetText(oldName or "")
                _G[fname .. "EditBox"]:SetFocus()
                _G[fname .. "EditBox"]:HighlightText()
            end
        end
    end,
    OnAccept = function(self, data)
        local oldName = data or self.data
        local edit = self.editBox
        if not edit then
            local fname = self:GetName()
            if fname and _G[fname .. "EditBox"] then edit = _G[fname .. "EditBox"] end
        end

        local text = ""
        if edit then
            local ok, t = pcall(function() return edit:GetText() end)
            if ok and t then text = t end
        end

        local newName = addon.trim(text)
        local ok, reason = addon.RenameGroup(oldName, newName)
        if ok then
            -- auto-select the renamed group
            addon.selectedGroup = newName
            addon.selectedGroupButton = nil
            addon.selectedMemberIndex = nil
            refreshGroupList()
            addon.safePrint("Renamed group:", oldName, "->", newName)
        else
            if reason == "exists" then
                addon.safePrint("A group with that name already exists.")
            else
                addon.safePrint("Rename failed.")
            end
        end
    end,
}


StaticPopupDialogs["INVITER3K_DELETE_GROUP"] = {
    text = "Delete group '%s'? This cannot be undone.",
    button1 = "Delete",
    button2 = "Cancel",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnAccept = function(self, name)
        addon.DeleteGroup(name)
        addon.selectedGroup = nil
        if addon.selectedGroupButton then addon.selectedGroupButton:UnlockHighlight() end
        addon.selectedGroupButton = nil
        refreshGroupList()
        addon.safePrint("Group deleted:", name)
    end,
}

StaticPopupDialogs["INVITER3K_REMOVE_MEMBER"] = {
    text = "Remove %s from group?",
    button1 = "Yes",
    button2 = "No",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnAccept = function(self, data)
        if type(data) == "table" then
            local grp = data.group
            local idx = data.index
            if addon.RemoveMemberFromGroup(grp, idx) then
                -- clear selection after removal
                addon.selectedMemberIndex = nil
                if addon.gui and addon.gui.rightPane and addon.gui.rightPane.memberButtons then
                    for _, btn in ipairs(addon.gui.rightPane.memberButtons) do
                        btn:UnlockHighlight()
                    end
                end
                refreshMemberList()
                addon.safePrint("Removed member from group:", grp)
            else
                addon.safePrint("Remove failed.")
            end
        end
    end,
}


-- Rebuild panes on show/resize and initial refresh
gui:HookScript("OnShow", function()
    buildPanes()
    refreshGroupList()
end)
gui:HookScript("OnSizeChanged", function()
    buildPanes()
    refreshGroupList()
end)

if gui:IsShown() then
    buildPanes()
    refreshGroupList()
end
