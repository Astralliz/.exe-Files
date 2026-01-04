class_name Intro
extends Node2D

@onready var text_box: RichTextLabel = $TextBox
@onready var continue_button: Button = $ContinueButton
@onready var fade_rect: ColorRect = $FadeRect

var story_texts: Array[String] = []
var current_index: int = 0
var typing_speed := 0.02  # seconds per character
var is_typing := false
var current_full_text := ""

func _ready() -> void:
	fade_rect.visible = false
	continue_button.pressed.connect(_on_continue_pressed)
	_initialize_story()
	_show_current_text()

func _initialize_story() -> void:
	story_texts = [
		# 1️⃣ World / Setting
		"In the heart of the digital metropolis, Files live as citizens.\n\nThey work, communicate, and move freely within the system.\n\nEvery day, new Files arrive at the city gates — entering through border checkpoints that regulate access to the system.",
		# 2️⃣ Player Lore
		"You are a newly appointed Security Officer assigned to one of these checkpoints.\n\nThis is your first day on the job.\n\nYour responsibility is to inspect incoming Filetizens, assess potential risks, and determine whether access should be granted.",
		# 3️⃣ Transition to Gameplay
		"Not all Files are what they claim to be...\n\nand every decision carries consequences.\n\nWelcome to your post."
	]

func _show_current_text() -> void:
	if current_index == story_texts.size() - 1:
		continue_button.text = "Begin Shift"
	else:
		continue_button.text = "Continue"
	
	_type_text(story_texts[current_index])

func _on_continue_pressed() -> void:
	if is_typing:
		is_typing = false
		text_box.text = current_full_text
		return
	
	current_index += 1
	if current_index < story_texts.size():
		_show_current_text()
	else:
		_fade_and_switch()

func switch_scene() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu Scenes/Story Scene/day.tscn")

func _type_text(text: String) -> void:
	is_typing = true
	current_full_text = text
	text_box.text = ""
	
	for i in text.length():
		if not is_typing:
			text_box.text = current_full_text
			return
		
		text_box.text = text.substr(0, i + 1)
		await get_tree().create_timer(typing_speed).timeout
		
	is_typing = false

func _fade_and_switch() -> void:
	fade_rect.visible = true
	fade_rect.modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.6)
	tween.finished.connect(func():
		switch_scene()
	)
