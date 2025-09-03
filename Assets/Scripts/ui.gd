extends Node2D

@onready var green_bar: Sprite2D = $GreenBar
@onready var red_bar: Sprite2D = $RedBar
@onready var top_right: Node2D = $TopRight
@onready var candy_label: Label = $TopRight/Candy/Label
@onready var candy_corn_label: Label = $TopRight/CandyCorn/Label

var static_center_pos: int = 272

func _ready() -> void:
	update_candies()

func _process(_delta: float) -> void:
	top_right.global_position.y = static_center_pos

func update_candies():
	candy_label.text = str(PlayerGlobals.candy_count)
	candy_corn_label.text = str(PlayerGlobals.candy_corn)
