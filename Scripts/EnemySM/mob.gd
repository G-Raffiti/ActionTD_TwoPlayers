extends CharacterBody3D
class_name Mob

var implements = [I.Killable]

var stats: MobStats = null
var target: PathFollow3D = null
var is_diying: bool = false
var action_player : Player

func _ready() -> void:
	if not multiplayer.is_server():
		set_process(false)
		set_physics_process(false)
		return

func set_action_player(player : Player):
	action_player = player

func start_move() -> void:
	pass

