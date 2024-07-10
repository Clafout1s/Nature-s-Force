extends Node2D
var spawn_point_list = []

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_point_list = [[$player_spawn,"player"],[$boar_spawn,"boar"]]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
