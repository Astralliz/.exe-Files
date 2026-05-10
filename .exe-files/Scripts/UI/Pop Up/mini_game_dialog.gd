extends Control
class_name MiniGameDialog

signal accepted
signal declined

@onready var dialog_label: Label = $Label
@onready var continue_btn: Button = $Continue
@onready var quit_btn: Button = $Quit

func _ready():
	hide()

	continue_btn.pressed.connect(_on_continue_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)

func show_dialog():
	show()

func _on_continue_pressed():
	hide()
	emit_signal("accepted")

func _on_quit_pressed():
	hide()
	emit_signal("declined")
