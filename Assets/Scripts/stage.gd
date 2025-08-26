extends Node

var player_scene: PackedScene = preload("uid://df8j72jtyei4v")
@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner
var ready_peers: Array[int] = []
var scene_ready_peers: Array[int] = []

func _ready() -> void:
	# Set up the spawner
	player_spawner.spawn_function = func(data):
		var new_player = player_scene.instantiate() as Player
		new_player.input_multiplayer_authority = data.peer_id
		new_player.name = str(data.peer_id)
		print("Created player for peer: ", data.peer_id)
		return new_player
	
	# Connect multiplayer signals
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	# Wait a bit longer for scene to be fully ready
	await get_tree().process_frame
	await get_tree().process_frame
	
	print("Scene fully loaded, notifying server...")
	# Tell server this peer's scene is ready
	scene_loaded.rpc_id(1)

@rpc("any_peer", "call_local", "reliable")
func scene_loaded():
	# Only server handles this
	if not multiplayer.is_server():
		return
	
	var sender_id = multiplayer.get_remote_sender_id()
	if sender_id == 0:  # Server calling itself
		sender_id = 1
	
	print("Scene loaded for peer: ", sender_id)
	scene_ready_peers.append(sender_id)
	
	# Now spawn player for this peer
	stage_ready_internal(sender_id)

func stage_ready_internal(peer_id: int):
	# Avoid duplicate spawning
	if peer_id in ready_peers:
		return
		
	ready_peers.append(peer_id)
	var result = player_spawner.spawn({"peer_id": peer_id})
	print("Spawned player for peer: ", peer_id, " Result: ", result)

func _on_peer_disconnected(peer_id: int):
	print("Peer disconnected: ", peer_id)
	
	# Only server removes nodes
	if multiplayer.is_server():
		ready_peers.erase(peer_id)
		scene_ready_peers.erase(peer_id)
		
		# Find and remove the player node
		var player_node = get_node_or_null(str(peer_id))
		if player_node and is_instance_valid(player_node):
			player_node.queue_free()
			print("Removed player for peer: ", peer_id)

func _on_server_disconnected():
	print("Disconnected from server")
	ready_peers.clear()
	scene_ready_peers.clear()
	
	# Clean up all player nodes when disconnected
	for child in get_children():
		if child is Player:
			child.queue_free()
