extends Node2D

var paper_stack: Array = []
var paper_scene := preload("res://Scenes/paper.tscn")
var dragged_paper: Node2D = null

@onready var approve_btn: Button = $ApproveBtn
@onready var decline_btn: Button = $DeclineBtn

func _ready() -> void:
	var paper = paper_scene.instantiate()

func add_paper(paper: Node2D) -> void:
	add_child(paper)
	paper_stack.append(paper)
	_update_z_indices()

func bring_to_front(paper: Node2D) -> void:
	if paper_stack.has(paper):
		paper_stack.erase(paper)
	
	paper_stack.append(paper)
	_update_z_indices()

func _update_z_indices() -> void:
	for i in range(paper_stack.size()):
		paper_stack[i].z_index = i
