extends Node

# All player Data is stored here and can be accessed by the game

var action_player : Player

func get_action_player() -> Player:
	if is_instance_valid(action_player):
		return action_player
	return null

func erase_data():
	pass
