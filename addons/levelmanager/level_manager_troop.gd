extends VBoxContainer

@onready var group_ps: PackedScene = preload("res://addons/levelmanager/group.tscn")
var level_manager = null
var group_count = 0

@export var label: Label
@export var group_container: VBoxContainer

func _add_group():
	group_count += 1
	var group = group_ps.instantiate()
	group.name = "group_" + str(group_count)
	group.init(group_count, level_manager)
	group_container.add_child(group)

func init(in_count: int, in_manager: Node):
	level_manager = in_manager
	label.text = "Troop " + str(in_count)
