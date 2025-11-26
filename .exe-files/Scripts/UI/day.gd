extends Node2D

@onready var filetizen = $Filetizen
@onready var spawner_component: SpawnerComponent = $SpawnerComponent
@onready var actors: Node2D = $Actors

var moved_out := false

func _ready():
	spawn_new_filetizen()
	move_filetizen_to_center()

func spawn_new_filetizen():
	# Decide a spawn location (left side of screen)
	var screen_size = get_viewport().get_visible_rect().size
	var spawn_pos = Vector2(-100, screen_size.y / 2)
	# Spawn the Filetizen
	var new_filetizen: Node2D = spawner_component.spawn(spawn_pos, actors)
	# Update your reference to the current filetizen
	filetizen = new_filetizen
	# Start moving it toward the center
	move_filetizen_to_center()

func move_filetizen_to_center():
	var target = get_viewport().get_visible_rect().size / 2.0
	var direction = target - filetizen.position
	filetizen.move_component.move(direction, 250)

func move_approved_filetizen():
	var screen_w = get_viewport().get_visible_rect().size.x
	var direction = Vector2(screen_w + 200, filetizen.position.y) - filetizen.position
	filetizen.move_component.move(direction, 300)

func move_declined_filetizen():
	var screen_w = get_viewport().get_visible_rect().size.x
	var direction = Vector2(screen_w + 200, filetizen.position.y) - filetizen.position
	filetizen.move_component.move(direction, -300)

func _process(delta):
	var target = get_viewport().get_visible_rect().size / 2.0
	# Check if sprite reaches the middle.
	if not moved_out and filetizen.position.distance_to(target) < 5.0:
		filetizen.move_component.stop()
		moved_out = true
		await get_tree().create_timer(1.0).timeout
		move_declined_filetizen()
