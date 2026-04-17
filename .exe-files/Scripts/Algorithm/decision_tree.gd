extends Resource
class_name DecisionTree

var real_tree: RealDecisionTree

# ==============================
# DATA POOLS
# ==============================
const SAFE_FILENAMES = [
	"test", "document1", "receipt", "photo_2025", "final_version",
	"backup_file", "notes", "profile_pic", "invoice", "report"
]

const SUSPICIOUS_FILENAMES = [
	"asdasg1341342362613e1eads4134123sd",
	"xJ9aK2pL2533132827",
	"ajd92ks1h3k8d",
	"temp9384kd93kd",
	"sys_update_8923"
]

const EXTENSION_POOL_SAFE = [".txt", ".pdf", ".png", ".jpg", ".mp3", ".mp4", ".docx"]
const RISKY_EXTENSIONS = [".exe", ".bat", ".js", ".ps1", ".vbs"]

const PUBLISHER_POOL = ["unknown", "ACME Software", "OpenSoft Labs", "Blue Horizon", "ByteForge", "NovaApps"]
const SOURCE_POOL = ["Downloads", "Email Attachment", "USB Device", "External Drive", "Browser Cache", "unknown"]

const ATTACK_TYPES = ["malware", "injection", "phishing", "trojan"]

# ==============================
# PAPER METADATA STRUCTURE
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
			"paper_no": paper_no
		}

# ==============================
# HELPER FUNCTIONS
# ==============================
func is_random_filename(name: String) -> bool:
	if name.length() > 15:
		for char in name:
			if char.is_valid_int():
				return true
	return false


func generate_metadata(paper_no: int) -> PaperMetadata:
	var metadata = PaperMetadata.new()
	var make_risky = randf() < 0.5
	
	# Filename
	metadata.filename = SUSPICIOUS_FILENAMES[randi() % SUSPICIOUS_FILENAMES.size()] if make_risky else SAFE_FILENAMES[randi() % SAFE_FILENAMES.size()]
	
	# Extension
	var all_extensions = RISKY_EXTENSIONS + EXTENSION_POOL_SAFE if make_risky else EXTENSION_POOL_SAFE
	metadata.extension = all_extensions[randi() % all_extensions.size()]
	
	# Size
	metadata.size = randf_range(40, 80) if make_risky else randf_range(5, 40)
	
	# Publisher
	metadata.publisher = "unknown" if (make_risky and randf() < 0.5) else PUBLISHER_POOL[randi() % PUBLISHER_POOL.size()]
	
	# Source
	metadata.source = "Email Attachment" if randf() < 0.5 else SOURCE_POOL[randi() % SOURCE_POOL.size()]
	
	# Signature Valid
	metadata.signature_valid = false if (make_risky and randf() < 0.5) else true
	
	# Requires Admin
	metadata.requires_admin = true if (make_risky and randf() < 0.6) else false
	
	# Is Compressed
	metadata.is_compressed = true if (make_risky and randf() < 0.4) else false
	
	# Hidden
	metadata.hidden = true if randf() < 0.4 else false
	
	# Modified Hours
	metadata.modified_hours = randi_range(1, 100)
	
	# Random Name
	metadata.random_name = 1 if is_random_filename(metadata.filename) else 0
	
	# Assign Label
	metadata.actual_label = real_tree.predict(metadata)
	metadata.paper_no = paper_no
	print("AI:", metadata.actual_label)
	return metadata

func _init():
	real_tree = RealDecisionTree.new()
	real_tree.load_tree("res://Scripts/Algorithm/Data/tree.json")

func assign_label(metadata: PaperMetadata) -> String:
	var ext = metadata.extension
	var pub = metadata.publisher
	var src = metadata.source
	var rnd = metadata.random_name
	
	# Injection rule
	if ext in [".bat", ".ps1"]:
		return "injection"
	
	# Malware rule
	if ext in [".exe", ".js", ".vbs"]:
		if pub == "unknown" or src in ["Downloads", "Browser Cache"]:
			return "malware"
	
	# Phishing rule
	if src == "Email Attachment":
		if rnd == 1 or pub == "unknown":
			return "phishing"
	
	# Trojan rule
	if ext in [".txt", ".pdf", ".docx"]:
		if pub == "unknown" and rnd == 1:
			return "trojan"
	
	# Default
	return "malware"


# ==============================
# DECISION TREE TRAVERSAL
# ==============================
func traverse_tree(metadata: PaperMetadata) -> Array:
	"""
	Simulates traversing the decision tree and returns the path taken.
	Returns array of step tuples: [(feature, decision), ...]
	"""
	var steps = []
	
	# Simplified decision tree based on the Python model
	# This is a rule-based approximation of the trained decision tree
	
	var node = 0
	var result = metadata.actual_label
	
	# Log decision path (simplified version)
	steps.append(["source_%s" % metadata.source, "YES" if metadata.source == "Email Attachment" else "NO"])
	steps.append(["extension_%s" % metadata.extension, "YES" if metadata.extension in [".exe", ".bat"] else "NO"])
	steps.append(["publisher_%s" % metadata.publisher, "YES" if metadata.publisher == "unknown" else "NO"])
	
	return steps


func generate_all_rounds(count: int = 10) -> Array:
	"""Generate the specified number of paper rounds"""
	var rounds = []
	for i in range(count):
		var metadata = generate_metadata(i + 1)
		rounds.append({
			"metadata": metadata,
			"steps": traverse_tree(metadata),
			"score": 0,
			"verdict": null  # Will be set by player
		})
	return rounds
