# res://Scripts/PlayerData.gd
#class_name PlayerData
extends Node

var TEMP_SAVE := true  # true = only memory, false = save to disk

# Default data
var data: Dictionary = {
	"new_game": true,
	"welcome_showed": false,
	"username": "",
	"level": 0,
	"speedtime": {},   # { "level1": 120.5, "level2": 95.2 } in seconds
	"achievements": [], # ["FirstScan", "ExpertAnalyzer"]
	"filter_used": 0,   # { "level1": 3, "level2": 1 } - track skill/question usage
	"evaluate_used": 0,
	"bug_bounty": 40
}

const SAVE_PATH := "user://player_data.cfg"
const SAVE_SECTION := "player"

signal bug_bounty_changed(new_amount)
signal filter_amount_change(new_amount)
signal evaluation_amount_change(new_amount)

func _ready() -> void:
	load_data()

# -----------------------
# SAVE/LOAD using ConfigFile
# -----------------------
func save_data() -> void:
	if TEMP_SAVE:
		print("TEMP SAVE: Player data saved in memory only:", data)
		return  # do not write to disk in dev mode

	var cfg := ConfigFile.new()
	cfg.set_value(SAVE_SECTION, "username", data["username"])
	cfg.set_value(SAVE_SECTION, "level", int(data["level"]))
	cfg.set_value(SAVE_SECTION, "speedtime", data["speedtime"])
	cfg.set_value(SAVE_SECTION, "achievements", data["achievements"])
	cfg.set_value(SAVE_SECTION, "filter_used", data["filter_used"])
	cfg.set_value(SAVE_SECTION, "evaluate_used", data["evaluate_used"])
	cfg.set_value(SAVE_SECTION, "bug_bounty", int(data["bug_bounty"]))

	var err := cfg.save(SAVE_PATH)
	if err == OK:
		print("Player data saved to %s" % SAVE_PATH)
	else:
		push_error("Failed to save player data (err %d) to %s" % [err, SAVE_PATH])


func load_data() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)

	if err != OK:
		print("No existing save file. Creating default save.")
		save_data()
		return

	# SAFELY READ VALUES
	data["username"] = str(cfg.get_value(SAVE_SECTION, "username", data["username"]))
	data["level"] = int(cfg.get_value(SAVE_SECTION, "level", data["level"]))

	# ---- Speedtime ----
	var st: Dictionary = cfg.get_value(SAVE_SECTION, "speedtime", {})
	if typeof(st) == TYPE_DICTIONARY:
		data["speedtime"] = st.duplicate(true)
	else:
		data["speedtime"] = {}

	# ---- Achievements ----
	var ach: Array = cfg.get_value(SAVE_SECTION, "achievements", [])
	if typeof(ach) == TYPE_ARRAY:
		data["achievements"] = ach.duplicate(true)
	else:
		data["achievements"] = []

	# ---- Questions Used ----
	var qu: Dictionary = cfg.get_value(SAVE_SECTION, "filter_used", {})
	if typeof(qu) == TYPE_DICTIONARY:
		data["filter_used"] = qu.duplicate(true)
	else:
		data["filter_used"] = {}

	# ---- Evaluate Used ----
	var eval: Dictionary = cfg.get_value(SAVE_SECTION, "evaluate_used", {})
	if typeof(eval) == TYPE_DICTIONARY:
		data["evaluate_used"] = eval.duplicate(true)
	else:
		data["evaluate_used"] = {}

	# ---- Bug Bounty Coins ----
	var bb: Dictionary = cfg.get_value(SAVE_SECTION, "bug_bounty", 0)
	if typeof(bb) == TYPE_INT:
		data["bug_bounty"] = bb
	else:
		data["bug_bounty"] = 0

	print("Player data loaded from %s" % SAVE_PATH)

# -----------------------
# HELPERS / API
# -----------------------

# ----------------------- New Game -----------------------
# Check if this is a new game
func is_new_game() -> bool:
	return bool(data.get("new_game", true))

# Set new_game flag
func set_new_game(value: bool) -> void:
	data["new_game"] = value
	save_data()

func is_welcome_showed() -> bool:
	return bool(data.get("welcome_showed", true))

# Set new_game flag
func set_welcome_showed(value: bool) -> void:
	data["welcome_showed"] = value
	save_data()
# ----------------------- HELPERS / API -----------------------
func set_username(name: String) -> void:
	data["username"] = name
	save_data()

func unlock_achievement(id: String) -> void:
	if id == "":
		return
	if id not in data["achievements"]:
		data["achievements"].append(id)
		save_data()

func set_level(lvl: int) -> void:
	data["level"] = int(lvl)
	save_data()

# ----------------------- Speedtime -----------------------
func set_speedtime(level_name: String, seconds: float) -> void:
	if level_name == "":
		return
	var current = float(data["speedtime"].get(level_name, 99999.9)) # default very high
	if seconds < current:  # only save if faster
		data["speedtime"][level_name] = seconds
		save_data()

func get_speedtime(level_name: String) -> float:
	return float(data["speedtime"].get(level_name, 0))

# ----------------------- Questions / Evaluate -----------------------
# Decrease (use)
func use_filter() -> void:
	if data["filter_used"] > 0:
		data["filter_used"] -= 1
		emit_signal("filter_amount_change", data["filter_used"])
		save_data()

func use_evaluate() -> void:
	if data["evaluate_used"] > 0:
		data["evaluate_used"] -= 1
		emit_signal("evaluation_amount_change", data["evaluate_used"])
		save_data()

# Increase / add
func add_filter(amount: int) -> void:
	data["filter_used"] += amount
	emit_signal("filter_amount_change", amount)
	save_data()

func add_evaluates(amount: int) -> void:
	data["evaluate_used"] += amount
	emit_signal("evaluation_amount_change", amount)
	save_data()

# Get current value
func get_filter_left() -> int:
	return int(data["filter_used"])

func get_evaluate_left() -> int:
	return int(data["evaluate_used"])
	
	
# ----------------------- Bug Bounty Coins -----------------------
# Add coins (or subtract if negative)
func modify_bug_bounty(amount: int) -> void:
	var current := int(data.get("bug_bounty", 0))
	current += amount
	if current < 0:
		current = 0  # Prevent negative coins
	data["bug_bounty"] = current
	save_data()
	emit_signal("bug_bounty_changed", current)

# Spend coins (returns true if enough coins, false if not)
func spend_bug_bounty(amount: int) -> bool:
	var current := int(data.get("bug_bounty", 0))
	if amount <= 0:
		return false  # invalid amount
	if current >= amount:
		data["bug_bounty"] = current - amount
		save_data()
		emit_signal("bug_bounty_changed", data["bug_bounty"])
		return true
	return false  # not enough coins

# Add coins (wrapper)
func add_bug_bounty(amount: int) -> void:
	modify_bug_bounty(amount)

# Get current coin count
func get_bug_bounty() -> int:
	return int(data.get("bug_bounty", 0))

# ----------------------- Reset -----------------------
func reset_data() -> void:
	data = {
		"new_game": true,
		"welcome_showed": false,
		"username": "",
		"level": 1,
		"speedtime": {},
		"achievements": [],
		"filter_used": 0,
		"evaluate_used": 0,
		"bug_bounty": 0
	}
	save_data()
