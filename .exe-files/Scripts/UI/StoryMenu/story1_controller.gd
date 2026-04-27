extends Node

@onready var day_2_panel: Panel = $Day_2_Lock_Panel
@onready var day_2_lock: Panel = $Day_2_lock
@onready var day_2_label: Label = $Day_2_label

@onready var day_3_panel: Panel = $Day_3_Lock_Panel
@onready var day_3_lock: Panel = $Day_3_lock
@onready var day_3_label: Label = $Day_3_label

func _on_back_1_pressed() -> void:
	SceneLoader.load_scene("res://Scenes/Menu Scenes/story_menu.tscn")

func _on_day_1_start_pressed():

	if Player_Data.data["new_to_game"] == 2:
		GameState.day = 1
		Player_Data.data["new_to_game"] = 3
		SceneLoader.load_scene("res://Scenes/UI/intro.tscn")
	else:
		GameState.day = 1
		SceneLoader.load_scene("res://Scenes/Menu Scenes/Story Scene/day.tscn")


func _on_day_2_start_pressed():
	GameState.day = 2
	SceneLoader.load_scene("res://Scenes/Menu Scenes/Story Scene/day.tscn")

func _on_day_3_start_pressed():
	GameState.day = 3
	SceneLoader.load_scene("res://Scenes/Menu Scenes/Story Scene/day.tscn")

func _ready() -> void:
	if Player_Data.data["level"] >= 1:
		day_2_panel.hide()
		day_2_lock.hide()
		day_2_label.hide()

	if Player_Data.data["level"] >= 2:
		day_3_panel.hide()
		day_3_lock.hide()
		day_3_label.hide()
