extends Control

# === Achievement Lock Panels ===
@onready var achievement_1_panel: Button = $HBoxContainer/Achievment1/Lock
@onready var achievement_2_panel: Button = $HBoxContainer/Achievment2/Lock2
@onready var achievement_3_panel: Button = $HBoxContainer/Achievment3/Lock3
@onready var achievement_4_panel: Button = $HBoxContainer/Achievment4/Lock4
@onready var achievement_5_panel: Button = $HBoxContainer/Achievment5/Lock5

# === Achievement Names ===
const METADATA_DETECTIVE := "Metadata Detective"
const THREAT_NEUTRALIZER := "Threat Neutralizer"
const SYSTEM_GATEKEEPER := "System Gatekeeper"
const AUDIT_MASTER := "Audit Master"
const SYSTEM_ARCHITECT := "System Architect"

# === Descriptions ===

var achievement_descriptions := {
	METADATA_DETECTIVE: "Complete Day 1 of the shift to unlock this achievement.",
	THREAT_NEUTRALIZER: "Complete the mini-game at least once to unlock this achievement.",
	SYSTEM_GATEKEEPER: "Complete the shift 1 to unlock this achievement.",
	AUDIT_MASTER: "Inspect a total of 100 files across all gameplay sessions." + "\n \n Total INspected:  
		" + str(Player_Data.data["total_inspected"]),
	SYSTEM_ARCHITECT: "Complete Day 6 (or shift 2) to unlock this achievement."
}


# === Scene preload ===
const AchievementDetailsScene = preload("res://Scenes/UI/AchievementDialog/achievement_details.tscn")

# === Map ===
var achievement_panels := {}

var details_popup: Control = null

func _ready() -> void:
	achievement_panels = {
		METADATA_DETECTIVE: achievement_1_panel,
		THREAT_NEUTRALIZER: achievement_2_panel,
		SYSTEM_GATEKEEPER: achievement_3_panel,
		AUDIT_MASTER: achievement_4_panel,
		SYSTEM_ARCHITECT: achievement_5_panel
	}

	# IMPORTANT: Enable input + connect
	for achievement_name in achievement_panels.keys():
		var panel = achievement_panels[achievement_name]
		panel.pressed.connect(show_achievement_details.bind(achievement_name))

	update_achievements_ui()

# === Handle tap/click (MOBILE + PC) ===
#func _on_panel_clicked(event: InputEvent, achievement_name: String) -> void:
	## Works for BOTH mouse and touch
	#if event is InputEventScreenTouch and event.pressed:
		#show_achievement_details(achievement_name)
#
	#elif event is InputEventMouseButton \
	#and event.pressed \
	#and event.button_index == MOUSE_BUTTON_LEFT:
		#show_achievement_details(achievement_name)

# === Show popup ===
func show_achievement_details(achievement_name: String):
	var text = achievement_descriptions.get(achievement_name, achievement_name)

	# Create ONLY ONCE
	if details_popup == null:
		details_popup = AchievementDetailsScene.instantiate()
		get_tree().current_scene.add_child(details_popup)

	# Reuse existing popup
	details_popup.set_description(text)
	details_popup.show()
# === Update UI ===
func update_achievements_ui() -> void:
	var unlocked_achievements: Array = Player_Data.data.get("achievements", [])

	for achievement_name in achievement_panels.keys():
		if achievement_name in unlocked_achievements:
			var lock_panel: Button = achievement_panels[achievement_name]
			lock_panel.visible = false
