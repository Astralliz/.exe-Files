extends Control

@onready var resume: Button = $VBoxContainer/Button
@onready var buttonContainer: VBoxContainer = $VBoxContainer
@onready var audio_panel: Panel = $AudioPanel
@onready var information_menu: Panel =$InformationPanel
@onready var label: Label = $Label


# InformationMenu.gd
@onready var metadata_panel = $InformationPanel/MetdataPanel
@onready var level1_panel = $InformationPanel/Level1Panel
@onready var level2_panel = $InformationPanel/Level2Panel
@onready var level3_panel = $InformationPanel/Level3Panel

func _ready() -> void:
	audio_panel.hide()
	information_menu.hide()

#--------------------------------------
# Resume
#--------------------------------------
func _on_button_pressed() -> void:
	hide()
	get_tree().paused = false

#----------------------------------------
# Audio Settings
#---------------------------------------
func _on_button_2_pressed() -> void:
	buttonContainer.hide()
	audio_panel.show()


func _on_general_bck_btn_pressed() -> void:
	audio_panel.hide()
	information_menu.hide()
	buttonContainer.show()
	label.show()

#----------------------------------------
# Information Menu
#----------------------------------------
func _on_button_3_pressed() -> void:
	buttonContainer.hide()
	information_menu.show()
	show_tab("metadata")

func show_tab(tab_name: String):
	# Hide all panels
	metadata_panel.visible = false
	level1_panel.visible = false
	level2_panel.visible = false
	level3_panel.visible = false
	
	# Show the selected panel
	match tab_name.to_lower():
		"metadata":
			metadata_panel.visible = true
		"level1":
			level1_panel.visible = true
		"level2":
			level2_panel.visible = true
		"level3":
			level3_panel.visible = true

# Connect buttons to these functions
func _on_metdata_pressed() -> void:
	show_tab("metadata")

func _on_level_1_pressed() -> void:
	show_tab("level1")

func _on_level_2_pressed() -> void:
	show_tab("level2")

func _on_level_3_pressed() -> void:
	show_tab("level3")

#-------------------------------------------
# Quit
#----------------------------------------
func _on_button_4_pressed() -> void:
	get_tree().paused = false
	hide()
	
	var game_over_scene = preload("res://Scenes/Finishing Scenes/game_over.tscn")
	var game_over_instance = game_over_scene.instantiate()
	
	get_tree().current_scene.add_child(game_over_instance)
