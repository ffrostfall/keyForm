type transform = {}

type key<T> = {
	read: (self: key<T>) -> T,
	lockAsync: (self: key<T>) -> boolean,
	unlock: (self: key<T>) -> (),
	useTransform: (self: key<T>, transform: transform) -> (),
	remove: (self: key<T>) -> (),
}

export type dataStore<T> = {
	createTransform: (self: dataStore<T>, (data: T) -> T) -> transform,
	loadKey: (self: dataStore<T>, keyName: string) -> key<T>,
}

export type keyForm = {
	createStore: <_, T>(name: string, template: T) -> dataStore<T>,
	showTrace: () -> (),
}

return nil
