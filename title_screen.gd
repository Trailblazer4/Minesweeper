extends Node2D


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://minesweeper.tscn")


func _on_settings_button_pressed():
	get_tree().change_scene_to_file("res://settings.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
