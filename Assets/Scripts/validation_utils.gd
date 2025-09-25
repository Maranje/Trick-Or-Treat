class_name ValidationUtils

# Check if node is valid and has a specific component
static func is_valid_node_with_component(node: Node, component_name: String) -> bool:
	return node and is_instance_valid(node) and node.has_node(component_name)

# Check if multiplayer peer is active
static func is_multiplayer_active(multiplayer_obj: MultiplayerAPI) -> bool:
	return multiplayer_obj.has_multiplayer_peer() and \
		   multiplayer_obj.multiplayer_peer != null and \
		   multiplayer_obj.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED

# Safely get a node component with validation
static func get_component_safe(node: Node, component_path: String) -> Node:
	if not is_valid_node_with_component(node, component_path):
		return null
	return node.get_node(component_path)

# Check if node is valid for multiplayer operations
static func is_valid_multiplayer_node(node: Node) -> bool:
	return node and is_instance_valid(node) and node.has_method("get_multiplayer_authority")

# Validate opponent node in squabbles
static func is_valid_opponent(opponent: Node) -> bool:
	return opponent and is_instance_valid(opponent) and \
		   opponent.has_node("PlayerSyncComponent")