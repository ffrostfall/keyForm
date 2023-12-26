local RunService = game:GetService("RunService")

local internalStore = require(script.Parent.Parent.internal.internalStore)
local key = require(script.Parent.key)
local transform = require(script.Parent.Parent.transforms.transform)
local transformAsync = require(script.Parent.Parent.transforms.transformAsync)

type keyInfoType = {
	isLocked: boolean,
	lastUpdated: number,
	lastSaved: number,
	data: any,

	keyObject: key.keyType,
}

local dataStorePrototype = {}
local dataStoreMetatable = { __index = dataStorePrototype }
type dataStoreType = typeof(setmetatable(
	{} :: {
		_store: internalStore.internalStoreType,
		_keyConnections: { [string]: {} },
		_keyInfo: { [string]: keyInfoType },
		_template: {},
	},
	dataStoreMetatable
))

function dataStorePrototype.loadKey(self: dataStoreType, keyName: string)
	local createdKey = key(keyName, self._store, self._template)

	self._keyInfo[keyName] = {
		isLocked = false,
		lastUpdated = 0,
		lastSaved = os.clock(),

		keyObject = createdKey,
	}
	self._keyConnections[keyName] = {
		createdKey._lockedSignal:Connect(function()
			self._keyInfo[keyName].isLocked = true
		end),

		createdKey._unlockedSignal:Connect(function()
			self._keyInfo[keyName].isLocked = false
		end),

		createdKey._updated:Connect(function(data)
			self._keyInfo[keyName].lastUpdated = os.clock()
			self._keyInfo[keyName].data = data
		end),
	}

	return createdKey
end

function dataStorePrototype:createTransform(transformFunction)
	return transform(transformFunction)
end

function dataStorePrototype:createAsyncTransform(transformFunction)
	return transformAsync(transformFunction)
end

return function(storeName: string, template: {}): dataStoreType
	local self = setmetatable({}, dataStoreMetatable)

	self._store = internalStore(storeName)
	self._template = template

	self._keyConnections = {}
	self._keyInfo = {}

	self._autosave = RunService.Heartbeat:Connect(function()
		for keyName, keyInfo: keyInfoType in pairs(self._keyInfo) do
			if os.clock() - keyInfo.lastUpdated <= 6 and os.clock() - keyInfo.lastSaved >= 6 then
				keyInfo.lastSaved = os.clock()
				self._store:updateKey(keyName, function(keyData, keyInfoInstance)
					local userIDs = {}
					local metadata = {}

					if keyInfoInstance then
						userIDs = keyInfoInstance:GetUserIds()
						metadata = keyInfoInstance:GetMetadata()
					end

					keyData.keyVersion += 1

					-- Don't override
					if keyInfo.data ~= nil then
						keyData.data = keyInfo.data
					end

					for _, userID in keyInfo.keyObject._pendingUserIDs do
						if not table.find(userIDs, userID) then
							table.insert(userIDs, userID)
						end
					end
					table.clear(keyInfo.keyObject._pendingUserIDs)

					return keyData, userIDs, metadata
				end)
			end
		end
	end)

	return self
end
