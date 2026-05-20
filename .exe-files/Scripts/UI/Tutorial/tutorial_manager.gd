class_name TutorialManager
extends Node

# ========================
# SIGNALS — Tutorial.gd listens to these
# ========================
signal part_started(part: int)
signal spawn_filetizen_requested
signal spawn_document_requested
signal show_panel_requested(scene_path: String)
signal tutorial_finished
signal tutorial_event(event_name: String)

# ========================
# STATE
# ========================
var current_part: int = -1
var _waiting_for_next: bool = false

var tutorial_dialogue: TutorialDialogueBox
var dialogue_box: DialogueBox

# ========================
# PART DEFINITIONS
# ========================
const PARTS: Array[Dictionary] = [
	# Part 0 — Welcome → Next → spawn both filetizen AND document at the same time
	{
		"text": "Welcome, Inspector %s. You'll be inspecting Filetizens requesting system access.",
		"wait_for_next": true,
		"after_next": "spawn_both"
	},
	# Part 1 — Both spawned → show document tutorial panel (NO DIALOGUE)
	{
		"text": "This is the Identification Panel. It holds everything you need to inspect a Filetizen.",
		"panel": "res://Scenes/UI/tutorial_panels/document_tutorial_panel.tscn",
		"skip_dialogue": true,
		"wait_for_next": true,
		"after_next": "none"
	},
	# Part 2 — Show dialogue, then show button panel on next
	{
		"text": "Use Approve or Decline to make your verdict. Also you can view your resources ingame",
		"panel": "res://Scenes/UI/tutorial_panels/button_panel.tscn",
		"wait_for_next": true,
		"after_next": "show_panel"
	},
	# Part 3 — Questions
	{
		"text": "Before deciding, ask the Filetizen questions using the panel on bottom-center. Not all answers are truthful.",
		"panel": "res://Scenes/UI/tutorial_panels/question_tutorial_panel.tscn",
		"wait_for_next": true,
		"after_next": "show_panel"
	},
	{
		"text": "Take note of filetizen answer and compare it with their metadata, a different answer from their metadata, is a hint that something is suspicious, but not all the time",
		"wait_for_next": true,
		"completes_on": "question_asked"
	},
	# Part 4 — Evaluate
	{
		"text": "Now i will introduce you a resources that will help you analyse the metadata.",
		"panel": "res://Scenes/UI/tutorial_panels/evaluate_tutorial_panel.tscn",
		"wait_for_next": true,
		"after_next": "show_panel"
	},
	{
		"text": "Here is the Thressohold score of filetizen, if their total score exceed this, theyre suspicious.",
		"panel": "res://Scenes/UI/tutorial_panels/threshold_panel.tscn",
		"wait_for_next": true,
		"after_next": "show_panel"
	},
	{
		"text": "Next is the indicator.",
		"panel": "res://Scenes/UI/tutorial_panels/indicator_panel.tscn",
		"wait_for_next": true,
		"after_next": "show_panel"
	},
	# Part 5 — Filter
	{
		"text": "Here's another resources you can use. the filter, its a shortcut, it will reveal the filetizen real identity directly",
		"panel": "res://Scenes/UI/tutorial_panels/filter_tutorial_panel.tscn",
		"wait_for_next": true,
		"after_next": "show_panel"
	},
	# Part 6 — Pause → finish
	{
		"text": "You can pause at any time using the Pause button in the top right corner.",
		"wait_for_next": true,
		"after_next": "none"
	},
	
	{
		"text": "That's everything — you're ready, Inspector %s .",
		"wait_for_next": true,
		"after_next": "finish"
	},
]

# ========================
# SETUP
# ========================
func setup(p_tutorial_dialogue: TutorialDialogueBox, p_dialogue_box: DialogueBox) -> void:
	tutorial_dialogue = p_tutorial_dialogue
	dialogue_box = p_dialogue_box
	tutorial_dialogue.closed.connect(_on_next_clicked)

# ========================
# ADVANCE PART
# ========================
func start() -> void:
	advance_to(0)

func advance_to(part: int) -> void:
	current_part = part
	if current_part >= PARTS.size():
		return

	var data = PARTS[current_part]
	
	# Show dialogue unless skip_dialogue is true
	if not data.get("skip_dialogue", false):
		var text: String = data["text"]

		if "%s" in text:
			text = text % Player_Data.data.get("username", "Inspector")

		tutorial_dialogue.show_dialogue(text)
	
	emit_signal("part_started", current_part)
	_waiting_for_next = data.get("wait_for_next", false)

	# For parts with skip_dialogue, request panel immediately
	if data.get("skip_dialogue", false) and data.has("panel"):
		emit_signal("show_panel_requested", data["panel"])

func notify_event(event: String) -> void:
	emit_signal("tutorial_event", event)
	if current_part < 0 or current_part >= PARTS.size():
		return
	var data = PARTS[current_part]
	if data.get("completes_on", "") == event:
		_complete_current_part()

# ========================
# NEXT BUTTON CLICKED
# ========================
func _on_next_clicked() -> void:
	if not _waiting_for_next:
		return
	_complete_current_part()

func _complete_current_part() -> void:
	var data = PARTS[current_part]
	var after: String = data.get("after_next", "none")

	match after:
		"spawn_both":
			emit_signal("spawn_filetizen_requested")
			emit_signal("spawn_document_requested")
			advance_to(current_part + 1)
		"spawn_document":
			emit_signal("spawn_document_requested")
			advance_to(current_part + 1)
		"spawn_filetizen":
			emit_signal("spawn_filetizen_requested")
			advance_to(current_part + 1)
		"show_panel":
			# Show panel after dialogue
			if data.has("panel"):
				emit_signal("show_panel_requested", data["panel"])
		"finish":
			emit_signal("tutorial_finished")
		_:
			advance_to(current_part + 1)
