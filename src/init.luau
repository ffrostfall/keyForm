local RunService = game:GetService("RunService")

local requester = require("@src/store/requester")
local store = require("@src/store")
local types = require("@src/types")

RunService.PostSimulation:Connect(requester.step)

local keyForm = {}

function keyForm.store<T>(name: string, template: T): store.Identity<T>
	return store.new(name, template)
end

return (table.freeze(keyForm) :: any) :: types.keyForm
