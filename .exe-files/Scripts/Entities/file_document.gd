class_name FileDocument
extends Node2D

@onready var paper: Sprite2D = $Sprite2D
@onready var vbox: VBoxContainer = $VBoxContainer
@onready var file_name: Label = $VBoxContainer/FileName
@onready var extension: Label = $VBoxContainer/Extension
@onready var size: Label = $VBoxContainer/Size
@onready var publisher: Label = $VBoxContainer/Publisher
@onready var source: Label = $VBoxContainer/Source
@onready var area_2d: Area2D = $Area2D
@onready var stamp_anchor: Node2D = $StampAnchor

@onready var pickup_sound = $Audio_Pickup

var tex_original := preload("res://Assets/Sprites/large-paper.png")
var tex_open := preload("res://Assets/Sprites/paper_down.png")
var approve_stamp_scene := preload("res://Scenes/Entities Scenes/approve_stamp.tscn")
var decline_stamp_scene := preload("res://Scenes/Entities Scenes/decline_stamp.tscn")

var _state := 0
var metadata: FileMetadata

const PRINTED_SCALE = Vector2(0.7, 0.7)
const ZOOM_SCALE = Vector2(1.2, 1.2)
const PAPER_DOWN_SCALE = Vector2(0.3, 0.3)

var FALL_START := Vector2(1035, 274)
var FALL_END := Vector2(1035, 374)
var CENTER := Vector2(830, 420)
var DOWN_POS := Vector2(830, 510)

func set_metadata(data: FileMetadata):
	file_name.text = "Filename: %s" % data.filename
	extension.text = "Extension: %s" % data.extension
	size.text = "Size: %.2f MB" % data.size_mb
	publisher.text = "Publisher: %s" % data.publisher
	source.text = "Source: %s" % data.source

func initialize_paper():
	_state = 0
	paper.texture = tex_original
	scale = PRINTED_SCALE
	position = FALL_START
	z_index = 0
	vbox.visible = true
	_spawn_fall_animation()

func _ready():
	print("titetete")
	area_2d.input_event.connect(_input_event)
	
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in vbox.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _input_event(viewport: Object, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			pickup_sound.play()
			_handle_state_switch()

func _handle_state_switch():
	match _state:
		0: # printed → showing
			_state = 1
			scale = ZOOM_SCALE
			position = CENTER
			paper.texture = tex_original
			vbox.visible = true
			z_index = 10
		1: # showing → down
			_state = 2
			scale = PAPER_DOWN_SCALE
			position = DOWN_POS
			paper.texture = tex_open
			vbox.visible = false
		2: # down → showing
			_state = 1
			scale = ZOOM_SCALE
			position = CENTER
			paper.texture = tex_original
			vbox.visible = true
			z_index = 10

func _spawn_fall_animation():
	var tween = create_tween()
	tween.tween_property(self, "position", FALL_END, 1.0)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)\
		.set_delay(0.2)

func spawn_approve_stamp():
	_spawn_stamp(approve_stamp_scene)

func spawn_decline_stamp():
	_spawn_stamp(decline_stamp_scene)

func _spawn_stamp(scene: PackedScene):
	var stamp = scene.instantiate()
	add_child(stamp)
	stamp.global_position = stamp_anchor.global_position
