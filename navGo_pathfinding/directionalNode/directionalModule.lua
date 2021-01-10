require("navGo_pathfinding.Node.nodeModule")

directional_node = navNode.New(nil, nil)

function directional_node.New(objectID, pos, ID, nextID)
	local self = {}
	--Gab all old information and add to new object
	setmetatable( self, directional_node.mt)
	for k,v in pairs(directional_node) do
		self[k] = v
	end

	--Save New Info
	self.objectID = objectID
	self.position = pos
	self.linkedNodes = {}
	self.ID = ID
	self.nextID = nextID
	return self
end

function directional_node.getNumberID(self)
	return self.ID 
end

function directional_node.getNextID(self)
	return self.nextID
end