extends Control

var wave_count = 0

@onready var wave_ps: PackedScene = preload("res://addons/levelmanager/wave.tscn")
@export var wave_container: Control
@export var types: Array[MobRes]

func _add_wave():
	wave_count += 1
	var wave = wave_ps.instantiate()
	wave.name = "wave_" + str(wave_count)
	wave.init(wave_count, self)
	wave_container.add_child(wave)

func get_mob_types():
	return types
