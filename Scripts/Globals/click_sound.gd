extends AudioStreamPlayer

func _ready():
	stream = Data.ui_button_sound
	bus = "UI"
	process_mode = Node.PROCESS_MODE_ALWAYS
	volume_db = -15

func play_click():
	pitch_scale = randf_range(0.7, 1.3)
	play()