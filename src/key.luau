local datastoreLink = require(script.Parent.datastoreLink)
local globalTransform = require(script.Parent.globalTransform)
local jobID = require(script.Parent.jobID)
local jobQueue = require(script.Parent.jobQueue)

type globalTransformData = {
	name: string,
	args: {},
}

type keyData = {
	session: string,
	sessionLockTime: number,
	data: {},
	pendingGlobalTransforms: { globalTransformData },
}?

local function deepCopy<T>(tableToClone: T & {}): T & {}
	local clone = table.clone(tableToClone)

	for index, value in clone do
		if typeof(value) == "table" then
			clone[index] = deepCopy(value :: {})
		end
	end

	return clone :: any
end

local function reconcile<T>(original: { [any]: any }, template: T & {}): T
	assert(typeof(template) == "table", "Luau")

	local tbl = table.clone(original)

	for key, value in template do
		if tbl[key] == nil then
			if typeof(value) == "table" then
				tbl[key] = deepCopy(value)
			else
				tbl[key] = value
			end
		elseif typeof(template[key]) == "table" then
			if typeof(value) == "table" then
				tbl[key] = reconcile(value, template[key] :: {})
			else
				tbl[key] = deepCopy(template[key] :: {})
			end
		end
	end

	-- Luau moment
	return tbl :: any
end

local keyPrototype = {}
local prototypeMetatable = { __index = keyPrototype }
export type keyType = typeof(setmetatable(
	{} :: {
		_link: datastoreLink.linkType,
		_userID: number?,

		_loaded: boolean,
		_data: {},

		_template: {},
	},
	prototypeMetatable
))

local function constructor(link: datastoreLink.linkType, template: {}, userID: number?): keyType
	local self = setmetatable({}, prototypeMetatable)

	self._link = link
	self._userID = userID

	self._data = {}
	self._loaded = false

	self._template = template

	return self
end

function keyPrototype.lockAndLoadAsync(self: keyType): boolean
	local runningThread = coroutine.running()

	jobQueue.newJob(self._link, function(data: keyData, keyInfo)
		local passedUserID = if self._userID then { self._userID } else keyInfo:GetUserIds()

		-- New player
		if data == nil then
			self._data = deepCopy(self._template)
			self._loaded = true

			task.spawn(runningThread)
			return {
				commit = true,
				data = {
					storedData = self._data,
					session = jobID,
					sessionTime = os.time(),
					pendingGlobalTransforms = {},
				},
				metadata = keyInfo:GetMetadata(),
				userIDs = passedUserID,
			}
		end

		if not self._loaded then
			self._data = reconcile(data, self._data)
			self._loaded = true
		end

		if data["pendingGlobalTransforms"] == nil then
			data.pendingGlobalTransforms = {}
		end

		for _, pendingTransform: globalTransformData in data.pendingGlobalTransforms do
			local transformer = globalTransform.get(pendingTransform.name)

			self._data = transformer:use(data, table.unpack(pendingTransform.args))
		end
		table.clear(data.pendingGlobalTransforms)

		task.spawn(runningThread)
		return {
			commit = true,
			data = self._data,
			metadata = keyInfo:GetMetadata(),
			userIDs = passedUserID,
		}
	end)

	return true
end

function keyPrototype._save(self: keyType)
	jobQueue.newJob(self._link, function(_, keyInfo)
		return {
			commit = true,
			data = self._data,
			metadata = keyInfo:GetMetadata(),
			userIDs = if self._userID then { self._userID } else keyInfo:GetUserIds(),
		}
	end)
end

function keyPrototype.unlockAsync(self: keyType): boolean
	return keySessionLocks.unlockKeyAsync(self._link)
end

function keyPrototype.useTransform() end

return {
	new = constructor,
}
