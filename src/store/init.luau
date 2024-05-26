local store = {}
export type Identity = typeof(setmetatable({} :: {}, {
	__index = store,
}))

local function constructor(name: string): Identity
	local self = setmetatable({}, { __index = store })

	return self
end

function store.lockAndLoad(self: Identity, key: string) end

function store.loadWithoutLock(self: Identity, key: string) end

return {
	new = constructor,
}
