navNode = {
	mt = {},

	New = function(objID, pos)
		local wp = {}
		setmetatable( wp, navNode.mt) --binds metaTable to table
		for k,v in pairs(navNode) do --loops through table (even with named indexes)
			wp[k] = v -- matches a key in the vec table to a value
			--vec.k = v is the same thing
		end
		wp.objectID = objID
		wp.position = pos
		wp.linkedNodes = {}
		return wp
	end,

	clearLinkedList = function(self)
		self.linkedNodes = {}
	end,

	inLinkedNodesList = function(self, value2Check)
		return self.linkedNodes[value2Check] ~= nil
	end,

	addToLinkedNodesList = function(self, value, distance)
		self.linkedNodes[value] = distance
	end,

	getAmountInLinkedList = function(self)
		local amount = 0
		for k, v in pairs(self.linkedNodes) do
			amount = amount + 1
		end
		return amount
	end,

	removeNodeFromLinkedList = function(self, value)
		self.linkedNodes[value] = nil
	end,

	getLinkedNodeList = function(self)
		return self.linkedNodes
	end,

	hasConnectedNodes = function(self)
		for k, v in pairs(self.linkedNodes) do
			return true
		end
		return false
	end,

	isObjectID = function(self, check)
		return check == self.objectID
	end,

	getObjID = function(self)
		return self.objectID
	end,

	getPosition = function(self)
		return self.position
	end
}