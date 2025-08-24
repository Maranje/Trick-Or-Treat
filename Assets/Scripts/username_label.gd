class_name UserLabel
extends Label

@onready var label_sync_component: MultiplayerSynchronizer = $LabelSyncComponent
var input_multiplayer_authority: int

func _ready() -> void:
	label_sync_component.set_multiplayer_authority(input_multiplayer_authority)
	set_process(is_multiplayer_authority())
	
func _process(_delta: float) -> void:
	text = label_sync_component.label_text
