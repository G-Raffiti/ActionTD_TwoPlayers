extends GridMap
class_name BuildingGrid

@export var towers: Dictionary = {}

var prev_index: Array[Vector3i] = []

func preview_tower(tower: TowerRes, in_position: Vector3i):
	if towers.has(in_position):
		return
	var tower_preview = tower.type
	set_cell_item(in_position, tower_preview)
	prev_index.append(in_position)

func clear_preview():
	for i in prev_index:
		set_cell_item(i, Data.NONE)
	prev_index.clear()

#@rpc("call_local")
func buid_tower(tower: TowerRes, in_position: Vector3i) -> void:
	print(str(multiplayer.get_unique_id()), "Building tower at: ", in_position)
	if not multiplayer.is_server(): return
	if towers.has(in_position):
		return
	var tower_instance: Tower = tower.packed_scene.instantiate()
	tower_instance.name = "Tower" + str(randi()) #Guid.get_id()
	tower_instance.position = map_to_local(in_position)
	set_cell_item(in_position, Data.NONE)
	add_child(tower_instance)
	tower_instance.build_tower(tower)
	towers[in_position] = tower_instance
	SignalBus.on_tower_built.emit(tower)

func get_tower(in_position: Vector3i) -> Tower:
	return towers[in_position]
