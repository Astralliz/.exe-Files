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
# -------------------------------------------------
# Audio
# -------------------------------------------------
@onready var pickup_sound = $Audio_Pickup
@onready var button_sound = $Button_Click
@onready var paper_printing = $Printing_Paper
@onready var filetizen_talking = $Talking

# -------------------------------------------------
# Sliding Panel (Questions Scene
# -------------------------------------------------
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

const HeuristicEngine = preload("res://Scripts/Algorithm/heuristic_engine.gd")
const RuleBase = preload("res://Scripts/Algorithm/Rules/rule_base.gd")

var engine := HeuristicEngine.new()
var rule_base := RuleBase.new()
var rules_for_level1 = rule_base.get_rules(1)

var moved_out := false
var current_document: FileDocument
#Counter loop
var filetizen_count := 0
const MAX_FILETIZENS := 7

func _ready():
	level_finished.hide()
	
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

# MOVE FILETIZEN AFTER DECISION
func move_approved_filetizen():
	var screen_w = get_viewport().get_visible_rect().size.x
	var direction = Vector2(screen_w + 200, filetizen.position.y) - filetizen.position
	filetizen.move_component.move(direction, 300)

func move_declined_filetizen():
	var screen_w = get_viewport().get_visible_rect().size.x
	var direction = Vector2(screen_w + 200, filetizen.position.y) - filetizen.position
	filetizen.move_component.move(direction, -300)

func _process(delta):
	var target = get_viewport().get_visible_rect().size / 2.0
	
	if filetizen and is_instance_valid(filetizen):
		if not moved_out and filetizen.position.distance_to(target) < 5.0:
			filetizen.move_component.stop()
			moved_out = true
			
			var score = engine.evaluate(filetizen.metadata, rules_for_level1, current_answers)
			print("Score: ", score)
			
			# 1️⃣ Generate answers first (for risky files, it will create lies)
			var answer_gen = AnswerGenerator.new()
			current_answers = answer_gen.generate_answers(filetizen.metadata, score) # temp 0 for now


			# 2️⃣ Evaluate score including answer
			score += engine.evaluate_type_mismatch(filetizen.metadata, current_answers, rules_for_level1)
			filetizen.metadata.risk_score = score

			# 3️⃣ Debug info
			print("Evaluating Filetizen:")
			print("Filename: ", filetizen.metadata.filename)
			print("Updated Score: ", score)
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
	enable_buttons(false)
	var score = filetizen.metadata.risk_score
	var approved = score <= 1.0

	if player_approved == approved:
		print("✔ Correct decision!")
	else:
		print("✘ Incorrect decision!")

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
	
	# Only spawn new Filetizen if under the max count
	if filetizen_count < MAX_FILETIZENS:
		spawn_new_filetizen()
		filetizen_count += 1
		move_filetizen_to_center()
		await get_tree().create_timer(1.0).timeout
		spawn_new_file_document()
	else:
		print("✅ All Filetizens completed.")
		level_finished.z_index = 20
		level_finished.show()
