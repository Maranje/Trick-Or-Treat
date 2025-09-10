extends RigidBody2D
var direction: int = 1000

@onready var candy_corn: Sprite2D = $CandyCorn

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 10
	candy_corn.rotation = randi() % 360
	apply_impulse(Vector2(direction, -100))
	body_entered.connect(_on_body_entered)
	
func _process(_delta: float) -> void:
	candy_corn.rotation += 0.1

func _on_body_entered(body):
	if not multiplayer.is_server(): return
	if "player_health" in body and body.player_health > 0:
		body.apply_damage.rpc_id(1, 1)
	queue_free()
