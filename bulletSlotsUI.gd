extends Control

var textureShellPlain = preload("res://sprites/shellPlain.png")
var textureShellEmpty = preload("res://sprites/shellEmpty.png")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func switch_to_empty_shell():
	var bullet1 = $HBoxContainer/bullet1
	var bullet2 = $HBoxContainer/bullet2
	if bullet2.texture == textureShellPlain:
		bullet2.set_texture(textureShellEmpty)
	elif bullet1.texture == textureShellPlain:
		bullet1.set_texture(textureShellEmpty)

func switch_to_plain_shell():
	var bullet1 = $HBoxContainer/bullet1
	var bullet2 = $HBoxContainer/bullet2
	if bullet1.texture == textureShellEmpty:
		bullet1.set_texture(textureShellPlain)
	elif bullet2.texture == textureShellEmpty:
		bullet2.set_texture(textureShellPlain)
