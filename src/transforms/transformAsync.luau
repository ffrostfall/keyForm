local key = require(script.Parent.Parent.public.key)

return function(transformFunction)
	return function(subjectKey: key.keyType, ...)
		subjectKey:_updateAsync(transformFunction(table.clone(subjectKey:read()), ...))
		if subjectKey._pendingDeletion then
			setmetatable((subjectKey :: any) :: {}, nil)
		end
	end
end
