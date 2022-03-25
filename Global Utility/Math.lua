local Math = {
	phi = 1.6180339887,
	e = 2.718281828459,
	G = 6.673*10^-11
}

function Math.mapToRange(t, a, b, c, d)
	return c + ((d-c)/(b-a)) * (t-a)
end

function Math.sum(...)
	local r = 0
	for _, g in ipairs({...}) do
		r += g
	end
	return r
end

function Math.prod(...)
	local r = 0
	for _, g in ipairs({...}) do
		r *= g
	end
	return r
end

function Math.rel_dist(p1, p2, floor)
	local r = (p1.Position-p2.Position).Magnitude
	return (floor and math.floor(r)) or r
end

function Math.rel_dir(p1, p2)
	-- opposite: -(Unit)
	return (p1.Position-p2.Position).Unit
end

function Math.bound(min,max,value)
	return (-max+value)/(-max + min)
end

function Math.derivative(x,dx, func)
	return (func(x + dx) - func(x))/dx
end

function Math.sigmoid(z)
	return 1/(1 + 2.718281828459^-z)
end

function Math.ellipse(minor, major, t)
	return {math.cos(2*t*math.pi-math.pi) * major, math.sin(2*t*math.pi - math.pi) * minor}
end

function Math.reflect(normal, dir)
	return dir-2*(dir:Dot(normal))*normal
end

function Math.naturalLog(exp)
	return math.log(exp, 2.718281828459)
end

function Math.quadratic(a, b, c, t)
	return a*(t^2)+(b*t)+c
end

function Math.Average(total, new)
	return (total+new)/2
end

function Math.MoveBehind(p1, p2, d)
	p1.CFrame = p2.CFrame * CFrame.new(0, 0, d) 
end

function Math.MoveFront(p1, p2, d)
	p1.CFrame = p2.CFrame * CFrame.new(0, 0, -d) * CFrame.Angles(0, math.rad(180), 0)
end

function Math.ScaleToOffset(x, y, parentFrame)
	local viewportSize = workspace.Cameracam.ViewportSize
	if not parentFrame then
		x *= viewportSize.X
		y *= viewportSize.Y
	else
		x *= parentFrame.AbsoluteSize.X
		y *= parentFrame.AbsoluteSize.Y
	end
	return x, y
end

function Math.OffsetToScale(x, y, parentFrame)
	local viewportSize = workspace.Cameracam.ViewportSize
	if not parentFrame then
		x /= viewportSize.X
		y /= viewportSize.Y
	else
		x /= parentFrame.AbsoluteSize.X
		y /= parentFrame.AbsoluteSize.Y
	end
	return math.round(x), math.round(y)
end

function Math.lookTowards(Character, info)
	local point, offset, applyY = info.point, info.offset, info.applyY
	
	local Root = Character.HumanoidRootPart
	local point = typeof(point) == 'Instance' and point.CFrame or point

	Root.CFrame = (
		CFrame.new(
			Root.Position, Vector3.new(point.p.X, applyY and Root.Position.Y or 0, point.p.X)
		)
	) * (offset or CFrame.new())
end

function Math.TweenModel(model, CF, info)
	local TweenService = game:GetService('TweenService')
	
	if typeof(CF) == 'Vector3' then
		CF = CFrame.new(CF)
	end

	local CFrameValue = Instance.new('CFrameValue')
	CFrameValue.Value = model:GetPrimaryPartCFrame()

	CFrameValue:GetPropertyChangedSignal'Value':Connect(function()
		model:SetPrimaryPartCFrame(CFrameValue.Value)
	end)

	local tween = TweenService:Create(CFrameValue, info, {Value = CF})
	tween:Play()

	tween.Completed:Connect(function()
		CFrameValue:Destroy()
	end)

	return tween
end

function Math.HasLineOfSight(obj1, obj2, dist, filter)
	local rayOrigin = obj1.Position
	local rayDirection = Math.rel_dir(obj2.Position, obj1.Position) * dist

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {obj2}
	raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
	raycastParams.IgnoreWater = true
	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

	print(raycastResult and raycastResult.Instance or nil)
	if raycastResult and raycastResult.Instance == obj2 then
		return true
	end
	return false
end


function Math.IsInRegion(pt, cf, sz)
	-- pt: Region, cf: TargetCFrame, sz: RegionSize
	-- CFrame.fromMatrix constructs a CFrame from column vectors
	local encodedOBB = CFrame.fromMatrix(
		cf.p,
		cf.XVector/sz.X,
		cf.YVector/sz.Y,
		cf.ZVector/sz.Z
	):inverse() * pt

	return math.abs(encodedOBB.X) <= .5
		and math.abs(encodedOBB.Y) <= .5
		and math.abs(encodedOBB.Z) <= .5
end

return Math
