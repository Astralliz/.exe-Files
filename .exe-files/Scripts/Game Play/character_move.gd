extends Node2D

func _ready():
	var tween = create_tween()
	var end_pos = Vector2(600,5)   # Middle of screen horizontally
	tween.tween_property(self, "position", end_pos, 1.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
