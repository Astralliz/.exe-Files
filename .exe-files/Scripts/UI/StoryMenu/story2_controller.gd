extends Node

@onready var day_5_panel: Panel = $Day_5_Lock_Panel
@onready var day_5_lock: Panel = $Day_5_lock
@onready var day_5_label: Label = $Day_5_label

@onready var day_6_panel: Panel = $Day_6_Lock_Panel
@onready var day_6_lock: Panel = $Day_6_lock
@onready var day_6_label: Label = $Day_6_label

func _on_back_1_pressed() -> void:
	SceneLoader.load_scene("res://Scenes/Menu Scenes/story_menu.tscn")

func _on_day_4_start_pressed() -> void:
	GameState.day = 4
	SceneLoader.load_scene("res://Scenes/Menu Scenes/Story Scene/day.tscn", "Starting...")

func _on_day_5_start_pressed() -> void:
	GameState.day = 5
	SceneLoader.load_scene("res://Scenes/Menu Scenes/Story Scene/day.tscn", "Starting...")

func _on_day_3_start_pressed():
	GameState.day = 6
	SceneLoader.load_scene("res://Scenes/Menu Scenes/Story Scene/day.tscn", "Starting...")

func _ready() -> void:
	if Player_Data.data["level"] >= 4:
		day_5_panel.hide()
		day_5_lock.hide()
		day_5_label.hide()

	if Player_Data.data["level"] >=5:
		day_6_panel.hide()
		day_6_lock.hide()
		day_6_label.hide()
