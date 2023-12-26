local DataStoreService = game:GetService("DataStoreService")

local Signal = require(script.Parent.Parent.Parent.Signal)
local jobScheduler = require(script.Parent.jobScheduler)
local logger = require(script.Parent.Parent.reporting.logger)

local internalStorePrototype = {}
local internalStoreMetatable = { __index = internalStorePrototype }
export type internalStoreType = typeof(setmetatable(
	{} :: {
		store: DataStore,
		scheduler: jobScheduler.jobSchedulerType,
		_storeName: string,
	},
	internalStoreMetatable
))

function internalStorePrototype.updateKey(
	self: internalStoreType,
	keyName: string,
	transformFunc: (
		data: any,
		keyInfo: DataStoreKeyInfo
	) -> (any, { number }, { [string]: any })
)
	self.scheduler:updateRequest(keyName, transformFunc)
end

function internalStorePrototype.loadKey(self: internalStoreType, keyName: string)
	logger.log():dialog(`Loading key: {keyName} in store: {self._storeName}`):trace(script.Name)
	local thread = coroutine.running()

	self.scheduler:loadRequest(keyName, function(keyData)
		logger.log():dialog(`Successfully loaded key: {keyName} in store: {self._storeName}`):trace(script.Name)
		task.spawn(thread, keyData)
	end)

	return coroutine.yield()
end

function internalStorePrototype.wipeKey(self: internalStoreType)
	
end

return function(name: string): internalStoreType
	local self = setmetatable({}, internalStoreMetatable)

	-- get
	self._getSignal = Signal.new()

	-- write
	self._writtenKeys = {}
	self._writeSignal = Signal.new()

	-- logging data
	self._storeName = name

	logger.log():dialog(`Loading store {self._storeName}`):trace(script.Name)
	self.store = DataStoreService:GetDataStore(name)
	self.scheduler = jobScheduler(self.store)

	return self
end
