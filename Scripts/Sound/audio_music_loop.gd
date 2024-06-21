extends AudioStreamPlayer

@export var musics: Array[AudioStream]
var music_indexes: Array[int]
var current_music: int = 0

func _ready():
	if musics.size() == 0:
		print(name + ": No music to play")
		return
	music_indexes = []
	for i in musics.size():
		music_indexes.append(i)
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_random_music()
	play()
	finished.connect(func(): 
		get_random_music()
		play()
		clear_music_indexes())

func _exit_tree():
	SignalBus.clear(finished)

func get_random_music():
	if musics.size() <= 1:
		stream = musics[0]
		return
	var index: int = music_indexes.pick_random()
	while index == current_music:
		print("Same music")
		index = music_indexes.pick_random()
	current_music = index
	for i in musics.size():
		if i == index:
			continue
		music_indexes.append(i)
	stream = musics[current_music]

func clear_music_indexes():
	var occ: Dictionary = {}
	for i in music_indexes.size():
		if occ.has(music_indexes[i]):
			occ[music_indexes[i]] += 1
		else:
			occ[music_indexes[i]] = 1
	var min_occ: int = 1000
	for key in occ.keys():
		if occ[key] < min_occ:
			min_occ = occ[key]
	for key in occ.keys():
		occ[key] = min_occ - 1
	var i = music_indexes.size() - 1
	while i > 0:
		if occ[music_indexes[i]] > 0:
			occ[music_indexes[i]] -= 1
			music_indexes.erase(i)
		i -= 1
