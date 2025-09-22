extends Node2D

@onready var icon: PackedScene = preload("uid://m3tp0beqghuw")
@onready var green_bar: Sprite2D = $GreenBar
@onready var red_bar: Sprite2D = $RedBar
@onready var top_right: Node2D = $TopRight
@onready var candy_label: Label = $TopRight/Candy/Label
@onready var candy_corn_label: Label = $TopRight/CandyCorn/Label
@onready var notificon: Node2D = $Notificon
@onready var obstruction: Sprite2D = $Obstruction

var static_center_pos: int = 272
var notificons: Dictionary = {}

func _ready() -> void:
	update_candies()

func _process(_delta: float) -> void:
	top_right.global_position.y = static_center_pos
	notificon.global_position.y = static_center_pos
	obstruction.global_position.y = static_center_pos

func update_candies():
	candy_label.text = str(PlayerGlobals.candy_count)
	candy_corn_label.text = str(PlayerGlobals.candy_corn)

@rpc("any_peer", "call_local", "reliable")
func update_loot():
	candy_label.text = str(PlayerGlobals.candy_count)
	candy_corn_label.text = str(PlayerGlobals.candy_corn)

func run_notificon(candy: int, candy_corn: int):
	for i in range(candy):
		notificons[str("candy",i)] = icon.instantiate()
		notificons[str("candy",i)].frame_number = 0
		notificons[str("candy",i)].position.x = randi() % 20 - 10
		notificons[str("candy",i)].position.y = randi() % 20 - 10
		notificon.add_child(notificons[str("candy",i)])
	for i in range(candy_corn):
		notificons[str("candy_corn",i)] = icon.instantiate()
		notificons[str("candy_corn",i)].frame_number = 1
		notificons[str("candy_corn",i)].position.x = randi() % 20 - 10
		notificons[str("candy_corn",i)].position.y = randi() % 20 - 10
		notificon.add_child(notificons[str("candy_corn",i)])

func update_health(current_health: int, max_health: int = 50):
	green_bar.scale.x = 20 * (float(current_health) / float(max_health))
