extends CharacterBody3D
class_name Mob

var implements = [I.Killable]

var stats: MobStats = null
var target: PathFollow3D = null
var is_diying: bool = false
var gold_value: int = 0
var action_player : Player

@onready var timer: Timer = $Timer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _physics_process(delta: float) -> void:
	if is_diying: return
	if target == null: return
	
	var direction: Vector3
	
	var distance_to_player = 10000
	if action_player != null and !action_player.is_dying:
		distance_to_player = global_position.distance_to(Vector3(action_player.global_position.x, global_position.y, action_player.global_position.z))
		
	if distance_to_player < stats.detection_radius:
		nav_agent.target_position = action_player.global_position
		if distance_to_player < stats.attack_radius and timer.time_left <= 0:
			attack(action_player)
	
	elif nav_agent.is_navigation_finished() || nav_agent.avoidance_enabled == true:
		nav_agent.target_position = target.global_position

	direction = global_position.direction_to(nav_agent.get_next_path_position())
	var new_velocity = velocity.lerp(direction * stats.speed, delta * stats.acceleration)

	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity_forced(new_velocity)
	else:
		velocity = new_velocity

	move_and_slide()

	if target.progress_ratio >= 1.0 and nav_agent.is_navigation_finished():
		SignalBus.on_mob_reached_end.emit(stats.damage)
		queue_free()
		
func attack(player : Player) :
	player.take_damage(stats.attack_damage)	
	timer.wait_time = stats.attack_speed
	timer.start()

func die() -> void:
	is_diying = true
	SignalBus.on_mob_killed.emit(gold_value)
	queue_free()

func take_damage(in_damage: float) -> void:
	if is_diying:
		return
	animation_player.play("hit")
	stats.hp -= in_damage
	if stats.hp <= 0:
		die()

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
