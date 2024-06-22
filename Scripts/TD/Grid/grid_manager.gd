extends Node

@export var grid: GridMap
@export var environment_grid: GridMap
@export var building_grid: BuildingGrid

var tower_to_build: TowerRes

var hovered_index: Vector3i
var selected_index: Array[Vector3i] = []

enum State { SELECTION, BUILDING }
var mode: State = State.SELECTION
enum Select { SINGLE, MULTI, BOX }
var select_mode: Select = Select.SINGLE

func _unhandled_input(event: InputEvent) -> void:
	if mode == State.BUILDING:
		return
	if event.is_action_pressed('multi_select'):
		select_mode = Select.MULTI
	elif event.is_action_released('multi_select'):
		select_mode = Select.SINGLE
	elif event.is_action_pressed('box_select'):
		select_mode = Select.BOX
	elif event.is_action_released('box_select'):
		select_mode = Select.SINGLE

func _ready() -> void:
	SignalBus.on_tile_hovered.connect(_on_tile_hovered)
	SignalBus.on_tile_unhovered.connect(_on_tile_unhovered)
	SignalBus.on_tile_selected.connect(_on_tile_selected)
	SignalBus.on_tower_to_build_selected.connect(_on_tower_to_build_selected)

func _on_tile_hovered(index: Vector3i, tile_type: int):
	if selected_index.has(index): return
	if tile_type == Data.EMPTY_TILE:
		grid.set_cell_item(index, Data.HOVERED)
		if mode == State.BUILDING:
			building_grid.preview_tower(tower_to_build, index)
	elif tile_type == Data.OBSTACLE_TILE:
		grid.set_cell_item(index, Data.BLOCKED)
	elif tile_type == Data.PATH_TILE:
		grid.set_cell_item(index, Data.BLOCKED)
	elif tile_type >= Data.BUILDING_TILE:
		grid.set_cell_item(index, Data.HOVERED)
	hovered_index = index

func _on_tile_unhovered(index: Vector3i):
	building_grid.clear_preview()
	if selected_index.has(index): 
		return
	grid.set_cell_item(index, Data.NONE)

func _on_tile_selected(index: Vector3i, tile_type: int):
	match mode:
		State.SELECTION:
			select_tile(index, tile_type)
		State.BUILDING:
			build_on_tile(index, tile_type)

func _on_tower_to_build_selected(tower: TowerRes) -> void:
	if tower == null:
		mode = State.SELECTION
		return
	tower_to_build = tower
	mode = State.BUILDING

func select_tile(index: Vector3i, tile_type: int) -> void:
	match select_mode:
		Select.SINGLE:
			select_single_tile(index, tile_type)
		Select.MULTI:
			select_multi_tile(index, tile_type)
		Select.BOX:
			select_box_tile(index, tile_type)
	_on_tile_hovered(index, tile_type)

func select_single_tile(index: Vector3i, tile_type: int) -> void:
	if selected_index.has(index):
		selected_index.erase(index)
	else: 
		if tile_type == Data.EMPTY_TILE or tile_type == Data.BUILDING_TILE:
			grid.set_cell_item(index, Data.SELECTED)
			selected_index.append(index)
	for i in selected_index:
		if i == index: 
			continue
		grid.set_cell_item(i, Data.NONE)
	if selected_index.has(index):
		selected_index = [index]
	else:
		selected_index = []

func select_multi_tile(index: Vector3i, tile_type: int) -> void:
	if selected_index.has(index):
		selected_index.erase(index)
	else:
		if tile_type == Data.EMPTY_TILE or tile_type == Data.BUILDING_TILE:
			grid.set_cell_item(index, Data.SELECTED)
			selected_index.append(index)

func select_box_tile(index: Vector3i, tile_type: int) -> void:
	if selected_index.size() == 0:
		if tile_type == Data.EMPTY_TILE or tile_type == Data.BUILDING_TILE:
			grid.set_cell_item(index, Data.SELECTED)
		selected_index = [index]
	for i in selected_index:
		grid.set_cell_item(i, Data.NONE)
	selected_index = [selected_index[0]]
	var start = Vector3i(min(selected_index[0].x, index.x), 0, min(selected_index[0].z, index.z))
	var end = Vector3i(max(selected_index[0].x, index.x), 0, max(selected_index[0].z, index.z))
	for x in range(start.x, end.x + 1):
		for z in range(start.z, end.z + 1):
			var index_in_box = Vector3i(x, 0, z)
			if Data.EMPTY_TILES.has(environment_grid.get_cell_item(index_in_box)):
				grid.set_cell_item(index_in_box, Data.SELECTED)
				selected_index.append(index_in_box)
			else:
				grid.set_cell_item(index_in_box, Data.NONE)

func build_on_tile(index: Vector3i, tile_type: int) -> void:
	if tile_type != Data.EMPTY_TILE:
		return
	if tower_to_build == null:
		mode = State.SELECTION
		return
	building_grid.buid_tower.rpc(tower_to_build, index)
	if select_mode != Select.MULTI:
		SignalBus.on_tower_to_build_selected.emit(null)
	else:
		SignalBus.on_try_to_select_tower_to_build.emit(tower_to_build)
