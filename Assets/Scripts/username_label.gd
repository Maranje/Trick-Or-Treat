class_name UserLabel
extends Label

@onready var label_sync_component: MultiplayerSynchronizer = $LabelSyncComponent
var input_multiplayer_authority: int
var player_ready: bool = false

func _ready() -> void:
	label_sync_component.set_multiplayer_authority(input_multiplayer_authority)
	set_process(is_multiplayer_authority())
	add_theme_font_size_override("font_size", 9)
	add_theme_color_override("font_color", Color.BLACK)
	
func _process(_delta: float) -> void:
	text = label_sync_component.label_text
	if label_sync_component.p_ready and not player_ready:
		add_theme_constant_override("outline_size", 9)
		add_theme_color_override("font_outline_color", Color.GREEN)
		player_ready = true
