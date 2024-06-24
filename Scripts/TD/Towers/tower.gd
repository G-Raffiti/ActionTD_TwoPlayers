extends Node3D
class_name Tower

var implements = [I.Killable]

enum targeting { FIRST, LAST, CLOSEST, STRONGEST }

@onready var mesh_tower: MeshInstance3D = $Mesh
@onready var construction: MeshInstance3D = $Construction
@onready var construction2: MeshInstance3D = $Construction2
@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_range: Area3D = $AttackRange

@export var fire_point: Node3D
@export var rotating_part: Node3D

var data: TowerRes
var stats: TowerStats
var unit_in_range: Array[Node3D] = []
var target: Node3D
var target_type: targeting = targeting.FIRST
var loaded: bool = false

func build_tower(in_tower_res: TowerRes):
	print(str(multiplayer.get_unique_id(), 'Tower ready'))
	data = in_tower_res
	stats = data.tower_stats.duplicate(true)
	attack_range.get_node('CollisionShape3D').shape.radius = stats.attack_range * Data.TILE_SIZE
	var t: Tween = create_tween()
	t.finished.connect(on_build_tower_finished)
	t.tween_property(mesh_tower, 'position', Vector3(0, 0, 0), 2.0)
	var t2: Tween = create_tween()
	t2.tween_property(construction, 'position', Vector3(0, 0, 0), 0.5)
	t2.tween_property(construction2, 'position', Vector3(0, 0, 0), 0.7)

func _ready() -> void:
	if not multiplayer.is_server(): return
	attack_range.body_entered.connect(_on_unit_enter_range)
	attack_range.body_exited.connect(_on_unit_exit_range)

func on_build_tower_finished():
	construction.queue_free()
	construction2.queue_free()
	timer.wait_time = 1.0 / stats.attack_speed
	timer.start()
	timer.timeout.connect(shoot)

func _on_unit_enter_range(unit: Node3D) -> void:
	if not multiplayer.is_server(): return
	if unit.is_in_group('Enemy'):
		unit_in_range.append(unit)

func _on_unit_exit_range(unit: Node3D) -> void:
	if not multiplayer.is_server(): return
	if target == unit:
		target = null
	unit_in_range.erase(unit)

func shoot():
	if not multiplayer.is_server(): return
	randomize()
	if target == null:
		return
	animation_player.animation_finished.connect(_reload)
	for i in data.tower_stats.projectile_count:
		var projectile: Projectile = data.projectile_ps.instantiate()
		projectile.name = "Projectile" + Guid.get_id()
		var direction = fire_point.global_position.direction_to(target.global_position)
		var angle = randf_range(-stats.spread_angle / 2.0, stats.spread_angle / 2.0) + (-stats.sequence_total_angle / 2.0) + (i * stats.sequence_total_angle / float(stats.projectile_count))
		direction = direction.rotated(Vector3.UP, deg_to_rad(angle))
		add_child(projectile)
		projectile.global_position = fire_point.global_position
		projectile.global_rotation = fire_point.global_rotation
		projectile.rotate(Vector3.UP, angle)
		projectile.initialize(stats.projectile_stats, stats.attack_range, target, direction)
		projectile.start()
		animation_player.play('shoot')
		await get_tree().create_timer(stats.projectile_deleay).timeout	
		if target == null:
			return
	loaded = false

func _physics_process(_delta: float) -> void:
	if not multiplayer.is_server(): return
	target = find_new_target()
	if target != null:
		rotating_part.look_at(target.global_position)
		# rotating_part.global_rotation.y = lerp_angle(rotating_part.global_rotation.y, target.global_position.angle_to(rotating_part.global_position), _delta * 10)

func _reload(_param):
	if not multiplayer.is_server(): return
	animation_player.animation_finished.disconnect(_reload)
	if not loaded:
		animation_player.play('load')
		loaded = true

func find_new_target() -> Node3D:
	if not multiplayer.is_server(): 
		return null
	if unit_in_range.size() == 0:
		return null
	match target_type:
		targeting.FIRST:
			return find_first_target()
		targeting.LAST:
			return find_last_target()
		targeting.CLOSEST:
			return find_closest_target()
		targeting.STRONGEST:
			return find_strongest_target()
		_:
			return null

func find_first_target() -> Node3D:
	if not multiplayer.is_server(): 
		return null
	var score: float = -1.0
	var new_target: Node3D = unit_in_range[0]
	for unit in unit_in_range:
		if unit == null:
			continue
		if unit.get_path_travelled() > score:
			score = unit.get_path_travelled()
			new_target = unit
	return new_target

func find_last_target() -> Node3D:
	if not multiplayer.is_server(): 
		return null
	var score: float = 0.0
	var new_target: Node3D = unit_in_range[0]
	for unit in unit_in_range:
		if unit == null:
			continue
		if unit.get_path_travelled() < score:
			score = unit.get_path_travelled()
			new_target = unit
	return new_target

func find_closest_target() -> Node3D:
	if not multiplayer.is_server(): 
		return null
	var score: float = unit_in_range[0].global_transform.origin.distance_squared_to(global_transform.origin)
	var new_target: Node3D = unit_in_range[0]
	for unit in unit_in_range:
		if unit == null:
			continue
		var dist = unit.global_transform.origin.distance_squared_to(global_transform.origin)
		if dist < score:
			score = dist
			new_target = unit
	return new_target

func find_strongest_target() -> Node3D:
	if not multiplayer.is_server(): 
		return null
	var score: float = unit_in_range[0].get_health()
	var new_target: Node3D = unit_in_range[0]
	for unit in unit_in_range:
		if unit == null:
			continue
		if unit.get_health() > score:
			score = unit.get_health()
			new_target = unit
	return new_target

func die(_damage_dealer_id = -1):
	pass

func take_damage(_damage, _damage_dealer_id = -1):
	pass
