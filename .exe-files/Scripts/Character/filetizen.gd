extends Node2D

var metadata: FileMetadata
var generator: MetadataGenerator
@onready var move_component: MoveComponent = $MoveComponent
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready():
	generator = MetadataGenerator.new()
	metadata = generator.generate_metadata()
	visible_on_screen_notifier_2d.screen_exited.connect(queue_free)

	print("Spawned Filetizen: ")
	print("Name: ", metadata.filename)
	print("Extension: ", metadata.extension)
	print("Size: ", metadata.size_mb)
	print("Source: ", metadata.source)
	print("Publisher: ", metadata.publisher)
