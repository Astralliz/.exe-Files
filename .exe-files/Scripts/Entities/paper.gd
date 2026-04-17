extends Panel
class_name Paper1

# ══════════════════════════════════════════════════════════════
# Set by the spawner before add_child()
# ══════════════════════════════════════════════════════════════
var metadata          = null   # DecisionTree.PaperMetadata
var game_reference    = null   # MalwareDetectionGame node

# ── State ─────────────────────────────────────────────────────
var is_open:       bool    = false
var is_dragging:   bool    = false
var is_animating:  bool    = false
var original_pos:  Vector2 = Vector2.ZERO
var drag_offset:   Vector2 = Vector2.ZERO
var click_pos_g:   Vector2 = Vector2.ZERO   # global position at press
var last_pos_g:    Vector2 = Vector2.ZERO   # last known global drag position
const DRAG_THRESHOLD: float = 8.0

var info_panel: Control = null
var tween_ref:  Tween   = null


# ══════════════════════════════════════════════════════════════
# READY
# ══════════════════════════════════════════════════════════════
func _ready() -> void:
	# Explicit size — required for gui_input to fire in Godot 4
	size                = Vector2(100, 120)
	custom_minimum_size = Vector2(100, 120)
	mouse_filter        = Control.MOUSE_FILTER_STOP
	z_index             = 10

	# Texture background
	var style         = StyleBoxTexture.new()
	style.texture     = game_reference.PAPER_TEXTURE
	add_theme_stylebox_override("panel", style)

	# Paper number label
	var lbl = Label.new()
	lbl.text          = str(metadata.paper_no)
	lbl.anchor_left   = 0.5
	lbl.anchor_top    = 0.5
	lbl.offset_left   = -20
	lbl.offset_top    = -20
	lbl.add_theme_font_override("font", game_reference.GAME_FONT)
	lbl.add_theme_font_size_override("font_size", 32)
	lbl.add_theme_color_override("font_color", Color.BLACK)
	lbl.mouse_filter  = Control.MOUSE_FILTER_IGNORE   # don't steal input
	add_child(lbl)

	# Connect input — this will now work because size is set
	gui_input.connect(_on_gui_input)


# ══════════════════════════════════════════════════════════════
# INPUT
# ══════════════════════════════════════════════════════════════
func _on_gui_input(event: InputEvent) -> void:
	if is_animating:
		return

	# ── TOUCH ────────────────────────────────────────────────
	if event is InputEventScreenTouch:
		if event.pressed:
			click_pos_g = event.position
			last_pos_g  = event.position
			drag_offset = event.position - global_position
		else:
			if is_dragging:
				_stop_dragging(last_pos_g)
			else:
				_toggle_open()

	elif event is InputEventScreenDrag:
		last_pos_g = event.position
		if not is_dragging:
			if event.position.distance_to(click_pos_g) > DRAG_THRESHOLD:
				_start_dragging(event.position)
		if is_dragging:
			global_position = event.position - drag_offset

	# ── MOUSE ────────────────────────────────────────────────
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				click_pos_g = get_global_mouse_position()
				drag_offset = get_global_mouse_position() - global_position
				last_pos_g  = click_pos_g
			else:
				if is_dragging:
					_stop_dragging(get_global_mouse_position())
				else:
					_toggle_open()

	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var gmp = get_global_mouse_position()
			last_pos_g = gmp
			if not is_dragging:
				if gmp.distance_to(click_pos_g) > DRAG_THRESHOLD:
					_start_dragging(gmp)
			if is_dragging:
				global_position = gmp - drag_offset


# ══════════════════════════════════════════════════════════════
# OPEN / CLOSE
# ══════════════════════════════════════════════════════════════
func _toggle_open() -> void:
	if is_open:
		_close_paper()
	else:
		_open_paper()


func _open_paper() -> void:
	if is_animating:
		return
	is_animating = true
	is_open      = true
	original_pos = position   # save conveyor position

	if tween_ref:
		tween_ref.kill()

	z_index = 200   # float above everything

	var center = get_viewport_rect().size / 2.0
	tween_ref = create_tween().set_parallel(true)
	tween_ref.tween_property(self, "global_position", center - Vector2(110, 150), 0.25)
	tween_ref.tween_property(self, "scale", Vector2(2.0, 2.0), 0.25)
	await tween_ref.finished

	_show_info_panel()
	is_animating = false


func _close_paper() -> void:
	if is_animating:
		return
	is_animating = true
	is_open      = false

	if info_panel:
		info_panel.queue_free()
		info_panel = null

	if tween_ref:
		tween_ref.kill()

	tween_ref = create_tween().set_parallel(true)
	tween_ref.tween_property(self, "position", original_pos, 0.25)
	tween_ref.tween_property(self, "scale", Vector2.ONE, 0.25)
	await tween_ref.finished

	z_index      = 10
	is_animating = false


func _show_info_panel() -> void:
	info_panel = Control.new()
	info_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(info_panel)

	# Background card (semi-transparent)
	var bg = ColorRect.new()
	bg.color            = Color(0.95, 0.92, 0.85, 0.97)
	bg.size             = Vector2(100, 145)   # in paper's local space (paper is scaled 2x)
	bg.position         = Vector2(0, 0)
	bg.mouse_filter     = Control.MOUSE_FILTER_IGNORE
	info_panel.add_child(bg)

	var m = metadata
	var lines = [
		"#%d  %s" % [m.paper_no, m.actual_label.to_upper()],
		"─────────────",
		"%s%s" % [m.filename, m.extension],
		"Size: %.1f MB" % m.size,
		"Pub: %s" % m.publisher,
		"Src: %s" % m.source,
		"Sig: %s" % ("OK" if m.signature_valid else "INVALID"),
		"Admin: %s  Zip: %s" % [("Y" if m.requires_admin else "N"), ("Y" if m.is_compressed else "N")],
		"Hidden: %s  Rnd: %s" % [("Y" if m.hidden else "N"), ("Y" if m.random_name == 1 else "N")],
		"Mod: %dh ago" % m.modified_hours,
		"─────────────",
		"DRAG TO SORT",
	]

	var lbl = Label.new()
	lbl.text            = "\n".join(lines)
	lbl.position        = Vector2(4, 4)
	lbl.add_theme_font_override("font", game_reference.GAME_FONT)
	lbl.add_theme_font_size_override("font_size", 8)
	lbl.add_theme_color_override("font_color", Color(0.1, 0.05, 0.0))
	lbl.mouse_filter    = Control.MOUSE_FILTER_IGNORE
	lbl.autowrap_mode   = TextServer.AUTOWRAP_WORD_SMART
	lbl.custom_minimum_size = Vector2(92, 0)
	info_panel.add_child(lbl)

	# Close button
	var btn = Button.new()
	btn.text            = "X"
	btn.position        = Vector2(82, 0)
	btn.size            = Vector2(18, 14)
	btn.add_theme_font_size_override("font_size", 8)
	btn.pressed.connect(_close_paper)
	info_panel.add_child(btn)


# ══════════════════════════════════════════════════════════════
# DRAG
# ══════════════════════════════════════════════════════════════
func _start_dragging(global_press: Vector2) -> void:
	# Close info panel if open when drag starts
	if is_open:
		if info_panel:
			info_panel.queue_free()
			info_panel = null
		is_open = false
		scale   = Vector2.ONE

	is_dragging = true
	drag_offset = global_press - global_position
	z_index     = 150


func _stop_dragging(global_release: Vector2) -> void:
	is_dragging = false
	z_index     = 10
	_check_drop(global_release)


func _check_drop(global_pos: Vector2) -> void:
	for attack_name in game_reference.attack_panels:
		var panel: Panel = game_reference.attack_panels[attack_name]
		if panel.get_global_rect().has_point(global_pos):
			if attack_name == metadata.actual_label:
				_accept()
			else:
				_reject()
			return
	# Dropped outside any panel — snap back
	_snap_back()


func _accept() -> void:
	is_animating = true
	var tw = create_tween().set_parallel(true)
	tw.tween_property(self, "scale",       Vector2.ZERO, 0.25)
	tw.tween_property(self, "modulate:a",  0.0,          0.25)
	await tw.finished
	game_reference.on_paper_correct(metadata.paper_no)
	queue_free()


func _reject() -> void:
	is_animating = true
	# Flash red
	var tw1 = create_tween()
	tw1.tween_property(self, "modulate", Color(1, 0.3, 0.3), 0.1)
	await tw1.finished
	var tw2 = create_tween()
	tw2.tween_property(self, "modulate", Color.WHITE, 0.2)
	await tw2.finished
	_snap_back()
	is_animating = false


func _snap_back() -> void:
	var tw = create_tween()
	tw.tween_property(self, "position", original_pos, 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
