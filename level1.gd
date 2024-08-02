extends Node2D
var spawn_point_list = []

func _ready():
	print(get_viewport_rect().size)
	spawn_point_list = [[$player_spawn,"player"],[$boar_spawn,"boar"]]
