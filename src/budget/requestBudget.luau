local DataStoreService = game:GetService("DataStoreService")

type requestBudgetReturn = {
	GetAsync: number,
	UpdateAsync: number,
	GetVersionAsync: number,
	RemoveVersionAsync: number,
}

local allDataStoreRequestTypesUsed = {
	GetAsync = Enum.DataStoreRequestType.GetAsync,
	UpdateAsync = Enum.DataStoreRequestType.UpdateAsync,
	GetVersionAsync = Enum.DataStoreRequestType.GetVersionAsync,
	RemoveVersionAsync = Enum.DataStoreRequestType.RemoveVersionAsync,
}

local requestBudget = {}

function requestBudget.availableRequests(): requestBudgetReturn
	local result = {}

	for name: string, enum in pairs(allDataStoreRequestTypesUsed) do
		result[name] = DataStoreService:GetRequestBudgetForRequestType(enum)
	end

	return result
end

return requestBudget
