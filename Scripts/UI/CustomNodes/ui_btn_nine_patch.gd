@tool
extends Control
class_name ButtonCustom

signal pressed()
@onready var button: Button = $ScaleBox/Button

@export_category('Button Textures')
@export var normal: Texture2D = null:
	set(value):
		normal = value
		if get_child_count() <= 0 : return
		$ScaleBox/NinePatchRect.texture = normal
@export var hover: Texture2D = null
@export var clicked: Texture2D = null
@export var disabled: bool = false:
	set(value):
		disabled = value
		if get_child_count() <= 0 : return
		$ScaleBox/Button.disabled = disabled
		$ScaleBox/NinePatchRect.self_modulate = Color(0.5, 0.5, 0.5, 1.0) if disabled else Color(1.0, 1.0, 1.0, 1.0)
		$ScaleBox/Margin/Content.modulate = Color(0.7, 0.7, 0.7, 0.5) if disabled else Color(1.0, 1.0, 1.0, 1.0)
@export var toggle_mode: bool = false:
	set(value):
		toggle_mode = value
		if get_child_count() <= 0 : return
		$ScaleBox/Button.toggle_mode = toggle_mode

@export_category('Content')
@export var text: String = '':
	set(value):
		text = value
		if get_child_count() <= 0 : return
		$ScaleBox/Margin/Content/Label.text = text
		update_size()

@export var font_size: int = 70:
	set(value):
		font_size = value
		if get_child_count() <= 0 : return
		$ScaleBox/Margin/Content/Label.set('theme_override_font_sizes/font_size', font_size)
		$ScaleBox/Margin/Content/Label.set('theme_override_constants/outline_size', int(font_size / 10.0))
		$ScaleBox/Margin/Content/Label.set('theme_override_constants/shadow_offset_x', int(font_size / 19.0))
		$ScaleBox/Margin/Content/Label.set('theme_override_constants/shadow_offset_y', int(font_size / 19.0))
		$ScaleBox/Margin/Content/IconLeft.custom_minimum_size = Vector2(font_size + 20, font_size + 20)
		$ScaleBox/Margin/Content/IconRight.custom_minimum_size = Vector2(font_size + 20, font_size + 20)
		update_size()

@export var icon: Texture2D = null:
	set(value):
		icon = value
		if get_child_count() <= 0 : return
		$ScaleBox/Margin/Content/IconLeft.texture = icon
		$ScaleBox/Margin/Content/IconRight.texture = icon
		update_size()

enum IconAlignment { NONE, LEFT, RIGHT, BOTH }
@export var icon_alignment: IconAlignment = IconAlignment.LEFT:
	set(value):
		icon_alignment = value
		if get_child_count() <= 0 : return
		if icon_alignment == IconAlignment.NONE:
			$ScaleBox/Margin/Content/IconLeft.visible = false
			$ScaleBox/Margin/Content/IconRight.visible = false
			update_size()
			return
		$ScaleBox/Margin/Content/IconLeft.visible = icon_alignment != IconAlignment.RIGHT
		$ScaleBox/Margin/Content/IconRight.visible = icon_alignment != IconAlignment.LEFT
		$ScaleBox/Margin/Content/IconRight.flip_h = icon_alignment == IconAlignment.BOTH
		update_size()

@export_category('Scale')
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

func update_size():
	custom_minimum_size = Vector2.ZERO
	if size_to_content:
		set_size(Vector2(0, 0))
		custom_minimum_size = size
	else:
		$ScaleBox._scale_content()

var is_button_down : bool = false
var is_hovered : bool = false
var button_pressed : bool: 
	get: return $ScaleBox/Button.button_pressed

func _ready():
	if layout_mode == 2:
		custom_minimum_size = size
		call_deferred('update_size')
	button.mouse_exited.connect(func(): 
		is_hovered = false
		if toggle_mode and button_pressed: return
		$ScaleBox/NinePatchRect.texture = normal
		if is_button_down:
			is_button_down = false
			$ScaleBox/Margin/Content.position.y -= int(font_size / 10.0)
	)
	button.mouse_entered.connect(func(): 
		is_hovered = true
		if toggle_mode and button_pressed: return
		$ScaleBox/NinePatchRect.texture = hover
	)
	button.button_down.connect(func():
		if is_button_down: return
		is_button_down = true
		$ScaleBox/NinePatchRect.texture = clicked
		$ScaleBox/Margin/Content.position.y += int(font_size / 10.0)
	)
	button.button_up.connect(func():
		if not is_button_down: return
		if is_hovered:
			$ScaleBox/NinePatchRect.texture = hover
		else:
			$ScaleBox/NinePatchRect.texture = normal
		$ScaleBox/Margin/Content.position.y -= int(font_size / 10.0)
		is_button_down = false
	)
	button.pressed.connect(func(): pressed.emit())

func _exit_tree():
	if Engine.is_editor_hint(): return
	SignalBus.clear(button.mouse_exited)
	SignalBus.clear(button.mouse_entered)
	SignalBus.clear(button.button_down)
	SignalBus.clear(button.button_up)
	SignalBus.clear(button.pressed)
	SignalBus.clear(pressed)
