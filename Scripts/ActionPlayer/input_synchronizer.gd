extends MultiplayerSynchronizer
class_name PlayerInputs

@onready var player = get_parent()

var movement_direction: Vector3 = Vector3.ZERO
enum MOVE { STAND, SPRINT, WALK, RUN }
var movement_state: MOVE = MOVE.STAND
enum STANCE { UPRIGHT, STEALTH, CROUCH, PRONE }
var stance: STANCE = STANCE.UPRIGHT
var target : Vector3 = Vector3.ZERO

func _ready() -> void:
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)

func _physics_process(_delta: float) -> void:
	if player.is_dying: 
		return

	if Input.is_action_just_pressed("primary_fire"):
		primary_fire.rpc()
		
	if Input.is_action_just_pressed("secondary_fire"):
		secondary_fire.rpc()
	
	movement_direction.x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	movement_direction.z = Input.get_action_strength("move_up") - Input.get_action_strength("move_down")
	
	if is_movement_ongoing():
		if Input.is_action_just_pressed("sprint"):
			movement_state = MOVE.SPRINT
			if stance == STANCE.STEALTH:
				stance = STANCE.UPRIGHT
		elif Input.is_action_pressed("walk"):
			movement_state = MOVE.WALK
		else:
			movement_state = MOVE.RUN
	else:
		movement_state = MOVE.STAND
		
	var mouse_position_2d: Vector2 = player.camera.get_viewport().get_mouse_position()
	var mouse_position_3d: Vector3 = player.camera.project_position(mouse_position_2d, 0)
	player.ray.global_position = mouse_position_3d
	player.ray.target_position = player.camera.project_local_ray_normal(mouse_position_2d) * 1000
	player.ray.force_raycast_update()

	if not player.ray.is_colliding(): return

	target = player.ray.get_collision_point()
	
	if Input.is_action_just_pressed("jump") and not player.is_attacking:
		jump.rpc()
	
	if player.is_on_floor():
		for stance_path in player.stances.values():
			if Input.is_action_just_pressed(get_node(stance_path).action_name):
				stance = get_node(stance_path).type

@rpc("call_local")
func jump():
	if multiplayer.is_server():
		player.do_jump = true

@rpc("call_local")
func primary_fire():
	if multiplayer.is_server():
		player.do_primary_attack = true
		
@rpc("call_local")
func secondary_fire():
	if multiplayer.is_server():
		player.do_secondary_attack = true

func is_movement_ongoing() -> bool:
	return abs(movement_direction.x) > 0 or abs(movement_direction.z) > 0
