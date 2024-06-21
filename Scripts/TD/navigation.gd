extends NavigationRegion3D

@export var grid_map: GridMap

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_navigation_map(grid_map.get_navigation_map())
