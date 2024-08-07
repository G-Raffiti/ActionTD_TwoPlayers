extends Node

# Interface Exemple:
#
class Killable:
	var name = 'I.Killable'
	func die(_damage_dealer_id = -1):
		pass
	func take_damage(_damage, _damage_dealer_id = -1):
		pass
#
# Script Exemple that implements interfaces:
#
# extends Node
# class_name MyNode
#
# var implements = [I.Damageable]
#
# func die():
# 	print('I died')
#
# func take_damage(_damage):
# 	print('I took ' + str(_damage) + ' damage')

func check_node(node: Node):
	if not is_instance_valid(node) or node.get_path().is_empty():
		return
	if 'implements' in node:
		if node.implements == null: return
		for interface in node.implements:
			var instance = interface.new()
			var methods = instance.get_script().get_script_method_list()
			for method in methods:
				assert(method.name in node, "Interface ERROR:\nNode '" + str(node.get_path()).substr(6, -1) + "' implements " + instance.name + ":\n\tMissing method: '" + method.name + "()'")

func get_all_nodes(node) -> Array:
	var nodes: Array = [node]
	for child in node.get_children():
		nodes.append_array(get_all_nodes(child))
	return nodes

func _ready():
	var all_nodes = get_all_nodes(get_tree().current_scene)
	for node in all_nodes:
		check_node(node)
	get_tree().node_added.connect(check_node)
