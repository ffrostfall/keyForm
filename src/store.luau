local datastoreLink = require(script.Parent.datastoreLink)
local datastoreServiceRef = require(script.Parent.serviceRefs.datastoreServiceRef)
local key = require(script.Parent.key)
local memoryStoreServiceRef = require(script.Parent.serviceRefs.memoryStoreServiceRef)

local storePrototype = {}
local prototypeMetatable = { __index = storePrototype }
export type storeType = typeof(setmetatable(
	{} :: {
		_store: DataStore,
		_memStore: MemoryStoreHashMap,

		_keys: { [string]: key.keyType },
		_template: {},
	},
	prototypeMetatable
))

local function constructor(name: string, template: {}): storeType
	local self = setmetatable({}, prototypeMetatable)

	self._store = datastoreServiceRef():GetDataStore(name)
	self._memStore = memoryStoreServiceRef():GetHashMap(`{name}_sessionLocks`)

	self._keys = {}
	
	self._template = template

	task.spawn(function()
		while true do
			self:_autosave()

			task.wait(10)
		end
	end)

	game:BindToClose(function()
		self:_autosave()
	end)

	return self
end

function storePrototype._autosave(self: storeType)
	for _, loadedKey in self._keys do
		loadedKey:_save()
	end
end

function storePrototype.loadKey(self: storeType, keyName: string, userID: number)
	local link = datastoreLink(self._store, self._memStore, keyName)
	local freshKey = key.new(link, self._template, userID)

	self._keys[keyName] = freshKey

	return freshKey
end

return {
	new = constructor,
}
