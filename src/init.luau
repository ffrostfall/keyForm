local dataStore = require(script.public.dataStore)
local logger = require(script.reporting.logger)
local publicTypes = require(script.public.publicTypes)

local keyForm = {}

function keyForm.showTrace()
	logger.showTrace()
end

function keyForm.createStore(name: string, template: {})
	logger.log():dialog(`createStore function called for store: {name}`):trace(script.Name)
	return dataStore(name, template)
end

export type key<T> = publicTypes.key<T>
export type store<T> = publicTypes.dataStore<T>

--[=[
	@class keyForm
	
	The root namespace for the library.
]=]

--[=[
	@function createStore
	@param name string
	@param template { [key: string]: any }
	@within keyForm
	
	Creates a new `store` instance. This is the main entry point for the library. The "name" parameter is used to identify the store in the Roblox data store. The "template" parameter is used to define the default values for the store, which will be reconciled when the player joins.
	
	```lua
	local keyForm = require(path.to.keyForm)
	
	local store = keyForm.createStore("storeName", {
		foo = "bar",
	})
	```
]=]

--[=[
	@function showTrace
	@within keyForm
		
	Enables verbose logging to the output window. This is useful for debugging.
	
	```lua
	local keyForm = require(path.to.keyForm)
	
	keyForm.showTrace()
	```
]=]

--[=[
	@class store
	
	Represents a data store. This is the main entry point for the library. You can create a new store using the `keyForm.createStore` function.
	
	```lua
	local keyForm = require(path.to.keyForm)
	
	local store = keyForm.createStore("storeName", {
		foo = "bar",
	}) -- Creates a new store with the name "storeName" and the default value of "foo" being "bar"
	```
]=]

--[=[
	@method loadKey
	@param keyName string
	@within store
	
	Loads a key from the store. This is used to interact with the store's data. The "keyName" parameter is used to identify the key in the store.
	
	```lua
	local keyForm = require(path.to.keyForm)
	
	local store = keyForm.createStore("storeName", {
		foo = "bar",
	})
	
	local key = store:loadKey("keyName") -- Loads the key "keyName" from the store "storeName"
	```
	
	@return key key
]=]

--[=[
	@method createTransform
	@param callback (data: T, ...any) -> T
	@within store
	
	Creates a new transform function. This is used to update the store's data. The "transformFunction" parameter is a function that takes the current data and any number of additional parameters. Transforms should always return the new data. This function is synchronous.
	
	```lua
	local keyForm = require(path.to.keyForm)
	
	local store = keyForm.createStore("storeName", {
		foo = "bar",
	})
	
	local transform = store:createTransform(function(data, newValue)
		data.foo = newValue
		return data
	end)
	```
	
	@return transformFunction (key, ...any) -> ()
]=]

--[=[
	@method createAsyncTransform
	@param callback (data: T, ...any) -> T
	@within store
	
	An async version of `createTransform`.
	
	@return transformFunction (key, ...any) -> ()
]=]

--[=[
	@class key
	
	Represents a key in a data store. You can create a new key using the `store:loadKey` function.
	
	```lua
	local keyForm = require(path.to.keyForm)
	
	local store = keyForm.createStore("storeName", {
		foo = "bar",
	})
	
	local myKey = store:loadKey("keyName") -- Creates a new key within the `storeName` data store, with the key's name being "keyName"
	```
]=]

--[=[
	@method read
	@within key
	
	Returns the current data for the key. Not editable, doesn't update data.
	
	```lua
	local keyForm = require(path.to.keyForm)
	
	local store = keyForm.createStore("storeName", {
		foo = "bar",
	})
	
	local myKey = store:loadKey("keyName")
	
	print(myKey:read()) -- Prints the current data for the key
	```
	
	@return data
]=]

--[=[
	@method lockAsync
	@within key
	
	Locks the key. This prevents other servers from interacting with the key. This function is asynchronous.
	
	@return status boolean
]=]

--[=[
	@method unlockAsync
	@within key
	
	Unlocks the key. This allows other servers to interact with the key again.
]=]

return (table.freeze(keyForm) :: unknown) :: publicTypes.keyForm
