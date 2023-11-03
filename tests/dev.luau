--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local newDatastoreLibrary = require(ReplicatedStorage.Packages.keyForm)
newDatastoreLibrary.showTrace()

local TestStore = newDatastoreLibrary.createStore("Store1", {
	secondsPlayed = 1,
})

local incrementSecondsPlayed = TestStore:createTransform(function(data, amount)
	data.secondsPlayed += amount
	return data
end)

local keys = {}
Players.PlayerAdded:Connect(function(player)
	local key = TestStore:loadKey(`player_{player.UserId}`)
	keys[player] = key

	if key:lockAsync() then
		task.spawn(function()
			while player:IsDescendantOf(game) do
				incrementSecondsPlayed(key, 5)
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
