type Operation = {
	-- The function should return true if it succeeded, false if it failed
	runner: () -> boolean,
	callback: (succeeded: boolean, errorMessage: string?) -> (),

	lastAttemptAt: number,
	attempts: number,
	threshold: number,
	active: boolean,
}

local queues: { Identity } = {}

local threadQueue = {}
export type Identity = typeof(setmetatable(
	{} :: {
		_queue: { Operation },
	},
	{
		__index = threadQueue,
	}
))

local function constructor(): Identity
	local self = setmetatable({}, { __index = threadQueue })

	self._queue = {}

	return self
end

function threadQueue.add(
	self: Identity,
	runner: () -> boolean,
	callback: (success: boolean) -> (),
	failureThreshold: number
)
	table.insert(self._queue, {
		callback = callback,
		runner = runner,

		threshold = failureThreshold,
		lastAttemptAt = os.time(),
		active = false,
		attempts = 0,
	})
end

function threadQueue.pop(self: Identity)
	local front = table.remove(self._queue, 1)
	if not front then
		return
	end

	if front.active then
		table.insert(self._queue, front)
		return
	end

	front.active = true
	local success, err = pcall(front.runner)
	if success then
		front.callback(true)
		return
	end

	if front.attempts + 1 >= front.threshold then
		front.callback(false, err :: any)
		return
	else
		front.attempts += 1
		table.insert(self._queue, front)
	end
end

function threadQueue._step(self: Identity)
	-- Iterate in reverse order to allow for removal of elements
	for i = #self._queue, 1, -1 do
		local operation = self._queue[i]

		if operation.active then
			continue
		end

		local nextRetry = operation.lastAttemptAt + (operation.attempts * 1)
		if os.time() <= nextRetry then
			continue
		end

		operation.active = true
		operation.attempts += 1
		operation.lastAttemptAt = os.time()

		local success, err: any = pcall(operation.runner)
		local shouldTryAgain = operation.attempts > operation.threshold

		if success then
			operation.callback(true)
		elseif not shouldTryAgain then
			operation.callback(false, err)
			table.remove(self._queue, i)
		end
	end
end

return {
	step = function()
		for _, queue in queues do
			queue:_step()
		end
	end,

	new = constructor,
}
