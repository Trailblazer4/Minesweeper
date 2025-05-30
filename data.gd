extends Node

var bg_color: Color = Color("96adaa")
var border_color: Color = Color("004737")

var number_color: Color = Color("000000")
var number_outline: Color = Color("b89cf5")

var explosion_color: Gradient = Gradient.new()

func _ready():
	explosion_color = load("res://explosion.tscn").instantiate().color_ramp
	for c in explosion_color.colors:
		print(c)
