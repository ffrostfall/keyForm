local Signal = require(script.Parent.Parent.Parent.Signal)
local TableKit = require(script.Parent.Parent.Parent.TableKit)
local internalStore = require(script.Parent.Parent.internal.internalStore)
local jobId = require(script.Parent.Parent.internal.jobId)

local keyPrototype = {}
local keyMetatable = { __index = keyPrototype }
export type keyType = typeof(setmetatable(
	{} :: {
		_store: internalStore.internalStoreType,
		_keyName: string,
		_creationTime: number,
		_data: {},
		_locked: boolean,
		_lockedSignal: Signal.Signal<()>,
		_unlockedSignal: Signal.Signal<()>,
		_updated: Signal.Signal<any>,
		_template: {},
	},
	keyMetatable
))

function keyPrototype.lockAsync(self: keyType)
	if os.clock() - self._creationTime >= 0.5 then
		return false
	else
		local thread = coroutine.running()

		self._store:updateKey(self._keyName, function(keyData)
			if typeof(keyData) ~= "table" then
				-- Corruption / New
				self._locked = true
				self._data = table.clone(self._template)
				task.spawn(thread, true)
				return {
					session = jobId(),
					keyVersion = 1,
					data = table.clone(self._template),
				}
			else
				if keyData.session ~= nil then
					if keyData.session ~= "" then
						-- it's already locked
						task.spawn(thread, false)
						return keyData
					else
						keyData.session = jobId()
					end
				else
					keyData.session = jobId()
				end

				if keyData.keyVersion ~= nil then
					keyData.keyVersion += 1
				else
					keyData.keyVersion = 1
				end

				if keyData.data == nil then
					keyData.data = table.clone(self._template)
				end

				TableKit.Reconcile(keyData.data, self._template)

				self._locked = true
				self._data = keyData.data

				task.spawn(thread, true)
				return keyData
			end
		end)

		return coroutine.yield()
	end
end

function keyPrototype.read(self: keyType)
	return table.clone(self._data)
end

function keyPrototype.unlock(self: keyType)
	if self._locked then
		self._store:updateKey(self._keyName, function(data)
			if typeof(data) ~= "table" then
				return {
					session = "",
					keyVersion = 1,
					data = self._data,
				}
			else
				if data.session ~= nil then
					if data.session == jobId() then
						data.session = ""
						self._locked = false
						self._unlockedSignal:Fire()
					end
				else
					data.session = ""
					self._locked = false
					self._unlockedSignal:Fire()
				end

				data.data = self._data

				return data
			end
		end)
	end
end

function keyPrototype.remove(self: keyType)
	self._lockedSignal:DisconnectAll()
	self._unlockedSignal:DisconnectAll()
	self._updated:DisconnectAll()
	setmetatable(self :: any, nil)
end

function keyPrototype._update(self: keyType, data)
	self._data = data
	self._updated:Fire(self._data)
end

function keyPrototype._updateAsync(self: keyType, data)
	self._data = data
	self._updated:Fire(self._data)
	local thread = coroutine.running()

	-- force a save, instantly
	self._store:updateKey(self._keyName, function(keyData)
		keyData.data = self._data
		keyData.keyVersion += 1
		task.spawn(thread)

		return data
	end)

	return coroutine.yield(thread)
end

return function(keyName: string, store: internalStore.internalStoreType, template: {}): keyType
	local self = setmetatable({}, keyMetatable)

	self._data = {}

	self._keyName = keyName
	self._store = store
	self._template = template

	self._creationTime = os.clock()

	self._locked = false
	self._lockedSignal = Signal.new()
	self._unlockedSignal = Signal.new()
	self._updated = Signal.new()

	return self
end
