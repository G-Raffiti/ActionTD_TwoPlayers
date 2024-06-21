extends Resource
class_name MobStats

@export var max_hp: int
@export var damage: int
@export var speed: float
@export var acceleration: float

var hp: float

func mult(value: float) -> void:
    max_hp = int(max_hp * value)
    damage = int(damage * value)
    speed = speed * max(1.0, value / 5.0)
    acceleration = acceleration * value

func init_stats(factor: float) -> void:
    mult(factor)
    hp = max_hp