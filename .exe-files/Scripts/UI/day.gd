extends Node2D

@onready var filetizen = $Filetizen

func _ready():
	move_filetizen_to_center()


func move_filetizen_to_center():
	var target = get_viewport().get_visible_rect().size / 2.0
	var direction = target - filetizen.position

	filetizen.move_component.move(direction, 250)

func _process(delta):
	var target = get_viewport().get_visible_rect().size / 2.0
	
	# Check arrival
	if filetizen.position.distance_to(target) < 5.0:
		filetizen.move_component.stop()
