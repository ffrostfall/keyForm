export type key<T> = {
	read: (self: key<T>) -> T,
	isLocked: (self: key<T>) -> boolean,
}

export type store<T> = {
	lockAndLoad: (self: store<T>, name: string) -> (key<T>, boolean),
	unlock: (self: store<T>, key: key<T>) -> (),
	createTransform: <A>(self: store<T>, transform: (data: T, args: A) -> T) -> (key: key<T>, args: A) -> (),
}

export type keyForm = {
	store: <T>(name: string, template: T) -> store<T>,
}

return nil
