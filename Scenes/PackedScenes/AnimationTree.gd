extends AnimationTree

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(str(multiplayer.is_server()), " ", get('parameters/attack_transition/current_state'))
