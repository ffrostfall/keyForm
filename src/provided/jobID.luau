local currentRuntime = require("./currentRuntime")

local jobID = ""
if currentRuntime() == "roblox" then
	local isStudio = game:GetService("RunService"):IsStudio()

	jobID = if isStudio then game:GetService("HttpService"):GenerateGUID(false) else game.JobId
else
	jobID = tostring(math.random(1, 10000))
end

return function()
	return jobID
end
