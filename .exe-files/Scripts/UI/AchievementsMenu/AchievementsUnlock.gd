extends Node

# === Achievement Lock Panels ===
@onready var achievement_1_panel: Panel = $HBoxContainer/Achievment1/Lock
@onready var achievement_2_panel: Panel = $HBoxContainer/Achievment2/Lock2
@onready var achievement_3_panel: Panel = $HBoxContainer/Achievment3/Lock3
@onready var achievement_4_panel: Panel = $HBoxContainer/Achievment4/Lock4
@onready var achievement_5_panel: Panel = $HBoxContainer/Achievment5/Lock5

# === Achievement Names (must match saved data exactly) ===
const METADATA_DETECTIVE := "Metadata Detective"
const THREAT_NEUTRALIZER := "Threat Neutralizer"
const SYSTEM_GATEKEEPER := "System Gatekeeper"
const AUDIT_MASTER := "Audit Master"
const SYSTEM_ARCHITECT := "System Architect"

# === Map achievement name -> lock panel ===
var achievement_panels := {}

func _ready() -> void:
	# Build the mapping
	achievement_panels = {
		METADATA_DETECTIVE: achievement_1_panel,
		THREAT_NEUTRALIZER: achievement_2_panel,
		SYSTEM_GATEKEEPER: achievement_3_panel,
		AUDIT_MASTER: achievement_4_panel,
		SYSTEM_ARCHITECT: achievement_5_panel
	}

	update_achievements_ui()

# === Update UI based on unlocked achievements ===
func update_achievements_ui() -> void:
	var unlocked_achievements: Array = Player_Data.data.get("achievements", [])

	for achievement_name in achievement_panels.keys():
		if achievement_name in unlocked_achievements:
			var lock_panel: Panel = achievement_panels[achievement_name]
			lock_panel.visible = false
