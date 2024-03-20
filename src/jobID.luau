local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

if RunService:IsStudio() then
	return HttpService:GenerateGUID(false)
end

return game.JobId
