local Table = {}


function Table.table_eq(table1, table2)
	-- compare 2 tables
	local avoid_loops = {}
	local function recurse(t1, t2)
		if type(t1) ~= type(t2) then return false end
		if type(t1) ~= 'table' then return t1 == t2 end

		if avoid_loops[t1] then return avoid_loops[t1] == t2 end
		avoid_loops[t1] = t2

		local t2keys = {}
		local t2tablekeys = {}
		for k, _ in pairs(t2) do
			if type(k) == 'table' then table.insert(t2tablekeys, k) end
			t2keys[k] = true
		end

		for k1, v1 in pairs(t1) do
			local v2 = t2[k1]
			if type(k1) == 'table' then
				local ok = false
				for i, tk in ipairs(t2tablekeys) do
					if Table.table_eq(k1, tk) and recurse(v1, t2[tk]) then
						table.remove(t2tablekeys, i)
						t2keys[tk] = nil
						ok = true
						break
					end
				end
				if not ok then return false end
			else
				if v2 == nil then return false end
				t2keys[k1] = nil
				if not recurse(v1, v2) then return false end
			end
		end

		if next(t2keys) then return false end
		return true
	end
	return recurse(table1, table2)
end

-- return path "a/b/c"
function Table.DeepSearch(t, val, CurrentPath)
	local CurrentPath = CurrentPath or ''

	for k, v in pairs(t) do
		if v == val then
			return CurrentPath .. k
		end

		if type(v) == 'table' then
			CurrentPath ..= k .. '/'
			return Table.DeepSearch(v, val, CurrentPath)
		end
	end
end

function Table.RecursiveCopy(obj, seen)
	-- Handle non-tables and previously-seen tables.
	if type(obj) ~= 'table' then
		return obj
	end
	if seen and seen[obj] then
		return seen[obj]
	end

	-- New table; mark it as seen and copy recursively.
	local s = seen or {}
	local res = {}
	s[obj] = res
	for k, v in pairs(obj) do
		res[Table.RecursiveCopy(k, s)] = Table.RecursiveCopy(v, s)
	end
	return setmetatable(res, getmetatable(obj))
end

function Table.merge(...)
	-- performance costy if ran a lot
	local t = {}

	for _, v in ipairs({...}) do
		--table.move(v, 1, #v, #t + 1, t)
		for k, g in pairs(v) do
			if type(k) == 'number' then
				k = #t + 1
			end
			t[k] = g
		end
	end

	return t
end


function Table.shuffle(tbl)
	for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return tbl
end


function Table.shift(tbl, old, new)
	local value = tbl[old]
	if new < old then
		table.move(tbl, new, old-1, new+1)
	else
		table.move(tbl, old+1, new, old)
	end
	tbl[new] = value
end


do
	local function scan(path, tbl)
		local s = path:split('/')
		local i = 1

		local res, scanS

		function scanS(target)
			for k, v in pairs(target) do
				if res then break end
				if i == #s and k == s[i] then
					res = target
					break
				end

				if i == #s then
					res = target
				end

				if type(v) == 'table' and k == s[i] then
					i += 1
					scanS(v)
					break
				end
			end
		end

		scanS(tbl)

		return res
	end

	function Table.SetValueFromPath(path, tbl, value)
		local t = scan(path, tbl)
		local Index = path:match('[^/]+$')

		if not t then
			tbl[path:match('%w+$')] = value
			return
		end

		if not t[Index] then
			t[Index] = {}
		end

		t[Index] = value
	end

	function Table.IncrementValueFromPath(path, tbl, value)
		local t = scan(path, tbl)

		local Index = path:match('[^/]+$')
		local CurrentVal = t[Index]
		t[Index] = CurrentVal + value
	end

	function Table.GetValueFromPath(path, tbl)
		local t = scan(path, tbl)
		local Index = path:match('[^/]+$')

		local r = t
		if r then
			r = t[Index]
		end

		return r
	end

	function Table.PathParse(path)
		local root, path = path:match('^(/?)(.+)$')

		local dir = path:gsub("%w*%.?%w*$", ''):gsub('/+$', '')
		local file = path:match('(%w*%.?%w*)$')

		local name, ext = file:match('^(%w*)%.?(%w*)$')

		return {
			Root = #root > 0 and root or nil,
			Directory = #dir > 0 and dir or nil,

			File = #file > 0 and file or nil,

			Filename = #name > 0 and name or nil,
			Extension = #ext > 0 and ext or nil
		}
	end
end

function Table.reverse(t)
	local t, n, i = t, #t, 1

	while i < n do
		t[i], t[n] = t[n], t[i]
		i = i + 1
		n = n - 1
	end

	return t
end

function Table.DictionnaryToArray(t)
	local new = {}
	for k in pairs(t) do
		table.insert(new, k)
	end
	return new
end

function Table.ArrayToDictionnary(t)
	local new = {}
	for _, v in ipairs(t) do
		new[v] = true
	end
	return new
end

function Table.getTableType(t)
	if next(t) == nil then return 'Empty' end
	local isArray = true
	local isDictionary = true
	for k, _ in next, t do
		if typeof(k) == 'number' and k%1 == 0 and k > 0 then
			isDictionary = false
		else
			isArray = false
		end
	end

	if isArray then
		return 'Array'
	elseif isDictionary then
		return 'Dictionary'
	end

	return 'Mixed'
end

local TableToInstance
TableToInstance = function(Table,Parent) -- turns table into folder
	for Index,Value in pairs(Table) do
		local Type = type(Value)
		local Obj
		if Type == 'string' then
			Obj = Instance.new("StringValue")
		elseif Type == 'number' then
			local NumberValue = Instance.new("NumberValue")
			NumberValue.Name = Index
			NumberValue.Value = Value
			NumberValue.Parent = Parent
		elseif Type == 'boolean' then
			Obj = Instance.new("BoolValue")
		elseif Type == 'table' then
			Obj = Instance.new('Folder')
			Table.TableToInstance(Value, Obj)
		end

		Obj.Name = Index
		Obj.Value = Value
		Obj.Parent = Parent
	end
end;Table.TableToInstance = TableToInstance;

local InstanceTableReversal
InstanceTableReversal = function(Parent,Table) -- turns folder with values into table
	for _, Obj in pairs(Parent:GetChildren()) do
		if Obj.ClassName:find'Value' then
			Table[Obj.Name] = Obj.Value
		elseif Obj:IsA'Folder' then
			local NewTable = {}
			if not tonumber(Obj.Name) then
				Table[Obj.Name] = NewTable
			else
				table.insert(Table,NewTable)
			end
			Table.InstanceTableReversal(Obj,NewTable)
		end
	end
end;Table.InstanceTableReversal = InstanceTableReversal;

return Table
