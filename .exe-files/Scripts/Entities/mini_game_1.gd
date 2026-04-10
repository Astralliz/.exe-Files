extends Control

# ==============================
# SIGNALS
# ==============================
signal minigame_finished(success: bool)

# ==============================
# ASSET PATHS
# ==============================
const CLEAN_FILE_TEXTURE = "res://Assets/Sprites/clean_file_mini.png"
const CORRUPTED_FILE_TEXTURE = "res://Assets/Sprites/corrupted_file_mini.png"

# ==============================
# REFERENCES
# ==============================
@onready var grid_panel: Panel = $Panel
@onready var timer_progress: ProgressBar = $Timer
@onready var correct_count_label: Label = $CorrectCount
@onready var boxes: Array[Panel] = []

# Audio nodes (optional)
var correct_sound: AudioStreamPlayer
var wrong_sound: AudioStreamPlayer
var win_sound: AudioStreamPlayer
var lose_sound: AudioStreamPlayer

# ==============================
# GAME STATE
# ==============================
var time_remaining: float = 10.0
var correct_taps: int = 0
var total_corrupted_files: int = 1  # Starts with 1, increases to 2 after 3 correct taps
var corrupted_positions: Array[int] = []  # Positions (0-7) that are corrupted
var correct_taps_in_set: int = 0  # Counter for this set of corrupted files

var game_active: bool = true
var boxes_disabled: bool = false  # Temporarily disable during animations

var clean_texture: Texture2D
var corrupted_texture: Texture2D

# ==============================
# CONSTANTS
# ==============================
const CORRECT_TAP_REWARD = 2.0  # +2 seconds per correct tap
const WRONG_TAP_PENALTY = 2.0   # -2 seconds per wrong tap
const TARGET_CORRECT_TAPS = 7   # Goal: 7 correct taps
const TIME_LIMIT = 10.0         # Starting time
const CORRUPTED_PER_SET = 3     # After 3 correct taps, add another corrupted file
const GRID_COLUMNS = 4
const GRID_ROWS = 2
const TOTAL_BOXES = 8

# Visual constants
const CORRUPTED_COLOR = Color(0.8, 0.2, 0.2)  # Red
const CLEAN_COLOR = Color(0.3, 0.3, 0.4)      # Dark blue-gray
const HIGHLIGHT_COLOR = Color(0, 1, 1)        # Cyan
const CORRECT_FLASH = Color.GREEN
const WRONG_FLASH = Color(1, 0.3, 0.3)        # Light red

# ==============================
# SETUP
# ==============================
func _ready():
	clean_texture = load(CLEAN_FILE_TEXTURE)
	corrupted_texture = load(CORRUPTED_FILE_TEXTURE)
	setup_audio()
	setup_grid()
	initialize_corrupted_files()
	setup_timer()
	update_ui()
	
	print("\n🎮 MALWARE ATTACK MINIGAME STARTED")
	print("Goal: Find and tap %d corrupted files" % TARGET_CORRECT_TAPS)
	print("Time: %.1f seconds" % time_remaining)

func setup_audio():
	# Create audio players if you have audio files
	# Optional: You can add sound effects
	# correct_sound = AudioStreamPlayer.new()
	# wrong_sound = AudioStreamPlayer.new()
	# win_sound = AudioStreamPlayer.new()
	# lose_sound = AudioStreamPlayer.new()
	pass

func play_sound(sound_type: String):
	match sound_type:
		"correct":
			# await correct_sound.play()
			pass
		"wrong":
			# await wrong_sound.play()
			pass
		"win":
			# await win_sound.play()
			pass
		"lose":
			# await lose_sound.play()
			pass

	# Collect all box panels from the grid
func setup_grid():
	for i in range(TOTAL_BOXES):
		var box = grid_panel.get_child(i) as Panel
		if box:
			boxes.append(box)
			box.custom_minimum_size = Vector2(150, 150)
			box.modulate = CLEAN_COLOR

			# ✅ ADD TEXTURE RECT
			if not box.has_node("FileTexture"):
				var texture_rect = TextureRect.new()
				texture_rect.name = "FileTexture"
				texture_rect.anchor_left = 0
				texture_rect.anchor_top = 0
				texture_rect.anchor_right = 1
				texture_rect.anchor_bottom = 1
				texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				box.add_child(texture_rect)

			# Button setup (your existing logic)
			if box.has_node("Button"):
				var button = box.get_node("Button") as Button
				button.pressed.connect(_on_box_pressed.bind(i))
			else:
				var button = Button.new()
				button.anchor_left = 0
				button.anchor_top = 0
				button.anchor_right = 1
				button.anchor_bottom = 1
				button.flat = true
				button.modulate = Color.TRANSPARENT
				box.add_child(button)
				button.pressed.connect(_on_box_pressed.bind(i))
	
	print("✅ Grid setup complete with %d boxes" % boxes.size())

func initialize_corrupted_files():
	# Start with 1 corrupted file
	total_corrupted_files = 1
	randomize_corrupted_positions()
	update_grid_visuals()

func randomize_corrupted_positions():
	corrupted_positions.clear()
	var available_positions = range(TOTAL_BOXES)
	available_positions.shuffle()
	
	# Select random positions for corrupted files
	for i in range(total_corrupted_files):
		corrupted_positions.append(available_positions[i])
	
	corrupted_positions.sort()
	correct_taps_in_set = 0
	
	print("🎲 Corrupted files at positions: %s (Total: %d)" % [corrupted_positions, total_corrupted_files])

func setup_timer():
	timer_progress.max_value = TIME_LIMIT
	timer_progress.value = time_remaining
	timer_progress.modulate = Color.CYAN
	set_process(true)

# ==============================
# PROCESS & TIMER
# ==============================
func _process(delta):
	if not game_active:
		return
	
	# Decrease time
	time_remaining -= delta
	timer_progress.value = time_remaining
	
	# Update timer color based on remaining time
	if time_remaining <= 2.0:
		timer_progress.modulate = Color.RED
		correct_count_label.modulate = Color.RED
	elif time_remaining <= 4.0:
		timer_progress.modulate = Color(1, 0.6, 0)  # Orange
		correct_count_label.modulate = Color(1, 0.8, 0)
	elif time_remaining <= 6.0:
		timer_progress.modulate = Color.YELLOW
		correct_count_label.modulate = Color.YELLOW
	else:
		timer_progress.modulate = Color.CYAN
		correct_count_label.modulate = Color.WHITE
	
	# Check if time is up
	if time_remaining <= 0.0:
		end_minigame(false)

# ==============================
# INPUT HANDLING
# ==============================
func _on_box_pressed(box_index: int):
	if not game_active or boxes_disabled:
		return
	
	print("📍 Box %d pressed" % box_index)
	
	# Check if this box is corrupted
	if box_index in corrupted_positions:
		# ✅ CORRECT TAP - It was a corrupted file
		handle_correct_tap(box_index)
	else:
		# ❌ WRONG TAP - It was a clean file
		handle_wrong_tap(box_index)

func handle_correct_tap(box_index: int):
	print("✅ CORRECT! Tapped corrupted file at position %d" % box_index)
	
	boxes_disabled = true
	
	# Play sound
	play_sound("correct")
	
	# Update counters
	correct_taps += 1
	correct_taps_in_set += 1
	
	# Add time reward
	time_remaining += CORRECT_TAP_REWARD
	print("⏱️  Time +%.1f seconds (Total: %.1f)" % [CORRECT_TAP_REWARD, time_remaining])
	
	# Play visual feedback
	await flash_box(box_index, CORRECT_FLASH)
	
	# Update UI
	update_ui()
	
	# Check if we've reached the set goal (3 correct taps in this set)
	if correct_taps_in_set >= CORRUPTED_PER_SET:
		# Add another corrupted file to the next set
		total_corrupted_files += 1
		randomize_corrupted_positions()
		await reset_grid_animation()
		print("🎯 Set complete! Now finding %d corrupted files" % total_corrupted_files)
	else:
		# Just randomize again with same number of corrupted files
		randomize_corrupted_positions()
		await reset_grid_animation()
	
	boxes_disabled = false
	
	# Check win condition
	if correct_taps >= TARGET_CORRECT_TAPS:
		end_minigame(true)

func handle_wrong_tap(box_index: int):
	print("❌ WRONG! Tapped clean file at position %d" % box_index)
	
	boxes_disabled = true
	
	# Play sound
	play_sound("wrong")
	
	# Subtract time penalty
	time_remaining -= WRONG_TAP_PENALTY
	print("⏱️  Time -%.1f seconds (Total: %.1f)" % [WRONG_TAP_PENALTY, time_remaining])
	
	# Play visual feedback
	await flash_box(box_index, WRONG_FLASH)
	
	# Update UI
	update_ui()
	
	boxes_disabled = false
	
	# Check if time is up
	if time_remaining <= 0.0:
		end_minigame(false)

# ==============================
# ANIMATIONS
# ==============================
func reset_grid_animation():
	# Fade out all boxes
	var tween = create_tween()
	tween.set_parallel(true)
	for box in boxes:
		tween.tween_property(box, "modulate:a", 0.5, 0.2)
	
	# Update visuals
	update_grid_visuals()
	
	# Fade back in
	await tween.finished
	tween = create_tween()
	tween.set_parallel(true)
	for box in boxes:
		tween.tween_property(box, "modulate:a", 1.0, 0.3)
	
	await tween.finished

func flash_box(box_index: int, color: Color) -> void:
	var box = boxes[box_index]
	var original_color = Color.WHITE
	var original_scale = box.scale
	
	# Create a tween for the flash effect
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Flash color
	tween.tween_property(box, "modulate", color, 0.1)
	# Slight scale up
	tween.tween_property(box, "scale", Vector2(1.1, 1.1), 0.1)
	
	await tween.finished
	
	# Reset
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(box, "modulate", original_color, 0.15)
	tween.tween_property(box, "scale", original_scale, 0.15)
	
	await tween.finished

# ==============================
# UI UPDATES
# ==============================
func update_ui():
	correct_count_label.text = "%d / %d" % [correct_taps, TARGET_CORRECT_TAPS]
	timer_progress.value = maxf(0, time_remaining)

func update_grid_visuals():
	# Update all boxes to show correct state
	for i in range(boxes.size()):
		var box = boxes[i]
		var is_corrupted = i in corrupted_positions
		
		var texture_rect = box.get_node("FileTexture") as TextureRect
		
		box.modulate = Color.WHITE
		
		if is_corrupted:
			# Corrupted file - red appearance with warning
			texture_rect.texture = corrupted_texture

		else:
			# Clean file - normal appearance
			texture_rect.texture = clean_texture

# ==============================
# GAME END
# ==============================
func end_minigame(success: bool):
	game_active = false
	set_process(false)
	
	if success:
		print("\n🎉 🎉 🎉 MINIGAME WON! 🎉 🎉 🎉")
		print("Completed in %.1f seconds remaining" % time_remaining)
		play_sound("win")
		
		# Victory animation
		await victory_animation()
	else:
		print("\n💥 💥 💥 MINIGAME FAILED - TIME'S UP! 💥 💥 💥")
		play_sound("lose")
		
		# Defeat animation
		await defeat_animation()
	
	# Small delay before closing
	await get_tree().create_timer(1.0).timeout
	
	emit_signal("minigame_finished", success)
	queue_free()

func victory_animation():
	# Scale and fade effect for victory
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	
	correct_count_label.modulate = Color.GREEN
	correct_count_label.text = "🎉 VICTORY! 🎉"
	
	var original_scale = correct_count_label.scale
	tween.tween_property(correct_count_label, "scale", original_scale * 1.5, 0.5)
	
	await tween.finished

func defeat_animation():
	# Shake effect for defeat
	var tween = create_tween()
	
	correct_count_label.modulate = Color.RED
	correct_count_label.text = "TIME'S UP!"
	
	for i in range(4):
		tween.tween_property(correct_count_label, "position:x", correct_count_label.position.x + 10, 0.05)
		tween.tween_property(correct_count_label, "position:x", correct_count_label.position.x - 10, 0.05)
	
	await tween.finished

# ==============================
# BUTTON HANDLERS (optional)
# ==============================
func _on_finished_pressed() -> void:
	end_minigame(true)

func _on_quit_pressed() -> void:
	end_minigame(false)
