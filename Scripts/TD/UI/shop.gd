extends PanelContainer

@onready var gold: TextBox = $VBoxTD/Resources/Gold
@onready var building: TextBox = $VBoxTD/Resources/Building

func _ready() -> void:
	SignalBus.on_gold_td_changed.connect(_display_gold)
	SignalBus.on_building_changed.connect(_display_building)

func _display_gold(gold_amount: int) -> void:
	gold.text = 'Gold: ' + str(gold_amount)

func _display_building(current_building: int, max_buildings: int) -> void:
	building.text = 'Building: ' + str(current_building) + '/' + str(max_buildings)
