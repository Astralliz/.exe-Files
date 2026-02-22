class_name RuleBase
extends Resource

# Predefined rules
var all_rules = [
	{"id": "R1", "condition": "size_large", "score": 0.5},
	{"id": "R2", "condition": "ext_exe", "score": 1},
	{"id": "R3", "condition": "ext_script", "score": 0.8},
	{"id": "R4", "condition": "ext_dropper", "score": 0.8},
	{"id": "R5", "condition": "unknown_publisher", "score": 1},
	{"id": "R6", "condition": "recent_modified", "score": 0.5},
	{"id": "R7", "condition": "src_email", "score": 1},
	{"id": "R8", "condition": "src_unknown", "score": 1},
	{"id": "R9", "condition": "is_hidden", "score": 0.7},
	{"id": "R10", "condition": "random_filename", "score": 0.6},
	{"id": "R11", "condition": "invalid_signature", "score": 1},
	{"id": "R12", "condition": "needs_admin", "score": 1},
	{"id": "R13", "condition": "type_mismatch", "score": 1},
	{"id": "R14", "condition": "compressed_exec", "score": 0.8},
]

# Rules per level
var level_rules = {
	1: [
		{"id": "R1", "condition": "size_large", "score": 0.4},
		{"id": "R2", "condition": "ext_exe", "score": 0.7},
		{"id": "R3", "condition": "ext_script", "score": 0.4},
		{"id": "R4", "condition": "ext_dropper", "score": 0.5},
		{"id": "R5", "condition": "unknown_publisher", "score": 0.6},
		{"id": "R8", "condition": "src_unknown", "score": 0.4},
		{"id": "R13", "condition": "type_mismatch", "score": 0.2},
	],
	2: [
		# Level 2 adds more conditions 
		{"id": "R1", "condition": "size_large", "score": 0.4},
		{"id": "R2", "condition": "ext_exe", "score": 0.6},
		{"id": "R3", "condition": "ext_script", "score": 0.4},
		{"id": "R4", "condition": "ext_dropper", "score": 0.5},
		{"id": "R5", "condition": "unknown_publisher", "score": 0.6},
		{"id": "R6", "condition": "recent_modified", "score": 0.3},
		{"id": "R7", "condition": "src_email", "score": 0.4},
		{"id": "R8", "condition": "src_unknown", "score": 0.5},
		{"id": "R9", "condition": "is_hidden", "score": 0.6},
		{"id": "R13", "condition": "type_mismatch", "score": 0.2},
	],
	3: [
		# Level 3 includes all rules for maximum complexity
		{"id": "R1", "condition": "size_large", "score": 0.4},
		{"id": "R2", "condition": "ext_exe", "score": 0.7},
		{"id": "R3", "condition": "ext_script", "score": 0.5},
		{"id": "R4", "condition": "ext_dropper", "score": 0.6},
		{"id": "R5", "condition": "unknown_publisher", "score":0.6},
		{"id": "R6", "condition": "recent_modified", "score": 0.4},
		{"id": "R7", "condition": "src_email", "score": 0.5},
		{"id": "R8", "condition": "src_unknown", "score": 0.5},
		{"id": "R9", "condition": "is_hidden", "score": 0.5},
		{"id": "R10", "condition": "random_filename", "score": 0.4},
		{"id": "R11", "condition": "invalid_signature", "score": 0.8},
		{"id": "R12", "condition": "needs_admin", "score": 0.8},
		{"id": "R13", "condition": "type_mismatch", "score": 0.2},
		{"id": "R14", "condition": "compressed_exec", "score": 0.5},
	]
}

# Get rules for a given level
func get_rules(level: int) -> Array:
	if level_rules.has(level):
		return level_rules[level]
	return []
