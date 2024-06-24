extends Area3D
class_name Projectile

@onready var explosion_area: Area3D = $ExplosionArea

var stats: TowerStats.ProjectileStats
var target: Node3D = null

var old_targets: Array[StringName] = []

var direction: Vector3

func initialize(in_stats: TowerStats.ProjectileStats, in_target: Node3D, in_direction: Vector3) -> void:
	if not multiplayer.is_server(): return
	stats = in_stats
	change_target(in_target)
	$ExplosionArea/ExplosionCollisionShape.shape.radius = stats.explosion_radius
	direction = in_direction

func change_target(in_target: Node3D):
	if not multiplayer.is_server(): return
	target = in_target
	target.tree_exiting.connect(_on_target_destroyed)
	old_targets.append(target.name)

func start():
	if not multiplayer.is_server(): return
	get_tree().create_timer(stats.lifetime).timeout.connect(_lifetime_expire)
	set_physics_process(true)
	body_entered.connect(_body_entered)

func _physics_process(delta: float) -> void:
	if not multiplayer.is_server(): return
	if stats.homing and target:
		direction = global_position.direction_to(target.global_position)

	global_position += direction * stats.speed * delta
	look_at(global_position + direction, Vector3.ONE)

func _on_new_target_found(projectile_name: StringName, new_target: Node3D) -> void:
	if not multiplayer.is_server(): return
	if name != projectile_name:
		return
	SignalBus.on_nearest_target_found.disconnect(_on_new_target_found)
	target = new_target
	if target == null:
		if old_targets.size() == 0:
			queue_free()
			return
		else:
			old_targets = [old_targets[-1]]
			explode()
			return
	change_target(new_target)
	direction = global_position.direction_to(target.global_position)

func _body_entered(body: Node3D):
	if not multiplayer.is_server(): return
	if 'implements' in body and body.implements.has(I.Killable):
		if stats.explosion_radius <= 0:
			body.take_damage(stats.damage, 1)
		explode()

func _lifetime_expire():
	if not multiplayer.is_server(): return
	explode()
	queue_free()

func explode():
	if not multiplayer.is_server(): return
	if stats.explosion_radius > 0:
		for node in explosion_area.get_overlapping_areas():
			if 'implements' in node and node.implements.has(I.Killable):
				node.take_damage(stats.damage, 1)
	if stats.should_end():
		queue_free()
	if stats.pierce > 0:
		stats.pierce -= 1
		if stats.homing:
			find_new_target()
		return
	if stats.bounce > 0:
		stats.bounce -= 1
		find_new_target()

func find_new_target():
	if not multiplayer.is_server(): return
	if is_instance_valid(target):
		target.tree_exiting.disconnect(_on_target_destroyed)
	target = null
	if not SignalBus.on_nearest_target_found.is_connected(_on_new_target_found):
		SignalBus.on_nearest_target_found.connect(_on_new_target_found)
		SignalBus.on_projectile_search_target.emit(name, old_targets, position)

func _on_target_destroyed() -> void:
	if not multiplayer.is_server(): return
	target = null
	if stats.homing:
		find_new_target()
