extends Camera3D

@export var grid: GridMap = null
@export var SPEED: float = 0.5
@export var ZOOM: float = 0.2
@export var min_zoom: float = 10.0
@export var max_zoom: float = 35.0

var hovered_index: Vector3i = Vector3i(0, 0, 0)
var click_down: bool = false

@export var player_id := 1:
	set(id):
		player_id = id
		%InputSync.set_multiplayer_authority(id)

@export var EMPTY_TILES: Array[int] = [0]
@export var PATH_TILES: Array[int] = []

@onready var ray: RayCast3D = $RayCast3D

func _ready():
	if multiplayer.is_server():
		make_current()
	grid = get_tree().get_current_scene().get_node("Navigation/GridMapEnvironment")
	print("I am " + str(multiplayer.get_unique_id()), grid)


func _process(_delta: float) -> void:
	if not multiplayer.is_server(): return
	var mouse_position_2d: Vector2 = get_viewport().get_mouse_position()
	var mouse_position_3d: Vector3 = project_position(mouse_position_2d, 0)
	ray.global_position = mouse_position_3d
	ray.target_position = project_local_ray_normal(mouse_position_2d) * 1000
	ray.force_raycast_update()

	if not ray.is_colliding(): return
	
	var collision_point: Vector3 = ray.get_collision_point()
	var index: Vector3i = grid.local_to_map(collision_point)

	if hovered_index != index:
		SignalBus.on_tile_unhovered.emit(hovered_index)
		var tile = get_tile_type(index)
		SignalBus.on_tile_hovered.emit(index, tile)
		hovered_index = index
		if Input.is_action_pressed('click'):
			SignalBus.on_tile_selected.emit(index, tile)

	if Input.is_action_just_pressed('click'):
		var tile = get_tile_type(index)
		SignalBus.on_tile_selected.emit(index, tile)
	
	if Input.is_action_just_pressed('right_click'):
		SignalBus.on_tower_to_build_selected.emit(null)
	
	#if Input.is_action_pressed("movement"):
func _physics_process(_delta: float) -> void:
	position.x += (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * SPEED
	position.z += (Input.get_action_strength("move_down") - Input.get_action_strength("move_up")) * SPEED
	if Input.is_action_just_pressed("zoom_+"):
		size -= ZOOM
	if Input.is_action_just_pressed("zoom_-"):
		size += ZOOM
	size = clampf(size, min_zoom, max_zoom)

func get_tile_type(index: Vector3i) -> int:
	var tile: int = grid.get_cell_item(index)
	if EMPTY_TILES.has(tile):
		return Data.EMPTY_TILE
	elif PATH_TILES.has(tile):
		return Data.PATH_TILE
	else:
		return Data.OBSTACLE_TILE
