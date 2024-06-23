extends PathFollow3D
class_name MobGroup

@onready var enemies_node : Node = $Enemies

var started: bool = false
var mobs: Array[Mob] = []
var speed: float = 1.0

func _ready():
	if not multiplayer.is_server():
		set_process(false)
		set_physics_process(false)
		return

func _physics_process(delta: float) -> void:
	if not started:
		return
	progress += delta * speed

func spawn_mobs_group(mob_res: MobRes, group_size: int, stats_modifier: float, gold_value: int, action_player : Player) -> Array[Mob]:
	for i in range(group_size):
		var mob: Mob = mob_res.mob_ps.instantiate()
		mob.stats = mob_res.stats.duplicate(true)
		mob.stats.init_stats(stats_modifier)
		mob.stats.gold_value = gold_value
		mob.target = self
		mob.top_level = true
		mob.action_player = action_player
		enemies_node.add_child(mob, true)
		mob.tree_exiting.connect(func(): _child_died(mob))
		mob.position = global_position + Vector3(-2 * i, 0, 0)
		mobs.append(mob)
	return mobs

func _child_died(mob: Mob) -> void:
	mobs.erase(mob)
	if mobs.size() == 0:
		queue_free()

func start() -> void:
	started = true
	progress = 0.0
	for mob in mobs:
		mob.start_move()
