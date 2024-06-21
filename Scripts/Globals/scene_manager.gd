extends Node

var current_scene_path: String = Data.main_menu_scene

func _ready() -> void:
	SignalBus.on_change_scene_to.connect(change_scene_deferred)
	SignalBus.on_change_scene_to_path.connect(change_scene_deferred_path)
	SignalBus.on_reload_scene.connect(reload_scene)
	SignalBus.on_back_to_main_menu.connect(func(): change_scene_deferred_path(Data.main_menu_scene))
	SignalBus.on_start_game.connect(func(): change_scene_deferred_path(Data.intro_scene))

func _exit_tree() -> void:
	SignalBus.on_change_scene_to.disconnect(change_scene_deferred)
	SignalBus.on_change_scene_to_path.disconnect(change_scene_deferred_path)
	SignalBus.on_reload_scene.disconnect(reload_scene)
	SignalBus.clear(SignalBus.on_back_to_main_menu)
	SignalBus.clear(SignalBus.on_start_game)

func change_scene_deferred(scene_name: String) -> void:
	assert(ResourceLoader.exists("res://Scenes/Levels/" + scene_name + ".tscn"), "Scene file does not exist: " + "res://Scenes/Levels/" + scene_name + ".tscn")
	call_deferred('change_scene', "res://Scenes/Levels/" + scene_name + ".tscn")

func change_scene_deferred_path(scene_path: String) -> void:
	assert(ResourceLoader.exists(scene_path), "Scene file does not exist: " + scene_path)
	call_deferred('change_scene', scene_path)

func change_scene(scene_path: String) -> void:
	get_tree().unload_current_scene()
	get_tree().change_scene_to_file(scene_path)
	current_scene_path = scene_path

func reload_scene() -> void:
	change_scene_deferred_path(current_scene_path)
