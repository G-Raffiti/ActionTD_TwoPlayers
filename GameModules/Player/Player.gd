extends CharacterBody3D
class_name Player

var implements = [I.Killable]

signal pressed_primary_fire
signal pressed_jump(jump_state : JumpState)
signal changed_stance(stance : Stance)
signal changed_movement_state(_movement_state: MovementState)
signal changed_movement_direction(_movement_direction: Vector3)

@export var max_air_jump : int = 1
@export var jump_states : Dictionary
@export var stances : Dictionary
@export var health_text : TextBox
@export var i_frame_timer: Timer

@export_category("Player settings")
@export var max_health : int = 1000
@export var attack : float = 1

@export var player_id := 1:
	set(id):
		player_id = id
		%ClientToServer_InputSynchronizer.set_multiplayer_authority(id)
		
var health : int = 0
var is_dying: bool = false
var experience: int = 0

var air_jump_counter : int = 0
var movement_direction : Vector3
var current_stance_name : PlayerInputs.STANCE = PlayerInputs.STANCE.UPRIGHT
var current_movement_state : MovementState
var current_movement_state_name : PlayerInputs.MOVE = PlayerInputs.MOVE.STAND
var stance_antispam_timer : SceneTreeTimer

var is_attacking : bool = false
var do_jump : bool = false
var do_primary_attack : bool = false

@onready var inputs: PlayerInputs = %ClientToServer_InputSynchronizer

func _ready():
	for child in $Stances.get_children():
		stances[child.type] = child.get_path()
	
	
	if not multiplayer.is_server():
		%Camera3D.make_current()
		set_process(false)
		set_physics_process(false)

	health = max_health;
	stance_antispam_timer = get_tree().create_timer(0.25)

	changed_movement_direction.emit(Vector3.BACK)
	set_stance(current_stance_name)
	set_movement_state(PlayerInputs.MOVE.STAND)
	SignalBus.on_health_action_changed.emit(health, max_health)
	
	on_spawned.rpc()

func _apply_input(_delta: float) -> void:
	if is_dying: 
		return
	
	if do_primary_attack:
		pressed_primary_fire.emit()
		set_stance(PlayerInputs.STANCE.UPRIGHT)
		do_primary_attack = false
	
	movement_direction = inputs.movement_direction

	set_movement_state(inputs.movement_state)
	set_stance(inputs.stance)
	
	if do_jump and air_jump_counter <= max_air_jump:
		if is_stance_blocked(PlayerInputs.STANCE.UPRIGHT):
			return
			
		if current_stance_name != PlayerInputs.STANCE.UPRIGHT and current_stance_name != PlayerInputs.STANCE.STEALTH:
			set_stance(PlayerInputs.STANCE.UPRIGHT)
			return
			
		var jump_name = "ground_jump"
			
		if air_jump_counter > 0:
			jump_name = "air_jump"
			
		pressed_jump.emit(jump_states[jump_name])
		air_jump_counter += 1
		
	do_jump = false


func _physics_process(delta):
	_apply_input(delta)
	if is_dying:
		return
	if is_movement_ongoing():
		changed_movement_direction.emit(movement_direction)
		
	if is_on_floor():
		air_jump_counter = 0
	elif air_jump_counter == 0:
		air_jump_counter = 1


func is_movement_ongoing() -> bool:
	return abs(movement_direction.x) > 0 or abs(movement_direction.z) > 0


func set_movement_state(state : PlayerInputs.MOVE):
	var stance = get_node(stances[current_stance_name])
	current_movement_state = stance.get_movement_state(state)
	current_movement_state_name = state
	changed_movement_state.emit(current_movement_state)


func set_stance(_stance_name : PlayerInputs.STANCE):
	if stance_antispam_timer.time_left > 0:
		return
	stance_antispam_timer = get_tree().create_timer(0.25)
	
	var next_stance_name : PlayerInputs.STANCE
	
	if _stance_name == current_stance_name:
		next_stance_name = PlayerInputs.STANCE.UPRIGHT
	else:
		next_stance_name = _stance_name
	
	if is_stance_blocked(next_stance_name):
		return
	
	var current_stance = get_node(stances[current_stance_name])
	current_stance.collider.disabled = true
	
	current_stance_name = next_stance_name
	current_stance = get_node(stances[current_stance_name])
	current_stance.collider.disabled = false
	
	changed_stance.emit(current_stance)
	set_movement_state(current_movement_state_name)


func is_stance_blocked(_stance_name : PlayerInputs.STANCE) -> bool:
	var stance = get_node(stances[_stance_name])
	return stance.is_blocked()
	
func die(_damage_dealer_id = -1) -> void:
	is_dying = true
	movement_direction = Vector3.ZERO
	set_stance(PlayerInputs.STANCE.PRONE)

func take_damage(in_damage: float, _damage_dealer_id = -1) -> void:
	if is_dying:
		return
	if i_frame_timer.time_left > 0:
		return
	i_frame_timer.start()
	blink.rpc()
	health -= int(in_damage)
	SignalBus.on_health_action_changed.emit(health, max_health)
	if health <= 0:
		die()

@rpc("call_local")
func blink():
	$hit_animation_player.play('hit')

func _on_hit_entered(body):
	if 'implements' in body and body.implements.has(I.Killable):
		body.take_damage(attack, player_id)

@rpc("any_peer", "call_local")
func on_spawned():
	PlayerData.action_player = self
