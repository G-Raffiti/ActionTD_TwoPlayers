extends StateMachineState

@export var parent :CharacterBody3D

# Called when the state machine enters this state.
func on_enter():
	pass


# Called every frame when this state is active.
func on_process(delta):
	pass


# Called every physics frame when this state is active.
func on_physics_process(delta):
	var direction: Vector3

	direction = parent.global_position.direction_to(parent.action_player.global_position)
	var new_velocity = parent.velocity.lerp(direction * parent.stats.speed, delta * parent.stats.acceleration)

	parent.velocity = new_velocity

	parent.move_and_slide()
	pass


# Called when there is an input event while this state is active.
func on_input(event: InputEvent):
	pass


# Called when the state machine exits this state.
func on_exit():
	pass

