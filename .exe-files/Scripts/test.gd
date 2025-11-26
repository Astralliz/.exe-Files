extends VBoxContainer

@onready var cb_type_mismatch  : CheckBox = $TypeMismatch
@onready var cb_invalid_signature : CheckBox = $InvalidSignature
@onready var cb_src_email : CheckBox = $SourceEmail
@onready var cb_size_large : CheckBox = $SizeLarge

@onready var btn_evaluate : Button = $EvaluateButton
@onready var btn_approve : Button = $ApproveButton
@onready var btn_reject : Button = $RejectButton

@onready var result_label : Label = $ResultLabel

# -------------------------------
# NEW — get paper node (Panel5)
# -------------------------------
@onready var _paper := get_parent().get_parent().get_node("Panel5")

var engine := HeuristicEngine.new()
var rules := RuleBase.new()
var file := FileMetadata.new()

func _ready():

	# Animate paper falling down
	_spawn_paper_animation()

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


# ------------------------------------------------
# PAPER ANIMATION FUNCTION
# ------------------------------------------------
func _spawn_paper_animation() -> void:
	if not is_instance_valid(_paper):
		print("ERROR: Panel5 not found.")
		return

	# Start above printer
	var start_pos : Vector2 = _paper.position + Vector2(0, 0)
	var end_pos : Vector2 = _paper.position + Vector2(0, 150)

	_paper.position = start_pos

	var tween := create_tween()
	tween.tween_property(_paper, "position", end_pos, 0.8)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
