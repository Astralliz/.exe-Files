extends Node2D

@onready var metadata: FileMetadata
@onready var generator: MetadataGenerator
@onready var sprite: Sprite2D = $Sprite2D
@onready var move_component:  = $MoveComponent
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var clean_sprites := [
	preload("res://Assets/Sprites/clean_file.png"),
	preload("res://Assets/Sprites/clean_file_girl.png"),
	preload("res://Assets/Sprites/clean_file_nerd_girl.png"),
	preload("res://Assets/Sprites/clean_file_punk.png")
]

var corrupted_sprites := [
	preload("res://Assets/Sprites/corrupted_file.png"),
	preload("res://Assets/Sprites/corrupted_file_girl.png"),
	preload("res://Assets/Sprites/corrupter_file_nerd_girl.png"),
	preload("res://Assets/Sprites/corrupted_file_punk.png")
]
var current_variant := 0

func _ready():
	generator = MetadataGenerator.new()
	metadata = generator.generate_metadata()
	visible_on_screen_notifier_2d.screen_exited.connect(queue_free)
	randomize()

	current_variant = randi() % clean_sprites.size()

	sprite.texture = clean_sprites[current_variant]
	if GameState.day <= 2:
		print("Spawned Filetizen: ")
		print("Name: ", metadata.filename)
		print("Extension: ", metadata.extension)
		print("Size: ", metadata.size_mb)
		print("Source: ", metadata.source)
		print("Publisher: ", metadata.publisher)
	elif GameState.day <= 4:
		print("Spawned Filetizen: ")
		print("Name: ", metadata.filename)
		print("Extension: ", metadata.extension)
		print("Size: ", metadata.size_mb)
		print("Source: ", metadata.source)
		print("Publisher: ", metadata.publisher)
		print("Modified: ", metadata.modified_hours_ago)
		print("Hidden: ", metadata.hidden)
	else:
		print("Spawned Filetizen: ")
		print("Name: ", metadata.filename)
		print("Extension: ", metadata.extension)
		print("Size: ", metadata.size_mb)
		print("Source: ", metadata.source)
		print("Publisher: ", metadata.publisher)
		print("Modified: ", metadata.modified_hours_ago)
		print("Hidden: ", metadata.hidden)
		print("Signature: ", metadata.signature_valid)
		print("Admin: ", metadata.requires_admin)
		print("Compressed: ", metadata.is_compressed)
		

func get_clean_texture() -> Texture2D:
	return clean_sprites[current_variant]

func get_corrupted_texture() -> Texture2D:
	return corrupted_sprites[current_variant]

func activate_filter():
	sprite.modulate.a = 0.0

func deactivate_filter():
	sprite.modulate.a = 1.0

func is_female() -> bool:
	return current_variant == 1 or current_variant == 2

		# Level 2 adds more conditions and increases scores
#{"id": "R1", "condition": "size_large", "score": 1},
#{"id": "R2", "condition": "ext_exe", "score": 1.2},
#{"id": "R3", "condition": "ext_script", "score": 0.8},
#{"id": "R4", "condition": "ext_dropper", "score": 0.8},
#{"id": "R6", "condition": "unknown_publisher", "score": 1},
#{"id": "R7", "condition": "recent_modified", "score": 0.5},
#{"id": "R8", "condition": "src_email", "score": 1},
#{"id": "R9", "condition": "src_unknown", "score": 0.8},
#{"id": "R10", "condition": "is_hidden", "score": 0.7},
