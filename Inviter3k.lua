local eventFrame = CreateFrame("Frame")
--Adds Event that need to be tracked
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", OnEvent)

--Defines Slash Comands
--Slash for inviting
SLASH_INVITER3KINVITE1 = "/inviter3kinv"
--shlash for Adding friend into invite pool
SLASH_INVITER3KADD1 = "/inviter3kadd"
--Slash for Removing Friend from invite pool
SLASH_INVITER3KREMOVE1 = "/inviter3kremove"
--Slash for showing current invite pool
SLASH_INVITER3KLIST1 = "/inviter3klist"
--Makes the Slash Commands do something

Battlenet = {}


function  SlashCmdList.INVITER3KINVITE(msg, editBox)
    print("Inviting")
end
SlashCmdList.INVITER3KADD = function(msg, editBox)
    local name = strsplit(" ", msg)
    if #name > 0 then
        table.insert(Battlenet, name)
    else 
        print("needs a name")
    end
end
    


function SlashCmdList.INVITER3KREMOVE(msg,editBox)
    print("Removed a person")
end
function SlashCmdList.INVITER3KLIST(msg, editBox)
    for key,value in ipairs(Battlenet) do
    print(key,value)
    end     
end


-- local function OnEvent(self, event, addOnName)
--     if addOnName == "Inviter3k" then
--         Inviter3kDB = Inviter3kDB or {}
--         self.db = Inviter3kDB -- makes it more readable and generally a good practice
-- 		for k, v in pairs(defaults) do -- copy the defaults table and possibly any new options
-- 			if self.db[k] == nil then -- avoids resetting any false values
-- 				self.db[k] = v
-- 			end
    
--         end
--     end
-- end

