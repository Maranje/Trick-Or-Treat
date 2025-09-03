extends Node

var recent_ip: String = ""
var user_name: String = ""
var candy_count: int = 0
var candy_corn: int = 0
var costume_count: int = 12
var current_costume: int = 0

var costumes = [
	preload("res://Assets/SpriteFrames/player_frames.tres"),
	preload("res://Assets/SpriteFrames/clown_frames.tres"),
	preload("res://Assets/SpriteFrames/cape_frames.tres"),
	preload("res://Assets/SpriteFrames/ninja_frames.tres"),
	preload("res://Assets/SpriteFrames/pants_frames.tres"),
	preload("res://Assets/SpriteFrames/nipple_frames.tres"),
	preload("res://Assets/SpriteFrames/faceless_frames.tres"),
	preload("res://Assets/SpriteFrames/egg_frames.tres"),
	preload("res://Assets/SpriteFrames/hole_frames.tres"),
	preload("res://Assets/SpriteFrames/unibrow_frames.tres"),
	preload("res://Assets/SpriteFrames/static_frames.tres"),
	preload("res://Assets/SpriteFrames/witch_hat_frames.tres")
]

const SAVE_FILE = "user://gamedata.save"

func _ready():
	load_data()

func save_data():
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		var save_dict = {
			"recent_ip": recent_ip,
			"user_name": user_name,
			"candy_count": candy_count,
			"candy_corn": candy_corn,
			"costume_count": costume_count,
			"current_costume": current_costume
		}
		file.store_string(JSON.stringify(save_dict))
		file.close()

func load_data():
	if FileAccess.file_exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				var loaded_data = json.data
				recent_ip = loaded_data.get("recent_ip", "")
				user_name = loaded_data.get("user_name", "")
				candy_count = loaded_data.get("candy_count", 0)
				candy_corn = loaded_data.get("candy_corn", 0)
				costume_count = loaded_data.get("costume_count", 12)
				current_costume = loaded_data.get("current_costume", 0)

# Convenience functions to update and save immediately
func add_candy(amount: int):
	candy_count += amount
	save_data()

func add_candy_corn(amount: int):
	candy_corn += amount
	save_data()
	
func remove_one_candy_corn():
	candy_corn -= 1
	save_data()
