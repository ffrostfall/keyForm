local function deepCopy<T>(tableToClone: T): T
	local clone = table.clone(tableToClone :: any)

	for index, value in clone do
		if typeof(value) == "table" then
			clone[index] = deepCopy(value)
		end
	end

	return clone :: any
end

local function reconcile<T>(original: {}, with: {} & T): T
	local tbl = table.clone(original)
	local withAsTable = with :: {}

	for key, value in pairs(with) do
		if tbl[key] == nil then
			if typeof(value) == "table" then
				tbl[key] = deepCopy(value)
			else
				tbl[key] = value
			end
		elseif typeof(withAsTable[key]) == "table" then
			if typeof(value) == "table" then
				tbl[key] = reconcile(value, withAsTable[key])
			else
				tbl[key] = deepCopy(withAsTable[key])
			end
		end
	end

	return tbl :: typeof(with)
end

export type Identity<T> = {
	globalTransforms: {},
	session: {
		locked: boolean,
		lockedBy: string,
		lockTimestamp: number,
	},

	data: T,
}

local keyData = {}

function keyData.fresh<T>(template: T): Identity<T>
	return {
		globalTransforms = {},
		session = {
			locked = false,
			lockedBy = "",
			lockTimestamp = 0,
		},

		data = deepCopy(template),
	}
end

function keyData.reconcile<T>(input: any, template: T): Identity<T>
	if not input then
		return keyData.fresh(template)
	end

	if not input.globalTransforms then
		input.globalTransforms = {}
	end

	if not input.session then
		input.session = {
			locked = false,
			lockedBy = "",
			lockTimestamp = 0,
		}
	end

	if not input.data then
		input.data = deepCopy(template)
	else
		local data = input.data

		input.data = reconcile(data, template :: any)
	end

	return input
end

return keyData
