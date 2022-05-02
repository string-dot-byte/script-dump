local Table = Framework.GetModule('Table')
local Events = {}

function Events.BindToEvent(instance, eventName, callback, info)
	--[[
		{
			OverwriteEvent = boolean,
			Trigger = {args}
		}
	]]
	
	info = info or {}
	if Events[instance] then
		if Events[instance][eventName] and info.OverwriteEvent ~= true then
			table.insert(Events[instance][eventName], callback)
		else
			if Events[instance][eventName] then
				Events.RemoveEvent(nil, instance, eventName)
				if not Events[instance] then
					Events[instance] = {}
				end
			end
			Events[instance][eventName] = {callback}
			Events.ConnectEvent(instance, eventName)
		end
	else
		Events[instance] = {[eventName] = {callback}}
		Events.ConnectEvent(instance, eventName)
	end
	
	if info.Trigger then
		Events.TriggerEvent(instance, eventName, info.Trigger)
	end
end

function Events.ConnectEvent(instance, eventName)
	local c c = instance[eventName]:Connect(function(...)
		if #Events[instance][eventName] == 0 then Events.RemoveEvent(c, instance, eventName) return end
		for _, cb in ipairs(Events[instance][eventName]) do
			coroutine.wrap(cb)(...)
		end
	end)
end

function Events.RemoveEvent(c, instance, eventName)
	if not Events[instance] then return end
	if c then
		c:Disconnect()
	end
	
	Events[instance][eventName] = {}
	Events.TriggerEvent(instance, eventName)
	
	local r = 0
	for k in pairs(Events[instance]) do r += 1 end
	if r == 0 then
		Events[instance] = nil
	end
end

function Events.RemoveInstanceEvents(instance)
	if not Events[instance] then return end
	
	for k, v in pairs(Events[instance]) do
		Events[instance][k] = {}
		Events.TriggerEvent(instance, k)
	end
	Events[instance] = nil
end

function Events.TriggerEvent(instance, eventName, args)
	args = args or {}
	for _, cb in ipairs(Events[instance][eventName]) do
		coroutine.wrap(cb)(table.unpack(args))
	end
end

function Events.SetPriority(callback, priority)
	local FoundIndex, instance, eventName
	
	for inst, v in pairs(Events) do
		if FoundIndex then break end
		if type(v) ~= 'table' then continue end
		for k, tbl in pairs(v) do
			local res = table.find(tbl, callback)
			if res then
				FoundIndex, instance, eventName = res, inst, k
				break
			end
		end
	end
	
	if not FoundIndex then warn('CALLBACK NOT FOUND -', callback) return end
	
	
	if priority > #Events[instance][eventName] then
		priority = #Events[instance][eventName]
	end
	
	Table.shift(Events[instance][eventName], FoundIndex, priority)
end



return Events
