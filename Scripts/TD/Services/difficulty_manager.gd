extends Node
class_name DifficultyManager

@export var game_length: float = 5.0 * 60.0
@export var spawn_interval_curve: Curve
@export var enemy_stat_curve: Curve
@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start(game_length)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func game_progress() -> float:
	return 1.0 - timer.time_left / game_length

func get_spawn_interval() -> float:
	return spawn_interval_curve.sample(game_progress())

func get_enemy_stat_multiplier() -> float:
	return enemy_stat_curve.sample(game_progress())

