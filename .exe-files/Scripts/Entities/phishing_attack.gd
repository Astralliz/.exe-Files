# ==============================
# PHISHING ATTACK MINIGAME
# ==============================
extends Control

signal minigame_finished(success: bool)

# ── Node References ──────────────────────────────────────────────────
@onready var chance_count_label: Label = $ChanceCount
@onready var sender_label: Label = $EmailContainer/Header/Sender
@onready var subject_label: Label = $EmailContainer/Header/Subject
@onready var message_label: Label = $EmailContainer/Body/Message
@onready var message2_label: Label = $EmailContainer/Body/Message2
@onready var message3_label: Label = $EmailContainer/Body/Message3

# ── Email Pool ───────────────────────────────────────────────────────
# Each entry: { "part": "key", "text": "display text", "suspicious": true/false }
# Parts: sender, subject, message, message2, message3
const EMAIL_POOL: Array[Dictionary] = [
	# Senders
	{ "part": "sender", "text": "support@facebook.com",         "suspicious": false },
	{ "part": "sender", "text": "noreply@paypa1.com",            "suspicious": true  },
	{ "part": "sender", "text": "security@google.com",           "suspicious": false },
	{ "part": "sender", "text": "alert@bank-secure.xyz",         "suspicious": true  },
	{ "part": "sender", "text": "no-reply@amazon.com",           "suspicious": false },
	{ "part": "sender", "text": "verify@appleid-login.net",      "suspicious": true  },

	# Subjects
	{ "part": "subject", "text": "Security Alert",               "suspicious": false },
	{ "part": "subject", "text": "Your account has been locked!", "suspicious": true  },
	{ "part": "subject", "text": "Password Reset Request",        "suspicious": false },
	{ "part": "subject", "text": "URGENT: Verify Now or Lose Access", "suspicious": true },
	{ "part": "subject", "text": "Your monthly statement",        "suspicious": false },

	# Opening messages
	{ "part": "message", "text": "Dear user,\nYour account will be suspended!", "suspicious": true  },
	{ "part": "message", "text": "Hello,\nWe noticed a login from a new device.", "suspicious": false },
	{ "part": "message", "text": "Dear customer,\nPlease review your recent activity.", "suspicious": false },
	{ "part": "message", "text": "ALERT: Unauthorized access detected. Act immediately!", "suspicious": true },

	# Links / message2
	{ "part": "message2", "text": "[ www.facebook-login.xyz ]",  "suspicious": true  },
	{ "part": "message2", "text": "[ www.facebook.com/security ]","suspicious": false },
	{ "part": "message2", "text": "[ verify.paypal.com ]",        "suspicious": false },
	{ "part": "message2", "text": "[ paypa1-secure.ru/verify ]",  "suspicious": true  },
	{ "part": "message2", "text": "[ amazon.com/account ]",       "suspicious": false },
	{ "part": "message2", "text": "[ amaz0n-deals.net/claim ]",   "suspicious": true  },

	# Closing lines / message3
	{ "part": "message3", "text": "Act now or lose access!",      "suspicious": true  },
	{ "part": "message3", "text": "Thank you for your patience.", "suspicious": false },
	{ "part": "message3", "text": "If you did not request this, ignore this email.", "suspicious": false },
	{ "part": "message3", "text": "Failure to comply will result in permanent ban!", "suspicious": true },
	{ "part": "message3", "text": "Contact us at support@service.com if you need help.", "suspicious": false },
]

# ── Game State ───────────────────────────────────────────────────────
const MAX_CHANCES: int = 3
const PARTS: Array[String] = ["sender", "subject", "message", "message2", "message3"]

var chances_left: int = MAX_CHANCES
var suspicious_parts: Array[String] = []      # which part-keys are suspicious this round
var found_parts: Array[String]      = []      # correctly tapped
var tapped_parts: Array[String]     = []      # all tapped (to avoid double-tap)
var current_email: Dictionary       = {}      # part -> { text, suspicious }
var found_label: Label                        # shows "1/2" progress
var part_labels: Dictionary         = {}      # part key -> Label node

# ── Feedback overlay nodes (created at runtime) ──────────────────────
var feedback_nodes: Dictionary = {}  # part -> Label (✓ or ✗)

# ── Lifecycle ────────────────────────────────────────────────────────
func _ready() -> void:
	_build_part_label_map()
	_create_found_label()
	_create_feedback_overlays()
	_start_round()

func _build_part_label_map() -> void:
	part_labels = {
		"sender":   sender_label,
		"subject":  subject_label,
		"message":  message_label,
		"message2": message2_label,
		"message3": message3_label,
	}

func _create_found_label() -> void:
	found_label = Label.new()
	found_label.name = "FoundLabel"
	found_label.add_theme_font_size_override("font_size", 22)
	found_label.add_theme_color_override("font_color", Color.BLACK)
	# Place it next to ChanceCount — adjust position to taste
	found_label.position = Vector2(600, 0)   # relative inside Panel; tweak as needed
	$EmailContainer.add_child(found_label)

func _create_feedback_overlays() -> void:
	for part in PARTS:
		var lbl: Label = Label.new()
		lbl.name = "Feedback_" + part
		lbl.add_theme_font_size_override("font_size", 32)
		lbl.visible = false
		part_labels[part].add_child(lbl)
		feedback_nodes[part] = lbl

# ── Round Setup ──────────────────────────────────────────────────────
func _start_round() -> void:
	chances_left = MAX_CHANCES
	found_parts.clear()
	tapped_parts.clear()

	_hide_all_feedback()

	current_email = _generate_email()
	suspicious_parts = []
	for part in PARTS:
		if current_email[part]["suspicious"]:
			suspicious_parts.append(part)

	_apply_email_to_labels()
	_update_ui()
	_connect_taps()

func _generate_email() -> Dictionary:
	# Pick one entry per part randomly from the pool
	var email: Dictionary = {}
	for part in PARTS:
		var candidates: Array = EMAIL_POOL.filter(func(e): return e["part"] == part)
		candidates.shuffle()
		email[part] = { "text": candidates[0]["text"], "suspicious": candidates[0]["suspicious"] }

	# Enforce: 1–3 suspicious parts total
	var sus_count: int = 0
	for part in PARTS:
		if email[part]["suspicious"]:
			sus_count += 1

	# If 0 or >3, rebuild (simple retry)
	if sus_count == 0 or sus_count > 3:
		return _generate_email()

	return email

func _apply_email_to_labels() -> void:
	for part in PARTS:
		part_labels[part].text = current_email[part]["text"]

func _connect_taps() -> void:
	for part in PARTS:
		var lbl: Label = part_labels[part]
		# Make label mouse-interactive
		lbl.mouse_filter = Control.MOUSE_FILTER_STOP
		# Disconnect old signals to avoid duplicates
		if lbl.gui_input.is_connected(_on_part_tapped.bind(part)):
			lbl.gui_input.disconnect(_on_part_tapped.bind(part))
		lbl.gui_input.connect(_on_part_tapped.bind(part))

# ── Input Handling ───────────────────────────────────────────────────
func _on_part_tapped(event: InputEvent, part: String) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if part in tapped_parts:
		return  # already tapped
	if chances_left <= 0:
		return
	
	tapped_parts.append(part)
	chances_left -= 1
	var is_suspicious: bool = current_email[part]["suspicious"]

	if is_suspicious:
		found_parts.append(part)
		_show_feedback(part, true)
	else:
		chances_left -= 1
		_show_feedback(part, false)

	_update_ui()
	_check_end_condition()

# ── Feedback ─────────────────────────────────────────────────────────
func _show_feedback(part: String, correct: bool) -> void:
	var lbl: Label = feedback_nodes[part]
	lbl.text = " ✓" if correct else " ✗"
	lbl.add_theme_color_override("font_color",
		Color(0.2, 0.9, 0.2) if correct else Color(0.9, 0.2, 0.2))
	lbl.visible = true

func _hide_all_feedback() -> void:
	for part in PARTS:
		feedback_nodes[part].visible = false

# ── UI Update ────────────────────────────────────────────────────────
func _update_ui() -> void:
	chance_count_label.text = str(chances_left)
	found_label.text = str(found_parts.size()) + "/" + str(suspicious_parts.size())

# ── End Condition ────────────────────────────────────────────────────
func _check_end_condition() -> void:
	var all_found: bool = found_parts.size() == suspicious_parts.size()
	var out_of_chances: bool = chances_left <= 0

	if all_found:
		_end_game(true)
	elif out_of_chances:
		# Reveal un-found suspicious parts
		for part in suspicious_parts:
			if not (part in found_parts):
				_show_feedback(part, false)  # mark missed ones red
		_end_game(false)

func _end_game(success: bool) -> void:
	# Brief delay so the player can see final feedback before closing
	await get_tree().create_timer(1.5).timeout
	emit_signal("minigame_finished", success)
	queue_free()

# ── Legacy buttons (keep for editor testing) ─────────────────────────
func _on_finished_pressed() -> void:
	emit_signal("minigame_finished", true)
	queue_free()

func _on_quit_pressed() -> void:
	emit_signal("minigame_finished", false)
	queue_free()
