extends Resource
class_name DecisionTree

var real_tree: RealDecisionTree

# ==============================
# ATTACK TYPES
# ==============================
const ATTACK_TYPES = ["malware", "injection", "phishing", "trojan"]

# ==============================
# SHARED POOLS
# ==============================
const PUBLISHER_POOL = [
	"unknown", "ACME Software", "OpenSoft Labs",
	"Blue Horizon", "ByteForge", "NovaApps"
]

# ==============================
# ATTACK-BASED POOLS
# ==============================
const ATTACK_POOLS = {
	"malware": {
		"filenames": ["system_update", "driver_patch", "security_fix"],
		"extensions": [".exe", ".bat", ".ps1"],
		"sources": ["Downloads", "Browser Cache"],
		"hints": [
			"This file tries to run automatically",
			"It asks for full access to your system",
			"It slows down your device after opening"
		]
	},
	"phishing": {
		"filenames": ["invoice_urgent", "password_reset", "verify_account"],
		"extensions": [".html", ".pdf", ".docx"],
		"sources": ["Email Attachment"],
		"hints": [
			"The message is trying to rush you",
			"The sender looks unfamiliar",
			"It asks for personal or account information"
		]
	},
	"injection": {
		"filenames": ["query_input", "login_script", "form_data"],
		"extensions": [".sql", ".js", ".txt"],
		"sources": ["Web Form Input", "Downloads"],
		"hints": [
			"The input contains unusual or messy text”",
			"This doesn’t look like a normal answer",
			"It includes strange symbols or repeated characters"
		]
	},
	"trojan": {
		"filenames": ["game_crack", "free_installer", "premium_unlock"],
		"extensions": [".exe", ".bat"],
		"sources": ["Community Forum", "Downloads"],
		"hints": [
			"It pretends to be something useful or fun",
			"The name and behavior don’t match",
			"It claims to be safe, but something feels off"
		]
	}
}

# ==============================
# METADATA STRUCTURE
# ==============================
class PaperMetadata:
	var filename: String
	var extension: String
	var size: float
	var publisher: String
	var source: String
	var signature_valid: bool
	var requires_admin: bool
	var is_compressed: bool
	var hidden: bool
	var modified_hours: int
	var random_name: int
	var actual_label: String
	var paper_no: int
	var flags: Array = []

	func to_dict() -> Dictionary:
		return {
			"filename": filename,
			"extension": extension,
			"size": size,
			"publisher": publisher,
			"source": source,
			"signature_valid": signature_valid,
			"requires_admin": requires_admin,
			"is_compressed": is_compressed,
			"hidden": hidden,
			"modified_hours": modified_hours,
			"random_name": random_name,
			"actual_label": actual_label,
			"paper_no": paper_no,
			"flags": flags
		}

# ==============================
# HELPERS
# ==============================
func is_random_filename(name: String) -> bool:
	if name.length() > 15:
		for char in name:
			if char.is_valid_int():
				return true
	return false


# ==============================
# GENERATION (CORE FIX)
# ==============================
func generate_metadata(paper_no: int) -> PaperMetadata:
	var metadata = PaperMetadata.new()

	# 1. Pick attack type
	var attack_type = ATTACK_TYPES[randi() % ATTACK_TYPES.size()]
	var pool = ATTACK_POOLS[attack_type]

	# 2. Basic fields
	metadata.filename = pool["filenames"].pick_random()
	metadata.extension = pool["extensions"].pick_random()
	metadata.source = pool["sources"].pick_random()

	# 3. Publisher logic
	if attack_type == "trojan":
		metadata.publisher = ["Micros0ft", "unknown"].pick_random()
	elif attack_type == "phishing":
		metadata.publisher = "unknown"
	else:
		metadata.publisher = PUBLISHER_POOL.pick_random()

	# 4. Size (aligned with tree behavior)
	if attack_type == "malware" or attack_type == "trojan":
		metadata.size = randf_range(45, 80)
	else:
		metadata.size = randf_range(5, 40)

	# 5. Boolean features
	metadata.signature_valid = false if attack_type == "phishing" else randf() > 0.3
	metadata.requires_admin = attack_type == "malware"
	metadata.is_compressed = randf() < 0.4
	metadata.hidden = randf() < 0.3
	metadata.modified_hours = randi_range(1, 100)

	# 6. Random filename feature
	metadata.random_name = 1 if is_random_filename(metadata.filename) else 0

	# 7. FLAGS (UI hints)
	metadata.flags = []
	for i in range(2):
		metadata.flags.append(pool["hints"].pick_random())

	# 8. Model prediction (GROUND TRUTH)
	metadata.actual_label = real_tree.predict(metadata)

	metadata.paper_no = paper_no

	print("AI:", metadata.actual_label, " | Generated:", attack_type)

	return metadata


# ==============================
# TREE VISUALIZATION (OPTIONAL)
# ==============================
func traverse_tree(metadata: PaperMetadata) -> Array:
	var steps = []

	steps.append(["source_" + metadata.source, "YES" if metadata.source == "Email Attachment" else "NO"])
	steps.append(["extension_" + metadata.extension, "YES" if metadata.extension in [".exe", ".bat"] else "NO"])
	steps.append(["publisher_" + metadata.publisher, "YES" if metadata.publisher == "unknown" else "NO"])

	return steps


# ==============================
# ROUND GENERATION
# ==============================
func generate_all_rounds(count: int = 10) -> Array:
	var rounds = []

	for i in range(count):
		var metadata = generate_metadata(i + 1)

		rounds.append({
			"metadata": metadata,
			"steps": traverse_tree(metadata),
			"score": 0,
			"verdict": null
		})

	return rounds


# ==============================
# INIT
# ==============================
func _init():
	real_tree = RealDecisionTree.new()
	real_tree.load_tree("res://Scripts/Algorithm/Data/tree.json")
