if not game:GetService("RunService"):IsServer() then return end

local Players = game:GetService("Players")

local Automoderation = {}

Automoderation.BannedUsers = {
	{3516904613, "Debugging account! You cannot access this experience."}
}

Automoderation.CheckPlayerStatus = function(Player)
	for _, user in ipairs(Automoderation.BannedUsers) do
		if Player.UserId == user[1] then
			Player:Kick(user[2])
			return
		end
	end
end

Automoderation.AttachAutomoderation = function()
	for _, Player in pairs(Players:GetPlayers()) do
		Automoderation.CheckPlayerStatus(Player)
	end
	
	Players.PlayerAdded:Connect(function(Player)
		Automoderation.CheckPlayerStatus(Player)
	end)

end

Automoderation.AttachAutomoderation()
