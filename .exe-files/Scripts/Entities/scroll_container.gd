extends ScrollContainer

var dragging := false
var last_touch_y := 0.0
var velocity := 0.0

func _ready():
	scroll_deadzone = 0
	follow_focus = false
	
	customize_scrollbar()

func customize_scrollbar():

	var v_scrollbar = get_v_scroll_bar()

	# =========================
	# THICKNESS
	# =========================
	v_scrollbar.custom_minimum_size.x = 30

	# =========================
	# BOX STYLE
	# =========================
	var grabber_style := StyleBoxFlat.new()

	# Main color
	grabber_style.bg_color = Color("#521B71")

	# Remove rounded corners
	grabber_style.corner_radius_top_left = 0
	grabber_style.corner_radius_top_right = 0
	grabber_style.corner_radius_bottom_left = 0
	grabber_style.corner_radius_bottom_right = 0

	# Optional border
	grabber_style.border_width_left = 2
	grabber_style.border_width_right = 2
	grabber_style.border_width_top = 2
	grabber_style.border_width_bottom = 2

	grabber_style.border_color = Color("#7B2FA8")

	# =========================
	# TRACK STYLE
	# =========================
	var scroll_style := StyleBoxFlat.new()

	scroll_style.bg_color = Color("#1A0E24")

	scroll_style.corner_radius_top_left = 0
	scroll_style.corner_radius_top_right = 0
	scroll_style.corner_radius_bottom_left = 0
	scroll_style.corner_radius_bottom_right = 0

	# =========================
	# APPLY THEMES
	# =========================
	v_scrollbar.add_theme_stylebox_override(
		"grabber",
		grabber_style
	)

	v_scrollbar.add_theme_stylebox_override(
		"grabber_pressed",
		grabber_style
	)

	v_scrollbar.add_theme_stylebox_override(
		"grabber_highlight",
		grabber_style
	)

	v_scrollbar.add_theme_stylebox_override(
		"scroll",
		scroll_style
	)

func _gui_input(event):

	# TOUCH START
	if event is InputEventScreenTouch:

		if event.pressed:
			dragging = true
			last_touch_y = event.position.y
			velocity = 0.0
		else:
			dragging = false

	# TOUCH DRAG
	elif event is InputEventScreenDrag and dragging:

		var delta = last_touch_y - event.position.y

		scroll_vertical += int(delta)

		velocity = delta

		last_touch_y = event.position.y

func _process(delta):

	# Smooth inertia
	if not dragging:

		if abs(velocity) > 0.1:

			scroll_vertical += int(velocity)

			velocity = lerp(velocity, 0.0, delta * 8.0)
