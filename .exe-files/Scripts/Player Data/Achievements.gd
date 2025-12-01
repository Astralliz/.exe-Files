extends Control

@onready var hbox: HBoxContainer = $HBoxContainer
# Panels fixed in the scene
@onready var panels: Array = [
	hbox.get_node("Panel"),
	hbox.get_node("Panel2"),
	hbox.get_node("Panel3"),
	hbox.get_node("Panel4"),
	hbox.get_node("Panel5")
]

func _ready():
	update_achievements()

func update_achievements() -> void:
	var achievements: Array = Player_Data.data.get("achievements", [])

	for i in range(panels.size()):
		var panel = panels[i]
		var label: Label = panel.get_node("Label") # Make sure each panel has a Label child
		
		# Always show the panel
		panel.visible = true

		if i < achievements.size():
			label.text = achievements[i]  # assign achievement text
		else:
			label.text = "Empty"  # optional placeholder if no achievement
