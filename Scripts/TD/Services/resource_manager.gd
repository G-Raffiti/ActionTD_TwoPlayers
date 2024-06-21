extends Node

var gold: int = 7
var buildings: int = 0
var buildings_max: int = 5

func _ready() -> void:
	SignalBus.on_tower_built.connect(_on_tower_built)
	SignalBus.on_try_to_select_tower_to_build.connect(_select_tower_to_build)
	SignalBus.on_mob_killed.connect(_gain_gold)

func _select_tower_to_build(tower: TowerRes) -> void:
	if gold >= tower.cost and buildings < buildings_max:
		SignalBus.on_tower_to_build_selected.emit(tower)
	else:
		SignalBus.on_tower_to_build_selected.emit(null)

func _on_tower_built(tower: TowerRes) -> void:
	gold -= tower.cost
	buildings += 1
	SignalBus.on_gold_changed.emit(gold)
	SignalBus.on_building_changed.emit(buildings, buildings_max)

func _gain_gold(gold_amount: int) -> void:
	gold += gold_amount
	SignalBus.on_gold_changed.emit(gold)

func _on_arrow_tower_pressed() -> void:
	SignalBus.on_try_to_select_tower_to_build.emit(Data.ARROW_TOWER)
