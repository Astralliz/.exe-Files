extends Node2D

var metadata: FileMetadata
var generator: MetadataGenerator
@onready var move_component: MoveComponent = $MoveComponent

func _ready():
	generator = MetadataGenerator.new()
	metadata = generator.generate_metadata()

	print("Spawned Filetizen: ")
	print("Name: ", metadata.filename)
	print("Extension: ", metadata.extension)
	print("Size: ", metadata.size_mb)
	print("Source: ", metadata.source)
	print("Publisher: ", metadata.publisher)
