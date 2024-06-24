extends Resource
class_name ProjectileStats

@export var damage: float    = 5.0
@export var speed: float     = 2.0
@export var lifetime : float = 10.0
@export var explosion_radius: float = 0.0
@export var pierce: int = 0
@export var bounce: int = 0
@export var homing: bool = false

func should_end() -> bool:
	return pierce <= 0 and bounce <= 0
