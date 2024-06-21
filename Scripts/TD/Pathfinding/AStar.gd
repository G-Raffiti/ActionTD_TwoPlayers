extends Object
class_name Pathfinding

var open_set = []
var closed_set = []
var path = []
var grid = []
var start = Vector2()
var end = Vector2()
var w = 0
var h = 0

func _init():
    open_set = []
    closed_set = []
    path = []
    grid = []
    start = Vector2()
    end = Vector2()
    w = 0
    h = 0

func set_grid(in_grid: Array):
    grid = in_grid

func get_path(in_start: Vector2, in_end: Vector2) -> Array[Vector2]:
    self.start = in_start
    self.end = in_end
    w = grid.size()
    h = grid[0].size()
    open_set.append(start)

    