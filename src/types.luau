export type Store<T> = {
	createAsyncTransform: <A>(self: Store<T>, transform: (data: T, args: A) -> T) -> (key: Key<T>, args: A) -> (),
	createTransform: <A>(self: Store<T>, transform: (data: T, args: A) -> T) -> (key: Key<T>, args: A) -> (),

	lockAndLoad: (self: Store<T>, name: string) -> (Key<T>, boolean),
	unlock: (self: Store<T>, key: Key<T>) -> (),
}

export type Key<T> = {
	onLockLost: (self: Key<T>, callback: () -> ()) -> (),
	read: (self: Key<T>) -> T,
}

export type keyForm = {
	store: <T>(name: string, template: T) -> Store<T>,
}

return nil
