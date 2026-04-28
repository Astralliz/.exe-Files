extends Control
#Information Button

func _on_info_pressed() -> void:
	SceneLoader.load_scene("res://Scenes/Menu Scenes/information_menu.tscn", "Initializing System...")

func _on_information_back_pressed() -> void:
	SceneLoader.load_scene("res://Scenes/Menu Scenes/main_menu.tscn", "Initializing System...")

#Settings Button
func _on_settings_pressed() -> void:
	SceneLoader.load_scene("res://Scenes/Menu Scenes/settings_menu.tscn", "Initializing System...")

func _on_settings_back_pressed() -> void:
	SceneLoader.load_scene("res://Scenes/Menu Scenes/main_menu.tscn", "Initializing System...")

#Start Button
func _on_start_pressed() -> void:
	SceneLoader.load_scene("res://Scenes/Menu Scenes/story_menu.tscn", "Initializing System...")

#Achievement Button
func _on_achievement_btn_pressed() -> void:
	SceneLoader.load_scene("res://Scenes/Menu Scenes/achievements_menu.tscn", "Initializing System...")

#Survey Button
func _on_survey_btn_pressed() -> void:
	SceneLoader.load_scene("res://Scenes/Menu Scenes/survey_menu.tscn", "Initializing System...")

func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu Scenes/main_menu.tscn")

func _on_shop_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu Scenes/shop_menu.tscn")
	
func _on_shop_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu Scenes/main_menu.tscn")
