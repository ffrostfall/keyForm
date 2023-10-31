local logger = require(script.Parent.Parent.reporting.logger)
local requestBudget = require(script.Parent.requestBudget)
local requestKinds = require(script.Parent.requestKinds)

local requestSchedule = {}
local requestKindToDataStoreBudget: {
	[requestKinds.allRequestKinds]: "GetAsync" | "UpdateAsync",
} = {
	[requestKinds.load] = "GetAsync",
	[requestKinds.update] = "UpdateAsync",
}
local function claim(dataStoreRequest, currentSecond)
	if requestSchedule[currentSecond] == nil then
		requestSchedule[currentSecond] = { [dataStoreRequest] = 1 }
	else
		if requestSchedule[currentSecond][dataStoreRequest] == nil then
			requestSchedule[currentSecond][dataStoreRequest] = 1
		else
			requestSchedule[currentSecond][dataStoreRequest] += 1
		end
	end

	logger.log():dialog(`Claimed request kind: {dataStoreRequest} at second: {currentSecond}`):trace(script.Name)
	return currentSecond
end

local budgetManager = {}

function budgetManager.claimNextAvailable(requestKind: requestKinds.allRequestKinds): number
	local budget = requestBudget.availableRequests()
	local dataStoreRequestType = requestKindToDataStoreBudget[requestKind]

	logger.log():dialog(`Scheduling request kind: {requestKind}`):trace(script.Name)

	if budget[dataStoreRequestType] > 30 then
		local currentSecond = math.round(os.clock() - (os.clock() % 1))
		claim(dataStoreRequestType, currentSecond)

		return os.clock()
	else
		local currentSecond = math.round(os.clock() - (os.clock() % 1))

		local secondPointer = currentSecond
		while true do
			if secondPointer >= 15 then
				return 0
			end

			if requestSchedule[secondPointer] == nil then
				return claim(dataStoreRequestType, secondPointer)
			else
				if requestSchedule[secondPointer][dataStoreRequestType] == nil then
					return claim(dataStoreRequestType, secondPointer)
				else
					if requestSchedule[secondPointer][dataStoreRequestType] >= 1 then
						secondPointer += 1
						continue
					end
				end
			end
		end
	end
end

return budgetManager
