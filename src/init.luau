local RunService = game:GetService("RunService")

local store = require("@src/store")
local threadQueue = require("@src/store/threadQueue")
local types = require("@src/types")

RunService.PostSimulation:Connect(threadQueue.step)
RunService.PostSimulation:Connect(store.step)
game:BindToClose(threadQueue.close)

local keyForm = {}

function keyForm.store<T>(name: string, template: T): store.Identity<T>
	return store.new(name, template)
end

export type key<T> = types.key<T>
export type store<T> = types.store<T>

return (table.freeze(keyForm) :: any) :: types.keyForm
