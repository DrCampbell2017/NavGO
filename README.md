# NavGO
Defold Library. Navigation using A* based on game objects rather than tile maps. This product contains an A* core that can be accessed by using either a NavGO handler with messaging or by requiring a singleton called NavGO_Global.

## To Use:
1. Add the /NavGO/Handler/NavGO_HandlerGO.go game object reference to the collection you need navigation in.
2. Add in Navigation nodes from /NavGO/Node/NavGO_NodeGO.go as game object references. Place these around your level for places the object can move to. I suggest putting them at least every 500 pixels and at crossing paths as well as corns.
3. Send an init message to the NavGO_HandlerGO.go to set values. Upon being ready, it will send back a message_id hash("NavGO_Ready").
- Alternatively, require("navGo_pathfinding.NavGO_Global") into a game object and NAVGO.IS_READY() will return true upon being ready.
4. Utalize path generation and random path generation to allow objects to move throughout your level.

# NAVGO_HANDLER

## Messages to the NavGO_HandlerGO

### Init
  This message sets up the key parameters for the NavGO. It should be called by a main script or the first script loaded in a collection proxy as a way of establishing the algorithm before the nodes spawn in. After initialized, will send a message_id hash("NavGO_Ready") to whatever game object requested the NavGo be initialized.
  ```
--Example init message
local message = {}
message.collisions = { hash("wall") } --<1>
message.debug = false --<2>
message.deleteNodeAfterGotten = false --<3>
message.nodeNeighborRange = 500 --<4>
msg.post("/NavGO_HandlerGO#NavGO_HandlerScript", hash("init"), message)
  ```
Values:

<1.> message.collisions must contain a list of hashed collisions that the path cannot be linked through. This can have multiple values in it.

<2.> message.debug can be true or false/nil. When true, will show the nodes as well as the connections between nodes.

<3.> message.deleteNodeAfterGotten can be true or false/nil. When true, will hide and disable all nodes on the map. This should help with efficiency as opposed to the default implementation which simple shrinks the sprite to vmath.vector3(0,0,0)

<4.> message.nodeNeighborRange is a number value, can be nil. This is the range that nodes will search for each other within. 500 by default.

### New Node
  This message is used for adding new nodes to the list. When the first node is added, there is a .05 second delay before the algorithm runs to create the map. This function is utilized by the built-in NavGO nodes.
```
msg.post("/NavGO_HandlerGO#NavGO_HandlerScript", hash("new_node"))
```

### Generate Path
  Message must contain a value called 'target' that is a node on the path.This command will use A* to generate the requested path using the nodes available. When finished, the NavGO_HandlerGO will send a message with 'message_id hash("path_to_follow")' and a variable 'message.path' that contains a list of vector3 values (excluding current position) that leads to the end goal.
```
msg.post("/NavGO_HandlerGO#NavGO_HandlerScript", hash("generate_path"), {target = go.get_id("/NavGO_NodeGO1")})
```

### Generate Path To Random Node
  This will generate a path to a random node in the tree and return it to the sender using 'message_id hash("path_to_follow")' and a variable 'message.path' that contains a list of vector3 values. This will not exclude any nodes (including a node the sender maybe ontop of).

```
msg.post("/NavGO_HandlerGO#NavGO_HandlerScript", hash("generate_path_to_random_node"), {target = go.get_id("/NavGO_NodeGO1")})
```

### Return Random Node
  Message will get a random node from the nodes list and return the url of the node to the sender with the message: message_id = hash("random_node"), message.node
```
msg.post("/NavGO_HandlerGO#NavGO_HandlerScript", hash("return_random_node"))
```

### Return All Nodes
  Message will send a list back of all node URL's in the tree. Will be sent with message_id hash("all_nodes") and message.nodes
  *note* If your tree has more then 50 nodes in it, due to buffer size limits, the message will be sent back in groups of 50 using message_id hash("nodes_fraction") with message message.node followed by the message_id hash("add_nodes_sent") to confirm everything was sent. With more then 50 nodes on the path, it is recommended to use NavGO_Global instead of the handler. See documentation for NavGO handler bellow.
 ```
 msg.post("/NavGO_HandlerGO#NavGO_HandlerScript", hash("return_all_nodes"))
 ```
 
 Return handling for 50+ nodes:
 ```
 -- add to init function: message.nodes={}
 if message_id == hash("nodes_fraction") then
		for i=1, #message.nodes do
			table.insert(self.nodesList, message.nodes[i])
		end
	elseif message_id == hash("add_nodes_sent") then
		allNodesGotten(self) --use message.nodes
	end
 ```

### debug
  This message will force on debug node to show all nodes on the map as well as the connections between them.
```
msg.post("/NavGO_HandlerGO#NavGO_HandlerScript", hash("debug"))
```

### Redraw Path
  This message will force the map to be redrawn, all links between nodes will be recalculated.
```
msg.post("/NavGO_HandlerGO#NavGO_HandlerScript", hash("redraw_path"))
```

### final 
  This message will cause the NavGo to reset to a default state. Must be re-initialized before it can be used again.
```
msg.post("/NavGO_HandlerGO#NavGO_HandlerScript", hash("final"))
```

# NavGO_Global

NavGO_Global is a world space singleton that can be used to generate paths, this function is usefull for larger paths (more then 50 nodes). It has some limitations, primarily the path cannot be rebuilt unless called through the Redraw path function to the NavGO Handler.

## Functions

### NAVGO.IS_READY()
Will return a true or false flag (boolean) to show if the NavGO is ready to be used. True = ready to be used. False = not yet initialized.
```
NAVGO.IS_READY()
```

### NAVGO.RETURN_ALL_NODES()

Returns a list of all url's for nodes in the tree.
```
 NAVGO.RETURN_ALL_NODES()
```

### NAVGO.GET_RANDOM_NODE()

Returns a random node from the tree.

```
NAVGO.GET_RANDOM_NODE()
```

### NAVGO.GENERATE_PATH(targetURL, myURL)

Will generate a path between myURL and the targetURL. Will return the path as a list of vector3 values.
```
NAVGO.GENERATE_PATH(targetURL, myURL)
```

### NAVGO.GENERATE_PATH_TO_RANDOM_NODE(myUrl)
 
Will generate a path from the current object's place to a random node in the tree. This includes the possibility of having the node currently on be returned.

```
NAVO.GENERATE_PATH_TO_RANDOM_NODE(myUrl)
```

*Note* Both NAVGO._FINAL and NAVGO._INIT are private functions and should not be called. 


