local Signal = require(script.Parent.Parent.Signal)
local TableKit = require(script.Parent.Parent.TableKit)
local internalStore = require(script.Parent.internalStore)
local jobId = require(script.Parent.jobId)
local transform = require(script.Parent.transform)

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

		self._store:updateKey(self._keyName, function(data)
			if typeof(data) ~= "table" then
				-- Corruption / New
				self._locked = true
				task.spawn(thread, true)
				return {
					session = jobId(),
					keyVersion = 1,
					data = TableKit.Reconcile({}, self._template),
				}
			else
				if data.session ~= nil then
					if data.session ~= "" then
						-- it's already locked
						task.spawn(thread, false)
						return data
					else
						data.session = jobId()
					end
				else
					data.session = jobId()
				end

				if data.keyVersion ~= nil then
					data.keyVersion += 1
				else
					data.keyVersion = 1
				end

				if data.data == nil then
					self._data = {}
					data.data = {}
				end

				local reconciled: any = TableKit.Reconcile(data.data, self._template)
				data.data = reconciled
				self._data = reconciled
				print(reconciled)

				self._locked = true
				task.spawn(thread, true)
				return data
			end
		end)

		return coroutine.yield()
	end
end

function keyPrototype.read(self: keyType)
	return table.freeze(self._data)
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

function keyPrototype.useTransform(self: keyType, transformFunction: transform.transformType)
	self._data = transformFunction:_run(self._data)
	self._updated:Fire(self._data)
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
