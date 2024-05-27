local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local keyForm = require(ReplicatedStorage.keyForm)

local keys = {}
local store = keyForm.store("hi", {
	numberthing = 1,
})

local addOne = store:createTransform(function(data, arguments: { amount: number })
	data.numberthing += arguments.amount

	return data
end)

Players.PlayerAdded:Connect(function(player)
	local key, locked = store:lockAndLoad(`player-${player.UserId}`)
	keys[player.UserId] = key

	if not locked then
		player:Kick("sessionlock")
		print("sessionlock")
		return
	end

	addOne(key, {
		amount = 5,
	})
end)

Players.PlayerRemoving:Connect(function(player)
	local key = keys[player.UserId]
	store:unlock(key)

	keys[player.UserId] = nil
end)
