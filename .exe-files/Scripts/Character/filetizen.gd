extends Node2D

var metadata: FileMetadata
var generator: MetadataGenerator

func _ready():
	generator = MetadataGenerator.new()
	metadata = generator.generate_metadata()

	print("Spawned Filetizen: ")
	print("Name: ", metadata.filename)
	print("Extension: ", metadata.extension)
	print("Size: ", metadata.size_mb)
	print("Source: ", metadata.source)
	print("Publisher: ", metadata.publisher)

	# Your existing movement animation
	var tween = create_tween()
	var end_pos = Vector2(600,350)
	tween.tween_property(self, "position", end_pos, 1.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
