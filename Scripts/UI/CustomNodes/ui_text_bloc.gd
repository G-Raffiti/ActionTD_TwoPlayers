@tool
extends Control
class_name TextBox

@export_multiline var text: String = "Text":
	set(value):
		text = value
		for i in range(0, len(icons)):
			value = value.replace("_" + icons[i].resource_path.get_basename().get_file() + "_", "[img=" + str(font_size) + "]" + icons[i].resource_path + "[/img]")
		if get_child_count() <= 0 : return
		$ScaleBox/Margin/Label.text = value
		update_size()

@export var font_size: int = 70:
	set(value):
		font_size = value
		if get_child_count() <= 0 : return
		$ScaleBox/Margin/Label.set('theme_override_font_sizes/normal_font_size', font_size)
		$ScaleBox/Margin/Label.set('theme_override_constants/outline_size', int(font_size / 10.0))
		$ScaleBox/Margin/Label.set('theme_override_constants/shadow_offset_x', int(font_size / 19.0))
		$ScaleBox/Margin/Label.set('theme_override_constants/shadow_offset_y', int(font_size / 19.0))
		$ScaleBox.set_deferred('min_size', Vector2(font_size + box_margin.x * 2, font_size + box_margin.y * 2))
		update_size()

@export_group('Advanced/Font')
@export var font_color: Color = Color(1, 1, 1, 1):
	set(value):
		font_color = value
		if get_child_count() <= 0 : return
		$ScaleBox/Margin/Label.set('theme_override_colors/default_color', font_color)

@export var horizontal_align: Control.SizeFlags = Control.SIZE_SHRINK_CENTER:
	set(value):
		horizontal_align = value
		if get_child_count() <= 0 : return
		$ScaleBox/Margin/Label.set('size_flags_horizontal', value)

@export var vertical_align: Control.SizeFlags = Control.SIZE_SHRINK_CENTER:
	set(value):
		vertical_align = value
		if get_child_count() <= 0 : return
		$ScaleBox/Margin/Label.set('size_flags_vertical', value)

@export_group('Advanced/Background')
@export var box_background: Texture2D = null:
	set(value):
		box_background = value
		if get_child_count() <= 0 : return
		$ScaleBox/NinePatchRect.texture = value
		update_size()

@export var box_margin: Vector2 = Vector2(0, 0):
	set(value):
		box_margin = value
		if get_child_count() <= 0 : return
		$ScaleBox/Margin.set('theme_override_constants/margin_left', value.x)
		$ScaleBox/Margin.set('theme_override_constants/margin_right', value.x)
		$ScaleBox/Margin.set('theme_override_constants/margin_top', value.y)
		$ScaleBox/Margin.set('theme_override_constants/margin_bottom', value.y)
		$ScaleBox/NinePatchRect.patch_margin_left = value.x
		$ScaleBox/NinePatchRect.patch_margin_right = value.x
		$ScaleBox/NinePatchRect.patch_margin_top = value.y
		$ScaleBox/NinePatchRect.patch_margin_bottom = value.y
		$ScaleBox.min_size = Vector2(font_size + box_margin.x * 2, font_size + box_margin.y * 2)
		update_size()

@export_group('Advanced/Size')
@export var scale_minimum: float = 1.0:
	set(value):
		scale_minimum = value
		if get_child_count() <= 0 : return
		$ScaleBox.base_scale = Vector2(scale_minimum, scale_minimum)
		update_size()

@export var size_to_content: bool = false:
	set(value):
		size_to_content = value
		if get_child_count() <= 0 : return
		update_size()

@export_group('Advanced/Icons')
var icon_map = {}
@export var icons: Array[Texture2D] = []:
	set(value):
		icons = value
		icon_map = {}
		for i in range(0, len(icons)):
			icon_map[icons[i].resource_path.get_basename().get_file()] = icons[i].resource_path

func update_size():
	if layout_mode == 2:
		custom_minimum_size = size
		call_deferred('resize_size')
	else:
		resize_size()
	
func resize_size():
	custom_minimum_size = Vector2.ZERO
	$ScaleBox.position = Vector2.ZERO
	if size_to_content:
		set_size(Vector2(0, 0))
		custom_minimum_size = size
	else:
		$ScaleBox._scale_content()

func _ready():
	if layout_mode == 2:
		custom_minimum_size = size
		call_deferred('update_size')
