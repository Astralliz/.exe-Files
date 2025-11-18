extends Control


func _on_info_pressed() -> void:
	print("Cyber Info Pressed");


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu Scenes/story_menu.tscn")


func _on_settings_pressed() -> void:
	print("Settings Pressed");
