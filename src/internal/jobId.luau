local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local logger = require(script.Parent.Parent.reporting.logger)

local fakeJobId = HttpService:GenerateGUID(false)

if RunService:IsStudio() then
	logger.log():kind(`Running in studio mode with a fake job ID of: {fakeJobId}`):log()
end

return function()
	if RunService:IsStudio() then
		return fakeJobId
	else
		return game.JobId
	end
end
