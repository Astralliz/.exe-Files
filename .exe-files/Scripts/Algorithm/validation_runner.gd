extends Node

var real_tree: RealDecisionTree

# confusion matrix
var matrix = {}
var classes = []

func _ready():
	real_tree = RealDecisionTree.new()
	real_tree.load_tree("res://Scripts/Algorithm/Data/tree.json")
	real_tree.load_features("res://Scripts/Algorithm/Data/features.json")
	real_tree.load_classes("res://Scripts/Algorithm/Data/classes.json")

	classes = real_tree.classes  # ensure SAME order as python

func _on_validate_button_pressed():
	init_matrix()
	run_validation("res://Scripts/Algorithm/Data/test_samples.csv")

func init_matrix():
	for actual in classes:
		matrix[actual] = {}
		for pred in classes:
			matrix[actual][pred] = 0

func run_validation(path: String):
	print(FileAccess.file_exists("res://Scripts/Algorithm/Data/test_samples.csv"))
	print("Trying to open: ", path)
	print("Absolute: ", ProjectSettings.globalize_path(path))

	var file = FileAccess.open(path, FileAccess.READ)

	if file == null:
		print("FAILED TO OPEN CSV")
		print("Error: ", FileAccess.get_open_error())
		return
	

	print("CSV OPENED SUCCESSFULLY")

	var lines = file.get_as_text().split("\n")

	var total = 0
	var match_count = 0
	var debug_limit = 10

	# 🚫 IGNORE CSV HEADERS — USE feature_list instead
	for i in range(1, lines.size()):
		if lines[i].strip_edges() == "":
			continue

		var values = lines[i].split(",")

		var sample = {}

		# ==============================
		# 🔥 CRITICAL FIX: FORCE ALIGNMENT
		# ==============================
		for j in range(real_tree.feature_list.size()):
			var key = real_tree.feature_list[j]

			if j < values.size():
				sample[key] = real_tree.to_float(values[j])
			else:
				sample[key] = 0.0

		# ==============================
		# LABELS (LAST 2 COLUMNS)
		# ==============================
		var true_label = values[values.size() - 2].strip_edges()
		var pred_python = values[values.size() - 1].strip_edges()

		# ==============================
		# PREDICT
		# ==============================
		var godot_pred = real_tree.predict_from_features(sample)

		if godot_pred == pred_python:
			match_count += 1
		else:
			if i <= debug_limit:
				print("\n❌ MISMATCH AT ROW ", i)

		total += 1

		matrix[true_label][godot_pred] += 1

		# ==============================
		# DEBUG
		# ==============================
		if i <= debug_limit:
			print("\n========================")
			print("ROW:", i)
			print("TRUE:", true_label)
			print("PYTHON:", pred_python)
			print("GODOT:", godot_pred)

	# ==============================
	# RESULTS
	# ==============================
	print("\n=== VALIDATION RESULT ===")
	print("Match:", match_count, "/", total)
	print("Accuracy:", float(match_count) / total * 100.0, "%")

	print("\n=== CONFUSION MATRIX ===")
	for actual in classes:
		print(actual, ":", matrix[actual])
