extends Resource
class_name MobStats

@export var max_hp: int
@export var damage: int
@export var speed: float
@export var acceleration: float
@export var detection_radius: float
@export var max_distance_from_path: float
@export var attack_radius: float
@export var attack_damage: float
@export var attack_speed: float
@export var gold_value: int = 0
@export var experience_value: int = 0

var hp: float

func mult(value: float) -> void:
	max_hp = int(max_hp * value)
	damage = int(damage * value)
	speed = speed * max(1.0, value / 5.0)
	acceleration = acceleration * value
	detection_radius = detection_radius * value
	attack_radius = attack_radius * value
	attack_damage = attack_damage * value
	attack_speed = attack_speed * value

func init_stats(factor: float) -> void:
	mult(factor)
	hp = max_hp
