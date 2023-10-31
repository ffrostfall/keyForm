local dataStore = require(script.dataStore)
local logger = require(script.reporting.logger)
local publicTypes = require(script.types.publicTypes)

local keyForm = {}

function keyForm._showTrace()
	logger.showTrace()
end

function keyForm.createStore(name: string, template: {})
	logger.log():dialog(`createStore function called for store: {name}`):trace(script.Name)
	return dataStore(name, template)
end

export type store<T> = publicTypes.dataStore<T>

return (table.freeze(keyForm) :: unknown) :: publicTypes.keyForm
