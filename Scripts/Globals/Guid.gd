extends Node

var id_gen: int = 1

func get_id() -> String:
    id_gen += 1
    return str(id_gen)