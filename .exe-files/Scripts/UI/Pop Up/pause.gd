extends Control

@onready var resume: Button = $VBoxContainer/Button


func _on_button_pressed() -> void:
	hide()
	get_tree().paused = false
