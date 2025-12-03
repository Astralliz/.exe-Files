extends Control

@onready var message: Label = $Label
@onready var accept_btn: Button = $Accept
@onready var continue_btn: Button = $Continue
@onready var ach_continue_btn: Button = $Achievement

var added_eval = 6
var added_ques = 4
var achievement = "Metadata Detective"

func _ready() -> void:
	continue_btn.hide()
	accept_btn.hide()
	Player_Data.set_level(2)
	Player_Data.unlock_achievement(achievement)
	Player_Data.add_evaluates(added_eval)
	Player_Data.add_questions(added_ques)
	message.text = "Congrats!\n You Unlock an\n Achievement \n'" +  achievement + "'\nPlay More Day\n to Unlock more!"


func _on_achievement_pressed() -> void:
	message.text = "\nCONGRATS\n You get a \n" + str(added_eval) + " evaluates! \n and \n" + str(added_ques) + " Questions!"
	accept_btn.show()
	ach_continue_btn.hide()

func _on_accept_pressed() -> void:
	message.text =  "\nCongrats  For Completing\n Your First Day\n You're now ready for more \n harder days \n to come.\n"
	continue_btn.show()
	accept_btn.hide()

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu Scenes/Story Scene/story_1.tscn")
