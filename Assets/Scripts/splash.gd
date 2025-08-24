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
	
	label_spawner.spawn_function = func(data):
		var new_label = label_scene.instantiate() as UserLabel
		new_label.position.y += label_y_offset
		new_label.input_multiplayer_authority = data.peer_id
		label_y_offset += 20
		new_label.name = str(data.peer_id)
		peer_labels[data.peer_id] = new_label
		return new_label

func reset_multiplayer():
	if multiplayer.connected_to_server.is_connected(_on_connected_client):
		multiplayer.connected_to_server.disconnect(_on_connected_client)
	if multiplayer.connection_failed.is_connected(_on_connection_failed):
		multiplayer.connection_failed.disconnect(_on_connection_failed)
	if multiplayer.peer_connected.is_connected(_on_connected_host):
		multiplayer.peer_connected.disconnect(_on_connected_host)
	
	multiplayer.multiplayer_peer = null
	peer = ENetMultiplayerPeer.new()
	
	peer_labels.clear()
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
	var my_peer_id = multiplayer.get_unique_id()
	if my_peer_id in peer_labels:
		peer_labels[my_peer_id].label_sync_component.player_ready()
		print("Player %s ready!" % peer_labels[my_peer_id].text)

func _user_name_edit(text):
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
	
func _on_splash_theme_finished():
	splash_theme.play()

@rpc("any_peer", "call_local", "reliable")
func peer_ready():
	var sender_id = multiplayer.get_remote_sender_id()
	label_spawner.spawn({"peer_id": sender_id})
