extends Control


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu Scenes/main_menu.tscn")


func _on_story_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu Scenes/Story Scene/story_1.tscn")
