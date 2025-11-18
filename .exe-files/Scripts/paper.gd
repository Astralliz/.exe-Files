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
	if Input.is_action_just_pressed("click") and mouseEntered and get_parent().dragged_paper == null:
		get_parent().dragged_paper = self
		get_parent().bring_to_front(self)
		offset = global_position - get_global_mouse_position()
	
	if Input.is_action_pressed("click") and get_parent().dragged_paper == self:
		global_position = get_global_mouse_position() + offset
	
	if Input.is_action_just_released("click") and get_parent().dragged_paper == self:
		get_parent().dragged_paper = null
	
	if Input.is_action_just_pressed("rightClick") and mouseEntered:
		spawn_stamp()

func spawn_stamp() -> void:
	if has_node("Stamp"):
		return
	
	var stamp := preload("res://Scenes/stamp.tscn").instantiate()
	stamp.name = "Stamp"
	add_child(stamp)
	stamp.global_position = get_global_mouse_position()
