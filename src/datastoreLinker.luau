--[[
	just an object to describe a "link" to a datastore
]]
local DataStoreService = game:GetService("DataStoreService")

local options = Instance.new("DataStoreOptions")
options:SetExperimentalFeatures({
	v2 = true,
})

local function link(name: string)
	return {
		datastore = DataStoreService:GetDataStore(name, nil, options),
	}
end

export type Identity = typeof(link(""))

return link
