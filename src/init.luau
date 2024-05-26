local store = require("./store")

local keyForm = {}

function keyForm.store<T>(name: string, template: T)
	return store.new(name)
end

return keyForm
