extends Area3D

var implements = [I.Killable]
@export var killable: Node

func _ready() -> void:
	pass
	#assert(killable != null and 'implements' in killable, "A Hurt Box is Not Linked to a Killable Object")
	#assert(killable.implements.has(I.Killable))
		
func die(_damage_dealer_id = -1):
	killable.die(_damage_dealer_id)

func take_damage(_damage, _damage_dealer_id = -1):
	killable.take_damage(_damage, _damage_dealer_id)
	pass
