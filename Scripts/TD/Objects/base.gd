extends Node3D

var implements = [I.Killable]

@export var hp_max: int = 10
@onready var hp: float = hp_max
@onready var hp_3d_label: Label3D = $UI_HPValue

@export var full_hp_color: Color = Color(0, 1, 0)
@export var low_hp_color: Color = Color(1, 0, 0)

var is_diying: bool = false

func _ready() -> void:
	SignalBus.on_mob_reached_end.connect(take_damage)
	hp_3d_label.text = str(hp) + '/' + str(hp_max)
	hp_3d_label.modulate = full_hp_color

func take_damage(damage : float, _damage_dealer_id = -1) -> void:
	if is_diying:
		return
	hp -= damage
	hp_3d_label.text = str(hp) + '/' + str(hp_max)
	hp_3d_label.modulate = low_hp_color.lerp(full_hp_color, hp / float(hp_max))
	if hp <= 0:
		die()

func die(_damage_dealer_id = -1) -> void:
	is_diying = true
	SignalBus.on_game_over_loose.emit()

	#debug
	SignalBus.on_reload_scene.emit()



func _on_area_3d_body_entered(body):
	print(body)
	if body is Mob:
		take_damage(body.stats.attack_damage)
		body.die()
