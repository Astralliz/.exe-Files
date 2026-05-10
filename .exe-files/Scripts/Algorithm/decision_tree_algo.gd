extends Resource
class_name RealDecisionTree

var tree_data
var classes = []
var feature_list = []

# ==============================
# LOADERS
# ==============================
func load_tree(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	tree_data = json

func load_classes(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	classes = json

func load_features(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	feature_list = json

func extract_filename_features(name: String) -> Dictionary:
	var lower = name.to_lower()
	return {
		"has_crack": 1 if lower.find("crack") != -1 else 0,
		"has_free": 1 if lower.find("free") != -1 else 0,
		"has_update": 1 if lower.find("update") != -1 else 0,
		"has_verify": 1 if lower.find("verify") != -1 else 0,
		"has_invoice": 1 if lower.find("invoice") != -1 else 0
	}

# ==============================
# SAFE VALUE PARSER
# ==============================
func to_float(val):
	var s = str(val).strip_edges().to_lower()

	if s == "true":
		return 1.0
	elif s == "false":
		return 0.0
	elif s == "":
		return 0.0
	else:
		return float(s)

# ==============================
# PREDICT FROM ALREADY-ENCODED FEATURES
# ==============================
func predict_from_features(sample: Dictionary) -> String:
	return _traverse(tree_data, sample)

# Convert metadata → feature vector
func metadata_to_features(metadata) -> Dictionary:
	var features = {}

	# initialize EXACT python order
	for f in feature_list:
		features[f] = 0.0

	# numeric
	features["size"] = float(metadata.size)
	features["random_name"] = float(metadata.random_name)

	# filename features
	var fname = extract_filename_features(metadata.filename)
	for k in fname.keys():
		if features.has(k):
			features[k] = float(fname[k])

	# extension
	var ext_key = "extension_" + metadata.extension
	if features.has(ext_key):
		features[ext_key] = 1.0

	# source
	var src_key = "source_" + metadata.source
	if features.has(src_key):
		features[src_key] = 1.0

	# publisher
	var pub_key = "publisher_" + metadata.publisher
	if features.has(pub_key):
		features[pub_key] = 1.0

	return features

# Prediction
func predict(metadata) -> String:
	var sample = metadata_to_features(metadata)
	return _traverse(tree_data, sample)

# ==============================
# TREE TRAVERSAL
# ==============================
func _traverse(node: Dictionary, sample: Dictionary) -> String:
	if node.has("feature"):
		var feature = node["feature"]
		var threshold = float(node["threshold"])
		var value = float(sample.get(feature, 0.0))

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
