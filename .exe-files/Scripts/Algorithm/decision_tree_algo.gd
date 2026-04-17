extends Resource
class_name RealDecisionTree

var tree_data
var classes = ["injection", "malware", "phishing", "trojan"]

# Load JSON
func load_tree(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	tree_data = json

# Convert metadata → feature vector
func metadata_to_features(metadata) -> Dictionary:
	var features = {}

	# One-hot encoding (same as pandas.get_dummies)
	
	# Extension
	for ext in [".exe", ".bat", ".js", ".ps1", ".vbs", ".txt", ".pdf", ".png", ".jpg", ".mp3", ".mp4", ".docx"]:
		features["extension_" + ext] = 1 if metadata.extension == ext else 0

	# Source
	for src in ["Downloads", "Email Attachment", "USB Device", "External Drive", "Browser Cache", "unknown"]:
		features["source_" + src] = 1 if metadata.source == src else 0

	# Publisher
	for pub in ["unknown","ACME Software","OpenSoft Labs","Blue Horizon","ByteForge","NovaApps"]:
		features["publisher_" + pub] = 1 if metadata.publisher == pub else 0

	# Boolean features
	features["signature_valid"] = int(metadata.signature_valid)
	features["requires_admin"] = int(metadata.requires_admin)
	features["is_compressed"] = int(metadata.is_compressed)
	features["hidden"] = int(metadata.hidden)

	# Numeric
	features["size"] = metadata.size
	features["modified_hours"] = metadata.modified_hours
	features["random_name"] = metadata.random_name

	return features

# Prediction
func predict(metadata) -> String:
	var sample = metadata_to_features(metadata)
	return _traverse(tree_data, sample)

func _traverse(node: Dictionary, sample: Dictionary) -> String:
	if node.has("feature"):
		var feature = node["feature"]
		var threshold = node["threshold"]
		var value = sample.get(feature, 0)

		if value <= threshold:
			return _traverse(node["left"], sample)
		else:
			return _traverse(node["right"], sample)
	else:
		# Leaf node
		var values = node["value"][0]

		var max_index = 0
		var max_value = values[0]

		for i in range(values.size()):
			if values[i] > max_value:
				max_value = values[i]
				max_index = i

		return classes[max_index]
