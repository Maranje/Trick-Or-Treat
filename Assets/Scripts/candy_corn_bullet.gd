extends RigidBody2D
var direction: int = 1000

@onready var candy_corn: Sprite2D = $CandyCorn

func _ready() -> void:
	candy_corn.rotation = randi() % 360
	contact_monitor = true
	max_contacts_reported = 10
	apply_impulse(Vector2(direction, -100))
	body_entered.connect(_on_body_entered)
	
func _process(_delta: float) -> void:
	candy_corn.rotation += 0.1

func _on_body_entered(body):
	if "player_health" in body and body.player_health > 0:
		if body.player_sync_component.scrapping: return
		body.player_health -= 1
		body.ui.green_bar.scale.x = body.player_health
	if multiplayer.is_server():
		queue_free()
