extends CharacterBody3D
class_name Mob

var implements = [I.Killable]

var stats: MobStats = null
var target: PathFollow3D = null
var is_diying: bool = false
var action_player : Player
var start :bool = false


func die(_damage_dealer_id = -1) -> void:
	is_diying = true
	SignalBus.on_mob_killed.emit(stats.gold_value, stats.experience_value, _damage_dealer_id)
	queue_free()

func start_move() -> void:
	pass

