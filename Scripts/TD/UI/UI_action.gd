extends PanelContainer

@onready var gold: TextBox = $VBoxAction/Resources/Gold
@onready var health: TextBox = $VBoxAction/Resources/Life
@onready var level: TextBox = $VBoxAction/Levels/Level
@onready var experience: TextBox = $VBoxAction/Levels/Experience

func _ready() -> void:
	SignalBus.on_gold_action_changed.connect(_display_gold)
	SignalBus.on_health_action_changed.connect(_display_health)
	SignalBus.on_experience_action_changed.connect(_display_level)

func _display_gold(gold_amount: int) -> void:
	gold.text = 'Gold: ' + str(gold_amount)
	
func _display_health(health_amount: int, max_health) -> void:
	health.text = 'Health: ' + str(health_amount) + "/" +  str(max_health)
	
func _display_level(level_amount: int, experience_amount: int, max_experience_amount, max_level = false) -> void:
	level.text = 'Level: ' + str(level_amount+1)
	if max_level:
		experience.text = "Max level"
	else:
		experience.text = 'Experience' + str(experience_amount) + "/" +  str(max_experience_amount)
	
