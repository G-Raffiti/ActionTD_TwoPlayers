extends MultiplayerSynchronizer
class_name PlayerInputs

@onready var player = get_parent()

var movement_direction: Vector3 = Vector3.ZERO
enum MOVE { STAND, SPRINT, WALK, RUN }
var movement_state: MOVE = MOVE.STAND
enum STANCE { UPRIGHT, STEALTH, CROUCH, PRONE }
var stance: STANCE = STANCE.UPRIGHT

func _ready() -> void:
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)

func _physics_process(delta: float) -> void:
	if player.is_dying: 
		return

	if Input.is_action_just_pressed("primary_fire"):
		primary_fire.rpc()
	
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
	
	if Input.is_action_just_pressed("jump") and not player.is_attacking:
		jump.rpc()
	
	if player.is_on_floor():
		for stance in player.stances.values():
			if Input.is_action_just_pressed(get_node(stance).action_name):
				stance = stance

@rpc("call_local")
func jump():
	if multiplayer.is_server():
		player.do_jump = true

@rpc("call_local")
func primary_fire():
	if multiplayer.is_server():
		player.do_primary_attack = true

func is_movement_ongoing() -> bool:
	return abs(movement_direction.x) > 0 or abs(movement_direction.z) > 0
