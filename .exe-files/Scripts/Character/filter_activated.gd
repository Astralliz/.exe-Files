extends Node2D

signal finished

@onready var safe_sprite: Sprite2D = $SafeSprite
@onready var suspicious_sprite: Sprite2D = $SuspiciousSprite
@onready var video: VideoStreamPlayer = $VideoStreamPlayer
@onready var talking: AudioStreamPlayer2D = $Talking
@onready var label: Label = $Label

var sprite: Sprite2D

# =========================
# TEXT LINES
# =========================
var lines := [
	"how long should i wait?!",
	"can i enter already?!",
	"is there something wrong?",
	"Why it takes so long?!"
]

var cps: float = 25.0
var playing := false

# =========================
# BOUNCE CONFIG
# =========================
var base_scale: Vector2
var stretch_amount := 0.05
var squash_amount := 0.05
var speed_multiplier := 5.0
var bouncing := false


# =========================
# READY
# =========================
func _ready():

	if safe_sprite:
		safe_sprite.hide()

	if suspicious_sprite:
		suspicious_sprite.hide()

	hide()


# =========================
# MAIN PLAY FUNCTION
# =========================
func play(is_suspicious: bool) -> void:

	if playing:
		return

	playing = true
	show()
	label.text = ""

	# reset effects
	video.stop()
	talking.stop()

	safe_sprite.hide()
	suspicious_sprite.hide()

	# choose sprite
	if is_suspicious:
		sprite = suspicious_sprite
	else:
		sprite = safe_sprite

	sprite.show()

	base_scale = sprite.scale

	# glitch starts instantly
	video.play()

	# reveal animation
	await reveal_sprite()

	# choose text
	var text: String = lines.pick_random()
	var typing_duration: float = float(text.length()) / cps

	# delay only talking
	await get_tree().create_timer(0.5).timeout

	talking.play()

	# bounce while talking
	bounce_for(typing_duration)

	# typing animation
	await type_text(text)

	await get_tree().create_timer(0.7).timeout

	label.text = ""

	video.stop()
	talking.stop()

	sprite.hide()

	playing = false
	hide()

	emit_signal("finished")


# =========================
# SPRITE REVEAL
# =========================
func reveal_sprite() -> void:

	var material := sprite.material as ShaderMaterial

	if material == null:
		return

	material.set_shader_parameter("reveal", 0.0)

	var tween = create_tween()

	tween.tween_method(
		func(v): material.set_shader_parameter("reveal", v),
		0.0,
		1.0,
		0.3
	)

	await tween.finished


# =========================
# BOUNCE ANIMATION
# =========================
func bounce_for(duration: float) -> void:

	if bouncing:
		return

	bouncing = true

	var end_time := Time.get_ticks_msec() / 1000.0 + duration

	while Time.get_ticks_msec() / 1000.0 < end_time:

		var t := Time.get_ticks_msec() / 1000.0 * speed_multiplier

		var scale_x = base_scale.x + squash_amount * sin(t * 2.0)
		var scale_y = base_scale.y + stretch_amount * -sin(t * 2.0)

		sprite.scale = Vector2(scale_x, scale_y)

		await get_tree().process_frame

	sprite.scale = base_scale
	bouncing = false


# =========================
# TYPE TEXT
# =========================
func type_text(full_text: String) -> void:

	for i in full_text.length():

		label.text = full_text.substr(0, i + 1)

		await get_tree().create_timer(1.0 / cps).timeout
