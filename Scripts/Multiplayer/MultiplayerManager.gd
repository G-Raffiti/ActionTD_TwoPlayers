extends Node

const SERVER_PORT = 8080
const SERVER_IP = "192.168.43.235"

var player_rts_ps = preload("res://Scenes/PackedScenes/ray_picker_camera.tscn")
var player_action_ps = preload("res://Scenes/PackedScenes/player.tscn")

var _players_spawn_node
var host_mode_enabled = false
var multiplayer_mode_enabled = false
var respawn_point = Vector2(30, 20)
@export var grid: GridMap = null


func become_host():
	print("Starting host!")
	
	_players_spawn_node = get_tree().get_current_scene().get_node("Players")
	
	multiplayer_mode_enabled = true
	host_mode_enabled = true
	
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	
	multiplayer.multiplayer_peer = server_peer
	
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_del_player)
	
	# _remove_single_player()
	
	if not OS.has_feature("dedicated_server"):
		_add_player_to_game(1)
	
func join_as_player_2():
	print("Player 2 joining")
	
	multiplayer_mode_enabled = true
	
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, SERVER_PORT)
	
	multiplayer.multiplayer_peer = client_peer
	
	# _remove_single_player()

func _add_player_to_game(id: int):
	print("Player %s joined the game!" % id)
	var player_to_add
	if (id == 1):
		player_to_add = player_rts_ps.instantiate()
	else:
		player_to_add = player_action_ps.instantiate()
		
	player_to_add.player_id = id
	player_to_add.name = str(id)
	
	_players_spawn_node.add_child(player_to_add, true)
	if _players_spawn_node.get_child_count() == 2:
		SignalBus.on_start_spawning_enemies.emit()
	
func _del_player(id: int):
	print("Player %s left the game!" % id)
	if not _players_spawn_node.has_node(str(id)):
		return
	_players_spawn_node.get_node(str(id)).queue_free()
	
func _remove_single_player():
	print("Remove single player")
	var player_to_remove = get_tree().get_current_scene().get_node("Player")
	player_to_remove.queue_free()
	
	
	
	
	
	
	
	
	
	
	
