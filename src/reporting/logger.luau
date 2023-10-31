local showTrace = false

local outputPrototype = {}
local outputMetatable = { __index = outputPrototype }
type outputType = typeof(setmetatable({} :: {
	_text: string,
}, outputMetatable))

local function output(): outputType
	return setmetatable({
		_text = "",
	}, outputMetatable)
end

function outputPrototype.kind(self: outputType, text: string): outputType
	self._text ..= `[newDatastoreLibrary] {text}\n`
	return self
end

function outputPrototype.code(self: outputType, code: string): outputType
	self._text ..= `\tCode: {code}\n`
	return self
end

function outputPrototype.text(self: outputType, text: string): outputType
	self._text ..= `\tText: {text}`
	return self
end

function outputPrototype.dialog(self: outputType, dialog: string): outputType
	self._text ..= `{dialog}\n`
	return self
end

function outputPrototype.newLine(self: outputType): outputType
	self._text ..= "\n"
	return self
end

function outputPrototype.raiseWarn(self: outputType): ()
	warn(self._text)
end

function outputPrototype.log(self: outputType): ()
	print(self._text)
end

function outputPrototype.trace(self: outputType, scope: string): ()
	if showTrace then
		print(`[{scope}:{debug.info(2, "l")}]: {self._text}`)
	end
end

function outputPrototype.raiseError(self: outputType): ()
	task.spawn(error, self._text)
end

local logger = {}

function logger.showTrace()
	showTrace = true
end

function logger.log(): outputType
	return output()
end

return logger
