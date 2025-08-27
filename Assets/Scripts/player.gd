class_name Player
extends CharacterBody2D
@onready var player_sync_component: MultiplayerSynchronizer = $PlayerSyncComponent
var input_multiplayer_authority: int
@onready var player_sync: MultiplayerSynchronizer = $PlayerSync
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D
@onready var tag: Label = $tag
var prev_anim: String
var prev_tag: String  # Add this to track tag changes
var speed: int = 500
var jump: int = -1000
var gravity: int = 2500
var jump_velocity: int = -1000

func _ready() -> void:
	player_sync_component.set_multiplayer_authority(input_multiplayer_authority)
	set_process(is_multiplayer_authority())
	animated_sprite_2d.animation = "idle"
	animated_sprite_2d.play()
	
	print("Player ready - Peer ID: ", multiplayer.get_unique_id())
	print("Input authority: ", input_multiplayer_authority)
	print("Is authority: ", is_multiplayer_authority())
	
	setup_individuals()

func setup_individuals():
	camera_2d.enabled = false
	
	# Set tag for ALL players
	tag.text = player_sync_component.tag
	prev_tag = player_sync_component.tag
	
	# Only enable camera for local player
	if input_multiplayer_authority == multiplayer.get_unique_id():
		camera_2d.enabled = true
		camera_2d.make_current()
		camera_2d.position.y = 240 - global_position.y

func _process(delta: float) -> void:
	# Update tag if it changed (for all players)
	if prev_tag != player_sync_component.tag:
		tag.text = player_sync_component.tag
		prev_tag = player_sync_component.tag
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	elif player_sync_component.jump:
		velocity.y = jump
	
	# Apply horizontal movement from sync component
	velocity.x = player_sync_component.movement.x * speed
	
	# Update animation
	if prev_anim != player_sync_component.animation_select:
		animated_sprite_2d.animation = player_sync_component.animation_select
		prev_anim = animated_sprite_2d.animation
	
	move_and_slide()
	
	# Update camera ONLY for the local player
	if camera_2d.enabled and input_multiplayer_authority == multiplayer.get_unique_id():
		camera_2d.position.y = 240 - global_position.y
