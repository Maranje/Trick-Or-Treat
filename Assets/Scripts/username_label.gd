class_name UserLabel
extends Label

@onready var label_sync_component: MultiplayerSynchronizer = $LabelSyncComponent
var input_multiplayer_authority: int

func _ready() -> void:
	label_sync_component.set_multiplayer_authority(input_multiplayer_authority)
	set_process(is_multiplayer_authority())

func update_text():
	text = label_sync_component.label_text
	if label_sync_component.p_ready:
		add_theme_color_override("font_color", Color.GREEN)
