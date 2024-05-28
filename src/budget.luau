local DataStoreService = game:GetService("DataStoreService")

local budget = {}

function budget.canAfford(priority: boolean)
	local amount = DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.UpdateAsync)
	local threshold = if priority then 5 else 100

	return amount >= threshold
end

return budget
