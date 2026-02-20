extends Node

@onready var story_2_panel: Panel = $Panel3
@onready var story_2_lock: Panel = $Panel4
@onready var story_2_label: Label = $Label5

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu Scenes/main_menu.tscn")

func _on_story_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu Scenes/Story Scene/story_1.tscn")

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu Scenes/Story Scene/story_2.tscn")
	

func _ready() -> void:
	if Player_Data.data["level"] >= 4:
		story_2_panel.hide()
		story_2_lock.hide()
		story_2_label.hide()
