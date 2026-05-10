extends HBoxContainer

@onready var music_slider: HSlider = $VBoxContainer/HSlider
@onready var sfx_slider: HSlider = $VBoxContainer3/HSlider

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"

func _ready():

	_setup_slider_theme(music_slider)
	_setup_slider_theme(sfx_slider)

	# =========================
	# MUSIC
	# =========================
	var music_bus = AudioServer.get_bus_index(MUSIC_BUS)

	music_slider.value = db_to_linear(
		AudioServer.get_bus_volume_db(music_bus)
	)

	music_slider.value_changed.connect(_on_music_volume_changed)

	# =========================
	# SFX
	# =========================
	var sfx_bus = AudioServer.get_bus_index(SFX_BUS)

	sfx_slider.value = db_to_linear(
		AudioServer.get_bus_volume_db(sfx_bus)
	)

	sfx_slider.value_changed.connect(_on_sfx_volume_changed)

func _setup_slider_theme(slider: HSlider) -> void:
	var theme = Theme.new()

	# =========================
	# COLORS
	# =========================
	var neon_pink = Color("#CD3EB9")
	var neon_pink_bright = Color("#ff5ce1")
	var slider_bg = Color("#3b244a")
	var border_dark = Color("#7c2d74")

	# =========================
	# TRACK BACKGROUND
	# =========================
	var track_stylebox = StyleBoxFlat.new()
	track_stylebox.bg_color = slider_bg
	track_stylebox.set_corner_radius_all(100)

	# THICKNESS
	track_stylebox.content_margin_top = 28
	track_stylebox.content_margin_bottom = 28

	# BORDER
	track_stylebox.border_width_left = 4
	track_stylebox.border_width_right = 4
	track_stylebox.border_width_top = 4
	track_stylebox.border_width_bottom = 4
	track_stylebox.border_color = border_dark

	theme.set_stylebox("slider", "HSlider", track_stylebox)

	# =========================
	# FILLED AREA
	# =========================
	var grab_area = StyleBoxFlat.new()
	grab_area.bg_color = neon_pink
	grab_area.set_corner_radius_all(100)

	# MATCH THICKNESS
	grab_area.content_margin_top = 28
	grab_area.content_margin_bottom = 28

	theme.set_stylebox("grabber_area", "HSlider", grab_area)
	theme.set_stylebox("grabber_area_highlight", "HSlider", grab_area)

	# =========================
	# GRABBER NORMAL
	# =========================
	var grabber_normal = StyleBoxFlat.new()
	grabber_normal.bg_color = neon_pink
	grabber_normal.set_corner_radius_all(100)

	grabber_normal.border_width_left = 6
	grabber_normal.border_width_right = 6
	grabber_normal.border_width_top = 6
	grabber_normal.border_width_bottom = 6
	grabber_normal.border_color = neon_pink_bright

	grabber_normal.content_margin_left = 32
	grabber_normal.content_margin_right = 32
	grabber_normal.content_margin_top = 32
	grabber_normal.content_margin_bottom = 32

	theme.set_stylebox("grabber", "HSlider", grabber_normal)

	# =========================
	# GRABBER HOVER
	# =========================
	var grabber_hover = grabber_normal.duplicate()
	grabber_hover.bg_color = neon_pink_bright
	grabber_hover.border_color = Color.WHITE

	theme.set_stylebox("grabber_highlight", "HSlider", grabber_hover)

	# =========================
	# FOCUS (NO MORE GRAY)
	# =========================
	var focus_style = StyleBoxEmpty.new()
	theme.set_stylebox("focus", "HSlider", focus_style)

	# =========================
	# SIZE
	# =========================
	theme.set_constant("grabber_width", "HSlider", 80)

	slider.theme = theme

	# BIG MOBILE FRIENDLY SIZE
	slider.custom_minimum_size = Vector2(600, 90)

	slider.step = 0.01
	slider.mouse_filter = Control.MOUSE_FILTER_STOP
	slider.self_modulate = Color.WHITE

# =========================
# MUSIC VOLUME
# =========================
func _on_music_volume_changed(value: float) -> void:

	var bus = AudioServer.get_bus_index(MUSIC_BUS)

	AudioServer.set_bus_volume_db(
		bus,
		linear_to_db(value)
	)


# =========================
# SFX VOLUME
# =========================
func _on_sfx_volume_changed(value: float) -> void:

	var bus = AudioServer.get_bus_index(SFX_BUS)

	AudioServer.set_bus_volume_db(
		bus,
		linear_to_db(value)
	)
