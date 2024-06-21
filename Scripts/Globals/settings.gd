extends Node

class PlayerPrefs:
	extends Resource

	# Audio
	var master_volume: float = 0.8
	var music_volume: float  = 0.8
	var sfx_volume: float    = 0.6
	var ui_volume: float     = 0.6

	# Video
	var full_screen: bool    = false
	var vsync: bool          = true

	# Keybinds
	var keybinds: Dictionary = {}

const SETTINGS_PATH = "user://player_prefs.tres"
var settings: PlayerPrefs

func _ready():
	if not FileAccess.file_exists(SETTINGS_PATH):
		settings = PlayerPrefs.new()
		save_settings()
	else:
		settings = load_settings()
	tree_exited.connect(save_settings)

func save_settings():
	ResourceSaver.save(settings, SETTINGS_PATH)

func load_settings() -> PlayerPrefs:
	if FileAccess.file_exists(SETTINGS_PATH):
		var temp_settings = ResourceLoader.load(SETTINGS_PATH)
		if temp_settings is PlayerPrefs:
			return temp_settings
	return PlayerPrefs.new()

func reset_settings():
	settings = PlayerPrefs.new()
	save_settings()