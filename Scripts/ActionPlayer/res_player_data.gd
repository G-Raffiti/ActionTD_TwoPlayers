extends Resource
class_name PlayerStats

@export_category("Player settings")
@export var max_health : int = 10
@export var attack : float = 1
@export var max_air_jump : int = 1
@export var levels_data : Array[PlayerLevelData]
@export var speed : float
@export var distance_attack_range: float = 1
@export var distance_attack_cooldown: float = 1
@export var projectile_ps: PackedScene
@export var projectile_stats: ProjectileStats
