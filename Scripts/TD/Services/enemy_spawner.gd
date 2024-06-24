extends Node

@onready var mob_group_ps: PackedScene = Data.mob_group_ps

@export_category('dependencies')
@export var path: Array[Path3D]
@export var level: LevelRes

var action_player: Player

var interval: float = 1.0
var time = 0.0
var game_started = false

var wave_index: int = 0
var troop_index: int = 0
var group_index: int = 0
var mob_group: MobGroup = null
var group_stat_multi: float = 1.0
var group_gold_value: int = 1

var mob_spawned: int = 0
var level_done: bool = false

var enemies: Array[Node3D] = []

func _ready() -> void:
	if not multiplayer.is_server():
		set_process(false)
		return
	
	SignalBus.on_start_spawning_enemies.connect(func(): game_started = true)
	SignalBus.on_projectile_search_target.connect(_find_nearest_mob_for)

func _process(delta: float) -> void:
	if multiplayer and not multiplayer.is_server():
		return
	if not game_started: return
	if level_done: return

	time += delta

	interval -= delta
	if interval > 0.0: return

	interval = level.get_spawn_interval(time)
	spawn_next_mob_group()
	increase_indexes()
	send_troop_to_battle()

func spawn_next_mob_group() -> void:
	if mob_group == null:
		mob_group = mob_group_ps.instantiate()
		mob_group.name = 'MobGroup' + str(mob_spawned)
		path[level.waves[wave_index].path_index].add_child(mob_group, true)
		group_stat_multi = level.get_enemy_stat_multiplier(time)
		group_gold_value = level.get_gold_value(time)

	var group: MobGroupRes = level.waves[wave_index].troops[troop_index].groups[group_index]
	mob_group.spawn_mobs_group(
		group.type, 
		group.amount,
		group_stat_multi,
		group_gold_value,
		PlayerData.action_player)
	mob_spawned += group.amount

func increase_indexes() -> void:
	group_index += 1
	if group_index >= level.waves[wave_index].troops[troop_index].groups.size():
		group_index = 0
		troop_index += 1
		if troop_index >= level.waves[wave_index].troops.size():
			troop_index = 0
			wave_index += 1
			if wave_index >= level.waves.size():
				wave_index = 0
				level_done = true

func send_troop_to_battle() -> void:
	if mob_group == null: return
	if group_index == 0:
		mob_group.start()
		mob_group = null
		interval = 5 * level.get_spawn_interval(time)

func _on_mob_died() -> void:
	enemies = enemies.filter(func(body): return is_instance_valid(body) and not body.is_diying)

func _find_nearest_mob_for(projectile_name: StringName, old_targets: Array[StringName], proj_position: Vector3) -> void:
	if enemies.size() == 0:
		return
	var target: Node3D = null
	var dist: float = 1000000000.0
	for mob in enemies:
		if not is_instance_valid(mob) or mob.is_diying:
			continue
		if old_targets.has(StringName(mob.name)):
			continue
		var new_dist = proj_position.distance_to(mob.global_position)
		if new_dist < dist:
			dist = new_dist
			target = mob
	SignalBus.on_nearest_target_found.emit(projectile_name, target)

