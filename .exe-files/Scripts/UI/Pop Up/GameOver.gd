extends Node

@onready var text: RichTextLabel = $TextEdit

func _ready() -> void:
	text.text = "GameOver"

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu Scenes/story_menu.tscn")
