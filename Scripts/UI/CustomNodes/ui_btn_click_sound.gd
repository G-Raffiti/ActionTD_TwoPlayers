extends Button
class_name SoundButton

func _ready():
	pressed.connect(ClickSound.play_click)

func _exit_tree():
	pressed.disconnect(ClickSound.play_click)