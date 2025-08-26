extends Node

var player_scene: PackedScene = preload("uid://df8j72jtyei4v")
@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner
var spawned_players: Dictionary = {}

func _ready() -> void:
	player_spawner.spawn_function = func(data):
		var new_player = player_scene.instantiate() as Player
		new_player.input_multiplayer_authority = data.peer_id
		new_player.name = str(data.peer_id)
		return new_player
	
	# Connect to peer disconnection signal
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	await get_tree().process_frame
		
	stage_ready.rpc_id(1)

@rpc("any_peer", "call_local", "reliable")
func stage_ready():
	# Only the server should handle spawning logic
	if not multiplayer.is_server():
		return
	
	var sender_id = multiplayer.get_remote_sender_id()
	if sender_id == 0:  # This means the call came from the server itself
		sender_id = 1  # Server is always peer ID 1
	
	# Only spawn if this player hasn't been spawned yet
	if not spawned_players.has(sender_id):
		player_spawner.spawn({"peer_id": sender_id})
		spawned_players[sender_id] = true
		print("Spawned player for peer: ", sender_id)

func _on_peer_disconnected(peer_id: int):
	if spawned_players.has(peer_id):
		spawned_players.erase(peer_id)
		print("Removed player tracking for peer: ", peer_id)
