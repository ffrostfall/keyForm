--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local keyForm = require(ReplicatedStorage.Packages.keyForm)
keyForm.showTrace()

local playerDataStore = keyForm.createStore("Store4", {
	secondsPlayed = 1,
})

local incrementSecondsPlayed = playerDataStore:createTransform(function(data, amount)
	data.secondsPlayed += amount
	return data
end)

local keys = {}
Players.PlayerAdded:Connect(function(player)
	local key = playerDataStore:loadKey(`player_{player.UserId}`)
	key:addUserID(player.UserId)
	keys[player] = key

	local successfulLock = key:lockAsync()
	if successfulLock then
		-- Every 1 second, increment the seconds played by 1
		task.spawn(function()
			while player:IsDescendantOf(game) do
				incrementSecondsPlayed(key, 1)
				task.wait(1)
			end
		end)
	else
		player:Kick("session locked")
	end
end)

Players.PlayerRemoving:Connect(function(player)
	if keys[player] then
		keys[player]:unlock()
		keys[player]:remove()
	end
end)

return true
