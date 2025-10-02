extends RigidBody2D
var direction: Vector2

@onready var shuriken_sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	angular_velocity = 100
	contact_monitor = true
	max_contacts_reported = 10
	apply_impulse(direction)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not multiplayer.is_server(): return
	if "player_health" in body and body.player_health > 0:
		body.apply_damage.rpc_id(1, 5)
	queue_free()
