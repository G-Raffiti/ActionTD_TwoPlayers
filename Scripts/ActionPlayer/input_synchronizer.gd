extends MultiplayerSynchronizer

@onready var player = get_parent()

var sync_event: InputEvent

func _input(event):
	sync_event = event
