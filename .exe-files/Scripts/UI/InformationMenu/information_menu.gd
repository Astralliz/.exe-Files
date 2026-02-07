extends Node

# InformationMenu.gd
@onready var metadata_panel = $MetdataPanel
@onready var level1_panel = $Level1Panel
@onready var level2_panel = $Level2Panel
@onready var level3_panel = $Level3Panel

func _ready():
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
