local budget = require("@src/budget")
local datastoreLinker = require("@src/datastoreLinker")
local jobID = require("@provided/jobID")
local key = require("./key")
local keyData = require("./keyData")
local threadQueue = require("./threadQueue")

type UpdateTransformFunction<T> = (keyData.Identity<T>, DataStoreKeyInfo) -> (keyData.Identity<T>, { number }?, {}?)

local function tryUpdate<T>(store: DataStore, keyName: string, transformFunction: UpdateTransformFunction<T>)
	print("trying")
	return store:UpdateAsync(keyName, transformFunction)
end

local store = {}
export type Identity<T> = typeof(setmetatable(
	{} :: {
		_link: datastoreLinker.Identity,
		_keys: { [string]: key.Identity<T> },
		_template: T,
		_threadQueue: threadQueue.Identity,
	},
	{
		__index = store,
	}
))

local stores: { Identity<any> } = {}

local function constructor<T>(name: string, template: T): Identity<T>
	local self = setmetatable({}, { __index = store })

	self._link = datastoreLinker(name)
	self._keys = {}
	self._template = template
	self._threadQueue = threadQueue.new()

	return self
end

function store.lockAndLoad<T>(self: Identity<T>, keyName: string, userID: number?): key.Identity<T>?
	local userIDArray = { userID :: number }
	local potentialKeyData: T? = {} :: any

	local successfullyLocked = false
	self:_updateAsync(keyName, function(data, info)
		local newKeyData = keyData.reconcile(data, self._template)

		local isSessionLocked = newKeyData.session.locked
		local isLockedByUs = newKeyData.session.lockedBy == jobID()
		local isLockExpired = os.time() - newKeyData.session.lockTimestamp >= 60

		local shouldLock = not isSessionLocked -- Case 1: Not locked
			or (isSessionLocked and isLockExpired) -- Case 2: Locked, expired
			or (isLockExpired and isLockedByUs) -- Case 3: Locked, expired, and locked by us

		if shouldLock then
			newKeyData.session.locked = true
			newKeyData.session.lockedBy = jobID()
			newKeyData.session.lockTimestamp = os.time()
		end

		successfullyLocked = shouldLock
		if successfullyLocked then
			potentialKeyData = newKeyData.data
		end

		return newKeyData, userIDArray, info:GetMetadata()
	end)

	if not successfullyLocked then
		return nil
	end

	local newKey = key.new(keyName, self._template)
	newKey._data = potentialKeyData :: T

	self._keys[keyName] = newKey

	return newKey, true
end

function store.unlock<T>(self: Identity<T>, keyToUnlock: key.Identity<T>)
	local name = keyToUnlock._name
	self:_updateAsync(name, function(data, info)
		local newKeyData = keyData.reconcile(data, self._template)

		-- an EVIL server Stole the lock...
		if newKeyData.session.lockedBy ~= jobID() then
			print("lost session lock")
			return newKeyData, nil, info:GetMetadata()
		end

		newKeyData.session.locked = false
		newKeyData.session.lockedBy = ""
		newKeyData.session.lockTimestamp = 0

		newKeyData.data = keyToUnlock._data

		print(newKeyData)
		return newKeyData, nil, info:GetMetadata()
	end)
end

function store._update<T>(self: Identity<T>, keyName: string, transformFunction: UpdateTransformFunction<T>)
	self._threadQueue:add(function()
		if not budget.canAfford(false) then
			return false
		end

		local success, err = pcall(tryUpdate, self._link.datastore, keyName, transformFunction)
		if not success then
			warn(err)
		end

		return success
	end, function() end, 5)
end

function store._updateAsync<T>(self: Identity<T>, keyName: string, transformFunction: UpdateTransformFunction<T>): boolean
	local thread = coroutine.running()
	print("This sh aint even running")

	self._threadQueue:add(function()
		if not budget.canAfford(true) then
			return false
		end

		local success, err = pcall(tryUpdate, self._link.datastore, keyName, transformFunction)
		if not success then
			warn(err)
		end

		print("yeap")
		return success
	end, function(successful)
		print("WHT")
		task.spawn(thread, successful)
	end, 8)

	return coroutine.yield()
end

function store.createTransform<T, A>(_self: Identity<T>, transform: (data: T, A) -> T)
	return function(keyToModify: key.Identity<T>, args: A)
		keyToModify._data = transform(keyToModify._data, args)
		keyToModify._modified = true
	end
end

function store._step<T>(self: Identity<T>)
	for _, memberKey in self._keys do
		if not memberKey._modified and memberKey._lastAutosave <= 30 then
			continue
		end

		if os.time() - memberKey._lastAutosave <= 10 then
			continue
		end

		memberKey._lastAutosave = os.time()
		self:_update(memberKey._name, function(data, info)
			local newKeyData = keyData.reconcile(data, self._template)
			if newKeyData.session.locked and newKeyData.session.lockedBy ~= jobID() then
				(memberKey :: key.Identity<T>):_invokeLockLostCallback()
				print("lost session lock")
				return newKeyData, nil, info:GetMetadata()
			end

			newKeyData.session.locked = true
			newKeyData.session.lockedBy = jobID()
			newKeyData.session.lockTimestamp = os.time()

			newKeyData.data = memberKey._data

			return newKeyData, nil, info:GetMetadata()
		end)
	end
end

return {
	step = function()
		for _, storeToStep in stores do
			(storeToStep :: Identity<any>):_step()
		end
	end,

	new = constructor,
}
