extends Node2D
var spawn_point_list = []
var character_list=[]
func _ready():
	spawn_point_list = [[$player_spawn,"player"],[$bird_spawn,"bird"],[$boar_spawn,"boar"],[$flag,"flag",["need_unlock"]]]
