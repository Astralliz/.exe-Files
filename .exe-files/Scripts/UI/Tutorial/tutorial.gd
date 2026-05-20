class_name Tutorial
extends Node2D

# ========================
# ONREADY REFERENCES
# ========================
@onready var filetizen = $Filetizen
@onready var filter_activated: Node2D = $FilterActivated
@onready var spawn_filetizen: SpawnerComponent = $FiletizenSpawner
@onready var document_spawner: SpawnerComponent = $DocumentSpawner
@onready var actors: Node2D = $Actors
@onready var documents: Node2D = $Document
@onready var filter_btn: Button = $FilterPanel/FilterBtn
@onready var approve_btn: Button = $ApproveBtn
@onready var decline_btn: Button = $DeclineBtn
@onready var answer_label: Label = $Answer_Label
@onready var dialogue_box: DialogueBox = $"Dialogue Box"
@onready var paused_btn: Button = $PauseBtn
@onready var paused: Control = $Pause
@onready var resource_display = $ResourceDisplay
@onready var sliding_panel: Control = $SlidingPanel
@onready var tutorial_dialogue: TutorialDialogueBox = $"TutorialDialogue"
@onready var skip_button: Button = $SkipButton

# Audio
@onready var pickup_sound = $Audio_Pickup
@onready var button_sound = $Button_Click
@onready var paper_printing = $Printing_Paper
@onready var filetizen_talking = $Talking
@onready var filetizen_talking_girl = $TalkingGirl
@onready var opening_door = $Open_Door
@onready var closing_door = $Closed_Door

@onready var threshold_score_day: Label = $Threshold

# ========================
# TUTORIAL MANAGER
# ========================
@onready var tutorial_manager: TutorialManager = $TutorialManager

# ========================
# SYSTEMS
# ========================
const HeuristicEngine = preload("res://Scripts/Algorithm/heuristic_engine.gd")
const RuleBase = preload("res://Scripts/Algorithm/Rules/rule_base.gd")

var engine := HeuristicEngine.new()
var rule_base := RuleBase.new()
var tutorial_metadata_generator := TutorialMetadataGenerator.new()
var dialogue_database := DialogueDatabase.new()


var _active_tutorial_panel: Control = null
# ========================
# GAME STATE
# ========================
var rules_for_level: Array
var moved_out := false
var current_document: FileDocument
var correct_today: int = 0
var filetizen_count := 0
var current_step: int = 0
var total_steps: int = 5
var max_filetizens: int = 5
var current_answers: Dictionary = {}

var prev_position := Vector2.ZERO

@onready var question_buttons: Dictionary = {
	"filename":  sliding_panel.get_node("Panel/ScrollContainer/VBoxContainer/Question1"),
	"extension": sliding_panel.get_node("Panel/ScrollContainer/VBoxContainer/Question2"),
	"size":      sliding_panel.get_node("Panel/ScrollContainer/VBoxContainer/Question3"),
	"source":    sliding_panel.get_node("Panel/ScrollContainer/VBoxContainer/Question4"),
	"publisher": sliding_panel.get_node("Panel/ScrollContainer/VBoxContainer/Question5"),
}

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	GlobalMusic.stop()
	paused.hide()
	resource_display.set_level(1)
	rules_for_level = rule_base.get_rules(1)
	max_filetizens = total_steps

	enable_buttons(false)
	get_tree().paused = false
	setup_question_buttons()

	$main_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$control_room.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_manager.show_panel_requested.connect(_on_show_panel_requested)

	tutorial_dialogue.z_index = 999
	skip_button.z_index = 1000 

	# ✅ Wire skip button
	skip_button.pressed.connect(_on_skip_button_pressed)

	# Wire buttons
	approve_btn.pressed.connect(_on_approve_btn_pressed)
	decline_btn.pressed.connect(_on_decline_btn_pressed)
	filter_btn.pressed.connect(_on_filter_btn_pressed)
	paused_btn.pressed.connect(_on_pause_btn_pressed)

	# Wire TutorialManager
	tutorial_manager.setup(tutorial_dialogue, dialogue_box)
	tutorial_manager.spawn_filetizen_requested.connect(_do_spawn_filetizen)
	tutorial_manager.spawn_document_requested.connect(_do_spawn_document)
	tutorial_manager.tutorial_finished.connect(_on_tutorial_finished)

	# Start — only shows Part 0 welcome dialogue, nothing spawns yet
	tutorial_manager.start()
	

func start_threshold_typing_animation() -> void:

	var message = "Suspicious Threshold: 1.0+"

	while true:

		# =========================
		# TYPE TEXT WITH GLITCH
		# =========================
		for i in range(message.length()):

			var partial = message.substr(0, i + 1)

			# random glitch chance
			if randf() < 0.25:
				partial = apply_glitch(partial)

			threshold_score_day.text = partial + "|"

			await get_tree().create_timer(
				randf_range(0.03, 0.08),
				false
			).timeout

		# =========================
		# BLINKING CARET
		# =========================
		var blink_time := 3.0
		var elapsed := 0.0
		var caret_visible := true

		while elapsed < blink_time:

			var display_text = message

			# occasional glitch while idle
			if randf() < 0.2:
				display_text = apply_glitch(display_text)

			if caret_visible:
				threshold_score_day.text = display_text + "|"
			else:
				threshold_score_day.text = display_text

			caret_visible = !caret_visible

			await get_tree().create_timer(0.4, false).timeout

			elapsed += 0.4

		# =========================
		# RESET
		# =========================
		threshold_score_day.text = ""

		await get_tree().create_timer(0.5, false).timeout	

func apply_glitch(text: String) -> String:

	var glitch_chars = [
		"#", "%", "&", "@", "!", "?",
		"$", "*", "=", "+", "~"
	]

	if text.length() <= 0:
		return text

	var chars = text.split("")

	# number of glitched letters
	var glitch_count = randi_range(1, min(3, chars.size()))

	for i in range(glitch_count):

		var index = randi_range(0, chars.size() - 1)

		# avoid replacing spaces
		if chars[index] != " ":
			chars[index] = glitch_chars.pick_random()

	return "".join(chars)
# ========================
# SPAWNING — only called by TutorialManager signals
# ========================
func _do_spawn_filetizen() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	var spawn_pos = Vector2(-100, screen_size.y / 2)

	var new_filetizen: Node2D = spawn_filetizen.spawn(spawn_pos, actors)
	filetizen = new_filetizen

	var tutorial_metadata = tutorial_metadata_generator.generate_metadata(current_step)
	filetizen.metadata = tutorial_metadata

	var evaluation = engine.evaluate(tutorial_metadata, rules_for_level)
	tutorial_metadata.risk_score = evaluation.score
	tutorial_metadata.issues = evaluation.issues

	move_filetizen_to_center()
	prev_position = filetizen.position
	filetizen_count += 1

	print("Tutorial Step %d: Spawned Filetizen" % current_step)
	print("Filename: ", tutorial_metadata.filename)
	print("Risk Score: ", tutorial_metadata.risk_score)

func _do_spawn_document() -> void:
	var spawn_pos = Vector2(1035, 274)
	var new_doc: FileDocument = document_spawner.spawn(spawn_pos, documents) as FileDocument
	new_doc.set_metadata(filetizen.metadata)
	new_doc.initialize_paper()
	paper_printing.play()
	current_document = new_doc
	current_document.document_opened.connect(_on_tutorial_document_opened)
	current_document.document_closed.connect(_on_tutorial_document_closed)

func _on_tutorial_document_opened() -> void:

	print("TUTORIAL RECEIVED: document_opened")

	tutorial_manager.notify_event("document_opened")


func _on_tutorial_document_closed() -> void:

	print("TUTORIAL RECEIVED: document_closed")

	tutorial_manager.notify_event("document_closed")

# ========================
# FILETIZEN MOVEMENT
# ========================
func move_filetizen_to_center() -> void:
	var target = get_viewport().get_visible_rect().size / 2.0
	var direction = target - filetizen.position
	filetizen.move_component.move(direction, 250)

func move_approved_filetizen() -> void:
	var screen_w = get_viewport().get_visible_rect().size.x
	if filetizen and is_instance_valid(filetizen):
		var direction = Vector2(screen_w + 200, filetizen.position.y) - filetizen.position
		filetizen.move_component.move(direction, 300)
		await wait_until_filetizen_exits(screen_w)
		closing_door.play()
	filetizen = null

func move_declined_filetizen() -> void:
	var screen_w = get_viewport().get_visible_rect().size.x
	if filetizen and is_instance_valid(filetizen):
		var direction = Vector2(screen_w + 200, filetizen.position.y) - filetizen.position
		filetizen.move_component.move(direction, -300)
		await wait_until_filetizen_exits(screen_w)
	filetizen = null

func wait_until_filetizen_exits(screen_w: float) -> void:
	while filetizen and is_instance_valid(filetizen):
		if filetizen.position.x > screen_w + 150:
			break
		await get_tree().process_frame

# ========================
# QUESTION SYSTEM
# ========================
func setup_question_buttons() -> void:
	for key in question_buttons.keys():
		question_buttons[key].pressed.connect(_on_question_button_pressed.bind(key))
	update_question_visibility()

func update_question_visibility() -> void:
	for btn in question_buttons.values():
		btn.visible = true   # all visible in tutorial

func _on_question_button_pressed(key: String) -> void:
	if key in current_answers:
		var text: String = str(current_answers[key])
		var cps: float = 25.0
		filetizen.move_component.bounce_for(float(text.length()) / cps)
		if filetizen.is_female():
			filetizen_talking_girl.play()
		else:
			filetizen_talking.play()
		await type_text(answer_label, text, cps)
		await get_tree().create_timer(1.0, false).timeout
		answer_label.text = ""
		# Notify manager that a question was asked
		tutorial_manager.notify_event("question_asked")

func type_text(label: Label, full_text: String, cps: float = 30.0) -> void:
	label.text = ""
	for i in full_text.length():
		label.text = full_text.substr(0, i + 1)
		await get_tree().create_timer(1.0 / cps, false).timeout


func _on_show_panel_requested(scene_path: String) -> void:
	# Clean up any previously shown panel
	if _active_tutorial_panel and is_instance_valid(_active_tutorial_panel):
		_active_tutorial_panel.queue_free()
		_active_tutorial_panel = null

	var packed: PackedScene = load(scene_path)
	if not packed:
		push_error("TutorialManager: could not load panel scene: " + scene_path)
		return

	var panel: Control = packed.instantiate()
	add_child(panel)
	_active_tutorial_panel = panel

	# If the panel has a close/done signal, dismiss it when fired
	if panel.has_signal("panel_closed"):
		panel.panel_closed.connect(_on_tutorial_panel_closed)

func _on_tutorial_panel_closed() -> void:
	if _active_tutorial_panel and is_instance_valid(_active_tutorial_panel):
		_active_tutorial_panel = null
	
	# When a panel closes, advance to the next part
	# This handles both:
	# 1. Part 1 (DocumentTutorialPanel) → advances to Part 2 (shows dialogue)
	# 2. Part 2 (ButtonPanel) → advances to Part 3 (shows questions dialogue)
	tutorial_manager.advance_to(tutorial_manager.current_part + 1)

# ========================
# PROCESS LOOP
# ========================
func _process(_delta: float) -> void:

	var target = get_viewport().get_visible_rect().size / 2.0

	if filetizen and is_instance_valid(filetizen):

		var current_pos = filetizen.position

		if not moved_out:

			# ✅ Detect crossing center
			if prev_position.x < target.x and current_pos.x >= target.x:

				# snap perfectly to center
				filetizen.position = target

				# stop movement
				filetizen.move_component.stop()

				moved_out = true

				var answer_gen = AnswerGenerator.new()

				var evaluate = engine.evaluate(
					filetizen.metadata,
					rules_for_level
				)

				current_answers = answer_gen.generate_answers(
					filetizen.metadata,
					evaluate.score,
					1
				)

				print("Score: ", evaluate.score)
				print("Answers: ", current_answers)

				enable_buttons(true)

		prev_position = current_pos

# ========================
# BUTTON HANDLERS
# ========================
func enable_buttons(state: bool) -> void:
	approve_btn.disabled = not state
	decline_btn.disabled = not state

func _on_approve_btn_pressed() -> void:
	if current_document:
		current_document.spawn_approve_stamp()
	button_sound.play()
	opening_door.play()
	tutorial_manager.notify_event("verdict_chosen")
	handle_player_decision(true)

func _on_decline_btn_pressed() -> void:
	if current_document:
		current_document.spawn_decline_stamp()
	button_sound.play()
	tutorial_manager.notify_event("verdict_chosen")
	handle_player_decision(false)

func _on_filter_btn_pressed() -> void:
	var score = filetizen.metadata.risk_score
	var suspicious = score > 1.0
	filter_activated.play(suspicious, 
		filetizen.get_clean_texture(),
		filetizen.get_corrupted_texture(),
		filetizen.is_female())
	if filetizen:
		filetizen.activate_filter()
	await filter_activated.finished
	if filetizen:
		filetizen.deactivate_filter()
	tutorial_manager.notify_event("filter_used")

func _on_pause_btn_pressed() -> void:
	paused.show()
	paused.z_index = 20
	get_tree().paused = true

# ========================
# SKIP BUTTON
# ========================
func _on_skip_button_pressed() -> void:
	print("✓ Tutorial skipped by user")
	button_sound.play()
	_finish_tutorial()

# ========================
# DECISION SYSTEM
# ========================
func handle_player_decision(player_approved: bool) -> void:
	enable_buttons(false)
	var result = evaluate_decision(player_approved)
	await get_tree().create_timer(0.8).timeout
	dialogue_box.show_dialogue(result.message)
	await process_filetizen_exit(player_approved)
	await next_turn_or_end()

func evaluate_decision(player_approved: bool) -> Dictionary:
	var suspicious = filetizen.metadata.risk_score > 1.0
	var is_correct = player_approved == (not suspicious)
	if is_correct:
		correct_today += 1
	return {
		"is_correct": is_correct,
		"message": "Correct. Good analysis." if is_correct else "Not quite. Look carefully at the metadata.",
	}

func process_filetizen_exit(player_approved: bool) -> void:
	await get_tree().create_timer(1.0, false).timeout
	if player_approved:
		await move_approved_filetizen()
	else:
		await move_declined_filetizen()
	if current_document:
		current_document.queue_free()
		current_document = null
	await get_tree().create_timer(3.0, false).timeout
	moved_out = false

func next_turn_or_end() -> void:
	dialogue_box.hide_dialogue()
	if current_step < total_steps - 1:
		current_step += 1
		_do_spawn_filetizen()
		await get_tree().create_timer(1.0, false).timeout
		_do_spawn_document()
	# If all steps done, TutorialManager handles finish via tutorial_finished signal

# ========================
# TUTORIAL FINISHED
# ========================
func _finish_tutorial() -> void:
	print("Tutorial complete — transitioning to day.tscn")
	GameState.day = 1
	SceneLoader.load_scene("res://Scenes/Menu Scenes/Story Scene/day.tscn")

func _on_tutorial_finished() -> void:
	_finish_tutorial()
