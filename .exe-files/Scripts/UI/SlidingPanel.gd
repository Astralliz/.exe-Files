extends Control

@onready var panel = $QuestionPanel
@onready var content = $Panel/ScrollContainer/VBoxContainer

var is_open := false

var closed_pos := Vector2(0, 320)
var open_pos := Vector2(0, 10)

func _ready():
	position = closed_pos
	content.visible = false
	self.z_index = 11 
	panel.gui_input.connect(_on_panel_clicked)

func _on_panel_clicked(event):
	if event is InputEventMouseButton and event.pressed:
		toggle_panel()

func toggle_panel():
	var tween = create_tween()

	if !is_open:
		tween.tween_property(self, "position", open_pos, 0.3)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)

		content.visible = true
		is_open = true

	else:
		tween.tween_property(self, "position", closed_pos, 0.3)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN)

		await tween.finished
		content.visible = false
		is_open = false
