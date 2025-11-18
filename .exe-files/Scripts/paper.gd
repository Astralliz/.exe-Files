extends Node2D

var offset = Vector2.ZERO
var mouseEntered = false

func _ready() -> void:
	$Area2D.mouse_entered.connect(onMouseEnter)
	$Area2D.mouse_exited.connect(onMouseExit)
	
func onMouseEnter() -> void:
	mouseEntered = true
	
func onMouseExit() -> void:
	mouseEntered = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("rightClick") and mouseEntered:
		spawn_stamp()
	
	if Input.is_action_just_pressed("click"):
		offset = global_position - get_global_mouse_position()
	
	if Input.is_action_pressed("click") and mouseEntered:
		global_position = get_global_mouse_position() + offset

func spawn_stamp() -> void:
	if has_node("Stamp"):
		return
	
	var stamp := preload("res://Scenes/stamp.tscn").instantiate()
	stamp.name = "Stamp"
	add_child(stamp)
	stamp.global_position = get_global_mouse_position()
