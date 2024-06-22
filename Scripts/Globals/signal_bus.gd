extends Node

# Here are all Signal that are Static

# UI
signal on_back_to_main_menu()
signal on_open_settings()
signal on_close_settings()
signal on_start_game()

# Resources
signal on_gold_changed(new_gold: int)
signal on_building_changed(new_building: int, max_building: int)

# Game
signal on_game_over_loose()
signal on_game_over_win()

signal on_mob_reached_end(damage: float)
signal on_mob_killed(gold: int)

# Grid
signal on_tile_hovered(index: Vector3i, tile_type: int)
signal on_tile_unhovered(index: Vector3i)
signal on_tile_selected(index: Vector3i, tile_type: int)

# Tower
signal on_tower_to_build_selected(tower_res: TowerRes)
signal on_try_to_select_tower_to_build(tower_res: TowerRes)
signal on_tower_built(tower_res: TowerRes)

# Projectile
signal on_projectile_search_target(name: StringName, old_targets: Array[StringName], position: Vector3)
signal on_nearest_target_found(name: StringName, target: Node3D)

# Change Scene
signal on_change_scene_to(scene_name: String)
signal on_change_scene_to_path(scene_path: String)
signal on_reload_scene()

func clear(in_signal):
	for i in in_signal.get_connections().size() - 1:
		in_signal.disconnect(in_signal.get_connections()[i]['callable'])

@rpc("call_local")
func call_on_server(in_signal, in_params):
	if multiplayer.is_server():
		in_signal.emit(in_params)
