extends Control

@export var background:            TextureRect

@export var play_btn:              ButtonCustom
@export var settings_btn:          ButtonCustom
@export var exit_btn:              ButtonCustom

@export var menu:                  Control
@export var settings_menu:         Control

@onready var sub_menus:            Array[Control] = [menu, settings_menu]

@onready var start_pos:            Vector2 = background.position + get_viewport_rect().size / 2
@onready var min_pos:              Vector2 = Vector2.ZERO
@onready var max_pos:              Vector2 = get_viewport_rect().size - background.size

func _process(delta):
	var dest = start_pos - get_local_mouse_position()
	var pos: Vector2 = Vector2(clamp(dest.x, max_pos.x, min_pos.x), clamp(dest.y, max_pos.y, min_pos.y))
	background.position = lerp(background.position, pos, delta)

func _ready():
	play_btn.pressed.connect(_on_play_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	exit_btn.pressed.connect(get_tree().quit)
	SignalBus.on_close_settings.connect(_show_menu)
	SignalBus.on_back_to_main_menu.connect(_show_menu)
	_show_menu()

func _exit_tree():
	play_btn.pressed.disconnect(_on_play_pressed)
	settings_btn.pressed.disconnect(_on_settings_pressed)
	exit_btn.pressed.disconnect(get_tree().quit)
	SignalBus.on_close_settings.disconnect(_show_menu)
	SignalBus.on_back_to_main_menu.disconnect(_show_menu)

func _on_play_pressed():
	SignalBus.on_start_game.emit()

func hide_all():
	for sub_menu in sub_menus:
		sub_menu.hide()

func _on_settings_pressed():
	hide_all()
	settings_menu.show()

func _show_menu():
	hide_all()
	menu.show()
