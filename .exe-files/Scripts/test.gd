extends VBoxContainer

@onready var cb_type_mismatch  : CheckBox = $TypeMismatch
@onready var cb_invalid_signature : CheckBox = $InvalidSignature
@onready var cb_src_email : CheckBox = $SourceEmail
@onready var cb_size_large : CheckBox = $SizeLarge

@onready var btn_evaluate : Button = $EvaluateButton
@onready var btn_approve : Button = $ApproveButton
@onready var btn_reject : Button = $RejectButton

@onready var result_label : Label = $ResultLabel

var engine := HeuristicEngine.new()
var rules := RuleBase.new()
var file := FileMetadata.new()

func _ready():
	# Dummy file
	file.filename = "setup_payload123.exe"
	file.extension = "pdf"
	file.size_mb = 20
	file.publisher = "google"
	file.source = "email"
	file.modified_hours_ago = 22
	file.hidden = false
	file.signature_valid = false
	file.requires_admin = false
	file.claimed_type = "pdf"

	# Connect signals
	btn_evaluate.connect("pressed", Callable(self, "_on_evaluate_pressed"))
	btn_approve.connect("pressed", Callable(self, "_on_approve_pressed"))
	btn_reject.connect("pressed", Callable(self, "_on_reject_pressed"))

	# Optionally auto-fill checkboxes from file metadata so player can start from a known state:
	# cb_type_mismatch.pressed = (file.extension != file.claimed_type)
	# cb_invalid_signature.pressed = (not file.signature_valid)
	# cb_src_email.pressed = (file.source == "email")
	# cb_size_large.pressed = (file.size_mb > 50)


func _on_evaluate_pressed() -> void:
	var score : float = engine.evaluate(file, rules)
	var auto_danger : bool = score >= 2.5

	var player_suspicious : bool = (
		cb_type_mismatch.pressed or
		cb_invalid_signature.pressed or
		cb_src_email.pressed or
		cb_size_large.pressed
	)

	# Warning UI
	if player_suspicious:
		result_label.text = "⚠️ You detected something suspicious!"
	else:
		result_label.text = "No suspicious flags detected by player."

	# Show engine score for debugging
	result_label.text += "\n[Engine score: %s]".format(str(score))

	# If you want to immediately show suggested action:
	if auto_danger:
		result_label.text += "\nEngine suggests: REJECT"
	else:
		result_label.text += "\nEngine suggests: APPROVE"


func _on_approve_pressed() -> void:
	_handle_player_decision(true)


func _on_reject_pressed() -> void:
	_handle_player_decision(false)


func _handle_player_decision(player_approves: bool) -> void:
	var score : float = engine.evaluate(file, rules)
	var auto_danger : bool = score >= 2.5

	if player_approves:
		if auto_danger:
			result_label.text = "❌ GAME OVER — You approved a dangerous file!"
		else:
			result_label.text = "✅ Correct — File was safe and you approved it."
	else:
		if auto_danger:
			result_label.text = "✅ Correct — You rejected a dangerous file."
		else:
			result_label.text = "❌ GAME OVER — You rejected a safe file!"
