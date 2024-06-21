@tool
extends PanelContainer
class_name ScaleBox

@export var min_size: Vector2 = Vector2.ZERO : 
	set(value):
		min_size = value
		_scale_content()
@export var base_scale: Vector2 = Vector2.ONE:
	set(value):
		if value.x == 0 or value.y == 0:
			return
		base_scale = value
		scale = base_scale
		_scale_content()

func _ready():
	if get_parent() == null:
		return
	get_parent().resized.connect(_scale_content)

func _scale_content():
	if get_parent() == null:
		return
	size = get_parent().get_rect().size / base_scale
	if get_parent().get_rect().size.x < min_size.x or get_parent().get_rect().size.y < min_size.y:
		get_parent().set_size(size * base_scale)

