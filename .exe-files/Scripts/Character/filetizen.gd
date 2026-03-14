extends Node2D

@onready var metadata: FileMetadata
@onready var generator: MetadataGenerator
@onready var sprite: Sprite2D = $Sprite2D
@onready var move_component: MoveComponent = $MoveComponent
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready():
	generator = MetadataGenerator.new()
	metadata = generator.generate_metadata()
	visible_on_screen_notifier_2d.screen_exited.connect(queue_free)
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
		

func activate_filter():
	sprite.modulate.a = 0.0

func deactivate_filter():
	sprite.modulate.a = 1.0

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
