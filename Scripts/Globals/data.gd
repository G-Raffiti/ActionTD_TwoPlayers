extends Node

# all preloads should be in this Autoload file
# all enum and const should be in this Autoload file

# Exemples:
# const my_var_name: Texture2D = preload('res://icon.svg')
# enum MyEnum { A, B, C }
# const DEFAULT_HEALTH = 100

const ui_button_sound: AudioStream = preload("res://_ Assets/_ Sound/UI/Button_Click.wav")

var main_menu_scene: String = 'res://UserInterface/Menus/main_menu.tscn'
#TODO set the intro scene
var intro_scene: String = 'res://Scenes/Levels/base_level.tscn'

const mob_group_ps: PackedScene = preload("res://Scenes/PackedScenes/mob_group.tscn")
const mob_type_1: MobRes = preload("res://Resources/MOBs/mob_type_1.tres")

# tyle types
const NONE: int = -1
# interaction grid tile types
const VOID: int = 0
const HOVERED: int = 1
const SELECTED: int = 2
const BLOCKED: int = 3

# building grid tile types
const EMPTY_TILE: int = 0
const OBSTACLE_TILE: int = 1
const PATH_TILE: int = 2
const BUILDING_TILE: int = 3

var EMPTY_TILES: Array = [0]

# building types
const ARROW_TOWER: TowerRes = preload("res://Resources/Towers/arrow_tower.tres")

const TILE_SIZE: float = 1.0
