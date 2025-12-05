extends Control

@onready var message: Label = $Label
@onready var accept_btn: Button = $Accept
@onready var continue_btn: Button = $Continue
@onready var ach_continue_btn: Button = $Achievement

var added_eval = 6
var added_fils = 4
var achievement = "Metadata Detective"

var day: int

func _ready() -> void:
	day = GameState.day
	setup_dialogue(day)


func setup_dialogue(day: int) -> void:
	# DAY 1 COMPLETE — unlock achievement + rewards
	if day == 1 && Player_Data.data["level"] < 1:
		continue_btn.hide()
		accept_btn.hide()

		Player_Data.unlock_achievement(achievement)
		Player_Data.add_evaluates(added_eval)
		Player_Data.add_filter(added_fils)

		message.text = "Congrats!\nYou unlocked an\nAchievement:\n'" + achievement + "'\nKeep playing to unlock more!"
	
	# OTHER DAYS — NO ACHIEVEMENT
	else:
		ach_continue_btn.hide()
		accept_btn.hide()
		continue_btn.show()
		
		message.text = "\nGreat job!\nYou finished Day " + str(day) + "\nGet ready for the next challenge!"


func _on_achievement_pressed() -> void:
	message.text = "\nCONGRATS!\nYou received:\n" + str(added_eval) + " Evaluates\n" + str(added_fils) + " Filters!"
	accept_btn.show()
	ach_continue_btn.hide()


func _on_accept_pressed() -> void:
	message.text = "\nDay 1 Complete!\nMore challenging days await!"
	accept_btn.hide()
	continue_btn.show()


func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu Scenes/Story Scene/story_1.tscn")
