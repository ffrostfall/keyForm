local keyIntegrities = require(script.Parent.keyIntegrities)

return function(rawData: any): keyIntegrities.allKeyIntegrities
	if rawData == nil then
		return keyIntegrities.new
	end

	if typeof(rawData) ~= "table" then
		return keyIntegrities.corrupt
	end

	local session = rawData["session"]
	local data = rawData["data"]

	if typeof(session) ~= "string" then
		return keyIntegrities.corrupt
	end
	if typeof(data) ~= "table" then
		return keyIntegrities.corrupt
	end

	return keyIntegrities.ok
end
