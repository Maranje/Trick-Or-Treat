extends Node

var label_scene: PackedScene = preload("uid://c2mrfsrph5ocy")
@onready var label_spawner: MultiplayerSpawner = $Lobby/LabelSpawner
@onready var address: LineEdit = $Connect/Address
@onready var host_button: Button = $Connect/HBoxContainer/Host
@onready var join_button: Button = $Connect/HBoxContainer/Join
@onready var ready_button: Button = $Lobby/Ready
@onready var user_name: LineEdit = $Lobby/UserName
@onready var connect_disp: Node2D = $Connect
@onready var lobby_disp: Node2D = $Lobby
@onready var splash_theme: AudioStreamPlayer2D = $SplashTheme

const PORT = 4139
var peer = ENetMultiplayerPeer.new()
var label_y_offset = 0
var peer_labels: Dictionary = {}

func _ready() -> void:
	if not address or not host_button or not join_button:
		print("ERROR: Missing UI nodes!")
		return
	
	lobby_disp.visible = false
	connect_disp.visible = true
	
	host_button.pressed.connect(_host_pressed)
	join_button.pressed.connect(_join_pressed)
	ready_button.pressed.connect(_ready_pressed)
	user_name.text_changed.connect(_user_name_edit)
	splash_theme.finished.connect(_on_splash_theme_finished)
	
	# Add disconnection signal handlers
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	label_spawner.spawn_function = func(data):
		var new_label = label_scene.instantiate() as UserLabel
		new_label.position.y += label_y_offset
		new_label.input_multiplayer_authority = data.peer_id
		label_y_offset += 20
		new_label.name = str(data.peer_id)
		peer_labels[data.peer_id] = new_label
		return new_label

func _process(_delta: float) -> void:
	if check_all_players_ready():
		print("all players ready!") #change this shit to a scene change to start the stage when all players are ready

func check_all_players_ready() -> bool:
	if not peer_labels: return false
	var all_ready = true
	for label in peer_labels.values():
		if not label.player_ready:
			all_ready = false
			break
	return all_ready

func is_multiplayer_active() -> bool:
	return multiplayer.has_multiplayer_peer() and \
		   multiplayer.multiplayer_peer != null and \
		   multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED

func reset_multiplayer():
	if multiplayer.connected_to_server.is_connected(_on_connected_client):
		multiplayer.connected_to_server.disconnect(_on_connected_client)
	if multiplayer.connection_failed.is_connected(_on_connection_failed):
		multiplayer.connection_failed.disconnect(_on_connection_failed)
	if multiplayer.peer_connected.is_connected(_on_connected_host):
		multiplayer.peer_connected.disconnect(_on_connected_host)
	
	multiplayer.multiplayer_peer = null
	peer = ENetMultiplayerPeer.new()
	
	for label in peer_labels.values():
		if is_instance_valid(label):
			label.queue_free()
	peer_labels.clear()
	label_y_offset = 0
	label_y_offset = 0

func _host_pressed():
	reset_multiplayer()
	
	var error = peer.create_server(PORT)
	if error != OK:
		print("Failed to create server: ", error)
		return
	
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_connected_host)
	
	lobby_disp.visible = true
	connect_disp.visible = false
	print("Server started on port ", PORT)
	peer_ready.rpc_id(1)

func _join_pressed():
	if address.text.is_empty():
		return
	
	reset_multiplayer()
	
	var error = peer.create_client(address.text, PORT)
	if error != OK:
		print("Failed to create client: ", error)
		return
	
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connected_client)
	multiplayer.connection_failed.connect(_on_connection_failed)

func _ready_pressed():
	if not is_multiplayer_active():
		print("Cannot ready - multiplayer not active")
		return
		
	var my_peer_id = multiplayer.get_unique_id()
	if my_peer_id in peer_labels:
		peer_labels[my_peer_id].label_sync_component.player_ready()
		PlayerGlobals.user_name = peer_labels[my_peer_id].text

func _user_name_edit(text):
	if not is_multiplayer_active():
		return
	var my_peer_id = multiplayer.get_unique_id()
	if my_peer_id in peer_labels:
		peer_labels[my_peer_id].label_sync_component.gather_input(text)

func _on_connected_host(id):
	print("Peer %s connected to server" % id)

func _on_connected_client():
	print("Successfully connected to server")
	lobby_disp.visible = true
	connect_disp.visible = false
	peer_ready.rpc_id(1)

func _on_connection_failed():
	print("Failed to connect to server")
	_return_to_connection_screen()

func _on_splash_theme_finished():
	splash_theme.play()

func reposition_all_labels():
	await get_tree().process_frame
	
	var valid_labels = []
	for peer_id in peer_labels.keys():
		if is_instance_valid(peer_labels[peer_id]):
			valid_labels.append(peer_labels[peer_id])
	
	valid_labels.sort_custom(func(a, b): return a.position.y < b.position.y)
	
	for i in range(valid_labels.size()):
		valid_labels[i].position.y = i * 20 - 141
	
	label_y_offset = valid_labels.size() * 20
	print("Repositioned %d labels" % valid_labels.size())

func _on_peer_disconnected(id):
	print("Peer ", id, " disconnected")
	if id in peer_labels:
		if is_instance_valid(peer_labels[id]):
			peer_labels[id].queue_free()
		peer_labels.erase(id)
		reposition_all_labels()

func _on_server_disconnected():
	print("Disconnected from server!")
	_return_to_connection_screen()

func _return_to_connection_screen():
	# Show connection screen
	lobby_disp.visible = false
	connect_disp.visible = true
	
	# Clean up all labels
	for label in peer_labels.values():
		if is_instance_valid(label):
			label.queue_free()
	peer_labels.clear()
	
	# Reset multiplayer
	multiplayer.multiplayer_peer = null
	peer = ENetMultiplayerPeer.new()
	
	print("Returned to connection screen")

func _reposition_labels():
	# Wait a frame for the queue_free to process
	await get_tree().process_frame
	
	# Reposition all remaining labels to remove gaps
	var position_index = 0
	for peer_id in peer_labels.keys():
		if is_instance_valid(peer_labels[peer_id]):
			peer_labels[peer_id].position.y = position_index * 20
			position_index += 1

@rpc("any_peer", "call_local", "reliable")
func peer_ready():
	var sender_id = multiplayer.get_remote_sender_id()
	label_spawner.spawn({"peer_id": sender_id})
