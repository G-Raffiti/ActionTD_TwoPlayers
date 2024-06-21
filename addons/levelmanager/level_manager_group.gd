extends HBoxContainer

var level_manager = null

@export var amount_input: SpinBox
@export var type_input: OptionButton

func init(in_count: int, in_manager: Node):
	level_manager = in_manager
	var index = 0
	for type in level_manager.get_mob_types():
		type_input.add_icon_item(type.icon, type.name, index)
