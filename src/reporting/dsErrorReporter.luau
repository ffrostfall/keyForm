local budgetManager = require(script.Parent.Parent.budget.budgetManager)
local requestKinds = require(script.Parent.Parent.budget.requestKinds)
local codeNames = require(script.Parent.errorCodes.codeNames)
local codes = require(script.Parent.errorCodes.codes)
local logger = require(script.Parent.logger)

local errorReporterPrototype = {}
local errorReporterMetatable = { __index = errorReporterPrototype }
type errorReporterType = typeof(setmetatable(
	{} :: {
		_code: string,
		_errorName: string,
		_errorString: string,
		_errorText: string,
		_newRuntime: number,
	},
	errorReporterMetatable
))
--[[
	- store error
	- schedule new runtime
	- log error
	- figure out error kind
]]

function errorReporterPrototype.getNewRuntime(self: errorReporterType)
	return self._newRuntime
end

return function(errorString, requestKind: requestKinds.allRequestKinds): errorReporterType
	local self = setmetatable({}, errorReporterMetatable)

	-- get error code
	local matchedCode = nil
	local lastCharacter = nil
	for _, errorCode in codes do
		local _, match = string.find(errorString, errorCode)
		if match then
			matchedCode, lastCharacter = errorCode, match
			break
		end
	end

	self._code = matchedCode
	self._errorName = codeNames[matchedCode]
	self._errorString = errorString
	self._errorText = string.sub(self._errorString, 1, lastCharacter)
	self._newRuntime = 0

	logger.log():kind("Datastore issue"):code(self._errorName):text(self._errorText):newLine():raiseError()

	if string.sub(self._code, 1, 1) == "3" then
		self._newRuntime = budgetManager.claimNextAvailable(requestKind)
	else
		self._newRuntime = os.clock() + 1
	end

	return self
end
