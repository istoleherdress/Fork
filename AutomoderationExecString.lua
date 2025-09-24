print("Loaded AUTOMOD APIIIIIIIIIIIIIIIIIIIIIIIIIIII")

local Players = game:GetService("Players")

local AutoBans = {
	{5469490435, "Debugging account! You cannot access this experience."};
}

local BadWords = {
	"test";
}

local FlagStore = {} -- { [UserId] = {flags = {}, count = 0} }

local MaxFlags = 5

local Config = {
	Ignore_Max_Flags = false, -- Kicks on 1 offense
	Kick_On_Flag_Temper_Detection = false, -- If you suspect tampering
}

--// Ban check
local function CheckAutoBan(Player)
	for _, ban in ipairs(AutoBans) do
		if Player.UserId == ban[1] then
			Player:Kick(ban[2])
			return true
		end
	end
	return false
end

--// Create storage for player
local function CreateFlags(Player)
	FlagStore[Player.UserId] = {
		flags = {},
		count = 0,
	}
end

--// Add a flag
local function AddFlag(Player, Reason)
	local data = FlagStore[Player.UserId]
	if not data then
		CreateFlags(Player)
		data = FlagStore[Player.UserId]
	end

	table.insert(data.flags, Reason or "Unspecified")
	data.count += 1

	if Config.Ignore_Max_Flags then
		Player:Kick("You were flagged: " .. tostring(data.flags[#data.flags]))
	elseif data.count >= MaxFlags then
		Player:Kick("Too many flags! (" .. data.count .. ")")
	end
end

--// Remove specific flag
local function RemoveFlag(Player, FlagNum)
	local data = FlagStore[Player.UserId]
	if not data or data.count == 0 then return end

	if FlagNum then
		if data.flags[FlagNum] then
			table.remove(data.flags, FlagNum)
			data.count -= 1
		end
	else
		table.remove(data.flags, #data.flags)
		data.count = math.max(0, data.count - 1)
	end
end

--// Remove all flags
local function RemoveAllFlags(Player)
	FlagStore[Player.UserId] = {
		flags = {},
		count = 0,
	}
end

--// Check flags
local function CheckFlags(Player)
	local data = FlagStore[Player.UserId]
	if not data then return 0, {} end
	return data.count, data.flags
end

--// Detect bad words
local function ContainsBadWord(message)
	message = string.lower(message)
	for _, word in ipairs(BadWords) do
		if string.find(message, word) then
			return word
		end
	end
	return nil
end

--// Player join/leave
Players.PlayerAdded:Connect(function(Player)
	if not CheckAutoBan(Player) then
		CreateFlags(Player)

		-- Chat listener
		Player.Chatted:Connect(function(msg)
			local bad = ContainsBadWord(msg)
			if bad then
				AddFlag(Player, "Bad language detected: " .. bad)
				warn(Player.Name .. " flagged for saying: " .. bad)
			end
		end)
	end
end)

Players.PlayerRemoving:Connect(function(Player)
	FlagStore[Player.UserId] = nil
end)
