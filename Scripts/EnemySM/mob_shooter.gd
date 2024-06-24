extends Mob

var last_nav_position :Vector3 = Vector3.ZERO

@onready var timer: Timer = $Timer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

@onready var state_machine: FiniteStateMachine = $FiniteStateMachine
@onready var state_idle: StateMachineState = $Idle
@onready var state_follow_path: StateMachineState = $FollowPath
@onready var state_follow_target: StateMachineState = $FollowTarget
@onready var state_return_to_path: StateMachineState = $ReturnToPath

@export var fire_point: Node3D

func _physics_process(delta: float) -> void:
	if is_diying: return
	if target == null: return
	if action_player == null or action_player.is_dying: return
	
	state_machine.current_state.on_physics_process(delta)
	
	var distance_to_player :float
	var distance_to_path :float
	if action_player != null and !action_player.is_dying:
		distance_to_player = global_position.distance_to(action_player.global_position)
	
	distance_to_path = global_position.distance_to(last_nav_position)
	
	if state_return_to_path.is_current_state():
		if distance_to_path < 0.1:
			state_machine.set_current_state(state_follow_path)
		elif distance_to_player < stats.detection_radius:
			state_machine.set_current_state(state_follow_target)
	elif state_follow_target.is_current_state():
		if distance_to_path > stats.max_distance_from_path or distance_to_player > stats.detection_radius:
			state_machine.set_current_state(state_return_to_path)
	elif state_follow_path.is_current_state():
		if distance_to_player < stats.detection_radius:
			state_machine.set_current_state(state_follow_target)
	
	if distance_to_player < stats.detection_radius:
		if distance_to_player < stats.attack_radius and timer.time_left <= 0:
			attack(action_player)

	if target.progress_ratio >= 1.0 and nav_agent.is_navigation_finished():
		SignalBus.on_mob_reached_end.emit(stats.damage)
		queue_free()
		
func attack(player : Player) :
	shoot(player)
	timer.wait_time = stats.attack_speed
	timer.start()
	
	
func shoot(player : Player):
	if not multiplayer.is_server(): return
	randomize()
	
	var projectile: Projectile = stats.projectile_ps.instantiate()
	projectile.name = "Projectile" + Guid.get_id()
	var direction = fire_point.global_position.direction_to(player.position)
	add_child(projectile)
	projectile.global_position = fire_point.global_position
	projectile.global_rotation = fire_point.global_rotation
	projectile.initialize(stats.projectile_stats, stats.attack_radius, player, direction)
	projectile.start()
	#animation_player.play('shoot')

func die(_damage_dealer_id = -1) -> void:
	is_diying = true
	SignalBus.on_mob_killed.emit(stats.gold_value, stats.experience_value, _damage_dealer_id)
	queue_free()

func take_damage(in_damage: float, _damage_dealer_id = -1) -> void:
	if is_diying:
		return
	stats.hp -= in_damage
	take_hit.rpc()
	if stats.hp <= 0:
		die(_damage_dealer_id)

@rpc("call_local")
func take_hit():
	animation_player.play("hit")

func get_path_travelled() -> float:
	return target.progress_ratio

func get_health() -> float:
	return stats.hp

func _ready() -> void:
	if not multiplayer.is_server():
		set_process(false)
		set_physics_process(false)
		return
		
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	
	action_player = PlayerData.action_player
	
	state_machine.set_current_state(state_follow_path)

func set_action_player(player : Player):
	action_player = player

func _on_velocity_computed(in_velocity: Vector3) -> void:
	velocity = in_velocity
