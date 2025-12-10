class_name MoveComponent
extends Node
@onready var walking: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var actor: Node2D
var velocity: Vector2 = Vector2.ZERO

# -----------------------
# Squash & stretch config
# -----------------------
var base_scale := Vector2.ONE       # normal scale
var stretch_amount := 0.05          # vertical stretch
var squash_amount := 0.05          # horizontal squash
var speed_multiplier := 5.0        # how fast the squash/stretch oscillates
var time_acc := 0.0                  # internal timer for sine wave
var bouncing := false

# -----------------------
# Movement functions
# -----------------------
func move(direction: Vector2, speed: float):
	velocity = direction.normalized() * speed
	walking.play()

func stop():
	velocity = Vector2.ZERO
	time_acc = 0.0
	actor.scale = base_scale
	walking.stop()

# Optional: bounce when spawned
func appear_bounce():
	actor.scale = Vector2(1.3, 0.6)
	var tween = get_tree().create_tween()
	tween.tween_property(actor, "scale", base_scale, 0.3).set_trans(Tween.TRANS_ELASTIC)
	

# -----------------------
# Answering Bounce
# -----------------------
func bounce_for(duration: float) -> void:
	if bouncing:
		return  # avoid overlapping bounces

	bouncing = true
	var end_time := Time.get_ticks_msec() / 1000.0 + duration

	while Time.get_ticks_msec() / 1000.0 < end_time:
		var t := Time.get_ticks_msec() / 1000.0 * speed_multiplier

		var scale_x = base_scale.x + squash_amount * sin(t * 2.0)
		var scale_y = base_scale.y + stretch_amount * -sin(t * 2.0)

		actor.scale = Vector2(scale_x, scale_y)
		await get_tree().process_frame  # smooth frame sync

	# reset to normal
	actor.scale = base_scale
	bouncing = false

# -----------------------
# Process
# -----------------------
func _process(delta: float):
	if velocity.length() > 0.1:
		# Move actor
		actor.position += velocity * delta

		# Update timer
		time_acc += delta * speed_multiplier

		# Oscillate scale with sine wave
		var scale_x = base_scale.x + squash_amount * sin(time_acc)
		var scale_y = base_scale.y + stretch_amount * -sin(time_acc)
		actor.scale = Vector2(scale_x, scale_y)
	else:
		# Return to normal scale when stopped
		actor.scale = actor.scale.lerp(base_scale, delta * speed_multiplier)
		time_acc = 0.0
