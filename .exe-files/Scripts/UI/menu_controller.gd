extends Node
#Information Button
func _on_info_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu Scenes/information_menu.tscn")

func _on_information_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu Scenes/main_menu.tscn")

#Settings Button
func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu Scenes/settings_menu.tscn")

func _on_settings_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu Scenes/main_menu.tscn")

#Start Button
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu Scenes/story_menu.tscn")
