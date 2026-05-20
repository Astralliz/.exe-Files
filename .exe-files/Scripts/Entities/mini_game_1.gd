extends Control
class_name MiniGame

signal minigame_finished(success: bool)

@onready var belt1: Panel = $Conveyor/Belt1
@onready var belt2: Panel = $Conveyor/Belt2
@onready var paper_container: Panel = $PaperContainer
@onready var attack_class_container: HBoxContainer = $AttackClass
@onready var bounty_label: Label = $BountyValue
@onready var score_label: Label = $ScoreValue

@onready var wrong_indicator: HBoxContainer = $FalseIndicator
@onready var panel_indicator1: Panel = $FalseIndicator/Panel
@onready var panel_indicator2: Panel = $FalseIndicator/Panel2
@onready var panel_indicator3: Panel = $FalseIndicator/Panel3

@onready var paused: Control = $Pause

const PAPER_TEXTURE = preload("res://Assets/Sprites/large-paper.png")
const GAME_FONT     = preload("res://Assets/Fonts/kenney_mini_square.ttf")
const FILE_DOCUMENT_SCENE = preload("res://Scenes/Entities Scenes/mini_game_file_document.tscn")
const MINIGAME_FINISHED_SCENE = preload("res://Scenes/Finishing Scenes/mini_game_finished.tscn")
const MINIGAME_TUTORIAL_PANEL = preload("res://Scenes/UI/tutorial_panels/mini_game_tutorial_panel.tscn")
const MINIGAME_TUTORIAL_PANELS = preload("res://Scenes/UI/tutorial_panels/mini_game_Panel.tscn")

const MAX_ROUNDS          = 10
const CONVEYOR_SPEED      = 150.0
const PAPER_SPAWN_INTERVAL = 1.5
const PAPER_WIDTH         = 220
const PAPER_HEIGHT        = 280
const PAPER_GAP           = 10

var y_true: Array = []
var y_pred: Array = []
var stopped_papers: Array        = []
var decision_tree
var current_rounds: Array        = []
var active_papers: Dictionary    = {}
var current_round_index: int     = 0
var total_score: int             = 0
var game_finished: bool          = false
var spawn_timer: float           = 0.0
var attack_panels: Dictionary    = {}
var is_tutorial_running: bool    = false

var wrong_drops: int = 0
var max_wrong_drops: int = 3

var parent_day: Day

# ══════════════════════════════════════════════════════════════
# PAPER CLASS
# ══════════════════════════════════════════════════════════════
class Paper extends Panel:
	enum State { CONVEYOR, OPEN, RETURNING }

	var metadata
	var state: State = State.CONVEYOR

	var is_dragging: bool = false
	var is_animating: bool = false

	var original_pos: Vector2 = Vector2.ZERO
	var drag_offset: Vector2 = Vector2.ZERO
	var click_pos: Vector2 = Vector2.ZERO
	var drag_threshold: float = 10.0

	var game_reference
	var last_touch_pos: Vector2 = Vector2.ZERO

	const SCALE_CONVEYOR = Vector2(1, 1)
	const SCALE_OPEN = Vector2(1.5, 1.5)
	
	var opened_document: Node = null

	# ── Setup ────────────────────────────────────────────────
	func _ready() -> void:
		custom_minimum_size = Vector2(PAPER_WIDTH, PAPER_HEIGHT)
		mouse_filter = Control.MOUSE_FILTER_STOP

		var style = StyleBoxTexture.new()
		style.texture = game_reference.PAPER_TEXTURE
		add_theme_stylebox_override("panel", style)
		

		var lbl = Label.new()
		lbl.text = str(metadata.paper_no)
		lbl.anchor_left = 0.5
		lbl.anchor_top = 0.1
		lbl.offset_left = -13
		lbl.offset_top = -1
		lbl.add_theme_font_override("font", game_reference.GAME_FONT)
		lbl.add_theme_font_size_override("font_size", 70)
		lbl.add_theme_color_override("font_color", Color.BLACK)
		add_child(lbl)

		gui_input.connect(_on_gui_input)

	# ── Input ────────────────────────────────────────────────
	func _on_gui_input(event: InputEvent) -> void:
		if is_animating:
			return

		# ── TOUCH ──────────────────────────────────────────
		if event is InputEventScreenTouch:
			if event.pressed:
				click_pos = event.position
				last_touch_pos = event.position
				var touch_global = get_viewport().get_mouse_position()
				drag_offset = touch_global - global_position
			else:
				var release_pos = last_touch_pos
				if is_dragging:
					_stop_dragging(release_pos)
				else:
					if release_pos.distance_to(click_pos) < drag_threshold:
						_handle_tap()

		elif event is InputEventScreenDrag:
			last_touch_pos = event.position
			
			var touch_global = get_viewport().get_mouse_position()
			
			if state == State.OPEN:
				if not is_dragging:
					if event.position.distance_to(click_pos) > drag_threshold:
						_start_dragging(event.position)
				if is_dragging:
					global_position = touch_global - drag_offset

		# ── MOUSE ──────────────────────────────────────────
		elif event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					click_pos = get_global_mouse_position()
					drag_offset = click_pos - global_position
				else:
					var release_pos = get_global_mouse_position()
					if is_dragging:
						_stop_dragging(release_pos)
					else:
						if release_pos.distance_to(click_pos) < drag_threshold:
							_handle_tap()

		elif event is InputEventMouseMotion:
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				var gmp = get_global_mouse_position()

				if state == State.OPEN:
					if not is_dragging:
						if gmp.distance_to(click_pos) > drag_threshold:
							_start_dragging(gmp)

					if is_dragging:
						global_position = gmp - drag_offset

	# ── Tap Logic ────────────────────────────────────────────
	func _handle_tap() -> void:
		match state:
			State.CONVEYOR:
				if self in game_reference.stopped_papers:
					_open_file()
			State.OPEN:
				_close_file()

	# ── Open / Close ─────────────────────────────────────────
	func _open_file() -> void:
		state = State.OPEN
		is_dragging = false

		if self not in game_reference.stopped_papers:
			game_reference.stopped_papers.append(self)

		z_index = 100
		modulate = Color(1, 1, 1, 0)
		
		original_pos = position

		var doc = game_reference.FILE_DOCUMENT_SCENE.instantiate()
		get_tree().current_scene.add_child(doc)

		doc.global_position = get_viewport_rect().size / 2

		# pass metadata
		doc.set_metadata(metadata)
		opened_document = doc  
		doc.open_document()
		
		# ✅ Wait for document to be freed, then show paper
		await _monitor_document_close()

	func _monitor_document_close() -> void:
		# ✅ Poll until document is destroyed
		while is_instance_valid(opened_document):
			await get_tree().process_frame
		
		# ✅ Document was closed, show the paper again
		if is_instance_valid(self):
			modulate = Color(1, 1, 1, 1)  # Show paper (alpha = 1)
			# ✅ KEEP state as OPEN so paper can still be dragged!
			opened_document = null

	func _close_file() -> void:
		state = State.RETURNING
		is_dragging = false

		z_index = 0

		var tw = create_tween().set_parallel(true)
		tw.tween_property(self, "position", original_pos, 0.25)
		tw.tween_property(self, "scale", SCALE_CONVEYOR, 0.25)

		await tw.finished

		state = State.CONVEYOR

	# ── Drag ─────────────────────────────────────────────────
	func _start_dragging(global_press_pos: Vector2) -> void:
		if state != State.OPEN:
			return

		is_dragging = true
		drag_offset = global_press_pos - global_position
		z_index = 100

	func _stop_dragging(global_release_pos: Vector2) -> void:
		is_dragging = false
		z_index = 0
		_check_drop_target(global_release_pos)

	# ── Drop Logic ───────────────────────────────────────────
	func _check_drop_target(global_drop_pos: Vector2) -> void:
		for attack_name in game_reference.attack_panels:
			var panel: Panel = game_reference.attack_panels[attack_name]

			if panel.get_global_rect().has_point(global_drop_pos):
				game_reference.record_result(attack_name, metadata.actual_label)
				if attack_name == metadata.actual_label:
					print("✔ CORRECT DROP ->", attack_name)
					await _accept_paper()
				else:
					print("✖ WRONG DROP ->", attack_name)
					await _reject_paper()

				return

		# no panel hit → return to conveyor slot
		_close_file()

	# ── Results ──────────────────────────────────────────────
	func _accept_paper() -> void:
		is_animating = true

		var tw = create_tween().set_parallel(true)
		tw.tween_property(self, "scale", Vector2.ZERO, 0.3)
		tw.tween_property(self, "modulate:a", 0.0, 0.3)

		await tw.finished

		game_reference.on_paper_correct(metadata.paper_no)
		queue_free()

	func _reject_paper() -> void:
		is_animating = true

		var tw = create_tween()
		tw.tween_property(self, "modulate", Color.RED, 0.1)
		await tw.finished

		var tw2 = create_tween()
		tw2.tween_property(self, "modulate", Color.WHITE, 0.2)
		await tw2.finished
		
		# PENALTY
		Player_Data.modify_bug_bounty(-1)

		game_reference.total_score -= 10

		# Prevent negative score
		if game_reference.total_score < 0:
			game_reference.total_score = 0

		game_reference.score_label.text = str(game_reference.total_score)

		# =========================
		# WRONG DROP SYSTEM
		# =========================
		game_reference.wrong_drops += 1
		game_reference.update_wrong_indicator()

		# GAME OVER
		if game_reference.wrong_drops >= game_reference.max_wrong_drops:
			game_reference._finish_game(false)
			return

		_close_file()
		is_animating = false

# ══════════════════════════════════════════════════════════════
# READY
# ══════════════════════════════════════════════════════════════
func _ready() -> void:
	paper_container.clip_contents   = true
	paper_container.mouse_filter    = Control.MOUSE_FILTER_PASS
	
	Player_Data.bug_bounty_changed.connect(_on_bug_bounty_changed)
	bounty_label.text = str(Player_Data.get_bug_bounty())
	score_label.text = str(total_score)
	update_wrong_indicator()
	
	paused.hide()
	paused.setup_pause(true, parent_day, self)

	decision_tree  = DecisionTree.new()
	setup_attack_panels()
	current_rounds = decision_tree.generate_all_rounds(MAX_ROUNDS)

	# ✅ START TUTORIAL (if needed)
	print("MiniGame started - checking tutorial requirements...")
	await _check_and_run_tutorial()
	print("Tutorial check complete - game ready!")

# ══════════════════════════════════════════════════════════════
# TUTORIAL HANDLING
# ══════════════════════════════════════════════════════════════
func _check_and_run_tutorial() -> void:
	# Check if player has already completed the "Threat Neutralizer" achievement
	if Player_Data.data["achievements"].has("Threat Neutralizer"):
		print("✓ Tutorial skipped: Already have 'Threat Neutralizer' achievement")
		return
	
	print("⚠ Tutorial starting - 'Threat Neutralizer' achievement not yet unlocked")
	
	# ✅ Set flag to indicate tutorial is running
	is_tutorial_running = true
	
	# ✅ Pause the game (don't spawn papers or run game logic)
	set_process(false)
	
	# Step 1: Show the initial dialogue tutorial
	await _show_dialogue_tutorial()
	
	# ✅ RESUME GAME BEFORE PANEL TUTORIAL - so papers spawn and game runs while panel shows
	set_process(true)
	is_tutorial_running = false
	print("✓ Dialogue tutorial finished - starting minigame with panel tutorial overlay")
	
	# Step 2: Show the interactive panel tutorial (game is running in background)
	await _show_panel_tutorial()
	
	print("✓ Tutorial complete - minigame fully active")

func _show_dialogue_tutorial() -> void:
	print("Showing dialogue tutorial...")
	
	# Create a CanvasLayer to ensure tutorial appears on top
	var canvas_layer = CanvasLayer.new()
	get_tree().current_scene.add_child(canvas_layer)
	
	var tutorial_dialogue = MINIGAME_TUTORIAL_PANEL.instantiate() as MiniGameTutorialPanel
	canvas_layer.add_child(tutorial_dialogue)
	
	# Ensure tutorial panel takes full screen
	tutorial_dialogue.set_anchors_preset(Control.PRESET_FULL_RECT)
	tutorial_dialogue.z_index = 100
	
	# Wait for the tutorial to finish
	await tutorial_dialogue.tutorial_finished
	print("✓ Dialogue tutorial finished")
	
	# Clean up canvas layer
	canvas_layer.queue_free()

func _show_panel_tutorial() -> void:
	print("Showing panel tutorial...")
	
	# Create a CanvasLayer to ensure tutorial appears on top
	var canvas_layer = CanvasLayer.new()
	get_tree().current_scene.add_child(canvas_layer)
	
	var tutorial_panels = MINIGAME_TUTORIAL_PANELS.instantiate() as MiniGameTutorialPanels
	canvas_layer.add_child(tutorial_panels)
	
	# Ensure tutorial panel takes full screen
	tutorial_panels.set_anchors_preset(Control.PRESET_FULL_RECT)
	tutorial_panels.z_index = 100
	
	# Wait for the tutorial to finish
	await tutorial_panels.tutorial_completed
	print("✓ Panel tutorial finished")
	
	# Clean up canvas layer
	canvas_layer.queue_free()

func record_result(predicted: String, actual: String):
	y_pred.append(predicted)
	y_true.append(actual)

# ══════════════════════════════════════════════════════════════
# PROCESS
# ══════════════════════════════════════════════════════════════
func _process(delta: float) -> void:
	if game_finished or is_tutorial_running:
		return

	_update_conveyor(delta)

	spawn_timer += delta
	if spawn_timer >= PAPER_SPAWN_INTERVAL and current_round_index < MAX_ROUNDS:
		_spawn_paper()
		spawn_timer = 0.0

	_move_papers(delta)
	
	if current_round_index >= MAX_ROUNDS and active_papers.is_empty():
		_finish_game(true)


# ══════════════════════════════════════════════════════════════
# SPAWN
# ══════════════════════════════════════════════════════════════
func _spawn_paper() -> void:
	var round_data = current_rounds[current_round_index]
	var meta       = round_data["metadata"]

	var paper           = Paper.new()
	paper.metadata      = meta
	paper.game_reference = self
	paper.position      = Vector2(paper_container.size.x - PAPER_WIDTH - 20, 30)
	paper_container.add_child(paper)

	paper.original_pos = paper.position

	active_papers[meta.paper_no] = paper
	current_round_index += 1


# ══════════════════════════════════════════════════════════════
# MOVEMENT
# ══════════════════════════════════════════════════════════════
func _move_papers(delta: float) -> void:
	for paper_no in active_papers.keys():
		var paper = active_papers[paper_no]
		if not is_instance_valid(paper):
			active_papers.erase(paper_no)
			continue

		if paper.is_dragging or paper in stopped_papers:
			continue

		paper.position.x -= CONVEYOR_SPEED * delta

		var stop_x = _get_stop_x_for(paper)
		if paper.position.x <= stop_x:
			paper.position.x  = stop_x
			paper.original_pos = paper.position
			stopped_papers.append(paper)


func _get_stop_x_for(paper: Panel) -> float:
	var idx = 0
	for p in stopped_papers:
		if is_instance_valid(p):
			idx += 1
	return 10.0 + idx * (PAPER_WIDTH + PAPER_GAP)


# ══════════════════════════════════════════════════════════════
# CONVEYOR BELT ANIMATION
# ══════════════════════════════════════════════════════════════
func _update_conveyor(delta: float) -> void:
	belt1.position.x -= CONVEYOR_SPEED * delta
	belt2.position.x -= CONVEYOR_SPEED * delta

	if belt1.position.x <= -belt1.size.x:
		belt1.position.x = belt2.position.x + belt2.size.x
	if belt2.position.x <= -belt2.size.x:
		belt2.position.x = belt1.position.x + belt1.size.x


# ══════════════════════════════════════════════════════════════
# ATTACK PANELS SETUP
# ══════════════════════════════════════════════════════════════
func setup_attack_panels() -> void:
	var types = ["malware", "injection", "phishing", "trojan"]
	var i = 0
	for child in attack_class_container.get_children():
		if child is Panel and i < types.size():
			attack_panels[types[i]] = child

			i += 1

# ══════════════════════════════════════════════════════════════
# GAME LOGIC CALLBACKS
# ══════════════════════════════════════════════════════════════
func on_paper_correct(paper_no: int) -> void:
	var paper = active_papers.get(paper_no)

	if paper and is_instance_valid(paper):
		stopped_papers.erase(paper)

	total_score += 10

	# =========================
	# BUG BOUNTY REWARD
	# =========================
	Player_Data.add_bug_bounty(1)

	active_papers.erase(paper_no)

	_rearrange_stopped_papers()

	score_label.text = str(total_score)

func _on_bug_bounty_changed(new_amount):
	bounty_label.text = str(new_amount)

func _rearrange_stopped_papers() -> void:
	var valid = stopped_papers.filter(func(p): return is_instance_valid(p))
	stopped_papers = valid
	for i in range(valid.size()):
		var p = valid[i]
		var target_x = 10.0 + i * (PAPER_WIDTH + PAPER_GAP)
		p.original_pos.x = target_x
		var tw = create_tween()
		tw.tween_property(p, "position:x", target_x, 0.2)

func update_wrong_indicator() -> void:

	# reset all
	panel_indicator1.modulate.a = 1.0
	panel_indicator2.modulate.a = 1.0
	panel_indicator3.modulate.a = 1.0

	match wrong_drops:

		1:
			panel_indicator1.modulate.a = 0.15

		2:
			panel_indicator1.modulate.a = 0.15
			panel_indicator2.modulate.a = 0.15

		3:
			panel_indicator1.modulate.a = 0.15
			panel_indicator2.modulate.a = 0.15
			panel_indicator3.modulate.a = 0.15

# ══════════════════════════════════════════════════════════════
# END GAME
# ══════════════════════════════════════════════════════════════
func _finish_game(success: bool) -> void:
	print("🔥 FINISH GAME TRIGGERED")
	game_finished = true

	var metrics = compute_metrics()

	# ✅ Create a CanvasLayer (VERY IMPORTANT for mobile)
	var layer = CanvasLayer.new()
	get_tree().current_scene.add_child(layer)

	var ui = MINIGAME_FINISHED_SCENE.instantiate()
	layer.add_child(ui)

	# ✅ Force fullscreen layout
	ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.offset_left = 0
	ui.offset_top = 0
	ui.offset_right = 0
	ui.offset_bottom = 0

	# ✅ Ensure it's visible
	ui.visible = true

	# ✅ Make sure it processes even if paused
	ui.process_mode = Node.PROCESS_MODE_ALWAYS

	ui.set_data(success, total_score, current_rounds, metrics)

	ui.connect("minigame_finished", Callable(self, "_on_finished_screen_continue"))

func _on_finished_screen_continue(success: bool) -> void:
	print("MiniGame UI finished → forwarding to Day")

	if success:
		Player_Data.queue_achievement("Threat Neutralizer")

	emit_signal("minigame_finished", success)
	queue_free()

# ══════════════════════════════════════════════════════════════
# COMPUTE METRICS
# ══════════════════════════════════════════════════════════════
func compute_metrics() -> Dictionary:
	var labels = ["malware", "injection", "phishing", "trojan"]

	var result = {}

	for label in labels: 
		var tp = 0
		var fp = 0
		var fn = 0

		for i in range(y_true.size()):
			var actual = y_true[i]
			var predicted = y_pred[i]

			if predicted == label and actual == label:
				tp += 1
			elif predicted == label and actual != label:
				fp += 1
			elif predicted != label and actual == label:
				fn += 1

		var precision = tp / float(tp + fp) if (tp + fp) > 0 else 0
		var recall = tp / float(tp + fn) if (tp + fn) > 0 else 0
		
		# ✅ F1-score added
		var f1 = 0.0
		if (precision + recall) > 0:
			f1 = 2 * (precision * recall) / (precision + recall)

		result[label] = {
			"precision": precision,
			"recall": recall,
			"f1": f1
		}

	# Accuracy
	var correct = 0
	for i in range(y_true.size()):
		if y_true[i] == y_pred[i]:
			correct += 1

	var accuracy = correct / float(y_true.size()) if y_true.size() > 0 else 0

	result["accuracy"] = accuracy

	return result

func _on_pause_btn_pressed() -> void:
	paused.show()
	paused.z_index = 2000
	get_tree().paused = true
