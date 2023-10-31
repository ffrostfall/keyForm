local Signal = require(script.Parent.Parent.Signal)

local transformPrototype = {}
local transformMetatable = { __index = transformPrototype }
export type transformType = typeof(setmetatable(
	{} :: {
		_transformSignal: typeof(Signal.new()),
		_transformFunction: (data: any) -> any,
	},
	transformMetatable
))

function transformPrototype.onTransform(self: transformType, callback: () -> ())
	local connection = self._transformSignal:Connect(function()
		callback()
	end)

	return function()
		connection()
	end
end

function transformPrototype._run(self: transformType, data: any)
	return self._transformFunction(table.clone(data))
end

return function(transformFunction: (data: any) -> any): transformType
	local self = setmetatable({}, transformMetatable)

	self._transformFunction = transformFunction
	self._transformSignal = Signal.new()

	return self
end
