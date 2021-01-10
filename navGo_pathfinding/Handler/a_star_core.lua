--[[
	This function holds to a-star code that both the NavGO_Handler and NavGo_Global depend upon.
	This is generic A-Star with some modifications to work within the established NavGO system.
	Please use an interface such as NavGO_Handler or NavGO_Global to access this script, calling
	it directly could lead to unexpected behavior.
	Enjoy,
	- The NavGO Team
]]
A_STAR = {}

local function distance(vec1, vec2)
	return math.ceil( math.sqrt( math.pow(vec1.x - vec2.x, 2) + math.pow(vec1.y - vec2.y, 2) ) )
end

function A_STAR.findNodeWithID(tree, find)
	local findPos = go.get_position(find)
	for key, value in pairs(tree) do
		local testPos = value:getPosition()
		if value:getPosition() == findPos then
			return value
		end
	end
	--If not found
	error("Point " .. tostring( find ) .. " must be on the path.")
end

function A_STAR.createTempNode(tree, collisions, fromGO)
	local from = go.get_position(fromGO)
	local newNode = navNode.New(fromGO, from)
	for i=1, #tree do
		local to = tree[i]:getPosition()
		local distance = distance(from, to)
		local result
		if distance ~= 0 then
			result = physics.raycast(from, to, collisions, false)
		end
		if result == nil then
			newNode:addToLinkedNodesList(tree[i], distance)
			foundConnection = true
		end
	end
	if not foundConnection then
		error("No paths exists, you need to add nodes to support this.")
	end
	return newNode
end

function A_STAR.calculateCost(current, from, to)
	local fromStart = distance(from, current)
	local toEnd = distance(current, to)
	local result = fromStart + toEnd
	return result
end

function A_STAR.findLowestFCostInTable(f_costs, nodes, from, to)
	local lowestPos = 0
	local lowestCost = 1000000
	for node, value in pairs(nodes) do
		if f_costs[ node ] == nil then
			f_costs[ node ] =  A_STAR.calculateCost(node:getPosition(), from, to)
		end
		local cost = f_costs[ node ]
		if cost < lowestCost then
			lowestCost = cost
			lowestPos = node
		end
	end
	local nodesFound = false
	if lowestCost ~= 1000000 then
		nodesFound = true
	end
	return lowestPos, lowestCost, nodesFound
end

function A_STAR.retracePath(path, startNode, endNode)
	local finalList = {}
	local currentNode = endNode
	while currentNode ~= startNode do
		table.insert(finalList, 1, currentNode)
		currentNode = path[currentNode]
	end
	return finalList
end

function A_STAR.convertPathToCordinates(path)
	local finalPath = {}
	for i=1, #path do
		local position = path[i]:getPosition()
		table.insert(finalPath, position)
	end
	return finalPath
end

--Returns the list of positions to follow for the path, a bool for if the path is found or not 
function A_STAR.A_Star(tree, collisions, fromGO, toGO)
	local endNode = A_STAR.findNodeWithID(tree, toGO)
	local startNode = A_STAR.createTempNode(tree, collisions, fromGO)
	--table.insert(self.nodes, startNode)
	local from = startNode:getPosition()
	local to = endNode:getPosition()

	local f_costs = {}
	local openNodes = {} --To be evaluated
	openNodes[startNode] = startNode
	local closedNodes = {} --Already checked
	local parent = {}
	local nodesFound

	local found = false
	while not found do
		local currentNode, currentCost, nodesFound = A_STAR.findLowestFCostInTable(f_costs, openNodes, from, to) --findLowestFCostInTable(self, f_costs, openNodes, from, to)
		if not nodesFound then
			return {}, false
		end

		openNodes[currentNode] = nil

		closedNodes[currentNode] = currentNode
		if currentNode == endNode then
			found = true
			local path = A_STAR.retracePath(parent, startNode, endNode)
			local positionList = A_STAR.convertPathToCordinates(path)
			return positionList, true
		end

		local neighborsList = currentNode:getLinkedNodeList()
		for neighbor, value in pairs(neighborsList) do
			if closedNodes[neighbor] then
				--Intentially left blank
			else
				--If new path is shorter or is not in open
				if openNodes[neighbor] == nil or f_costs[neighbor] < currentCost then
					f_costs[neighbor] = A_STAR.calculateCost(neighbor:getPosition(), from, to)
					parent[neighbor] = currentNode
					if openNodes[neighbor] == nil then
						openNodes[neighbor] = neighbor
					end
				end
			end
		end
	end
end

