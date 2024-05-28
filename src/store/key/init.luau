local key = {}
export type Identity<T> = typeof(setmetatable(
	{} :: {
		_data: T,
		_name: string,

		_lastAutosave: number,
		_modified: boolean,

		_lockLostCallback: () -> (),
	},
	{
		__index = key,
	}
))

local function constructor<T>(name: string, _: T): Identity<T>
	local self = setmetatable({}, { __index = key })

	self._name = name
	self._data = {} :: any

	self._lastAutosave = 0
	self._modified = false

	self._lockLostCallback = function() end

	return self
end

function key.onLockLost<any>(self: Identity<any>, callback: () -> ())
	self._lockLostCallback = callback
end

function key._invokeLockLostCallback(self: Identity<any>)
	self._lockLostCallback()
end

function key.read<T>(self: Identity<T>)
	return self._data
end

return {
	new = constructor,
}
