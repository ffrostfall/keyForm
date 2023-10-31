task.wait(1)
local TableKit = require(script.Parent.TableKit)

local template = {
	A = false,
	B = true,
	C = {
		D = "",
	},
}

local toReconcile = {
	A = true,
	B = false,
	C = {},
}

local DictionaryA = {
	A = "Z",
	B = "X",
	C = "Y",
}
local DictionaryB = {
	D = 4,
	E = 5,
	F = 6,
}

local ArrayA = { "A", "B", "CC" }
local ArrayB = { "D", "E", "FF" }

local Empty = {}

--

print("---------------------------------------")
print("Merges:")
local dictionaryMerged = TableKit.MergeDictionary(DictionaryA, DictionaryB)
local arrayMerged = TableKit.MergeArrays(ArrayA, ArrayB)
print(dictionaryMerged)
print(arrayMerged)
print("---------------------------------------")
print("Values & Keys:")
local values = TableKit.Values(DictionaryA)
local keys = TableKit.Keys(DictionaryA)
print(values)
print(keys)
print("---------------------------------------")
print("tostring:")
local stringified = TableKit.ToString(DictionaryA)
print(stringified)
print("---------------------------------------")
print("dictionaryIsArray, arrayIsArray:")
local dictionaryIsArray = TableKit.IsArray(DictionaryA)
local arrayIsArray = TableKit.IsArray(ArrayA)
print(dictionaryIsArray)
print(arrayIsArray)
print("---------------------------------------")
print("reconcile:")
local reconciled = TableKit.Reconcile(toReconcile, template)
print(reconciled)
print("---------------------------------------")
print("HasKey:")
local hasKey = TableKit.HasKey(DictionaryA, "A") -- true
local hasKeyB = TableKit.HasKey(DictionaryA, "B") -- true
local hasKeyC = TableKit.HasKey(DictionaryA, "H") -- false
print(hasKey, hasKeyB, hasKeyC)
print("---------------------------------------")
print("HasValue:")
local hasValue = TableKit.HasValue(DictionaryA, "Z") -- true
local hasValueB = TableKit.HasValue(DictionaryA, "X") -- true
local hasValueC = TableKit.HasValue(DictionaryA, "H") -- false
print(hasValue, hasValueB, hasValueC)
print("---------------------------------------")
print("IsEmpty:")
local isEmpty = TableKit.IsEmpty(Empty)
local notEmpty = TableKit.IsEmpty({ "sdfsdf" })
print(isEmpty, notEmpty)
print("---------------------------------------")
print("IsFlat:")
local notFlat = TableKit.IsFlat({ {} })
local flat = TableKit.IsFlat({ 1, 2 })
print(flat, notFlat) -- true, false
print("---------------------------------------")
print("Every:")
local array = { 1, 2, 3, 4, 5 }
local even = function(value)
	return value % 2 == 0
end
local odd = function(value)
	return value % 2 ~= 0
end
local returnsTrue = function()
	return true
end

print(TableKit.Every(array, even)) -- Prints false
print(TableKit.Every(array, odd)) -- Prints false
print(TableKit.Every(array, returnsTrue)) -- Prints true
print("---------------------------------------")
print("Some:")
local array2 = { 1, 2, 3, 4, 5 }

print(TableKit.Some(array2, even)) -- Prints true
print("---------------------------------------")
print("From:")
local str = "Abcdefg"

print(TableKit.From(str))
