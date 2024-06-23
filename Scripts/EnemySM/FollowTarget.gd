extends StateMachineState

@export var parent :CharacterBody3D

# Called when the state machine enters this state.
func on_enter():
	print("enter follow player")
	parent.nav_agent.target_position = parent.action_player.global_position


# Called every frame when this state is active.
func on_process(_delta):
	pass


# Called every physics frame when this state is active.
func on_physics_process(delta):
	var direction: Vector3
	
	if parent.nav_agent.is_navigation_finished() || parent.nav_agent.avoidance_enabled == true:
		parent.nav_agent.target_position = parent.target.global_position

	direction = parent.global_position.direction_to(parent.nav_agent.get_next_path_position())
	var new_velocity = parent.velocity.lerp(direction * parent.stats.speed, delta * parent.stats.acceleration)

	if parent.nav_agent.avoidance_enabled:
		parent.nav_agent.set_velocity_forced(new_velocity)
	else:
		parent.velocity = new_velocity

	parent.move_and_slide()


# Called when there is an input event while this state is active.
func on_input(_event: InputEvent):
	pass


# Called when the state machine exits this state.
func on_exit():
	pass

