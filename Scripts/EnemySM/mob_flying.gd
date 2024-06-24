extends Mob


@onready var timer: Timer = $Timer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

@onready var state_machine: FiniteStateMachine = $FiniteStateMachine
@onready var state_idle: StateMachineState = $Idle
@onready var state_straight_to_target: StateMachineState = $StraightToTarget

func _physics_process(delta: float) -> void:
	if is_diying: return
	if target == null: return
	
	state_machine.current_state.on_physics_process(delta)

	if target.progress_ratio >= 1.0 and nav_agent.is_navigation_finished():
		SignalBus.on_mob_reached_end.emit(stats.damage)
		queue_free()
		
func attack(player : Player) :
	player.take_damage(stats.attack_damage)
	timer.wait_time = stats.attack_speed
	timer.start()

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
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	
	action_player = PlayerData.action_player
	
	state_machine.set_current_state(state_straight_to_target)

func set_action_player(player : Player):
	action_player = player

func _on_velocity_computed(in_velocity: Vector3) -> void:
	velocity = in_velocity
