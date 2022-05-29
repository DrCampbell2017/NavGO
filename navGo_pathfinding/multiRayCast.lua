--[[
This code is to be used in the NavGo to simplify
drawing calls and checking ray casts between points
--]]

navgo_multiRayCast = {}

function navgo_multiRayCast.generatePointsToCheck(from, to, radius)
	local returnList = {}
	local angleBetweenPoints = math.atan2(from.y - to.y, from.x - to.x)
	-- 90 degrees in radians is 
	local nintyDegrees = math.pi / 2

	-- determine distance
	local newAngle = angleBetweenPoints + nintyDegrees
	local dx = radius * math.cos( newAngle )
	local dy = radius * math.sin( newAngle )

	-- point 1
	local newFrom = vmath.vector3(from.x + dx, from.y + dy, from.z)
	local newTo = vmath.vector3(to.x + dx, to.y + dy, to.z)
	local points = { from = newFrom, to = newTo }
	table.insert(returnList, points)

	-- point 2
	local newFrom = vmath.vector3(from.x - dx, from.y - dy, from.z)
	local newTo = vmath.vector3(to.x - dx, to.y - dy, to.z)
	local points = { from = newFrom, to = newTo }
	table.insert(returnList, points)

	-- return
	return returnList
end

function navgo_multiRayCast.validateSeveralPoints(pointsList, collisions)
	for i=1, #pointsList do
		local from = pointsList[i].from
		local to = pointsList[i].to
		local result = physics.raycast(from, to, collisions, false)
		if result ~= nil then
			-- second one is false, fail it as none are valid!
			return false
		end
	end
	return nil -- everything worked correctly!
end

function navgo_multiRayCast.determineIfValidConnection(from, to, collisions, numberOfRays, radius)
	-- self.rayRadius = 32
	if numberOfRays <= 1 then
		return physics.raycast(from, to, collisions, false)
	elseif numberOfRays == 2 then
		-- will ray cast from two corners
		local points = navgo_multiRayCast.generatePointsToCheck(from, to, radius)
		return navgo_multiRayCast.validateSeveralPoints(points, collisions)
	else
		-- corners plus the center
		local points = navgo_multiRayCast.generatePointsToCheck(from, to, radius)
		local point = { from = from, to = to }
		table.insert(points, point)
		return navgo_multiRayCast.validateSeveralPoints(points, collisions)
	end
end

function navgo_multiRayCast.update_drawLineToPoints(points)
	for i=1, #points do
		local from = points[i].from
		local to = points[i].to
		msg.post("@render:", "draw_line", { start_point = from, end_point = to, color = vmath.vector4(1,0,0,1) })
	end
end



	