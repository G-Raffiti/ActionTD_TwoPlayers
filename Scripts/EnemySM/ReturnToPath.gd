extends StateMachineState

@export var parent :CharacterBody3D

# Called when the state machine enters this state.
func on_enter():
	parent.nav_agent.target_position = parent.last_nav_position
	parent.stats.detection_radius = 1


# Called every frame when this state is active.
func on_process(_delta):
	pass


# Called every physics frame when this state is active.
func on_physics_process(delta):
	var direction :Vector3 = Vector3.ZERO
	
	direction = parent.nav_agent.get_next_path_position() - parent.global_position
	direction = direction.normalized()
	direction.y = 0
	
	var look_direction = parent.last_nav_position
	look_direction.y = parent.position.y
	parent.look_at(look_direction, Vector3.UP, true)
	
	var new_velocity = parent.velocity.lerp(direction * parent.stats.speed, delta * parent.stats.acceleration)
	
	parent.velocity = new_velocity
	
	parent.move_and_slide()


# Called when there is an input event while this state is active.
func on_input(_event: InputEvent):
	pass


# Called when the state machine exits this state.
func on_exit():
	parent.stats.detection_radius = 4
	pass

