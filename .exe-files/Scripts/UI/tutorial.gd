class_name Tutorial
extends Day

@onready var tutorial_dialogue: TutorialDialogueBox = $"Tutorial Dialogue"

var tutorial_step: int = 0

func _ready():
	super._ready()
	
	tutorial_dialogue.z_index = 999
	
	if tutorial_dialogue.visible:
		return
	
	# Connect DayScene signals
	filetizen_spawned.connect(_on_filetizen_spawned)
	document_spawned.connect(_on_document_spawned)
	question_asked.connect(_on_question_asked)
	verdict_chosen.connect(_on_verdict_chosen)
	verdict_resolved.connect(_on_verdict_resolved)
	
	start_tutorial()

func start_tutorial():
	if tutorial_step == 0:
		tutorial_dialogue.show_dialogue(
			"Welcome, Analyst. Today, you’ll be inspecting Filetizens attempting to access the system."
		)

func _on_filetizen_spawned():
	if tutorial_step == 0:
		tutorial_step = 1
		tutorial_dialogue.show_dialogue(
			"This is a Filetizen. Each one represents a file requesting system access."
		)

func _on_document_spawned():
	if tutorial_step == 1:
		tutorial_step = 2
		tutorial_dialogue.show_dialogue(
			"This is the Filetizen Identification Panel. Use it to inspect metadata and behavior."
		)

func _on_question_asked(key: String):
	if tutorial_step == 2:
		tutorial_step = 3
		tutorial_dialogue.show_dialogue(
			"Good. Asking questions reveals information — but remember, not all answers are truthful."
		)

func _on_verdict_chosen(approved: bool):
	if tutorial_step == 3:
		tutorial_step = 4
		tutorial_dialogue.show_dialogue(
			"You’ve made your decision. Let’s see if your judgment was correct."
		)

func _on_verdict_resolved(is_correct: bool):
	if tutorial_step == 4:
		tutorial_step = 5
		if is_correct:
			tutorial_dialogue.show_dialogue(
				"Correct. Careful inspection is the key to protecting the system."
			)
		else:
			tutorial_dialogue.show_dialogue(
				"Mistakes happen. Pay attention to inconsistencies in file behavior."
			)
