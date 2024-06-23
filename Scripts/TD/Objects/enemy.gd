extends CharacterBody3D
#class_name Mob

var implements = [I.Killable]

var stats: MobStats = null
var target: PathFollow3D = null
var is_diying: bool = false
var action_player : Player

@onready var timer: Timer = $Timer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var state_machine: FiniteStateMachine = $FiniteStateMachine
@onready var state_follow_path: StateMachineState = $FollowPath
@onready var state_idle: StateMachineState = $Idle

func _physics_process(delta: float) -> void:
	if is_diying: return
	if target == null: return
	
	var distance_to_player = 10000
	if action_player != null and !action_player.is_dying:
		distance_to_player = global_position.distance_to(Vector3(action_player.global_position.x, global_position.y, action_player.global_position.z))
		
		if distance_to_player < stats.detection_radius:
			state_machine.set_current_state(state_idle)
			nav_agent.target_position = action_player.global_position
			if distance_to_player < stats.attack_radius and timer.time_left <= 0:
				attack(action_player)

	state_machine.current_state.on_physics_process(delta)

	if target.progress_ratio >= 1.0 and nav_agent.is_navigation_finished():
		SignalBus.on_mob_reached_end.emit(stats.damage)
		queue_free()
		
func attack(player : Player) :
	player.take_damage(stats.attack_damage)
	timer.wait_time = stats.attack_speed
	timer.start()

func die(_damage_dealer_id = -1) -> void:
	is_diying = true
	SignalBus.on_mob_killed.emit(stats.gold_value, stats.experience_value, _damage_dealer_id)
	queue_free()

func take_damage(in_damage: float, _damage_dealer_id = -1) -> void:
	if is_diying:
		return
	animation_player.play("hit")
	stats.hp -= in_damage
	if stats.hp <= 0:
		die(_damage_dealer_id)

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

func start_move() -> void:
	var direction: Vector3
	nav_agent.target_position = target.global_position

	direction = global_position.direction_to(nav_agent.get_next_path_position())
	var new_velocity = direction * stats.speed

	nav_agent.set_velocity_forced(new_velocity)
	
	timer.wait_time = stats.attack_speed
	timer.start()
	timer.timeout.connect(timer.stop)

func _on_velocity_computed(in_velocity: Vector3) -> void:
	velocity = in_velocity
