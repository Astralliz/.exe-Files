# ==============================
# TROJAN ATTACK MINIGAME
# "Odd One Out" – Color Differentiation
# ==============================
extends Control

signal minigame_finished(success: bool)

# ── Node references ─────────────────────────────────────────
@onready var level_label: Label     = $Level
@onready var wrong_label: Label     = $Wrong
@onready var boxes: Array[Panel]    = [
	$Panel/HBoxContainer/Box1,
	$Panel/HBoxContainer/Box2,
	$Panel/HBoxContainer/Box3,
	$Panel/HBoxContainer/Box4,
	$Panel/HBoxContainer2/Box5,
	$Panel/HBoxContainer2/Box6,
	$Panel/HBoxContainer2/Box7,
	$Panel/HBoxContainer2/Box8,
]

# ── Game state ───────────────────────────────────────────────
var current_level:   int  = 1
var wrong_count:     int  = 0
var odd_box_index:   int  = -1
var accepting_input: bool = true

const MAX_LEVELS: int = 5
const MAX_WRONG:  int = 3

# ── Level config: [base_color, hue_shift_deg, sat_offset, val_offset]
# Difference shrinks as level increases → harder to spot
const LEVEL_DATA: Array = [
	# base_hue, base_sat, base_val, diff_hue, diff_sat, diff_val
	{ "h": 0.0,   "s": 0.85, "v": 0.85, "dh": 0.0,  "ds":  0.0,  "dv": -0.22 },  # L1: red vs dark-red (easy)
	{ "h": 0.33,  "s": 0.75, "v": 0.80, "dh": 0.0,  "ds":  0.18, "dv":  0.12 },  # L2: green vs bright-green
	{ "h": 0.6,   "s": 0.70, "v": 0.80, "dh": 0.0,  "ds": -0.15, "dv":  0.10 },  # L3: blue vs slightly lighter
	{ "h": 0.08,  "s": 0.80, "v": 0.78, "dh": 0.0,  "ds":  0.12, "dv": -0.10 },  # L4: orange vs close shade
	{ "h": 0.75,  "s": 0.55, "v": 0.72, "dh": 0.0,  "ds": -0.08, "dv":  0.08 },  # L5: purple vs near-identical
]

# ── Icon scenes (create dynamically) ────────────────────────
var check_scene:  PackedScene
var cross_scene:  PackedScene

# ============================================================
func _ready() -> void:
	_build_icon_scenes()
	_setup_box_signals()
	_start_level()

# ── Build simple Label-based icons at runtime ────────────────
func _build_icon_scenes() -> void:
	# We create them dynamically instead of PackedScene to keep it self-contained
	pass  # icons are spawned inline in _show_feedback()

# ── Connect click signals for every box ──────────────────────
func _setup_box_signals() -> void:
	for i in range(boxes.size()):
		var box: Panel = boxes[i]
		box.gui_input.connect(_on_box_input.bind(i))
		box.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

# ============================================================
# LEVEL SETUP
# ============================================================
func _start_level() -> void:
	accepting_input = true
	level_label.text = "LEVEL %d" % current_level
	wrong_label.text = "WRONG: %d" % wrong_count

	var cfg: Dictionary = LEVEL_DATA[current_level - 1]
	var base_color: Color = Color.from_hsv(cfg["h"], cfg["s"], cfg["v"])
	var odd_color:  Color = Color.from_hsv(
		cfg["h"] + cfg["dh"],
		clampf(cfg["s"] + cfg["ds"], 0.0, 1.0),
		clampf(cfg["v"] + cfg["dv"], 0.0, 1.0)
	)

	odd_box_index = randi() % boxes.size()

	for i in range(boxes.size()):
		var panel: Panel = boxes[i]
		var color: Color = odd_color if i == odd_box_index else base_color
		_set_panel_color(panel, color)

		# Animate panels in with a staggered pop
		panel.scale    = Vector2(0.85, 0.85)
		panel.modulate = Color(1, 1, 1, 0)
		var tw: Tween = create_tween()
		tw.set_parallel(true)
		tw.tween_property(panel, "scale",    Vector2.ONE,       0.25).set_delay(i * 0.04).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(panel, "modulate", Color.WHITE,       0.20).set_delay(i * 0.04)

# ── Apply a StyleBoxFlat color to a Panel ───────────────────
func _set_panel_color(panel: Panel, color: Color) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color         = color
	sb.corner_radius_top_left     = 8
	sb.corner_radius_top_right    = 8
	sb.corner_radius_bottom_left  = 8
	sb.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", sb)

# ============================================================
# INPUT HANDLING
# ============================================================
func _on_box_input(event: InputEvent, box_index: int) -> void:
	if not accepting_input:
		return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return

	accepting_input = false

	if box_index == odd_box_index:
		_on_correct_tap(box_index)
	else:
		_on_wrong_tap(box_index)

# ============================================================
# CORRECT TAP
# ============================================================
func _on_correct_tap(box_index: int) -> void:
	var panel: Panel = boxes[box_index]
	_show_feedback(panel, true)

	# Flash green briefly
	_flash_panel(panel, Color(0.2, 0.9, 0.4, 1.0))

	await get_tree().create_timer(0.7).timeout

	current_level += 1
	if current_level > MAX_LEVELS:
		_end_game(true)
	else:
		_reset_then_start()

# ============================================================
# WRONG TAP
# ============================================================
func _on_wrong_tap(box_index: int) -> void:
	var panel: Panel = boxes[box_index]
	_show_feedback(panel, false)

	# Shake the wrong panel
	_shake_panel(panel)
	_flash_panel(panel, Color(0.9, 0.15, 0.15, 1.0))

	wrong_count += 1
	wrong_label.text = "WRONG: %d" % wrong_count

	await get_tree().create_timer(0.7).timeout

	if wrong_count >= MAX_WRONG:
		_end_game(false)
	else:
		_reset_then_start()

# ============================================================
# FEEDBACK ICONS (check ✓ / cross ✗)
# ============================================================
func _show_feedback(panel: Panel, correct: bool) -> void:
	var icon := Label.new()
	icon.text              = "✓" if correct else "✗"
	icon.add_theme_font_size_override("font_size", 48)
	icon.add_theme_color_override("font_color", Color.WHITE)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(icon)

	# Animate: pop in then fade out
	icon.scale    = Vector2(0.4, 0.4)
	icon.modulate = Color(1, 1, 1, 0)
	var tw: Tween = create_tween()
	tw.set_parallel(true)
	tw.tween_property(icon, "scale",    Vector2.ONE,         0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(icon, "modulate", Color.WHITE,         0.12)
	tw.tween_property(icon, "modulate", Color(1, 1, 1, 0),   0.30).set_delay(0.40)
	await tw.finished
	icon.queue_free()

# ── Flash a panel to a highlight color then restore ──────────
func _flash_panel(panel: Panel, flash_color: Color) -> void:
	var original := (panel.get_theme_stylebox("panel") as StyleBoxFlat).bg_color
	var sb_flash  := StyleBoxFlat.new()
	sb_flash.bg_color = flash_color
	sb_flash.corner_radius_top_left     = 8
	sb_flash.corner_radius_top_right    = 8
	sb_flash.corner_radius_bottom_left  = 8
	sb_flash.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", sb_flash)

	await get_tree().create_timer(0.12).timeout

	_set_panel_color(panel, original)

# ── Shake animation ──────────────────────────────────────────
func _shake_panel(panel: Panel) -> void:
	var origin := panel.position
	var tw: Tween = create_tween()
	var offsets: Array = [8, -8, 6, -6, 4, -4, 2, -2, 0]
	for off in offsets:
		tw.tween_property(panel, "position", origin + Vector2(off, 0), 0.04)
	await tw.finished
	panel.position = origin

# ============================================================
# TRANSITION BETWEEN ROUNDS
# ============================================================
func _reset_then_start() -> void:
	# Fade all panels out
	var tw: Tween = create_tween()
	tw.set_parallel(true)
	for i in range(boxes.size()):
		tw.tween_property(boxes[i], "modulate", Color(1, 1, 1, 0), 0.18).set_delay(i * 0.025)
	await tw.finished
	_start_level()

# ============================================================
# GAME OVER
# ============================================================
func _end_game(success: bool) -> void:
	accepting_input = false

	# Final flash: green sweep for win, red pulse for loss
	var flash_color: Color = Color(0.2, 0.9, 0.45) if success else Color(0.9, 0.15, 0.15)
	for i in range(boxes.size()):
		var tw: Tween = create_tween()
		tw.tween_property(boxes[i], "modulate", Color(flash_color.r, flash_color.g, flash_color.b, 1.0), 0.12).set_delay(i * 0.05)
		tw.tween_property(boxes[i], "modulate", Color(1, 1, 1, 0), 0.25).set_delay(i * 0.05 + 0.15)

	await get_tree().create_timer(0.85).timeout

	emit_signal("minigame_finished", success)
	queue_free()

# ── Legacy button hooks (keep in case scene still has them) ──
func _on_finished_pressed() -> void:
	emit_signal("minigame_finished", true)
	queue_free()

func _on_quit_pressed() -> void:
	emit_signal("minigame_finished", false)
	queue_free()
