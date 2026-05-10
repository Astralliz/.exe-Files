extends Control

@onready var message: Label = $Label
@onready var accept_btn: Button = $Accept
@onready var continue_btn: Button = $Continue
@onready var ach_continue_btn: Button = $Achievement

@onready var trophy_panel: Panel = $TrophyPanel
@onready var trophy_image: TextureRect = $TrophyPanel/TrophyImage
@onready var achievement_label: Label = $TrophyPanel/AchievementLabel

const REWARD_EVAL := 5
const REWARD_FILTER := 2

var total_added_eval := 0
var total_added_filters := 0

var achievement_images := {
	"Metadata Detective": "res://Assets/Trophy/MetadataDetective.png",
	"System Gatekeeper": "res://Assets/Trophy/SystemGatekeeper.png",
	"Audit Master": "res://Assets/Trophy/AuditMaster.png",
	"Threat Neutralizer": "res://Assets/Trophy/ThreatNeutralizer.png",
	"System Architect": "res://Assets/Trophy/SystemArchitect.png"
}

var day: int

# =========================
# QUEUE SYSTEM (FIXED)
# =========================
var achievement_queue: Array[String] = []
var current_achievement_index := 0


func _ready() -> void:
	day = GameState.day
	trophy_panel.visible = false
	setup_dialogue(day)


func setup_dialogue(day: int) -> void:

	# RESET UI
	accept_btn.hide()
	continue_btn.hide()
	ach_continue_btn.hide()
	trophy_panel.visible = false
	message.text = ""

	achievement_queue.clear()
	current_achievement_index = 0

	# =========================
	# SNAPSHOT NEWLY UNLOCKED
	# =========================
	if Player_Data.newly_unlocked.size() > 0:
		achievement_queue = Player_Data.newly_unlocked.duplicate()
		Player_Data.newly_unlocked.clear()
	# =========================
	# CALCULATE TOTAL REWARDS
	# =========================
	var achievement_count = achievement_queue.size()

	total_added_eval = achievement_count * REWARD_EVAL
	total_added_filters = achievement_count * REWARD_FILTER

	# Give rewards immediately
	if achievement_count > 0:
		Player_Data.add_evaluates(total_added_eval)
		Player_Data.add_filter(total_added_filters)

	# =========================
	# FLOW CONTROL
	# =========================
	if achievement_queue.size() > 0:
		show_next_achievement()
	else:
		show_normal_completion(day)


# =========================
# ACHIEVEMENT DISPLAY
# =========================
func show_next_achievement() -> void:

	if current_achievement_index >= achievement_queue.size():
		show_normal_completion(day)
		return

	var unlocked = achievement_queue[current_achievement_index]

	achievement_label.text = unlocked
	set_trophy_image(unlocked)

	message.text = "Congrats!\nYou unlocked an Achievement!"
	show_trophy_animation()

	ach_continue_btn.show()


func _on_achievement_pressed() -> void:

	current_achievement_index += 1

	if current_achievement_index < achievement_queue.size():
		show_next_achievement()
	else:
		# FINAL REWARD SCREEN
		message.text = "\nCONGRATS!\nYou received:\n" \
			+ str(total_added_eval) + " Evaluates\n" \
			+ str(total_added_filters) + " Filters!"

		accept_btn.show()
		trophy_panel.visible = false
		ach_continue_btn.hide()


# =========================
# NORMAL FLOW
# =========================
func show_normal_completion(day: int) -> void:
	message.text = "\nGreat job!\nYou finished Day " + str(day) + "\nGet ready for the next challenge!"
	continue_btn.show()


func _on_accept_pressed() -> void:
	message.text = "\n\nDay " + str(day) + " Complete!\nMore challenging days await!"
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


# =========================
# UI HELPERS
# =========================
func set_trophy_image(achievement_name: String) -> void:
	if achievement_images.has(achievement_name):
		trophy_image.texture = load(achievement_images[achievement_name])


func show_trophy_animation() -> void:
	trophy_panel.visible = true
	trophy_panel.scale = Vector2(0.2, 0.2)

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
