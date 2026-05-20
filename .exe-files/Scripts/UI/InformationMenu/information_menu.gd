extends Node

# InformationMenu.gd
@onready var metadata_panel = $MetdataPanel
@onready var level1_panel = $Level1Panel
@onready var level2_panel = $Level2Panel
@onready var level3_panel = $Level3Panel

func _ready():
	show_tab("metadata")

func show_tab(tab_name: String):

	var panels = [
		metadata_panel,
		level1_panel,
		level2_panel,
		level3_panel
	]

	# Disable all panels completely
	for panel in panels:

		panel.visible = false

		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

		panel.process_mode = Node.PROCESS_MODE_DISABLED

	# Enable selected panel
	match tab_name.to_lower():

		"metadata":
			enable_panel(metadata_panel)

		"level1":
			enable_panel(level1_panel)

		"level2":
			enable_panel(level2_panel)

		"level3":
			enable_panel(level3_panel)

func enable_panel(panel: Control):

	panel.visible = true

	panel.mouse_filter = Control.MOUSE_FILTER_PASS

	panel.process_mode = Node.PROCESS_MODE_INHERIT

# Connect buttons to these functions
func _on_metdata_pressed() -> void:
	show_tab("metadata")

func _on_level_1_pressed() -> void:
	show_tab("level1")

func _on_level_2_pressed() -> void:
	show_tab("level2")

func _on_level_3_pressed() -> void:
	show_tab("level3")
