local key = require(script.Parent.Parent.public.key)

return function(transformFunction)
	return function(subjectKey: key.keyType, ...)
		subjectKey:_updateAsync(transformFunction(table.clone(subjectKey:read()), ...))
	end
end
