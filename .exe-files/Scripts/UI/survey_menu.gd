extends Control

@onready var intro_panel: Panel = $"Inner Panel/Intro Panel"
@onready var intro_text: Label = $"Inner Panel/Intro Panel/IntroContainer/IntroText"
@onready var intro_btn: Button = $"Inner Panel/Intro Panel/IntroContainer/IntroBtn"
@onready var question_panel: Panel = $"Inner Panel/Question Panel"
@onready var question_text: Label = $"Inner Panel/Question Panel/QuestionContainer/QuestionText"
@onready var question_counter: Label = $"Inner Panel/Question Panel/QuestionContainer/QuestionCounter"
@onready var choices_container: VBoxContainer = $"Inner Panel/Question Panel/QuestionContainer/ChoicesContainer"
@onready var result_panel: Panel = $"Inner Panel/Result Panel"
@onready var result_text: Label = $"Inner Panel/Result Panel/ResultContainer/ResultText"
@onready var question_progress: ProgressBar = $"Inner Panel/Question Panel/QuestionContainer/QuestionProgress"
@onready var verdict_text: Label = $"Inner Panel/Result Panel/ResultContainer/VerdictText"

# Declare Quiz Questions
var quiz_questions = [
	{
		"question": "A program advertised as a utility tool installs additional unknown processes after being granted administrator access. What type of threat does this represent?",
		"choices": ["Phishing", "Injection", "Trojan", "Firewall"],
		"correct": 2
	},
	{
		"question": "A file appears with a random filename, is hidden, and stored in an unusual directory. What does this most likely indicate?",
		"choices": ["System optimization", "Temporary file usage", "Possible obfuscation to evade detection", "File compression process"],
		"correct": 2
	},
	{
		"question": "An email claims to be from a bank and urges immediate action, but the sender address slightly differs from the official domain. What type of threat does this represent?",
		"choices": ["It is legitimate due to urgency", "It is phishing due to domain inconsistency", "It is an automated system alert", "It is a backup notification"],
		"correct": 1
	},
	{
		"question": "A system displays irregular strings of symbols and unexpected command-like inputs within a process. What is the most likely issue?",
		"choices": ["File corruption", "Injection of malicious input into the system", "Normal debugging process", "Software update logs"],
		"correct": 1
	},
	{
		"question": "A compressed executable file is received from an unknown source and shows unusual behavior when opened. What is the best classification?",
		"choices": ["Safe archived file", "Malware using obfuscation techniques", "Normal installer package", "System update file"],
		"correct": 1
	},
	{
		"question": "Why are executable files considered higher risk compared to other file types?",
		"choices": ["They cannot be deleted", "They automatically encrypt files", "They can run commands directly on the system", "They are always hidden"],
		"correct": 2
	},
	{
		"question": "When encountering a suspicious file with multiple risk indicators, what is the most appropriate action?",
		"choices": ["Open it to verify contents", "Ignore the indicators", "Avoid execution and remove or report the file", "Rename the file"],
		"correct": 2
	},
	{
		"question": "Which of the following best distinguishes phishing from other types of cyberattacks?",
		"choices": ["It relies on hidden system files", "It uses deceptive communication to trick users", "It compresses files to avoid detection", "It modifies system permissions"],
		"correct": 1
	},
	{
		"question": "Why is a file with a mismatched file type considered suspicious?",
		"choices": ["It improves performance", "It indicates possible disguise or masquerading behavior", "It is required for compatibility", "It reduces file size"],
		"correct": 1
	},
	{
		"question": "Which combination of indicators most strongly suggests a file may be malicious?",
		"choices": ["Known publisher and verified signatures", "Unknown source and requests admin permission", "Small file size and recent modification", "Common file type and normal behavior"],
		"correct": 1
	},
]

# Declare Likert Questions
var likert_questions = [
	"I am aware of common file-based cyber threats.",
	"I can identify suspicious file behaviors.",
	"I feel confident in detecting malicious files.",
	"I can distinguish safe and unsafe files.",
	"I know the correct actions to take when encountering a suspicious file."
]

# Initialize Variables
var current_index = 0
var mode
var quiz_score = 0
var likert_total = 0

func _ready():
	intro_panel.show()
	question_panel.hide()
	result_panel.hide()
	
	mode = "intro1"
	
	# Connect buttons
	for i in range(choices_container.get_child_count()):
		var btn = choices_container.get_child(i)
		btn.pressed.connect(_on_choice_pressed.bind(i))

func _on_intro_button_pressed():
	if mode == "intro1":
		intro_text.text = "You will be presented with a series of questions related to identifying suspicious file behaviors and appropriate security practices. \n\nPlease answer each question to the best of your ability. \n\nClick ‘Start Test’ when you are ready to begin."
		intro_btn.text = "Start Test"
		mode = "intro2"
	elif mode == "intro2":
		start_quiz()

func start_quiz():
	mode = "quiz"
	current_index = 0
	intro_panel.hide()
	question_panel.show()
	show_question()

# Shows each question
func show_question():
	var total_questions = quiz_questions.size() + likert_questions.size()
	var display_index = current_index
	
	if mode == "likert":
		display_index += quiz_questions.size()
		
	question_counter.text = "Question " + str(display_index + 1) + " / " + str(total_questions)
	question_progress.value = display_index + 1
	
	if mode == "quiz":
		var q = quiz_questions[current_index]
		question_text.text = q["question"]
		for i in range(4):
			var btn = choices_container.get_child(i)
			btn.text = q["choices"][i]
			btn.show()
		choices_container.get_child(4).hide()
	elif mode == "likert":
		var q = likert_questions[current_index]
		question_text.text = q
		var labels = ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"]
		for i in range(5):
			var btn = choices_container.get_child(i)
			btn.text = labels[i]
			btn.show()

# Switches questions after answering
func _on_choice_pressed(index): 
	if mode == "quiz":
		if index == quiz_questions[current_index]["correct"]:
			quiz_score += 1
	elif mode == "likert":
		likert_total += (index + 1) # 1–5 scale
	current_index += 1
	if mode == "quiz" and current_index >= quiz_questions.size():
		mode = "likert"
		current_index = 0
		show_question()
	elif mode == "likert" and current_index >= likert_questions.size():
		show_results()
	else:
		show_question()

func show_results():
	question_panel.hide()
	result_panel.show()

	var quiz_percent = (quiz_score / 10.0) * 100
	var likert_mean = likert_total / 5.0

	var performance = ""
	if quiz_percent >= 80:
		performance = "High"
	elif quiz_percent >= 50:
		performance = "Moderateg"
	else:
		performance = "Low"
		
	var awareness = ""
	if likert_mean >= 4:
		awareness = "High Confidence"
	elif likert_mean >= 3:
		awareness = "Moderate Confidence"
	else:
		awareness = "Low Confidence"
		
	result_text.text = \
		"Results:\n\n" + \
		"Quiz Score: " + str(round(quiz_percent)) + "%\n" + \
		"Performance Level: " + performance + "\n\n" + \
		"Awareness Score: " + str(round(likert_mean * 100) / 100.0) + "\n" + \
		"Confidence Level: " + awareness
	
	if quiz_percent >= 80:
		result_text.text += "\n\nExcellent performance!"
	elif quiz_percent >= 50:
		result_text.text += "\n\nYou're on the right track."
	else:
		result_text.text += "\n\nConsider reviewing the concepts more."

func _on_retake_pressed():
	quiz_score = 0
	likert_total = 0
	current_index = 0
	mode = "quiz"
	result_panel.hide()
	start_quiz()

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menu Scenes/main_menu.tscn")
