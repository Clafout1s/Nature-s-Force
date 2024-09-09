extends Node2D
var spawn_point_list=[]
var character_list = []
# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_point_list = [[$player_spawn,"player"],[$ennemy_spawn,"boar"]]


