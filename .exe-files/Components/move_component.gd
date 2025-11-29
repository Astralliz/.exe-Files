class_name MoveComponent
extends Node

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

# -----------------------
# Movement functions
# -----------------------
func move(direction: Vector2, speed: float):
	velocity = direction.normalized() * speed

func stop():
	velocity = Vector2.ZERO
	time_acc = 0.0
	actor.scale = base_scale

# Optional: bounce when spawned
func appear_bounce():
	actor.scale = Vector2(1.3, 0.6)
	var tween = get_tree().create_tween()
	tween.tween_property(actor, "scale", base_scale, 0.3).set_trans(Tween.TRANS_ELASTIC)

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
