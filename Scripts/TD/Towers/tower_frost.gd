extends Tower
class_name TowerFrost

func _on_unit_enter_range(unit: Node3D) -> void:
	if not multiplayer.is_server(): return
	if unit.is_in_group('Enemy'):
		var mob = unit as Mob
		mob.stats.speed /= 2.0
		mob.stats.acceleration /= 2.0
		mob.stats.attack_speed /= 2.0

func _on_unit_exit_range(unit: Node3D) -> void:
	if not multiplayer.is_server(): return
	var mob = unit as Mob
	mob.stats.speed *= 2.0
	mob.stats.acceleration *= 2.0
	mob.stats.attack_speed *= 2.0

func shoot():
	pass

func _physics_process(_delta: float) -> void:
	pass

func _reload(_param):
	pass

func die(_damage_dealer_id = -1):
	is_dying = true
	queue_free()
	pass

func take_damage(damage, damage_dealer_id = -1):
	if is_dying: return
	stats.hp -= damage
	if stats.hp <= 0:
		die(damage_dealer_id)
