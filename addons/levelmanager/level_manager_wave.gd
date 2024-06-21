extends HBoxContainer

@onready var troop_ps: PackedScene = preload("res://addons/levelmanager/troop.tscn")
var level_manager = null
var troop_count = 0

@export var label: Label
@export var troop_container: HBoxContainer

func _add_troop():
	troop_count += 1
	var troop = troop_ps.instantiate()
	troop.name = "troop_" + str(troop_count)
	troop.init(troop_count, level_manager)
	troop_container.add_child(troop)

func init(in_count: int, in_manager: Node):
	level_manager = in_manager
	label.text = "Wave " + str(in_count)