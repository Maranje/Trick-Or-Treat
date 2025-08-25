extends CharacterBody2D

@onready var player_sync_component: MultiplayerSynchronizer = $PlayerSyncComponent
@onready var player_sync: MultiplayerSynchronizer = $PlayerSync
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var speed: int = 30000

func _ready() -> void:
	animated_sprite_2d.animation = "idle"
	animated_sprite_2d.play()
	
func _process(delta: float) -> void:
	velocity = player_sync_component.movement * delta * speed
	if velocity.x < 0: animated_sprite_2d.animation = "left"
	elif velocity.x > 0: animated_sprite_2d.animation = "right"
	else: animated_sprite_2d.animation = "idle"
	move_and_slide()
