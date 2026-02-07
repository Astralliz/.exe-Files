extends Node

const EDIT_USERNAME_SCENE := preload("res://Scenes/UI/SettingsDialog/edit_username.tscn")
const MANAGE_USER_DATA_SCENE := preload("res://Scenes/UI/SettingsDialog/manage_user_data.tscn")

var edit_username_instance: Control
var manage_user_data_insatnce: Control
func _ready() -> void:
	print("READ USERNAME INSTANCE:", Player_Data)
	print("USERNAME VALUE:", Player_Data.data.get("username"))
	

func _on_username_pressed() -> void:
	if edit_username_instance:
		return # already open

	edit_username_instance = EDIT_USERNAME_SCENE.instantiate()
	get_tree().current_scene.add_child(edit_username_instance)


func _on_user_d_ata_pressed() -> void:
	if manage_user_data_insatnce:
		return # already open
		
	manage_user_data_insatnce = MANAGE_USER_DATA_SCENE.instantiate()
	get_tree().current_scene.add_child(manage_user_data_insatnce)
