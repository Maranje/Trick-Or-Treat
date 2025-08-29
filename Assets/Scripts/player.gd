class_name Player
extends CharacterBody2D

@onready var player_sync_component: MultiplayerSynchronizer = $PlayerSyncComponent
var input_multiplayer_authority: int
@onready var player_sync: MultiplayerSynchronizer = $PlayerSync
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D
@onready var tag: Label = $tag
var prev_anim: String
var prev_tag: String
var speed: int = 500
var jump: int = -1000
var gravity: int = 2500
var jump_velocity: int = -1000
var door_number: int
var doors_hit: Array[Array]

func _ready() -> void:
	player_sync_component.set_multiplayer_authority(input_multiplayer_authority)
	set_process(is_multiplayer_authority())
	
	print("Player ready - Peer ID: ", multiplayer.get_unique_id())
	print("Input authority: ", input_multiplayer_authority)
	print("Is authority: ", is_multiplayer_authority())
	
	for i in range(PlayerGlobals.costume_count):
		doors_hit.append([])
	
	setup_individuals()

func setup_individuals():
	camera_2d.enabled = false
	animated_sprite_2d.sprite_frames = PlayerGlobals.costumes[PlayerGlobals.current_costume]
	animated_sprite_2d.animation = "idle"
	animated_sprite_2d.play()
	tag.text = player_sync_component.tag
	prev_tag = player_sync_component.tag
	
	if input_multiplayer_authority == multiplayer.get_unique_id():
		camera_2d.enabled = true
		camera_2d.make_current()

func _process(delta: float) -> void:
	if prev_tag != player_sync_component.tag:
		tag.text = player_sync_component.tag
		prev_tag = player_sync_component.tag
	
	if not is_on_floor():
		velocity.y += gravity * delta
	elif player_sync_component.jump:
		velocity.y = jump
	
	velocity.x = player_sync_component.movement.x * speed
	
	if prev_anim != player_sync_component.animation_select:
		animated_sprite_2d.animation = player_sync_component.animation_select
		prev_anim = animated_sprite_2d.animation
	
	if Input.is_action_just_pressed("ui_up") and player_sync_component.at_door:
		trick_or_treat(door_number)
		print(doors_hit)
	
	move_and_slide()
	
func trick_or_treat(door: int):
	if door not in doors_hit[PlayerGlobals.current_costume]:
		doors_hit[PlayerGlobals.current_costume].append(door)
