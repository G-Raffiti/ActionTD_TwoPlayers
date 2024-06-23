extends CanvasLayer

@export var action_UI : PanelContainer
@export var TD_UI : PanelContainer


func _ready():
	action_UI.visible = false
	TD_UI.visible = true

func _on_players_multiplayer_spawner_spawned(node):
	if not multiplayer.is_server():
		action_UI.visible = true
		TD_UI.visible = false
	else:
		action_UI.visible = false
		TD_UI.visible = true
