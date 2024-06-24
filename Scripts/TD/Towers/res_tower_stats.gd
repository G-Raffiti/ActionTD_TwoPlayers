extends Resource
class_name TowerStats

@export_category("Tower Stats")
@export var attack_range: int           = 3
@export var attack_speed: float         = 1.0
@export var projectile_count: int       = 1
@export var spread_angle: float         = 0.0
@export var projectile_deleay: float       = 0
@export var sequence_total_angle: int   = 0
@export var projectile_stats: ProjectileStats = null
@export var hp: int
