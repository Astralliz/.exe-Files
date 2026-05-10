extends Panel

@onready var walking_file: Control = $WalkingFile
@onready var walking_file_punk: Control = $WalkingFilePunk

var time_acc := 0.0

# Movement
var sway_amount := 6.0
var sway_speed := 1.2

# Rotation
var rotate_amount := 2.0
var rotate_speed := 1.5

# Tiny breathing
var scale_amount := 0.01

# Base transforms
var file_base_pos: Vector2
var punk_base_pos: Vector2

var file_base_scale: Vector2
var punk_base_scale: Vector2

func _ready():

	file_base_pos = walking_file.position
	punk_base_pos = walking_file_punk.position

	file_base_scale = walking_file.scale
	punk_base_scale = walking_file_punk.scale

	# IMPORTANT:
	# makes rotation happen near the bottom
	# so it feels grounded
	walking_file.pivot_offset = Vector2(
		walking_file.size.x / 2,
		walking_file.size.y
	)

	walking_file_punk.pivot_offset = Vector2(
		walking_file_punk.size.x / 2,
		walking_file_punk.size.y
	)

func _process(delta):

	time_acc += delta

	animate_sprite(
		walking_file,
		file_base_pos,
		file_base_scale,
		0.0
	)

	animate_sprite(
		walking_file_punk,
		punk_base_pos,
		punk_base_scale,
		PI
	)

func animate_sprite(
	node: Control,
	base_pos: Vector2,
	base_scale: Vector2,
	offset: float
):

	var t = time_acc + offset

	# LEFT / RIGHT sway
	node.position.x = base_pos.x + sin(t * sway_speed) * sway_amount

	# slight leaning rotation
	node.rotation_degrees = sin(t * rotate_speed) * rotate_amount

	# VERY subtle breathing
	var scale_wave = sin(t * 2.0) * scale_amount

	node.scale = Vector2(
		base_scale.x + scale_wave,
		base_scale.y - scale_wave
	)
