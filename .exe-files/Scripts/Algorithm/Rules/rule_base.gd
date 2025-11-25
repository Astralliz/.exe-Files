class_name RuleBase
extends Resource

var rules = [
	{"id": "R1", "condition": "size_large", "score": 0.5},
	{"id": "R2", "condition": "ext_exe", "score": 1},
	{"id": "R3", "condition": "ext_script", "score": 0.8},
	{"id": "R4", "condition": "ext_dropper", "score": 0.8},
	{"id": "R5", "condition": "name_installer", "score": 0.4},
	{"id": "R6", "condition": "unknown_publisher", "score": 1},
	{"id": "R7", "condition": "recent_modified", "score": 0.5},
	{"id": "R8", "condition": "src_email", "score": 1},
	{"id": "R9", "condition": "src_unknown", "score": 1},
	{"id": "R10", "condition": "is_hidden", "score": 0.7},
	{"id": "R11", "condition": "random_filename", "score": 0.6},
	{"id": "R12", "condition": "invalid_signature", "score": 1},
	{"id": "R13", "condition": "needs_admin", "score": 1},
	{"id": "R14", "condition": "type_mismatch", "score": 1},
	{"id": "R15", "condition": "compressed_exec", "score": 0.8},
]
