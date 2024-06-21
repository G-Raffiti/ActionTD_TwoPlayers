extends Resource
class_name TowerStats

@export_category("Tower Stats")
@export var attack_range: int           = 3
@export var attack_speed: float         = 1.0
@export var projectile_count: int       = 1
@export var spread_angle: float         = 0.0
@export var projectile_deleay: float       = 0
@export var sequence_total_angle: int   = 0

@export_category("Projectile Stats")
@export var projectile_damage: float    = 5.0
@export var projectile_speed: float     = 2.0
@export var explosion_radius: float     = 0.0
@export var pierce: int                 = 0
@export var bounce: int                 = 0
@export var homing: bool                = false

class ProjectileStats:
    var damage: float
    var speed: float
    var lifetime: float
    var explosion_radius: float
    var pierce: int
    var bounce: int
    var homing: bool

    func should_end() -> bool:
        return pierce <= 0 and bounce <= 0

func get_projectile_stats() -> ProjectileStats:
    var stats = ProjectileStats.new()
    stats.damage = projectile_damage
    stats.speed = projectile_speed * Data.TILE_SIZE
    stats.lifetime = attack_range / projectile_speed
    stats.explosion_radius = explosion_radius
    stats.pierce = pierce
    stats.bounce = bounce
    stats.homing = homing
    return stats