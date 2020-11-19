--[[
This lua script can be used in place of the messaging system within the handler 
for instant results on the navGO tree.
Require this script and use the NAVGO keyword to utlize this tool
]]
require("navGo_pathfinding.Handler.a_star_core")

NAVGO = {}
NAVGO.NODE_TREE = {}
NAVGO.COLLISIONS = {}
NAVGO.READY_TO_USE = false

function NAVGO._INIT(tree, collisions)
	NAVGO.NODE_TREE = tree
	NAVGO.COLLISIONS = collisions
	NAVGO.READY_TO_USE = true
end

function NAVGO.IS_READY()
	return NAVGO.READY_TO_USE
end

function NAVGO.RETURN_ALL_NODES()
	if NAVGO.READY_TO_USE then
		local nodes = {}
		for i=1, #NAVGO.NODE_TREE do
			local url = NAVGO.NODE_TREE[i]:getObjID()
			table.insert(nodes, url)
		end
		return nodes
	else
		print("WARNING: Code is not yet ready to use.")
	end
end

function NAVGO.GET_RANDOM_NODE()
	if NAVGO.READY_TO_USE then
		if #NAVGO.NODE_TREE > 0 then
			local randomNode = NAVGO.NODE_TREE[math.random(1, #NAVGO.NODE_TREE)]
			local randomURL = randomNode:getObjID()
			return randomURL
		else
			print("WARNING: " .. tostring( sender ) .. " attempted to call a function in the NavGO Global before nodes are initialized.")
		end
	else
		print("WARNING: NavGO is not ready to be used.")
	end
end

function NAVGO.GENERATE_PATH(targetURL, myURL)
	if NAVGO.READY_TO_USE then
		local exists = A_STAR.findNodeWithID(NAVGO.NODE_TREE, targetURL)
		assert(exists, "ERROR: Target node must exist on the path.")
		local fromGO = myURL
		local toGO = targetURL
		return A_STAR.A_Star(NAVGO.NODE_TREE, NAVGO.COLLISIONS, fromGO, toGO)
	else
		print("WARNING: NavGO is not yet ready to be used.")
	end
end

function NAVGO.GENERATE_PATH_TO_RANDOM_NODE(myUrl)
	if NAVGO.READY_TO_USE then
		local fromGO = myUrl
		local senderPosition = go.get_position(myUrl)
		local to = NAVGO.NODE_TREE[math.random(1,#NAVGO.NODE_TREE)]:getObjID()
		return A_STAR.A_Star(NAVGO.NODE_TREE, NAVGO.COLLISIONS, fromGO, to)
	else
		print("WARNING: NavGO is not yet ready to use")
	end
end

local function distanceBetweem(v1, v2)
	return math.sqrt( (v1.x - v2.x) * (v1.x - v2.x) + (v1.y - v2.y) * (v1.y - v2.y) )
end


function NAVGO.GET_NODE_NEAREST_TO_POSITION(position)
	if NAVGO.READY_TO_USE then
		local smallestDistance = 0
		local smallestNode = nil
		for key, value in pairs(NAVGO.NODE_TREE) do
			local myPosition = value:getPosition()
			local dist = distanceBetweem(position, myPosition)
			if smallestNode == nil or dist < smallestDistance then
				smallestNode = value
				smallestDistance = dist
			end
		end
		return smallestNode:getObjID()
	end
end

function NAVGO._FINAL()
	NAVGO.NODE_TREE = {}
	NAVGO.COLLISIONS = {}
	NAVGO.READY_TO_USE = false
end



