extends RigidBody2D

@onready var loot_sprite: Sprite2D = $LootSprite
var frame: int = 0
var rix: int
var riy: int

func _ready() -> void:
	loot_sprite.frame = frame
	contact_monitor = true
	max_contacts_reported = 2
	apply_impulse(Vector2(rix, riy))
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not multiplayer.is_server(): return
	if not body is Player: return
	if body.player_health <= 0: return
	if body.player_sync_component.scrapping: return
	
	var peer_id = body.input_multiplayer_authority
	if frame == 0: 
		body.add_candy.rpc_id(peer_id)
	else: 
		body.add_candy_corn.rpc_id(peer_id)
	body.ui.update_loot.rpc_id(peer_id)
	queue_free()
