extends Node2D

func _ready():
	pass

func _process(_delta):
	if Input.is_action_just_pressed("debug"):
		var list = ["a","b","c"]
		for i in range(3):
			print(list[i])
