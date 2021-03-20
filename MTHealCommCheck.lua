
local COMM_PREFIX = "LHC40"

local healCommPlayers = {}

local raidList = {
	"raid1", "raid2", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8", "raid9", "raid10",
	"raid11", "raid12", "raid13", "raid14", "raid15", "raid16", "raid17", "raid18", "raid19", "raid20",
	"raid21", "raid22", "raid23", "raid24", "raid25", "raid26", "raid27", "raid28", "raid29", "raid30",
	"raid31", "raid32", "raid33", "raid34", "raid35", "raid36", "raid37", "raid38", "raid39", "raid40"
}
local partyList = {"player", "party1", "party2", "party3", "party4"}



local function findUnitIdByName(playerName) 

	if IsInRaid() then
		for i, raidId in ipairs(raidList) do
			name, realm = UnitName(raidId)
			if name == playerName then
				return raidId
			end
		end
	 else 
	    
		for i, partyId in ipairs(partyList) do 
			name, realm = UnitName(partyId)

			if name == playerName then
				return partyId
			end
		end
	 end
	return nil
end

local function findClass(unitId)

	
	if unitId ~= nil then
		localizedClass, englishClass, classIndex = UnitClass(unitId)
	else 
		localizedClass = "Unknown"
	end

	return localizedClass
end 


local function getTarget(playerName, list)
	for i, player in ipairs(list) do
		if player.name == playerName then
			return player, i
		end
	end 

	return nil, -1
end 



local function addTarget(playerName, list)
	
	local existingTarget, index = getTarget(playerName, healCommPlayers) 

	if existingTarget ~= nil then
		return false
	end 

	player = {}
	player.name = playerName
	unitId = findUnitIdByName(playerName) 
	player.class = findClass(unitId)
	table.insert(list, player)
	return true
end



local function getRaidPlayers() 
	local raidPlayers = {}
	if IsInRaid() then
		for i, raidId in ipairs(raidList) do
			playerName, realm = UnitName(raidId)
			if playerName ~= nil then 
				addTarget(playerName, raidPlayers)
			end
		end
	
	else
	    
		for i, partyId in ipairs(partyList) do 
			playerName, realm = UnitName(partyId)
			if playerName ~= nil then 
				addTarget(playerName, raidPlayers)
			end
		end
	 end

	return raidPlayers
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
		addTarget(playerName, healCommPlayers)

	end 

end

frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:SetScript("OnEvent", myEventHandler)


local function getInvertOutputPlayers(listType)

	local outputPlayers = {}

	for i, player in ipairs(healCommPlayers) do

		local insertPlayer = false

		if listType == "all" then
			insertPlayer = true
		elseif listType == string.lower(player.class) then
			insertPlayer = true 
		elseif listType == "healer" and (player.class == "Priest" or player.class == "Paladin" or player.class == "Druid" or player.class == "Shaman") then
			insertPlayer = true 
		elseif listType == string.lower(player.name) then
			insertPlayer = true 
		else 
			insertPlayer = false
		end

		if insertPlayer == true then
			table.insert(outputPlayers, player)
		end

	end 

	return outputPlayers

end

local function getOutputPlayers(listType,  list)

	local outputPlayers = {}

	for i, player in ipairs(list) do

		local insertPlayer = false

		if listType == "all" then
			insertPlayer = true
		elseif listType == string.lower(player.class) then
			insertPlayer = true 
		elseif listType == "healer" and (player.class == "Priest" or player.class == "Paladin" or player.class == "Druid" or player.class == "Shaman") then
			insertPlayer = true 
		elseif listType == string.lower(player.name) then
			insertPlayer = true 
		else 
			insertPlayer = false
		end

		if insertPlayer == true then
			table.insert(outputPlayers, player)
		end

	end 

	return outputPlayers

end

local function printTargets(args)

	local listType = nil
	if args == nil or args == "" then
		listType = "healer"
	else 
		listType = string.lower(args)
	end

	outputPlayers = getOutputPlayers(listType, healCommPlayers)
	count = getn(outputPlayers)

	print("List for ".. listType .. " (".. count .. ")")

	for i, target in ipairs(outputPlayers) do
		line = target.name .. " (" .. target.class .. ")"
		print(line)
	end
end

local function printMissingTargets(args)

	local listType = nil
	if args == nil or args == "" then
		listType = "healer"
	else 
		listType = string.lower(args)
	end

	raidPlayers = getRaidPlayers()

	subPlayers = {}

	for i, player in ipairs(raidPlayers) do

		foundTarget = getTarget(player.name, healCommPlayers)

		if foundTarget == nil then
			table.insert(subPlayers, player)
		end
	end

	outputPlayers = getOutputPlayers(listType, subPlayers)
	count = getn(outputPlayers)

	print("List for missing ".. listType .. " (".. count .. ")")

	for i, target in ipairs(outputPlayers) do
		line = target.name .. " (" .. target.class .. ")"
		print(line)
	end
end


local function whisperTargets(args)

	recipient, listType = strsplit(" ", args, 2) 

	if listType == nil or listType == "" then
		listType = "healer"
	else 
		listType = string.lower(listType)
	end

	outputPlayers = getOutputPlayers(listType, healCommPlayers)
	
	count = getn(outputPlayers)

	SendChatMessage("List for ".. listType .. " (".. count .. ")", "WHISPER", "Common", recipient);

	for i, target in ipairs(outputPlayers) do
		line = target.name .. " (" .. target.class .. ")"
		SendChatMessage(line, "WHISPER", nil, recipient);
	end
end


local function whisperMissingTargets(args)

	recipient, listType = strsplit(" ", args, 2) 

	if listType == nil or listType == "" then
		listType = "healer"
	else 
		listType = string.lower(listType)
	end

	raidPlayers = getRaidPlayers()

	subPlayers = {}

	for i, player in ipairs(raidPlayers) do

		foundTarget = getTarget(player.name, healCommPlayers)

		if foundTarget == nil then
			table.insert(subPlayers, player)
		end
	end

	outputPlayers = getOutputPlayers(listType, subPlayers)
	
	count = getn(outputPlayers)

	SendChatMessage("List for missing ".. listType .. " (".. count .. ")", "WHISPER", "Common", recipient);


	for i, target in ipairs(outputPlayers) do
		line = target.name .. " (" .. target.class .. ")"
		SendChatMessage(line, "WHISPER", nil, recipient);
	end
end

local function MyAddonCommands(msg, editbox)

	local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
	if cmd == "print" then
		printMissingTargets(args)
	elseif cmd == "whisper" then
		whisperMissingTargets(args)	
	elseif cmd == "clear" then
		healCommPlayers = {}
	else
		-- If not handled above, display some sort of help message
		print("Syntax: /mthcc (print | whisper | clear)");
	end

  end
  
  SLASH_MTHCC1 = '/mthcc'
  
  SlashCmdList["MTHCC"] = MyAddonCommands   -- add /hiw and /hellow to command list