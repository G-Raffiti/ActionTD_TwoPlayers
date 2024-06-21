@tool
extends EditorPlugin

var dock: Control = null

func _enter_tree() -> void:
	dock = preload("res://addons/levelmanager/level_manager.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UR, dock)

func _exit_tree() -> void:
	remove_control_from_docks(dock)
	dock.queue_free()
