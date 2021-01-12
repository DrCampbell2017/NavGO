# NavGO
Defold Library. Navigation using A* based on game objects rather than tile maps. This product contains an A* core that can be accessed by using either a NavGO handler with messaging or by requiring a singleton called NavGO_Global.

## To Use:
1. Add the /NavGO/Handler/NavGO_HandlerGO.go game object reference to the collection you need navigation in.
2. Add in Navigation nodes from /NavGO/Node/NavGO_NodeGO.go as game object references. Place these around your level for places the object can move to. I suggest putting them at least every 500 pixels and at crossing paths as well as corns.
3. Send an init message to the NavGO_HandlerGO.go to set values. Upon being ready, it will send back a message_id hash("NavGO_Ready").
- Alternatively, require("navGo_pathfinding.NavGO_Global") into a game object and NAVGO.IS_READY() will return true upon being ready.
4. Utalize path generation and random path generation to allow objects to move throughout your level.

## Directional Paths:
A secondary type of Node called the "NavGO_directionalNodeGO" can be used for when a specific path needs to be followed. Example patrolling NPCs. To Use:
1. Add the /NavGO/Handler/NavGO_HandlerGO.go game object reference to the collection you need navigation in.
2. Add in Navigation nodes from /NavGO/directionalNode/NavGO_directionalNodeGO.go as game object references. Place these around your level in the order you would like your character to move. Within each node, there are three values, 
- "Node ID" is the number ID for the object
- "Node Next" is the number ID for the next object in the directional list
- "Independent path" is a true/false value. True means that it will not be included for use outside of the path. Functions such as "GET_RANDOM_NODE" can not pick these nodes for the path and they will not be used in any other path finding. True means that the node will be used in other path finding.
3. Give each directional node an ID for the "Node ID" and the "Node Next" values. This will determine the order of the path that is generated. The path does not have to be in sequential order, you can go from ID 1 to 4, from 4 to 2 and from 2 to 1, see directional_navGo_OutOfOrder file in the project for an example of doing this.
4. Send an init message to the NavGO_HandlerGO.go to set values. Upon being ready, it will send back a message_id hash("NavGO_Directional_Ready").
- Alternatively, require("navGo_pathfinding.NavGO_Global") into a game object and NAVGO.IS_DIRECTIONS_READY() will return true upon being ready.
5. Utalize path generation using the function "GET_PATH_FROM_DIRECTIONAL_ID".

## Test collections:
Included within full project (which you can download as a .zip) there are currently two different collections showing various elements of the NavGO. To View a specific example.
1. Open up the project in Defold
2. Navigate to the game.project file
3. In the section "Bootstap" change the value of "Main collection" to one of the following:
- "standard_NavGo_Demo.collection" (default value) is the main demo space for the NavGo and showcases two moving characters, one character uses the singleton and one messages with the handler. A few seconds into the test, additional characters will spawn with no possible path to show handling that. This collection showcases the primary functions of NavGo.
- "directional_NavGo_Demo.collection" is the demo for showing off the directional movement. Two characters will follow separate directional paths defined in their movement script. A third character will path find to a randomly picked node that is either on the normal NavGo nodes or the directional nodes where the value of "Independent Path" is set to false.

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
  Message must contain a value called 'target' that is a node on the path.This command will use A* to generate the requested path using the nodes available. When finished, the NavGO_HandlerGO will send a message with 'message_id hash("path_to_follow")' and a variable 'message.path' that contains a list of vector3 values (excluding current position) that leads to the end goal. If a path was not found, the NavGO_HandlerGO will send a message with 'message_id hash("path_not_found")'. If the NavGo handler was not initialized, a warning message with print in the console. 
```
msg.post("/NavGO_HandlerGO#NavGO_HandlerScript", hash("generate_path"), {target = go.get_id("/NavGO_NodeGO1")})
```

### Generate Path To Random Node
  This will generate a path to a random node in the tree and return it to the sender using 'message_id hash("path_to_follow")' and a variable 'message.path' that contains a list of vector3 values. This will not exclude any nodes (including a node the sender maybe ontop of). If a path was not found, the NavGO_HandlerGO will send a message with 'message_id hash("path_not_found")'. If the NavGo handler was not initialized, a warning message with print in the console. 

```
msg.post("/NavGO_HandlerGO#NavGO_HandlerScript", hash("generate_path_to_random_node"), {target = go.get_id("/NavGO_NodeGO1")})
```

### Return Random Node
  Message will get a random node from the nodes list and return the url of the node to the sender with the message: message_id = hash("random_node"), message.node . If the NavGo handler was not initialized, a warning message with print in the console. 
```
msg.post("/NavGO_HandlerGO#NavGO_HandlerScript", hash("return_random_node"))
```

### Return All Nodes
  Message will send a list back of all node URL's in the tree. Will be sent with message_id hash("all_nodes") and message.nodes
  *note* If your tree has more then 50 nodes in it, due to buffer size limits, the message will be sent back in groups of 50 using message_id hash("nodes_fraction") with message message.node followed by the message_id hash("add_nodes_sent") to confirm everything was sent. With more then 50 nodes on the path, it is recommended to use NavGO_Global instead of the handler. See documentation for NavGO handler bellow. If the NavGo handler was not initialized, a warning message with print in the console. 
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
  This message will force on debug node to show all nodes on the map as well as the connections between them. If the NavGo handler was not initialized, a warning message with print in the console. Connections between standard NavGo nodes will appear in red, connections between directional nodes will appear in blue.
```
msg.post("/NavGO_HandlerGO#NavGO_HandlerScript", hash("debug"))
```

### Redraw Path
  This message will force the map to be redrawn, all links between nodes will be recalculated. If the NavGo handler was not initialized, a warning message with print in the console. 
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

Will return nothing if the NavGo Handler has not been initialized.

```
 NAVGO.RETURN_ALL_NODES()
```

### NAVGO.GET_RANDOM_NODE()

Returns a random node from the tree. 

Will return nothing if the NavGo Handler has not been initialized.

```
NAVGO.GET_RANDOM_NODE()
```

### NAVGO.GENERATE_PATH(targetURL, myURL)

Will generate a path between myURL and the targetURL. This function returns two values, 'Path' and 'found'. 
- Path is a table of vector3 positions leading from the current position to the end position, will be empty table '{}' if no path is possible. 
- Found is a boolean value that will be true if the path does exist, false if no path is found. 

Will return nothing if the NavGo Handler has not been initialized.

*Note You can check if a path exists by either checking if the path has no nodes or if the found value is true/false
```
local path, found = NAVGO.GENERATE_PATH(targetURL, myURL)
```

### NAVGO.GENERATE_PATH_TO_RANDOM_NODE(myUrl)
 
Will generate a path from the current object's place to a random node in the tree. This includes the possibility of having the node currently on be returned.
This function returns two values, 'Path' and 'found'. 
- Path is a table of vector3 positions leading from the current position to the end position, will be empty table '{}' if no path is possible. 
- Found is a boolean value that will be true if the path does exist, false if no path is found.

Will return nothing if the NavGo Handler has not been initialized.

*Note You can check if a path exists by either checking if the path has no nodes or if the found value is true/false

```
local path, found = NAVO.GENERATE_PATH_TO_RANDOM_NODE(myUrl)
```

### NAVGO.GET_NODES_IN_RANGE(centerPosition, range)

Will generate a table of navigation node urls that are within the range of a given position. Take two arguments, 'centerPosition' and 'range'. CenterPosition will be the center of the area you want to check. Range is the distance from the center point that you want to measure and include nodes from.

Will return nothing if the NavGo Handler has not been initialized.

*Note This calculation will include nodes that are within range of the center position, no path is guaranteed between any of the nodes. Example: Two nodes on opposite sides of a wall will be included, even if an NPC cannot travel directly from one to another.

```
local nodesNearPosition = NAVGO.GET_NODES_IN_RANGE(centerPosition, range)
```

### NAVGO.GET_NODE_NEAREST_TO_POSITION(position)
Will return the url of the navigation node that is closest to the center position. This function takes one argument, 'position'. Position is the location where you want to measure the nearest node to. 

Will return nothing if the NavGo Handler has not been initialized.

*Note This caluclation does not guarantee a path from the position to the suggested node. Example: the node could be on the other side of a wall.

```
local nearestNode = NAVGO.GET_NODE_NEAREST_TO_POSITION(position)
```


### NAVGO.IS_DIRECTIONS_READY()
Will return a true or false flag (boolean) to show if the NavGO directional tree is ready to be used. True = ready to be used. False = not yet initialized.
*Note Directional nodes must be placed within the level for this function to return true.
```
NAVGO.IS_DIRECTIONS_READY()
```

### NAVGO.GET_PATH_FROM_DIRECTIONAL_ID(start_node_id, end_node_id)
Will return a list of positional values from one node to another using the directional path trees, meaning it will be one direction. This function takes two arguments, 'start_node_id' and 'end_node_id'. 'start_node_id' is the ID of the node the path will start at. 'end_node_id' is the ID of the node the path will end at. The ID is user defined and exists in the "NavGO_directionalNodeGO" game object.  

Will return two values, path and found. Path is a list of vector three values of the positions for the nodes along the path. Found is a bool variable indicating if the path was successfully generated (returns true) or not (returns false). 
If the NavGo Handler has not been initialized, path will be an empty table "{}" and found will be "false".

*Note Directional nodes must be placed within the level to use this function. The directional values do not hard enforce the collision rules as defined in the init NavGO_HandlerGO message. A warning will appear if a wall is in the way but will still compile and the path will generate through the wall.

```
local path, found = NAVGO.GET_PATH_FROM_DIRECTIONAL_ID(start_node_id, end_node_id)
```


*Note* NAVGO._FINAL, NAVGO._INIT, and NAVGO._INIT_DIRECTIONS_PATH are private functions and should not be called. 

