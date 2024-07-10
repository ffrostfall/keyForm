local function deepCopy<T>(tableToClone: T): T
	local clone = table.clone(tableToClone :: any)

	for index, value in clone do
		if typeof(value) == "table" then
			clone[index] = deepCopy(value)
		end
	end

	return (clone :: any) :: T
end

local function reconcile<T>(original: { [any]: any }, template: T & {}): T
	local tbl = table.clone(original)

	for key, value: any in template :: {} do
		local tbl_key = tbl[key]

		if not tbl_key then
			tbl[key] = if type(value) == "table" then deepCopy(value) else value
		elseif type(tbl_key) == "table" and type(value) == "table" then
			tbl[key] = reconcile(tbl_key, value)
		end
	end

	return tbl :: any
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
