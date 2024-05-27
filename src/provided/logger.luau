local currentRuntime = require("./currentRuntime")

local runtime = currentRuntime()

local logger = {}
export type Identity = typeof(setmetatable(
	{} :: {
		_name: string,
	},
	{
		__index = logger,
	}
))

local function constructor(name: string?): Identity
	local self = setmetatable({}, { __index = logger })

	self._name = name or debug.info(2, "s")

	return self
end

function logger.trace(self: Identity, ...)
	print(`[{self._name}]`, ...)
end

function logger.log(self: Identity, ...)
	print(`[{self._name}]`, ...)
end

function logger.out(self: Identity, ...)
	print(`[{self._name}]`, ...)
end

function logger.warn(self: Identity, ...)
	warn(`[{self._name}]`, ...)
end

function logger.error(self: Identity, ...)
	task.spawn(error, `[{self._name}]`, ...)
end

function logger.fatal(self: Identity, ...)
	if runtime == "lune" then
		print(`[{self._name}]`, ...)
		require("@lune/process").exit(-1)
	else
		error(`[{self._name}]`, ...)
	end
end

return {
	new = constructor,
}
