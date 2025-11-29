extends Node2D

@onready var filetizen = $Filetizen
@onready var spawn_filetizen: SpawnerComponent = $FiletizenSpawner
@onready var document_spawner: SpawnerComponent = $DocumentSpawner
@onready var actors: Node2D = $Actors
@onready var documents: Node2D = $Document
@onready var approve_btn: Button = $ApproveBtn
@onready var decline_btn: Button = $DeclineBtn

const HeuristicEngine = preload("res://Scripts/Algorithm/heuristic_engine.gd")
const RuleBase = preload("res://Scripts/Algorithm/Rules/rule_base.gd")

var engine := HeuristicEngine.new()
var rule_base := RuleBase.new()

var moved_out := false
var current_document: FileDocument

func _ready():
	$main_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$control_room.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	enable_buttons(false)
	spawn_new_filetizen()
	move_filetizen_to_center()
	await get_tree().create_timer(1.0).timeout
	spawn_new_file_document()

# -------------------------
# SPAWN / MOVE FILETIZEN
# -------------------------
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
	current_document = new_doc

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

	if not moved_out and filetizen.position.distance_to(target) < 5.0:
		filetizen.move_component.stop()
		moved_out = true
		var score = engine.evaluate(filetizen.metadata, rule_base)
		filetizen.metadata.risk_score = score
		print("Evaluating Filetizen:")
		print("Filename: ", filetizen.metadata.filename)
		print("Score: ", score)
		enable_buttons(true)

func enable_buttons(state: bool):
	approve_btn.disabled = not state
	decline_btn.disabled = not state

func _on_approve_btn_pressed() -> void:
	if current_document:
		current_document.spawn_approve_stamp()
	handle_player_decision(true)

func _on_decline_btn_pressed() -> void:
	if current_document:
		current_document.spawn_decline_stamp()
	handle_player_decision(false)

func handle_player_decision(player_approved: bool):
	enable_buttons(false)
	var score = filetizen.metadata.risk_score
	var approved = score <= 2.0

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
	spawn_new_filetizen()
	move_filetizen_to_center()
	await get_tree().create_timer(1.0).timeout
	spawn_new_file_document()
