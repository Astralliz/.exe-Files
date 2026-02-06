extends HBoxContainer

@onready var music_slider: HSlider = $VBoxContainer/HSlider
@onready var sfx_slider: HSlider = $VBoxContainer3/HSlider

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"

func _ready():
	print("SFX bus index:", AudioServer.get_bus_index("SFX"))	
	# --- MUSIC ---
	var music_bus = AudioServer.get_bus_index(MUSIC_BUS)
	music_slider.value = db_to_linear(
		AudioServer.get_bus_volume_db(music_bus)
	)
	music_slider.value_changed.connect(_on_music_volume_changed)

	# --- SFX ---
	var sfx_bus = AudioServer.get_bus_index(SFX_BUS)
	sfx_slider.value = db_to_linear(
		AudioServer.get_bus_volume_db(sfx_bus)
	)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)

func _on_music_volume_changed(value: float) -> void:
	var bus = AudioServer.get_bus_index(MUSIC_BUS)
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))

func _on_sfx_volume_changed(value: float) -> void:
	var bus = AudioServer.get_bus_index(SFX_BUS)
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
