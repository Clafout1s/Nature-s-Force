extends "res://test.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_numero()


func get_numero():
	super()
	
func _process(delta):
	move_and_slide()
