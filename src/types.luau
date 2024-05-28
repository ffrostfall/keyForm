export type store<T> = {
	createAsyncTransform: <A>(self: store<T>, transform: (data: T, args: A) -> T) -> (key: key<T>, args: A) -> (),
	createTransform: <A>(self: store<T>, transform: (data: T, args: A) -> T) -> (key: key<T>, args: A) -> (),

	lockAndLoad: (self: store<T>, name: string) -> (key<T>, boolean),
	unlock: (self: store<T>, key: key<T>) -> (),
}

export type key<T> = {
	onLockLost: (self: key<T>, callback: () -> ()) -> (),
	read: (self: key<T>) -> T,
}

export type keyForm = {
	store: <T>(name: string, template: T) -> store<T>,
}

return nil
