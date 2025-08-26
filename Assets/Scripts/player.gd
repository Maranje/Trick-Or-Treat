class_name Player
extends CharacterBody2D

@onready var player_sync_component: MultiplayerSynchronizer = $PlayerSyncComponent
var input_multiplayer_authority: int
@onready var player_sync: MultiplayerSynchronizer = $PlayerSync
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var prev_anim: String
var speed: int = 400
var gravity: int = 2500
var jump_velocity: int = -1000  # Jump strength (negative = up)

func _ready() -> void:
	player_sync_component.set_multiplayer_authority(input_multiplayer_authority)
	set_process(is_multiplayer_authority())
	animated_sprite_2d.animation = "idle"
	animated_sprite_2d.play()
	
func _process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle jumping
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):  # Space bar to jump
		velocity.y = jump_velocity
	
	# Apply horizontal movement from sync component
	velocity.x = player_sync_component.movement.x * speed
	
	# Update animation
	if prev_anim != player_sync_component.animation_select:
		animated_sprite_2d.animation = player_sync_component.animation_select
		prev_anim = animated_sprite_2d.animation
	
	move_and_slide()
