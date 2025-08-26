extends Node

var player_scene: PackedScene = preload("uid://df8j72jtyei4v")
@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner

func _ready() -> void:
	print("Stage scene ready. Is server: ", multiplayer.is_server())
	print("My peer ID: ", multiplayer.get_unique_id())
	
	player_spawner.spawn_function = func(data):
		var new_player = player_scene.instantiate() as Player
		new_player.input_multiplayer_authority = data.peer_id
		new_player.name = str(data.peer_id)
		print("Created player instance for peer: ", data.peer_id)
		return new_player
	
	# Connect to multiplayer signals
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	await get_tree().process_frame
	
	print("Calling stage_ready RPC to server...")
	stage_ready.rpc_id(1)

@rpc("any_peer", "call_local", "reliable")
func stage_ready():
	var sender_id = multiplayer.get_remote_sender_id()
	print("stage_ready called by sender_id: ", sender_id)
	
	# Fix the server self-call issue
	if sender_id == 0:
		sender_id = 1
	
	print("Spawning player for peer_id: ", sender_id)
	var spawned_player = player_spawner.spawn({"peer_id": sender_id})
	
	if spawned_player:
		print("Successfully spawned player: ", spawned_player.name)
	else:
		print("Failed to spawn player for peer_id: ", sender_id)

func _on_peer_disconnected(peer_id: int):
	print("Player disconnected: ", peer_id)
	
	# Find and remove the player node (let Godot handle multiplayer cleanup)
	var player_node = get_node_or_null(str(peer_id))
	if player_node and is_instance_valid(player_node):
		player_node.queue_free()

func _on_server_disconnected():
	print("Disconnected from server")
