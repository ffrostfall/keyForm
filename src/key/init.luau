local key = {}
export type Identity = typeof(setmetatable({} :: {}, {
	__index = key,
}))

local function constructor(): Identity
	local self = setmetatable({}, { __index = key })

	return self
end

function key.useTransform(self: Identity) end

function key.useAsyncTransform(self: Identity) end

function key.useGlobalTransform(self: Identity) end

return {
	new = constructor,
}
