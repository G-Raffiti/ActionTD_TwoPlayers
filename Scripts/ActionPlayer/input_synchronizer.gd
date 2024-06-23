extends MultiplayerSynchronizer

@onready var player = get_parent()

var sync_event: InputEvent = null

func _ready() -> void:
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)

func _input(event):
	sync_event = event
