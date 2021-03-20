
local COMM_PREFIX = "LHC40"

local playerNames = {}
local healerNames = {}

local raidList = {
	"raid1", "raid2", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8", "raid9", "raid10",
	"raid11", "raid12", "raid13", "raid14", "raid15", "raid16", "raid17", "raid18", "raid19", "raid20",
	"raid21", "raid22", "raid23", "raid24", "raid25", "raid26", "raid27", "raid28", "raid29", "raid30",
	"raid31", "raid32", "raid33", "raid34", "raid35", "raid36", "raid37", "raid38", "raid39", "raid40"
}
local partyList = {"player", "party1", "party2", "party3", "party4"}

local function findUnitIdByName(playerName) 

	for i, raidId in ipairs(raidList) do
		name, realm = UnitName(raidId)
		if name == playerName then
			return raidId
		end
	end

	for i, partyId in ipairs(partyList) do 
		name, realm = UnitName(partyId)

		if name == playerName then
			return partyId
		end
	end

	return nil
end

local function findClass(playerName)

	unitId = findUnitIdByName(playerName) 

	if unitId ~= nil then
		localizedClass, englishClass, classIndex = UnitClass(playerName)
	else 
		localizedClass = "Unknown"
	end

	return localizedClass
end 


local function getTarget(playerName)
	for i, player in ipairs(playerNames) do
		if player.name == playerName then
			return player, i
		end
	end 

	return nil, -1
end 


local function addTarget(playerName)
	
	local existingTarget, index = getTarget(playerName) 

	if existingTarget ~= nil then
		return false
	end 

	player = {}
	player.name = playerName
	player.class = findClass(playerName)
	table.insert(playerNames, player)
	return true
end


local function formatTargetName(playerName)

	if playerName == nil then
		return
	end 

	return playerName:gsub("(%w*)-(%w*)", function(a,b) return a end)

end


local function myEventHandler(self, event, ...)

	if (event == "CHAT_MSG_ADDON") then 

		prefix, message, channel, sender = ...

		if (prefix ~= COMM_PREFIX) then return end 

		playerName = formatTargetName(sender) 
		addTarget(playerName)

	end 

end

frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:SetScript("OnEvent", myEventHandler)


local function printTargest(args)


	if args == nil or args == "" then
		args = "healer"
	else 
		args = string.lower(args)
	end

	outputPlayers = {}

	for i, player in ipairs(playerNames) do

		insertPlayer = false

		if args == "all" then
			insertPlayer = true
		elseif args == string.lower(player.class) then
			insertPlayer = true 
		elseif args == "healer" and (player.class == "Priest" or player.class == "Paladin" or player.class == "Druid" or player.class == "Shaman") then
			insertPlayer = true 
		elseif args == string.lower(player.name) then
			insertPlayer = true 
		else 
			insertPlayer = false
		end

		if insertPlayer == true then
			table.insert(outputPlayers, player)
		end

	end 

	count = getn(outputPlayers)

	print ("List for ".. args .. " (".. count .. ")")

	for i, target in ipairs(outputPlayers) do
		line = target.name .. " (" .. target.class .. ")"
		print(line)
	end
end

local function MyAddonCommands(msg, editbox)

	local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")

	if cmd == "list" then
		printTargest(args)
	elseif cmd == "clear" then
		playerNames = {}
	else
		-- If not handled above, display some sort of help message
		print("Syntax: /mthcc (list|clear)");
	end

  end
  
  SLASH_MTHCC1 = '/mthcc'
  
  SlashCmdList["MTHCC"] = MyAddonCommands   -- add /hiw and /hellow to command list