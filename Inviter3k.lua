local ADDON_NAME = ...
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")

-- ==============================
-- Initialize SavedVariables
-- ==============================
local function InitDatabase()
    Inviter3kDB = Inviter3kDB or {}
    Inviter3kDB.minimap = Inviter3kDB.minimap or { minimapPos = 220, hide = false }
end

-- ==============================
-- GUI Frame
-- ==============================
local gui = CreateFrame("Frame", "Inviter3kFrame", UIParent, "BasicFrameTemplateWithInset")
gui:SetSize(320, 450)
gui:SetPoint("CENTER")
gui:SetMovable(true)
gui:EnableMouse(true)
gui:RegisterForDrag("LeftButton")
gui:SetScript("OnDragStart", gui.StartMoving)
gui:SetScript("OnDragStop", gui.StopMovingOrSizing)
gui:Hide()

gui.title = gui:CreateFontString(nil, "OVERLAY")
gui.title:SetFontObject("GameFontHighlight")
gui.title:SetPoint("LEFT", gui.TitleBg, "LEFT", 5, 0)
gui.title:SetText("Inviter3k")

-- Add BattleTag Input
gui.addInput = CreateFrame("EditBox", nil, gui, "InputBoxTemplate")
gui.addInput:SetSize(180, 25)
gui.addInput:SetPoint("TOP", gui, "TOP", 0, -50)
gui.addInput:SetAutoFocus(false)
gui.addInput:SetText("Enter BattleTag")

gui.addButton = CreateFrame("Button", nil, gui, "GameMenuButtonTemplate")
gui.addButton:SetPoint("TOP", gui.addInput, "BOTTOM", 0, -5)
gui.addButton:SetSize(100, 25)
gui.addButton:SetText("Add")
gui.addButton:SetNormalFontObject("GameFontNormal")
gui.addButton:SetHighlightFontObject("GameFontHighlight")

-- ==============================
-- Scrollable List
-- ==============================
gui.listScroll = CreateFrame("ScrollFrame", nil, gui, "UIPanelScrollFrameTemplate")
gui.listScroll:SetSize(280, 250)
gui.listScroll:SetPoint("TOP", gui.addButton, "BOTTOM", 0, -10)

gui.listContent = CreateFrame("Frame", nil, gui.listScroll)
gui.listContent:SetSize(280, 1)  -- height grows with buttons
gui.listScroll:SetScrollChild(gui.listContent)

gui.listScroll.buttons = {}

local function IsFriendOnline(name)
    local numOfFriends = BNGetNumFriends()
    for i = 1, numOfFriends do
        local info = C_BattleNet.GetFriendAccountInfo(i)
        if info and info.accountName == name then
            local games = info.gameAccountInfo
            if games then
                if games.isOnline ~= nil then -- single entry
                    games = {games}
                end
                for _, gameInfo in ipairs(games) do
                    if gameInfo.isOnline and gameInfo.clientProgram == "WoW" then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function gui.listScroll:UpdateList()
    for _, button in ipairs(self.buttons) do
        button:Hide()
    end

    local yOffset = 0
    for i, name in ipairs(Inviter3kDB) do
        local button = self.buttons[i]
        if not button then
            button = CreateFrame("Button", nil, gui.listContent, "GameMenuButtonTemplate")
            button:SetSize(250, 20)
            button:SetPoint("TOPLEFT", 0, -yOffset)
            button:SetNormalFontObject("GameFontNormal")
            button:SetHighlightFontObject("GameFontHighlight")
            button:SetScript("OnClick", function()
                StaticPopup_Show("INVITER3K_REMOVE_CONFIRM", name, nil, i)
            end)
            self.buttons[i] = button
        end
        button:SetText(name)
        if IsFriendOnline(name) then
            button:GetFontString():SetTextColor(1, 1, 1)
        else
            button:GetFontString():SetTextColor(0.5, 0.5, 0.5)
        end
        button:Show()
        yOffset = yOffset + 22
    end
    gui.listContent:SetHeight(math.max(yOffset, 1))
end

-- ==============================
-- Add & Remove Buttons
-- ==============================
gui.addButton:SetScript("OnClick", function()
    local tag = gui.addInput:GetText()
    if tag and tag ~= "" then
        for _, name in ipairs(Inviter3kDB) do
            if name == tag then
                print("Already added:", tag)
                return
            end
        end
        table.insert(Inviter3kDB, tag)
        gui.addInput:SetText("")
        gui.listScroll:UpdateList()
        print("Added:", tag)
    end
end)

-- ==============================
-- Invite All Button
-- ==============================
gui.inviteButton = CreateFrame("Button", nil, gui, "GameMenuButtonTemplate")
gui.inviteButton:SetSize(140, 25)
gui.inviteButton:SetPoint("BOTTOM", gui, "BOTTOM", 0, 50)
gui.inviteButton:SetText("Invite All Online")
gui.inviteButton:SetNormalFontObject("GameFontNormal")
gui.inviteButton:SetHighlightFontObject("GameFontHighlight")
gui.inviteButton:SetScript("OnClick", function()
    local numOfFriends = BNGetNumFriends()
    if numOfFriends == 0 then
        print("No Battle.net friends found.")
        return
    end
        for i = 1, BNGetNumFriends() do
            local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
        if accountInfo and accountInfo.battleTag and accountInfo.gameAccountInfo then
            local games = accountInfo.gameAccountInfo
            if games.isOnline ~= nil then
            games = {games} -- handle single-entry case
        end
        for _, gameInfo in ipairs(games) do
            if gameInfo.isOnline and gameInfo.clientProgram == "WoW" then
                for _, savedTag in ipairs(Inviter3kDB) do
                    if string.lower(accountInfo.battleTag) == string.lower(savedTag) then
                        BNInviteFriend(gameInfo.gameAccountID)
                        print("Invited:", accountInfo.battleTag)
                        end
                    end
                end
            end
        end
    end

end)

-- ==============================
-- Reset Button
-- ==============================
gui.resetButton = CreateFrame("Button", nil, gui, "GameMenuButtonTemplate")
gui.resetButton:SetSize(140, 25)
gui.resetButton:SetPoint("BOTTOM", gui.inviteButton, "TOP", 0, 5)
gui.resetButton:SetText("Reset List")
gui.resetButton:SetNormalFontObject("GameFontNormal")
gui.resetButton:SetHighlightFontObject("GameFontHighlight")
gui.resetButton:SetScript("OnClick", function()
    StaticPopup_Show("INVITER3K_RESET_CONFIRM")
end)

-- ==============================
-- Confirmation Popups
-- ==============================
StaticPopupDialogs["INVITER3K_RESET_CONFIRM"] = {
    text = "Are you sure you want to reset the invite list?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        Inviter3kDB = {}
        gui.listScroll:UpdateList()
        print("Invite list has been reset.")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["INVITER3K_REMOVE_CONFIRM"] = {
    text = "Remove %s from the invite list?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function(self, data)
        table.remove(Inviter3kDB, data)
        gui.listScroll:UpdateList()
        print("Removed from invite list.")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}
-- helper to apply saved state
local function UpdateMinimapIcon()
    local dbicon = LibStub("LibDBIcon-1.0", true)
    if not dbicon then return end
    if Inviter3kDB.minimap.hide then
        dbicon:Hide("Inviter3k")
        print("Inviter3k minimap icon hidden.")
    else
        dbicon:Show("Inviter3k")
        print("Inviter3k minimap icon shown.")
    end
end
-- helper to print one command line
local function PrintCmd(cmd, desc)
    print(string.format("|cffffff00%s|r - %s", cmd, desc))
end

-- Help handler: list all available slash commands and short descriptions
SLASH_INVITER3KHELP1 = "/inviter3khelp"
SLASH_INVITER3KHELP2 = "/i3khelp"
SlashCmdList["INVITER3KHELP"] = function()
    print("Inviter3k commands:")
    PrintCmd("/inviter3k or /i3k", "Toggle the main GUI")
    PrintCmd("/invite3k or /i3kinvite", "Invite saved BattleTags who are online in WoW")
    PrintCmd("/i3ktoggle or /inviter3ktoggle", "Toggle the minimap icon; also accepts 'show' or 'hide'")
    PrintCmd("/inviter3khelp or /i3khelp", "Show this help list")
end
-- ==============================
-- Slash command to toggle GUI
-- ==============================
SLASH_INVITER3K1 = "/inviter3k"
SLASH_INVITER3K2 = "/i3k"
SlashCmdList["INVITER3K"] = function()
    if gui:IsShown() then
        gui:Hide()
    else
        gui:Show()
        gui.listScroll:UpdateList()
    end
end
SLASH_INVITER3KINVITE1 = "/invite3k"
SLASH_INVITER3KINVITE2 = "/i3kinvite"
SlashCmdList["INVITER3KINVITE"] = function()
    gui.inviteButton:Click()
end

SLASH_INVITER3KTOGGLEMAP1 = "/i3ktoggle"
SLASH_INVITER3KTOGGLEMAP2 = "/inviter3ktoggle"
SlashCmdList["INVITER3KTOGGLEMAP"] = function(msg)
    local cmd = msg and msg:lower():trim() or ""
    if cmd == "show" then
        Inviter3kDB.minimap.hide = false
    elseif cmd == "hide" then
        Inviter3kDB.minimap.hide = true
    else
        Inviter3kDB.minimap.hide = not Inviter3kDB.minimap.hide
    end
    UpdateMinimapIcon()
end
-- ==============================
-- Event Handler
-- ==============================
eventFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        InitDatabase()

        -- Minimap Icon (registered after DB is initialized)
        local ldb = LibStub("LibDataBroker-1.1"):NewDataObject("Inviter3k", {
            type = "launcher",
            text = "Inviter3k",
            icon = "Interface\\AddOns\\Inviter3k\\icon.tga",
            OnClick = function(_, button)
                if button == "LeftButton" then
                    gui.inviteButton:Click()
                else
                    if gui:IsShown() then
                        gui:Hide()
                    else
                        gui:Show()
                        gui.listScroll:UpdateList()
                    end
                end
            end,
        })
        LibStub("LibDBIcon-1.0"):Register("Inviter3k", ldb, Inviter3kDB.minimap)
                -- apply minimap saved state if you have an UpdateMinimapIcon helper
        if UpdateMinimapIcon then
            UpdateMinimapIcon()
        end
        -- print a short help hint after loading
        print("|cffffff00Inviter3k loaded.|r Type |cffffff00/i3khelp|r for list of commands.")
    end
end)

