export type linkType = {
	store: DataStore,
	memStore: MemoryStoreHashMap,
	keyName: string,
}

return function(store: DataStore, memStore: MemoryStoreHashMap, keyName: string): linkType
	return {
		store = store,
		memStore = memStore,
		keyName = keyName,
	}
end
