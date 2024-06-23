extends Menu
class_name SettingsMenu

@export_category('Navigation Buttons')
@export var close_btn:         Button
@export var back_btn:          ButtonCustom

@export_category('sound')
@onready var master_bus_index: int = AudioServer.get_bus_index('Master')
@onready var music_bus_index:  int = AudioServer.get_bus_index('Music')
@onready var sfx_bus_index:    int = AudioServer.get_bus_index('SFX')
@onready var ui_bus_index:     int = AudioServer.get_bus_index('UI')

@export_group('sliders')
@export var master_volume:     HSlider
@export var music_volume:      HSlider
@export var sfx_volume:        HSlider
@export var ui_volume:         HSlider

@export_group('mute buttons')
@export var master_mute:       Button
@export var music_mute:        Button
@export var sfx_mute:          Button
@export var ui_mute:           Button

@export_category('Graphics')
@export var full_screen:       ButtonCustom
@export var vsync_checkbox:    ButtonCustom
@export var resolution_option: OptionButton
@export var screen_selector:   OptionButton
var resolutions: Dictionary = {	"1920x1080":Vector2i(1920,1080),
								"1600x900":Vector2i(1600,900),
								"1536x864":Vector2i(1536,864),
								"1366x768":Vector2i(1366,768),
								"1280x720":Vector2i(1280,720),
								"640x360":Vector2i(640,360),}

@export_category('Save / Load')
@export var reset_save_btn:    ButtonCustom
var reset_save_warning_count:  int = 0

func _ready():
	master_volume.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus_index))
	music_volume.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus_index))
	sfx_volume.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_index))
	ui_volume.value = db_to_linear(AudioServer.get_bus_volume_db(ui_bus_index))
	master_volume.value_changed.connect(_change_master_volume)
	music_volume.value_changed.connect(_change_music_volume)
	sfx_volume.value_changed.connect(_change_fx_volume)
	ui_volume.value_changed.connect(_change_ui_volume)
	full_screen.pressed.connect(_full_screen)
	full_screen.text = "ON" if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN else "OFF"
	full_screen.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	vsync_checkbox.pressed.connect(_vsync)
	vsync_checkbox.text = "ON" if DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED else "OFF"
	vsync_checkbox.button_pressed = DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED
	close_btn.pressed.connect(_close)
	back_btn.pressed.connect(_close)
	reset_save_btn.pressed.connect(_reset_save)
	master_mute.pressed.connect(func(): AudioServer.set_bus_mute(master_bus_index, master_mute.button_pressed))
	music_mute.pressed.connect(func(): AudioServer.set_bus_mute(music_bus_index, music_mute.button_pressed))
	sfx_mute.pressed.connect(func(): AudioServer.set_bus_mute(sfx_bus_index, sfx_mute.button_pressed))
	ui_mute.pressed.connect(func(): AudioServer.set_bus_mute(ui_bus_index, ui_mute.button_pressed))
	add_resolutions()
	get_screens()
	resolution_option.item_selected.connect(_on_resolution_option_item_selected)
	screen_selector.item_selected.connect(_on_screen_selector_item_selected)

func _change_master_volume(value: float):
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(value))

func _change_music_volume(value: float):
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(value))

func _change_fx_volume(value: float):
	AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(value))

func _change_ui_volume(value: float):
	AudioServer.set_bus_volume_db(ui_bus_index, linear_to_db(value))

func _full_screen():
	if full_screen.button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		full_screen.text = "ON"
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		full_screen.text = "OFF"

func _close():
	SignalBus.on_close_settings.emit()

func _reset_save():
	if reset_save_warning_count == 0:
		reset_save_btn.text = "Are you sure ?"
	elif reset_save_warning_count == 1:
		reset_save_btn.text = "Realy ?"
	else:
		PlayerData.erase_save()
		SignalBus.on_back_to_main_menu.emit()
	reset_save_warning_count += 1

func show_menu(_param):
	show()
	get_tree().paused = true

func hide_menu():
	hide()
	get_tree().paused = false

func add_resolutions():
	for res in resolutions.keys():
		resolution_option.add_item(res)
	resolution_option.select(4)

func _on_resolution_option_item_selected(id: int):
	var res = resolutions[resolution_option.get_item_text(id)]
	DisplayServer.window_set_size(Vector2(res.x, res.y))

func _vsync():
	if vsync_checkbox.button_pressed:
		vsync_checkbox.text = "ON"
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		vsync_checkbox.text = "OFF"
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func get_screens():
	var Screens = DisplayServer.get_screen_count()
	
	for s in Screens:
		screen_selector.add_item("Screen: "+str(s))

func _on_screen_selector_item_selected(index: int):
	var _window = get_window()
	
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_current_screen(index)
	
	if full_screen.button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
