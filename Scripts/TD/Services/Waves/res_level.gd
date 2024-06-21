extends Resource
class_name LevelRes

@export var waves: Array[WaveRes] = []
@export var total_duration: float

@export var spawn_interval: Curve
@export var gold_curve: Curve
@export var enemy_stats_curve: Curve

func get_total_enemy_count() -> int:
	var total = 0
	for wave in waves:
		for troop in wave.troops:
			for group in troop.groups:
				total += group.amount
	return total

func get_spawn_interval(time: float) -> float:
	return spawn_interval.sample(time / total_duration)

func get_enemy_stat_multiplier(time: float) -> float:
	return enemy_stats_curve.sample(time / total_duration)

func get_gold_value(time: float) -> int:
	return int(gold_curve.sample(time / total_duration))

