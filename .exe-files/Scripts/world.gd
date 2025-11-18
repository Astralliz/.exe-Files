extends Node2D

var paper_stack: Array = []
var paper_scene := preload("res://Scenes/paper.tscn")
var dragged_paper: Node2D = null

func _ready() -> void:
	for i in range(2):
		var paper = paper_scene.instantiate()
		add_paper(paper)

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
