# NavGO
Defold Library. Navigation using A* based on game objects rather than tile maps.

## To Use:
1. Add the /NavGO/Handler/NavGO_HandlerGO.go game object reference to the collection you need navigation in.
2. Add in Navigation nodes from /NavGO/Node/NavGO_NodeGO.go as game object references. Place these around your level for places the object can move to. I suggest putting them at least every 500 pixels and at crossing paths as well as corns.
3. Send an init message to the NavGO_HandlerGO.go to set values.
4. Have object (such as a character) message the NavGO_HandlerGO.go with hash("generate_path") to get a path generated. Path will be returned with hash("path_to_follow")' and a variable 'message.path' that contains a list of vector3 values (excluding current position) that leads to the end goal.


## Messages to the NavGO_HandlerGO

### Init
  This message sets up the key parameters for the NavGO. It should be called by a main script or the first script loaded as a way of establishing the algorithm before the nodes spawn in.
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

### Return Random Node
  Message will get a random node from the nodes list and return the url of the node to the sender with the message: message_id = hash("random_node"), message.node
```
msg.post("/NavGO_HandlerGO#NavGO_HandlerScript", hash("return_random_node"))
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
