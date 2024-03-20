local datastoreLink = require(script.Parent.datastoreLink)

type updateResult = {
	commit: boolean,
	userIDs: { number }?,
	metadata: { [string]: any },
	data: { [any]: any },
}
type queueObject = {
	link: datastoreLink.linkType,
	updateFunction: (data: any, metadata: DataStoreKeyInfo) -> updateResult,
	retries: number,
	lastRetry: number,
	nextRetry: number,
}
local queue: { queueObject } = {}

local function emptyQueue()
	for index, job in queue do
		task.spawn(function()
			local success, err = pcall(function()
				job.link.store:UpdateAsync(job.link.keyName, function(data, info)
					local result = job.updateFunction(data, info)

					if not result.commit then
						return nil
					end

					return result.data, result.userIDs, result.metadata
				end)
			end)

			if success then
				table.remove(queue, index)
			else
				job.retries += 1
				job.lastRetry = os.clock()

				job.nextRetry = job.lastRetry + (job.retries * 5)
				warn(err) -- temp
			end
		end)
	end
end

local jobQueue = {}

function jobQueue.init()
	task.spawn(function()
		while true do
			emptyQueue()

			task.wait()
		end
	end)
end

function jobQueue.newJob(link: datastoreLink.linkType, updateFunction)
	table.insert(queue, {
		link = link,
		updateFunction = updateFunction,
		retries = 0,
		lastRetry = 0,
		nextRetry = 0,
	})
end

return jobQueue
