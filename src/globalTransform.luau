local globalTransformDict: { [string]: globalTransformType } = {}

local globalTransformPrototype = {}
local prototypeMetatable = { __index = globalTransformPrototype }
export type globalTransformType = typeof(setmetatable(
	{} :: {
		_transformer: (data: {}, ...any) -> {},
		_name: string,
	},
	prototypeMetatable
))

local function constructor(name: string, transformer: (data: {}) -> {}): globalTransformType
	local self = setmetatable({}, prototypeMetatable)

	self._transformer = transformer
	self._name = name

	globalTransformDict[name] = self
	return self
end

function globalTransformPrototype.use(self: globalTransformType, data: {}, ...)
	return self._transformer(data, ...)
end

return {
	new = constructor,

	get = function(name: string): globalTransformType
		return globalTransformDict[name]
	end,
}
