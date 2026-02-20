extends Control

@onready var message: Label = $Label
@onready var accept_btn: Button = $Accept
@onready var continue_btn: Button = $Continue
@onready var ach_continue_btn: Button = $Achievement

@onready var trophy_panel: Panel = $TrophyPanel
@onready var trophy_image: TextureRect = $TrophyPanel/TrophyImage
@onready var achievement_label: Label = $TrophyPanel/AchievementLabel

var added_eval = 6
var added_fils = 4
var achievement = ["Metadata Detective", "System Gatekeeper"]

var achievement_images := {
	"Metadata Detective": "res://Assets/Trophy/MetadataDetective.png",
	"System Gatekeeper": "res://Assets/Trophy/SystemGatekeeper.png"
}

var day: int

func _ready() -> void:
	day = GameState.day
	trophy_panel.visible = false
	setup_dialogue(day)


func setup_dialogue(day: int) -> void:
	# DAY 1 COMPLETE — unlock achievement + rewards
	if day == 1 && Player_Data.data["level"] < 1:
		continue_btn.hide()
		accept_btn.hide()

		var unlocked = achievement[0]

		Player_Data.unlock_achievement(unlocked)
		Player_Data.add_evaluates(added_eval)
		Player_Data.add_filter(added_fils)

		achievement_label.text = unlocked
		set_trophy_image(unlocked)
		show_trophy_animation()

		message.text = "Congrats!\nYou unlocked an Achievement!"

		
		achievement_label.text = achievement[0]
	
	# OTHER DAYS — NO ACHIEVEMENT
	
	elif day == 3 && Player_Data.data["level"] >= 2:
		continue_btn.hide()
		accept_btn.hide()

		var unlocked = achievement[1]

		Player_Data.unlock_achievement(unlocked)
		achievement_label.text = unlocked
		set_trophy_image(unlocked)

		show_trophy_animation()
	else:
		ach_continue_btn.hide()
		accept_btn.hide()
		continue_btn.show()
		
		message.text = "\nGreat job!\nYou finished Day " + str(day) + "\nGet ready for the next challenge!"
		

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
	message.text = "\n\nDay 1 Complete!\nMore challenging days await!"
	accept_btn.hide()
	trophy_panel.visible = false
	continue_btn.show()


func _on_continue_pressed() -> void:
	if Player_Data.data["level"] >= 3:
		get_tree().change_scene_to_file("res://Scenes/Menu Scenes/story_menu.tscn")
	else: 
		get_tree().change_scene_to_file("res://Scenes/Menu Scenes/Story Scene/story_1.tscn")
	trophy_panel.visible = false
	GlobalMusic.play()
