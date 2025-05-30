extends Node2D


func _ready():
	$VBoxContainer/BlockColor/Block/Label.visible = false
	$VBoxContainer/BlockColor/Block.material.set_shader_parameter("bg_color", Data.bg_color)
	$VBoxContainer/BlockColor/Block.material.set_shader_parameter("border_color", Data.border_color)
	$NumberColor/Label.text = "%d " % randi_range(1, 8)
	$NumberColor/Label.add_theme_color_override("font_color", Data.number_color)
	$NumberColor/Label.add_theme_color_override("font_outline_color", Data.number_outline)
	
	for color in Data.explosion_color.colors:
		var picker = ColorPicker.new()
		picker.color = color
		$GradientColors.add_child(picker)
	$GradientColors.scale = Vector2(0.4, 0.4)


func _on_bg_color_color_changed(color):
	$VBoxContainer/BlockColor/Block.material.set_shader_parameter("bg_color", color)


func _on_border_color_color_changed(color):
	$VBoxContainer/BlockColor/Block.material.set_shader_parameter("border_color", color)


func _on_back_button_pressed():
	Data.bg_color = $VBoxContainer/BlockColor/Block.material.get_shader_parameter("bg_color")
	Data.border_color = $VBoxContainer/BlockColor/Block.material.get_shader_parameter("border_color")
	for i in $GradientColors.get_child_count():
		Data.explosion_color.colors[i] = $GradientColors.get_child(i).color
	get_tree().change_scene_to_file("res://title_screen.tscn")


func _on_number_color_color_changed(color):
	Data.number_color = color
	$NumberColor/Label.add_theme_color_override("font_color", Data.number_color)


func _on_number_outline_color_changed(color):
	Data.number_outline = color
	$NumberColor/Label.add_theme_color_override("font_outline_color", Data.number_outline)
