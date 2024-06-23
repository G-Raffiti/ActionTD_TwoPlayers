extends Node
class_name Stance

@export var type: PlayerInputs.STANCE
@export var action_name: String

@export_category("Movement States")
@export var idle_state : MovementState
@export var walk_state : MovementState
@export var run_state : MovementState
@export var sprint_state : MovementState

@export_category("Camera Data")
@export var camera_height : float = 1.3

@export_category("Collision")
@export var collider : CollisionShape3D
@export var col_raycast : RayCast3D
@export var higher_stances : Array[Stance]


func is_blocked() -> bool:
	return col_raycast and col_raycast.is_colliding()


func get_movement_state(state_name : PlayerInputs.MOVE) -> MovementState:
	
	match state_name:
		PlayerInputs.MOVE.STAND:
			return idle_state
		PlayerInputs.MOVE.WALK:
			return walk_state
		PlayerInputs.MOVE.RUN:
			return run_state
		PlayerInputs.MOVE.SPRINT:
			return sprint_state
		_:
			return idle_state
	
