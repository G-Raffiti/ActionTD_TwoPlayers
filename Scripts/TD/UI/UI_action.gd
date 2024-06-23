extends PanelContainer

@onready var gold: TextBox = $VBoxAction/Resources/Gold
@onready var health: TextBox = $VBoxAction/Resources/Life

func _ready() -> void:
	SignalBus.on_gold_action_changed.connect(_display_gold)
	SignalBus.on_health_action_changed.connect(_display_health)

func _display_gold(gold_amount: int) -> void:
	gold.text = 'Gold: ' + str(gold_amount)
	
func _display_health(health_amount: int, max_health) -> void:
	health.text = 'Health: ' + str(health_amount) + "/" +  str(max_health)
