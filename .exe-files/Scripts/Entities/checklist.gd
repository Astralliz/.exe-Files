class_name Checklist
extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var list: Sprite2D = $Sprite2D
@onready var vbox_container: VBoxContainer = $VBoxContainer
@onready var file_name: CheckBox = $VBoxContainer/FileName
@onready var extension: CheckBox = $VBoxContainer/Extension
@onready var size: CheckBox = $VBoxContainer/Size
@onready var publisher: CheckBox = $VBoxContainer/Publisher
@onready var source: CheckBox = $VBoxContainer/Source
@onready var evaluate: Button = $VBoxContainer/Evaluate
@onready var result: Label = $VBoxContainer/Result

@onready var pickup_sound = $Audio_Pickup

var tex_closed := preload("res://Assets/Sprites/paper_down_ask.png")
var tex_open := preload("res://Assets/Sprites/large-paper.png")

var _state := 0

const CLOSED_SCALE := Vector2(0.3, 0.3)
const OPEN_SCALE := Vector2(1.2, 1.2)

var CLOSED_POS := Vector2(310, 510)
var OPEN_POS := Vector2(310, 420)

func _ready() -> void:
	_init_appearance()

	area_2d.input_event.connect(_input_event)
	vbox_container.visible = false  

func _init_appearance():
	_state = 0
	list.texture = tex_closed
	scale = CLOSED_SCALE
	position = CLOSED_POS
	z_index = 5

func _input_event(viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		pickup_sound.play()
		_toggle_state()

func _toggle_state():
	match _state:
		0:
			_state = 1
			list.texture = tex_open
			scale = OPEN_SCALE
			position = OPEN_POS
			vbox_container.visible = true
		1:
			_state = 0
			list.texture = tex_closed
			scale = CLOSED_SCALE
			position = CLOSED_POS
			vbox_container.visible = false
