local RunService = game:GetService("RunService")

local budgetManager = require(script.Parent.Parent.budget.budgetManager)
local dsErrorReporter = require(script.Parent.Parent.reporting.dsErrorReporter)
local logger = require(script.Parent.Parent.reporting.logger)
local requestKinds = require(script.Parent.Parent.budget.requestKinds)

type successfulJobResult = {
	content: {}?,
}
type failedJobResult = {
	newRuntime: number,
	shouldCancel: boolean,
}
type runJobResult = {
	status: true,
	result: successfulJobResult,
} | {
	status: false,
	result: failedJobResult,
}
type job = {
	thread: thread,
	jobType: requestKinds.allRequestKinds,
	runAt: number,
	data: { [any]: any },
}

local jobSchedulerPrototype = {}
local jobSchedulerMetatable = { __index = jobSchedulerPrototype }
export type jobSchedulerType = typeof(setmetatable(
	{} :: {
		store: DataStore,
		_jobs: {
			[number]: job,
		},
	},
	jobSchedulerMetatable
))

function jobSchedulerPrototype._run(self: jobSchedulerType, jobType: string, data: { [any]: any }): runJobResult
	if jobType == requestKinds.load then
		local success, result: any = pcall(function()
			local keyData, keyInfo = self.store:GetAsync(data.key)

			return { keyData, keyInfo }
		end)

		if success then
			return {
				status = true,
				result = { content = result[1] },
			}
		else
			local report = dsErrorReporter(result, requestKinds.load)
			local failResult: failedJobResult = {
				newRuntime = report:getNewRuntime(),

				-- TODO
				shouldCancel = false,
			}

			return {
				status = false,
				result = failResult,
			}
		end
	elseif jobType == requestKinds.update then
		local success, result: any = pcall(function()
			self.store:UpdateAsync(data.key, function(keyData, keyInfo)
				return data.transform(keyData, keyInfo)
			end)
		end)

		if success then
			return {
				status = true,
				result = {},
			}
		else
			local report = dsErrorReporter(result, requestKinds.update)
			local failResult: failedJobResult = { newRuntime = report:getNewRuntime(), shouldCancel = false }

			return {
				status = false,
				result = failResult,
			}
		end
	end

	return {
		status = true,
		result = {},
	}
end

function jobSchedulerPrototype._doJob(
	self: jobSchedulerType,
	requestKind: requestKinds.allRequestKinds,
	runAt: number,
	data: { any }
)
	local newJob: job = {
		thread = coroutine.running(),
		jobType = requestKind,
		runAt = runAt,
		data = data,
	}
	table.insert(self._jobs, newJob)
end

function jobSchedulerPrototype.updateRequest(
	self: jobSchedulerType,
	key: string,
	transform: (
		data: any,
		keyInfo: DataStoreKeyInfo
	) -> (any, { number }, { [string]: any })
)
	self:_doJob(
		requestKinds.update,
		budgetManager.claimNextAvailable(requestKinds.update),
		{ key = key, transform = transform }
	)
end

function jobSchedulerPrototype.loadRequest(self: jobSchedulerType, key: string, whenFinished: (keyData: any) -> ())
	task.spawn(function()
		self:_doJob(requestKinds.load, budgetManager.claimNextAvailable(requestKinds.load), {
			key = key,
		})
		whenFinished(coroutine.yield())
	end)
end

function jobSchedulerPrototype.wipeRequest(self: jobSchedulerType, key: string)
	
end

return function(store: DataStore): jobSchedulerType
	local self = setmetatable({
		store = store,
		_jobs = {},
	}, jobSchedulerMetatable)

	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		debug.profilebegin("requestWorkers")

		local removeJobs = {}
		for index, job in ipairs(self._jobs) do
			if os.clock() >= job.runAt then
				logger.log():dialog(`Running job`):trace(script.Name)

				task.spawn(function()
					local runResult = self:_run(job.jobType, job.data)

					if runResult.status then
						-- the job might've resumed itself
						if coroutine.status(job.thread) == "suspended" then
							task.spawn(job.thread, runResult.result.content)
						end
					else
						local failedJobResult = runResult.result

						if not failedJobResult.shouldCancel then
							job.runAt += failedJobResult.newRuntime
						end
					end
				end)

				table.insert(removeJobs, index)
			end
		end

		for _, index in removeJobs do
			table.remove(self._jobs, index)
		end

		debug.profileend()
	end)

	game:BindToClose(function()
		heartbeatConnection:Disconnect()

		for _, job in ipairs(self._jobs) do
			if os.clock() >= job.runAt then
				logger.log():dialog(`Running job`):trace(script.Name)

				local runResult = self:_run(job.jobType, job.data)

				if runResult.status then
					-- the job might've resumed itself
					if coroutine.status(job.thread) == "suspended" then
						task.spawn(job.thread, runResult.result.content)
					end
				else
					warn("A job failed and the game is closing so it cannot be ran again")
				end
			end
		end
	end)

	return self
end
