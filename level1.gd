extends Node2D
var spawn_point_list = []
var character_list=[]
func _ready():
	spawn_point_list = [[$player_spawn,"player"],[$boar_spawn,"boar"],[$flag,"flag",["need_unlock"]]]
