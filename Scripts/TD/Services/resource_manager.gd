extends Node

var buildings: int = 0
var buildings_max: int = 5

var resources : Dictionary

func _ready() -> void:
	SignalBus.on_tower_built.connect(_on_tower_built)
	SignalBus.on_try_to_select_tower_to_build.connect(_select_tower_to_build)
	SignalBus.on_mob_killed.connect(_gain_gold_rpc)
	
	resources["gold_td"] = 10
	resources["gold_action"] = 0
	SignalBus.on_gold_td_changed.emit(resources["gold_td"])
	SignalBus.on_gold_action_changed.emit(resources["gold_action"])

func _select_tower_to_build(tower: TowerRes) -> void:
	if resources.get("gold_td") >= tower.cost and buildings < buildings_max:
		SignalBus.on_tower_to_build_selected.emit(tower)
	else:
		SignalBus.on_tower_to_build_selected.emit(null)

func _on_tower_built(tower: TowerRes) -> void:
	resources["gold_td"] -= tower.cost
	buildings += 1
	SignalBus.on_gold_td_changed.emit(resources["gold_td"])
	SignalBus.on_building_changed.emit(buildings, buildings_max)

@rpc("call_local")
func _gain_gold_rpc(gold_amount: int, _killer_id: int) -> void:
	if not multiplayer.is_server():
		return
	_gain_gold(gold_amount, _killer_id)

func _gain_gold(gold_amount: int, _killer_id: int) -> void:
	if _killer_id == 1:
		resources["gold_td"] += gold_amount
		SignalBus.on_gold_td_changed.emit(resources["gold_td"])
	else :
		resources["gold_action"] += gold_amount
		SignalBus.on_gold_action_changed.emit(resources["gold_action"])

func _on_arrow_tower_pressed() -> void:
	SignalBus.on_try_to_select_tower_to_build.emit(Data.ARROW_TOWER)
