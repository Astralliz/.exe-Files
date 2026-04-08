class_name Day
extends Node2D

@onready var filetizen = $Filetizen
@onready var filter_activated: Node2D = $FilterActivated
@onready var spawn_filetizen: SpawnerComponent = $FiletizenSpawner
@onready var document_spawner: SpawnerComponent = $DocumentSpawner
@onready var actors: Node2D = $Actors
@onready var documents: Node2D = $Document
@onready var filter_btn: Button = $FilterPanel/FilterBtn
@onready var approve_btn: Button = $ApproveBtn
@onready var decline_btn: Button = $DeclineBtn
@onready var answer_label : Label = $Answer_Label
@onready var level_finished: Control = $Level1Finished
@onready var wrong_decision_popup: Control = $GameOver
@onready var dialogue_box: DialogueBox = $"Dialogue Box"

@onready var paused_btn: Button = $PauseBtn
@onready var paused: Control = $Pause

@onready var resource_display = $ResourceDisplay

# Audio
@onready var pickup_sound = $Audio_Pickup
@onready var button_sound = $Button_Click
@onready var paper_printing = $Printing_Paper
@onready var filetizen_talking = $Talking
@onready var opening_door = $Open_Door
@onready var closing_door = $Closed_Door

# Sliding Panel (Questions Scene)
@onready var sliding_panel : Control = $SlidingPanel

# =========================
# SIGNALS
# =========================
signal filetizen_spawned
signal document_spawned
signal question_asked(key: String)
signal verdict_chosen(approved: bool)
signal verdict_resolved(is_correct: bool)

# =========================
# CONSTANTS / SYSTEMS
# =========================
const HeuristicEngine = preload("res://Scripts/Algorithm/heuristic_engine.gd")
const RuleBase = preload("res://Scripts/Algorithm/Rules/rule_base.gd")

var dialogue_database := DialogueDatabase.new()
var engine := HeuristicEngine.new()
var rule_base := RuleBase.new()

# =========================
# GAME STATE
# =========================
var rules_for_level: Array
var moved_out := false
var current_document: FileDocument
var correct_today: int = 0
# Counter loop
var filetizen_count := 0
var max_filetizens: int
var day: int

var current_answers : Dictionary = {}

# C---------- Mini Games state ----------------
var pending_player_approved: bool = false
var minigame_active: bool = false

# Question buttons inside SlidingPanel
@onready var question_buttons : Dictionary = {
	"filename": sliding_panel.get_node("Panel/ScrollContainer/VBoxContainer/Question1"),
	"extension": sliding_panel.get_node("Panel/ScrollContainer/VBoxContainer/Question2"),
	"size": sliding_panel.get_node("Panel/ScrollContainer/VBoxContainer/Question3"),
	"source": sliding_panel.get_node("Panel/ScrollContainer/VBoxContainer/Question4"),
	"publisher": sliding_panel.get_node("Panel/ScrollContainer/VBoxContainer/Question5"),
	
	"modified": sliding_panel.get_node("Panel/ScrollContainer/VBoxContainer/Question6"),
	"hidden": sliding_panel.get_node("Panel/ScrollContainer/VBoxContainer/Question7"),
	"signature": sliding_panel.get_node("Panel/ScrollContainer/VBoxContainer/Question8"),
	"admin": sliding_panel.get_node("Panel/ScrollContainer/VBoxContainer/Question9"),
	"compressed": sliding_panel.get_node("Panel/ScrollContainer/VBoxContainer/Question10")
}

func _ready():

	GlobalMusic.stop()

	day = GameState.day
	print("day: ", day)
	var rule_level = get_rule_level_from_day(day)
	rules_for_level = rule_base.get_rules(rule_level)
	max_filetizens = get_filetizen_count_from_day(day)

	level_finished.hide()
	wrong_decision_popup.hide()
	paused.hide()
	resource_display.set_level(day)
	filter_activated.hide()

	enable_buttons(false)
	get_tree().paused = false
	print("Game started, paused state:", get_tree().paused)

	setup_question_buttons()	

	$main_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$control_room.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	

	spawn_new_filetizen()
	filetizen_count += 1
	move_filetizen_to_center()

	await get_tree().create_timer(1.0, false).timeout
	spawn_new_file_document()

# =========================
# DIFFICULTY SYSTEM
# =========================
func get_rule_level_from_day(day: int) -> int:
	if day <= 2:
		return 1
	elif day <= 4:
		return 2
	else:
		return 3

func get_filetizen_count_from_day(day: int) -> int:
	match get_rule_level_from_day(day):
		1:
			return 7
		2:
			return 9
		3:
			return 10
		_:
			return 7

func get_suspicious_threshold() -> float:
	match get_rule_level_from_day(day):
		1:
			return 1.0
		2:
			return 1.5
		3:
			return 2.0
		_:
			return 1.0

func is_file_suspicious(score: float) -> bool:
	return score > get_suspicious_threshold()

# =========================
# SPAWN SYSTEM
# =========================
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

# =========================
# FILETIZEN EXIT
# =========================
func move_approved_filetizen():
	var screen_w = get_viewport().get_visible_rect().size.x
	var direction = Vector2(screen_w + 200, filetizen.position.y) - filetizen.position
	filetizen.move_component.move(direction, 300)

	await wait_until_filetizen_exits(screen_w)

	closing_door.play()

func wait_until_filetizen_exits(screen_w: float) -> void:
	while filetizen and is_instance_valid(filetizen):
		if filetizen.position.x > screen_w + 150:
			break
		await get_tree().process_frame

func move_declined_filetizen():
	var screen_w = get_viewport().get_visible_rect().size.x
	var direction = Vector2(screen_w + 200, filetizen.position.y) - filetizen.position
	filetizen.move_component.move(direction, -300)

# =========================
# QUESTION SYSTEM
# =========================
func setup_question_buttons():

	# Connect all buttons
	for key in question_buttons.keys():
		question_buttons[key].pressed.connect(_on_question_button_pressed.bind(key))

	update_question_visibility()

func update_question_visibility():

	var level = get_rule_level_from_day(day)

	# Hide everything first
	for btn in question_buttons.values():
		btn.visible = false

	match level:

		# =====================
		# LEVEL 1
		# =====================
		1:
			question_buttons["filename"].visible = true
			question_buttons["extension"].visible = true
			question_buttons["size"].visible = true
			question_buttons["source"].visible = true
			question_buttons["publisher"].visible = true

		# =====================
		# LEVEL 2
		# =====================
		2:
			for key in [
				"filename",
				"extension",
				"size",
				"source",
				"publisher",
				"modified",
				"hidden"
			]:
				question_buttons[key].visible = true

		# =====================
		# LEVEL 3
		# =====================
		3:
			for key in question_buttons.keys():
				question_buttons[key].visible = true

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
		await get_tree().create_timer(1, false).timeout

		# clear the label
		answer_label.text = ""
		emit_signal("question_asked", key)

func type_text(label: Label, full_text: String, cps: float = 30.0) -> float:
	# ensure inputs are typed
	var text: String = str(full_text)
	label.text = ""
	var duration: float = float(text.length()) / cps

	for i in text.length():
		label.text = text.substr(0, i + 1)
		await get_tree().create_timer(1.0 / cps, false).timeout

	return duration

# =========================
# PROCESS LOOP
# =========================
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
			current_answers = answer_gen.generate_answers(filetizen.metadata, evaluate.score, GameState.day) # temp 0 for now

			# 2️⃣ Evaluate score including answer
			filetizen.metadata.risk_score = evaluate.score
			filetizen.metadata.issues = evaluate.issues

			# 3️⃣ Debug info
			print("Evaluating Filetizen:")
			print("Filename: ", filetizen.metadata.filename)
			print("Updated Score: ", evaluate.score)
			print("Answers: ", current_answers)

			# 4️⃣ Enable buttons
			enable_buttons(true)

# =========================
# BUTTONS
# =========================
func enable_buttons(state: bool):
	approve_btn.disabled = not state
	decline_btn.disabled = not state

func _on_approve_btn_pressed() -> void:
	if current_document:
		current_document.spawn_approve_stamp()
	button_sound.play()
	opening_door.play()
	handle_player_decision(true)

func _on_decline_btn_pressed() -> void:
	if current_document:
		current_document.spawn_decline_stamp()
	button_sound.play()
	handle_player_decision(false)

func _on_filter_btn_pressed() -> void:

	# ✅ Check if player has filters left
	if Player_Data.data["level"] >= 1:
		if Player_Data.get_filter_left() <= 0:
			show_no_filter_popup("filter")
			return
		Player_Data.use_filter()  # Deduct normally

	var score = filetizen.metadata.risk_score
	var suspicious = is_file_suspicious(score)

	filter_activated.play(suspicious)

	if filetizen:
		filetizen.activate_filter()

	await filter_activated.finished

	if filetizen:
		filetizen.deactivate_filter()

func show_no_filter_popup(resource_type: String) -> void:
	var message: String = ""

	match resource_type:
		"filter":
			message = dialogue_database.insufficient_resource[0]  # "Insufficient amount of Filters"
		"evaluate":
			message = dialogue_database.insufficient_resource[1]  # "Insufficient amount of Evaluate"
		_:
			message = "Insufficient resources!"

	# Show the dialogue box instead of printing
	dialogue_box.show_dialogue(message)

# =========================
# MINI GAMES SYSTEM 
# =========================
func start_minigame():
	print("MINIGAME STARTED")
	
		# 🔇 STOP ALL SOUNDS
	button_sound.stop()
	opening_door.stop()
	closing_door.stop()
	filetizen_talking.stop()
	paper_printing.stop()

	var minigame_scene = preload("res://Scenes/Mini Games Scene/malware_attack.tscn")
	var minigame_instance = minigame_scene.instantiate()

	# Add to current scene (NOT as child in editor, only runtime)
	get_tree().current_scene.add_child(minigame_instance)

	# Optional: make sure it's on top
	minigame_instance.z_index = 100

	# Connect signal
	minigame_instance.connect("minigame_finished", Callable(self, "_on_minigame_finished"))

func on_minigame_result(success: bool):

	print("MINIGAME RESULT: ", success)

	minigame_active = false
	wrong_decision_popup.hide()

	if success:
		# ✅ CONTINUE GAME FLOW
		await process_filetizen_exit(pending_player_approved)
		await next_turn_or_end(false)

	else:
		# ❌ REAL GAME OVER
		wrong_decision_popup.show()
		wrong_decision_popup.text.text = build_gameover_message()
		
func _on_minigame_finished(success: bool):
	on_minigame_result(success)

# =========================
# DECISION SYSTEM 
# =========================
func handle_player_decision(player_approved: bool):

	emit_signal("verdict_chosen", player_approved)
	enable_buttons(false)

	var result = evaluate_decision(player_approved)

	emit_signal("verdict_resolved", result.is_correct)
	show_decision_feedback(result)

	# 🚨 STOP NORMAL FLOW if minigame triggered
	if result.trigger_minigame:
		return

	await process_filetizen_exit(player_approved)

	await next_turn_or_end(result.show_gameover)

func evaluate_decision(player_approved: bool) -> Dictionary:

	var score = filetizen.metadata.risk_score
	var suspicious = is_file_suspicious(score)

	var result = {
		"is_correct": false,
		"message": "",
		"show_gameover": false,
		"trigger_minigame": false
	}

	if player_approved == (not suspicious):
		result.is_correct = true
		result.message = dialogue_database.get_random_correct()
		apply_rewards(player_approved, suspicious)

		correct_today += 1
	else:
		if player_approved and suspicious:
			if Player_Data.can_use_minigame(day):
				result.trigger_minigame = true
				result.message = "You made a critical mistake!\nComplete the minigame to recover!"
				
				pending_player_approved = player_approved
				minigame_active = true
				
				Player_Data.mark_minigame_used(day)
			else:
				result.show_gameover = true
				result.message = build_gameover_message()
		else:
			result.message = build_wrong_message()

	return result

func apply_rewards(player_approved: bool, suspicious: bool):
	if player_approved and not suspicious:
		Player_Data.add_bug_bounty(1)
	elif not player_approved and suspicious:
		Player_Data.add_bug_bounty(2)

func build_wrong_message() -> String:
	var message = dialogue_database.get_random_wrong()
	message += "\n" + dialogue_database.build_wrong_details(filetizen.metadata.issues)
	return message

func build_gameover_message() -> String:
	var message = "Game Over: This file was unsafe but you approved it!\n"
	message += dialogue_database.get_random_wrong()
	message += "\n" + dialogue_database.build_wrong_details(filetizen.metadata.issues)
	return message

func show_decision_feedback(result: Dictionary):
	if result.trigger_minigame:
		start_minigame()

	elif result.show_gameover:
		wrong_decision_popup.show()
		wrong_decision_popup.text.text = result.message

	else:
		dialogue_box.show_dialogue(result.message)

func process_filetizen_exit(player_approved: bool) -> void:

	await get_tree().create_timer(1.0, false).timeout

	if player_approved:
		move_approved_filetizen()
	else:
		move_declined_filetizen()

	if current_document:
		current_document.queue_free()
		current_document = null

	await get_tree().create_timer(3.0, false).timeout
	moved_out = false


func next_turn_or_end(show_gameover: bool) -> void:
	
	if minigame_active:
		return

	if filetizen_count < max_filetizens and not show_gameover:
		dialogue_box.hide_dialogue()
		spawn_new_filetizen()
		filetizen_count += 1
		move_filetizen_to_center()

		await get_tree().create_timer(1.0, false).timeout
		spawn_new_file_document()

	else:
		if show_gameover:
			wrong_decision_popup.show()
		else:
			commit_day_progress()
			level_finished.z_index = 20
			level_finished.setup_dialogue(GameState.day)
			level_finished.show()
			level_up()

func commit_day_progress():
	if correct_today > 0:
		Player_Data.data["total_inspected"] += correct_today
		Player_Data.save_data()

		print("Day completed. Added correct inspections:", correct_today)
		print("New total inspected:", Player_Data.data["total_inspected"])

	correct_today = 0

func level_up():
	var current_level = Player_Data.data["level"]
	if day > current_level:
		Player_Data.set_level(day)
		print("Level up! New player level: ", day)
	else:
		print("Player already has a higher level: ", current_level)


func _on_pause_btn_pressed() -> void:
	paused.show()
	paused.z_index = 20
	get_tree().paused = true
