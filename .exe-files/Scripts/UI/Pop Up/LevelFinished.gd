extends Control

@onready var message: Label = $Label
@onready var accept_btn: Button = $Accept
@onready var continue_btn: Button = $Continue
@onready var ach_continue_btn: Button = $Achievement

@onready var trophy_panel: Panel = $TrophyPanel
@onready var trophy_image: TextureRect = $TrophyPanel/TrophyImage
@onready var achievement_label: Label = $TrophyPanel/AchievementLabel

var added_eval = 5
var added_fils = 1
var achievement = ["Metadata Detective", "System Gatekeeper", "Audit Master", "Threat Neutralizer", "System Architect"]

var achievement_images := {
	"Metadata Detective": "res://Assets/Trophy/MetadataDetective.png",
	"System Gatekeeper": "res://Assets/Trophy/SystemGatekeeper.png",
	"Audit Master" : "res://Assets/Trophy/AuditMaster.png",
	"Threat Neutralizer" : "res://Assets/Trophy/ThreatNeutralizer.png",
	"System Architect" : "res://Assets/Trophy/SystemArchitect.png"
}

var day: int

func _ready() -> void:
	day = GameState.day
	trophy_panel.visible = false
	setup_dialogue(day)

func setup_dialogue(day: int) -> void:

	# RESET EVERYTHING
	accept_btn.hide()
	continue_btn.hide()
	ach_continue_btn.hide()
	trophy_panel.visible = false
	message.text = ""
	
	var unlocked: String = ""

	# Check achievements in priority order
	if day == 1 and Player_Data.data["level"] < 1:
		unlocked = achievement[0]
		Player_Data.add_evaluates(added_eval)
		Player_Data.add_filter(added_fils)

	elif day == 3 and Player_Data.data["level"] >= 2:
		unlocked = achievement[1]

	elif day == 6 and Player_Data.data["level"] >= 5:
		unlocked = achievement[4]

	elif Player_Data.data["total_inspected"] >= 100:
		unlocked = achievement[2]

	# If we found an achievement
	if unlocked != "":
		show_achievement(unlocked)
	else:
		show_normal_completion(day)

func show_achievement(unlocked: String) -> void:

	if !Player_Data.data["achievements"].has(unlocked):
		Player_Data.unlock_achievement(unlocked)

	achievement_label.text = unlocked
	set_trophy_image(unlocked)

	message.text = "Congrats!\nYou unlocked an Achievement!"

	show_trophy_animation()
	ach_continue_btn.show()

func show_normal_completion(day: int) -> void:
	message.text = "\nGreat job!\nYou finished Day " + str(day) + "\nGet ready for the next challenge!"
	continue_btn.show()

func set_trophy_image(achievement_name: String) -> void:
	if achievement_images.has(achievement_name):
		trophy_image.texture = load(achievement_images[achievement_name])

func show_trophy_animation() -> void:
	trophy_panel.visible = true

	# Start small
	trophy_panel.scale = Vector2(0.2, 0.2)

	# Ensure scale happens from center
	await get_tree().process_frame
	trophy_panel.pivot_offset = trophy_panel.size / 2

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		trophy_panel,
		"scale",
		Vector2.ONE,
		0.6
	)

func _on_achievement_pressed() -> void:
	message.text = "\nCONGRATS!\nYou received:\n" + str(added_eval) + " Evaluates\n" + str(added_fils) + " Filters!"
	accept_btn.show()
	trophy_panel.visible = false
	ach_continue_btn.hide()

func _on_accept_pressed() -> void:
	message.text = "\n\nDay " +  str(day) + " Complete!\nMore challenging days await!"
	accept_btn.hide()
	trophy_panel.visible = false
	continue_btn.show()

func _on_continue_pressed() -> void:
	if Player_Data.data["level"] == 3:
		get_tree().change_scene_to_file("res://Scenes/Menu Scenes/story_menu.tscn")
	else: 
		get_tree().change_scene_to_file("res://Scenes/Menu Scenes/Story Scene/story_1.tscn")
	trophy_panel.visible = false
	GlobalMusic.play()
