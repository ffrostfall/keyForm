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
	local key = store:lockAndLoad(`player-${player.UserId}`)
	if key then
		keys[player.UserId] = key
	else
		player:Kick("sessionlock")
	end

	addOne(key, {
		amount = 5,
	})

	print(key:read().numberthing)
end)

Players.PlayerRemoving:Connect(function(player)
	local key = keys[player.UserId]
	if not key then
		return
	end

	store:unlock(key)
	keys[player.UserId] = nil
end)
