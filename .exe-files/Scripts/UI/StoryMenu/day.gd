class_name Day
extends Node2D

@onready var filetizen = $Filetizen
@onready var spawn_filetizen: SpawnerComponent = $FiletizenSpawner
@onready var document_spawner: SpawnerComponent = $DocumentSpawner
@onready var actors: Node2D = $Actors
@onready var documents: Node2D = $Document
@onready var approve_btn: Button = $ApproveBtn
@onready var decline_btn: Button = $DeclineBtn
@onready var answer_label : Label = $Answer_Label
@onready var level_finished: Control = $Level1Finished
@onready var wrong_decision_popup: Control = $GameOver
@onready var dialogue_box: DialogueBox = $"Dialogue Box"

# Audio
@onready var pickup_sound = $Audio_Pickup
@onready var button_sound = $Button_Click
@onready var paper_printing = $Printing_Paper
@onready var filetizen_talking = $Talking

# Sliding Panel (Questions Scene)
@onready var sliding_panel : Control = $SlidingPanel
var current_answers : Dictionary = {}

# Question buttons inside SlidingPanel
@onready var question_buttons : Dictionary = {
	"filename": sliding_panel.get_node("Panel/VBoxContainer/Question1"),
	"extension": sliding_panel.get_node("Panel/VBoxContainer/Question2"),
	"size": sliding_panel.get_node("Panel/VBoxContainer/Question3"),
	"source": sliding_panel.get_node("Panel/VBoxContainer/Question4"),
	"publisher": sliding_panel.get_node("Panel/VBoxContainer/Question5")
}

@onready var resource_display = $ResourceDisplay

# Signals for Tutorial
signal filetizen_spawned
signal document_spawned
signal question_asked(key: String)
signal verdict_chosen(approved: bool)
signal verdict_resolved(is_correct: bool)

const HeuristicEngine = preload("res://Scripts/Algorithm/heuristic_engine.gd")
const RuleBase = preload("res://Scripts/Algorithm/Rules/rule_base.gd")

var dialogue_database := DialogueDatabase.new()
var engine := HeuristicEngine.new()
var rule_base := RuleBase.new()
var rules_for_level: Array
var moved_out := false
var current_document: FileDocument
# Counter loop
var filetizen_count := 0
const MAX_FILETIZENS := 7
var day: int

func _ready():
	
	GlobalMusic.stop()
	day = GameState.day
	print("day: ", day)
	var rule_level = get_rule_level_from_day(day)
	
	rules_for_level = rule_base.get_rules(rule_level)
	
	level_finished.hide()
	wrong_decision_popup.hide()
	resource_display.set_level(day)
	
	$main_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$control_room.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	enable_buttons(false)
	spawn_new_filetizen()
	filetizen_count += 1
	move_filetizen_to_center()
	await get_tree().create_timer(1.0).timeout
	
	# Get the buttons from the child SlidingPanel scene
	question_buttons = {
		"filename": sliding_panel.get_node("Panel/VBoxContainer/Question1"),
		"extension": sliding_panel.get_node("Panel/VBoxContainer/Question2"),
		"size": sliding_panel.get_node("Panel/VBoxContainer/Question3"),
		"source": sliding_panel.get_node("Panel/VBoxContainer/Question4"),
		"publisher": sliding_panel.get_node("Panel/VBoxContainer/Question5")
	}
	
	# Connect each button to the main scene handler
	for key in question_buttons.keys():
		question_buttons[key].pressed.connect(_on_question_button_pressed.bind(key))
	
	spawn_new_file_document()

# SPAWN / MOVE FILETIZEN
func spawn_new_filetizen():
	var screen_size = get_viewport().get_visible_rect().size
	var spawn_pos = Vector2(-100, screen_size.y / 2)
	var new_filetizen: Node2D = spawn_filetizen.spawn(spawn_pos, actors)
	filetizen = new_filetizen
	move_filetizen_to_center()
	emit_signal("filetizen_spawned")

func move_filetizen_to_center():
	var target = get_viewport().get_visible_rect().size / 2.0
	var direction = target - filetizen.position
	filetizen.move_component.move(direction, 250)

func spawn_new_file_document():
	var spawn_pos = Vector2(1035, 274)
	var new_doc: FileDocument = document_spawner.spawn(spawn_pos, documents) as FileDocument
	new_doc.set_metadata(filetizen.metadata)
	new_doc.initialize_paper()
	paper_printing.play()
	current_document = new_doc
	emit_signal("document_spawned")

# MOVE FILETIZEN AFTER DECISION
func move_approved_filetizen():
	var screen_w = get_viewport().get_visible_rect().size.x
	var direction = Vector2(screen_w + 200, filetizen.position.y) - filetizen.position
	filetizen.move_component.move(direction, 300)

func move_declined_filetizen():
	var screen_w = get_viewport().get_visible_rect().size.x
	var direction = Vector2(screen_w + 200, filetizen.position.y) - filetizen.position
	filetizen.move_component.move(direction, -300)

func get_rule_level_from_day(day: int) -> int:
	if day <= 2:
		return 1
	elif day == 3:
		return 2
	return 1  # default fallback

func _process(delta):
	var target = get_viewport().get_visible_rect().size / 2.0
	
	if filetizen and is_instance_valid(filetizen):
		if not moved_out and filetizen.position.distance_to(target) < 5.0:
			filetizen.move_component.stop()
			moved_out = true
			
			var evaluate = engine.evaluate(filetizen.metadata, rules_for_level, current_answers)
			print("Score: ", evaluate.score)
			print("Issues: ", evaluate.issues)
			
			# 1️⃣ Generate answers first (for risky files, it will create lies)
			var answer_gen = AnswerGenerator.new()
			current_answers = answer_gen.generate_answers(filetizen.metadata, evaluate.score) # temp 0 for now

			# 2️⃣ Evaluate score including answer
			evaluate.score += engine.evaluate_type_mismatch(filetizen.metadata, current_answers, rules_for_level)
			filetizen.metadata.risk_score = evaluate.score
			filetizen.metadata.issues = evaluate.issues

			# 3️⃣ Debug info
			print("Evaluating Filetizen:")
			print("Filename: ", filetizen.metadata.filename)
			print("Updated Score: ", evaluate.score)
			print("Answers: ", current_answers)

			# 4️⃣ Enable buttons
			enable_buttons(true)

# -------------------------
# QUESTION BUTTON PRESSED
# -------------------------
func type_text(label: Label, full_text: String, cps: float = 30.0) -> float:
	# ensure inputs are typed
	var text: String = str(full_text)
	label.text = ""
	var duration: float = float(text.length()) / cps

	for i in text.length():
		label.text = text.substr(0, i + 1)
		await get_tree().create_timer(1.0 / cps).timeout

	return duration

# QUESTION BUTTON PRESSED
func _on_question_button_pressed(key: String) -> void:
	if key in current_answers:
		var text: String = str(current_answers[key])
		var cps: float = 25.0

		# compute duration first
		var typing_duration: float = float(text.length()) / cps

		# bounce runs alongside typing
		filetizen.move_component.bounce_for(typing_duration)
		
		filetizen_talking.play()

		# type animation
		await type_text(answer_label, text, cps)

		# hold full text for 0.5s
		await get_tree().create_timer(1).timeout

		# clear the label
		answer_label.text = ""
		emit_signal("question_asked", key)

func enable_buttons(state: bool):
	approve_btn.disabled = not state
	decline_btn.disabled = not state

func _on_approve_btn_pressed() -> void:
	if current_document:
		current_document.spawn_approve_stamp()
	button_sound.play()
	handle_player_decision(true)

func _on_decline_btn_pressed() -> void:
	if current_document:
		current_document.spawn_decline_stamp()
	button_sound.play()
	handle_player_decision(false)

func handle_player_decision(player_approved: bool):
	emit_signal("verdict_chosen", player_approved)
	
	enable_buttons(false)
	var score = filetizen.metadata.risk_score
	var approved = score <= 1.0	
	var is_correct = player_approved == approved
	var message: String
	var show_gameover: bool = false
	
	emit_signal("verdict_resolved", is_correct)
	
	if is_correct:
		message = dialogue_database.get_random_correct()
		if player_approved and approved:
			# Correct approval
			Player_Data.add_bug_bounty(1)
		elif not player_approved and not approved:
			# Correct decline
			Player_Data.add_bug_bounty(2)
		print("✔ Correct decision!")
	elif not player_approved and approved:
		message = dialogue_database.get_random_false_negative()
		print("✘ False Negative!")
	elif player_approved and not approved:
		# Approved but should have declined → game over
		message = "Game Over: This file was unsafe but you approved it!\n" + dialogue_database.get_random_wrong()
		message += "\n" + dialogue_database.build_wrong_details(filetizen.metadata.issues)
		show_gameover = true
		print("✘ Incorrect decision! Game Over!")
	else:
		message = dialogue_database.get_random_wrong()
		message += "\n" + dialogue_database.build_wrong_details(filetizen.metadata.issues)
		print("✘ Incorrect decision!")

	# Show dialogue if not game over
	if not show_gameover:
		dialogue_box.show_dialogue(message)
	else:
		wrong_decision_popup.show()
		wrong_decision_popup.text.text = message

	if player_approved:
		await get_tree().create_timer(1.0).timeout
		move_approved_filetizen()
	else:
		await get_tree().create_timer(1.0).timeout
		move_declined_filetizen()
	
	if current_document:
		current_document.queue_free()
		current_document = null
	
	await get_tree().create_timer(3.0).timeout
	moved_out = false
	
	# Only spawn new Filetizen if under the max count AND game is not over
	if filetizen_count < MAX_FILETIZENS and not show_gameover:
		dialogue_box.hide_dialogue()
		spawn_new_filetizen()
		filetizen_count += 1
		move_filetizen_to_center()
		await get_tree().create_timer(1.0).timeout
		spawn_new_file_document()
	else:
		# Either max filetizens reached OR game over
		if show_gameover:
			wrong_decision_popup.show()
			# The text is already set earlier when decision was wrong
		else:
			level_finished.z_index = 20
			level_finished.show()
			level_up()
			print("Player Level:", Player_Data.data["level"])

		
func level_up():
	var current_level = Player_Data.data["level"]
	if day > current_level:
		Player_Data.set_level(day)
		print("Level up! New player level: ", day)
	else:
		print("Player already has a higher level: ", current_level)
