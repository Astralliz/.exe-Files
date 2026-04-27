# res://Scripts/PlayerData.gd
#class_name PlayerData
extends Node

var TEMP_SAVE := true  # true = only memory, false = save to disk

# Default data
var data: Dictionary = {
	"new_to_game": 4,
	"username": "xebec",
	"level": 2,
	"total_inspected": 94,  
	"achievements": [], # ["FirstScan", "ExpertAnalyzer"]
	"filter_used": 10,   # { "level1": 3, "level2": 1 } - track skill/question usage
	"evaluate_used": 0,
	"bug_bounty": 40,
	"minigame_usage": {}
}

var newly_unlocked: Array[String] = []

const SAVE_PATH := "user://player_data.cfg"
const SAVE_SECTION := "player"

signal bug_bounty_changed(new_amount)
signal filter_amount_change(new_amount)
signal evaluation_amount_change(new_amount)
signal username_changed(new_username)

func _ready() -> void:
	load_data()

# -----------------------
# SAVE/LOAD using ConfigFile
# -----------------------
func save_data() -> void:
	if TEMP_SAVE:
		print("TEMP SAVE: Player data saved in memory only:", data, newly_unlocked)
		return  # do not write to disk in dev mode

	var cfg := ConfigFile.new()
	cfg.set_value(SAVE_SECTION, "username", data["username"])
	cfg.set_value(SAVE_SECTION, "level", int(data["level"]))
	cfg.set_value(SAVE_SECTION, "total_inspected", data["total_inspected"])
	cfg.set_value(SAVE_SECTION, "achievements", data["achievements"])
	cfg.set_value(SAVE_SECTION, "filter_used", data["filter_used"])
	cfg.set_value(SAVE_SECTION, "evaluate_used", data["evaluate_used"])
	cfg.set_value(SAVE_SECTION, "bug_bounty", int(data["bug_bounty"]))
	cfg.set_value(SAVE_SECTION, "minigame_usage", data["minigame_usage"])

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

	# ---- Total inspected ----
	var ti: int = int(cfg.get_value(SAVE_SECTION, "total_inspected", 0))
	data["total_inspected"] = ti
	if typeof(ti) == TYPE_INT:
		data["total_inspected"] = ti
	else:
		data["total_inspected"] = 0

	# ---- Achievements ----
	var ach: Array = cfg.get_value(SAVE_SECTION, "achievements", [])
	if typeof(ach) == TYPE_ARRAY:
		data["achievements"] = ach.duplicate(true)
	else:
		data["achievements"] = []

	# ---- Questions Used ----
	var filt: Dictionary = cfg.get_value(SAVE_SECTION, "filter_used", {})
	if typeof(filt) == TYPE_DICTIONARY:
		data["filter_used"] = filt.duplicate(true)
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

	# ---- Mini Games ----
	var mg = cfg.get_value(SAVE_SECTION, "minigame_usage", {})
	if typeof(mg) == TYPE_DICTIONARY:
		data["minigame_usage"] = mg.duplicate(true)
	else:
		data["minigame_usage"] = {}

	print("Player data loaded from %s" % SAVE_PATH)

# -----------------------
# HELPERS / API
# -----------------------

# ----------------------- Mini Games System ----------------------
# Get today's real-world date
func get_today_date() -> String:
	return Time.get_date_string_from_system()  # "YYYY-MM-DD"

# Build unique key: "2026-04-08_day1"
func build_minigame_key(day: int) -> String:
	return get_today_date() + "_day" + str(day)

# Check if minigame can be used
func can_use_minigame(day: int) -> bool:
	var key = build_minigame_key(day)
	return not data["minigame_usage"].has(key)

# Mark minigame as used
func mark_minigame_used(day: int) -> void:
	var key = build_minigame_key(day)
	data["minigame_usage"][key] = true
	save_data()

# ----------------------- New Game -----------------------
# Check if this is a new game
func get_new_game_status() -> int:
	return data.get("new_to_game", 0)

# Set new_game flag
func set_new_game_status(value: int) -> void:
	data["new_to_game"] = value
	save_data()
# ----------------------- HELPERS / API -----------------------
func set_username(name: String) -> void:
	print("SET USERNAME:", name, " INSTANCE:", self)
	data["username"] = name
	save_data()
	emit_signal("username_changed", name)

func queue_achievement(id: String) -> void:
	if id == "":
		return

	# permanent unlock
	if not data["achievements"].has(id):
		data["achievements"].append(id)

	# queue for UI (only once per session/day)
	if not newly_unlocked.has(id):
		newly_unlocked.append(id)

	save_data()

func set_level(lvl: int) -> void:
	data["level"] = int(lvl)
	save_data()

# ----------------------- Total INspected -----------------------
func add_correct_inspection() -> void:
	data["total_inspected"] += 1
	save_data()
	
# Getter
func get_total_inspected() -> int:
	return int(data["total_inspected"])

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
		"new_to_game": 0,
		"username": "",
		"level": 0,
		"total_inspected": 0,
		"achievements": [],
		"filter_used": 0,
		"evaluate_used": 0,
		"bug_bounty": 40,
		"minigame_usage": {}
	}
	save_data()
