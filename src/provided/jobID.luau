local currentRuntime = require("./currentRuntime")

return function()
	if currentRuntime() == "lune" then
		return ""
	else
		local isStudio = game:GetService("RunService"):IsStudio()

		if isStudio then
			return tostring(math.random(1, 100))
		else
			return game.JobId
		end
	end
end
