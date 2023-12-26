export type key<T> = {
	read: (self: key<T>) -> T,
	lockAsync: (self: key<T>) -> boolean,
	unlock: (self: key<T>) -> (),
	remove: (self: key<T>) -> (),
	addUserID: (self: key<T>, userID: number) -> (),
}

export type dataStore<T> = {
	createTransform: <V...>(self: dataStore<T>, transformFunction: (template: T, V...) -> T) -> (key<T>, V...) -> (),
	createAsyncTransform: <V...>(
		self: dataStore<T>,
		transformFunction: (template: T, V...) -> T
	) -> (key<T>, V...) -> (),
	loadKey: (self: dataStore<T>, keyName: string) -> key<T>,
}

export type keyForm = {
	createStore: <_, T>(name: string, template: T) -> dataStore<T>,
	showTrace: () -> (),
}

return nil
