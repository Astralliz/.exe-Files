# ==============================
# INJECTION ATTACK MINIGAME
# ==============================
extends Control

signal minigame_finished(success: bool)

# Asset paths
const CLEAN_FILE_TEXTURE = "res://Assets/Sprites/clean_file_mini.png"
const CORRUPTED_FILE_TEXTURE = "res://Assets/Sprites/corrupted_file_mini.png"

# Game states (renamed to avoid conflict with global game_state.gd)
enum InjectionGameState { PLAYING, WON, LOST }

# UI References
@onready var container_panel: Panel = $Panel
@onready var slice_count_bar: ProgressBar = $SliceCount
@onready var fallen_count_bar: ProgressBar = $FallenCount

# Game variables
var current_state: InjectionGameState = InjectionGameState.PLAYING
var slice_count: int = 0  # Sliced corrupted files (max 5)
var fallen_count: int = 0  # Fallen corrupted files (max 4)
var max_slices: int = 5
var max_fallen: int = 4

# Falling items pool
var falling_items: Array[FallingFile] = []
var spawn_timer: float = 0.0
var spawn_interval: float = 0.8  # Time between spawns (seconds)

# Input handling
var touch_input: Dictionary = {}  # Track active touches
var is_processing: bool = true

# Animation variables
var victory_anim_playing: bool = false
var game_over_anim_playing: bool = false

# Audio/Visual effects
var slice_effects: Array[CanvasItem] = []

class FallingFile:
	var sprite: Sprite2D
	var texture_path: String
	var is_corrupted: bool
	var position_y: float = 0.0
	var fall_speed: float = 0.0
	var is_sliced: bool = false
	var container_ref: Control
	var slice_particles: Node2D
	
	func _init(p_texture: String, p_is_corrupted: bool, p_container: Control):
		texture_path = p_texture
		is_corrupted = p_is_corrupted
		container_ref = p_container
		
		# Create sprite
		sprite = Sprite2D.new()
		sprite.texture = load(p_texture)
		var target_size = 180.0  # desired width in pixels

		var texture_size = sprite.texture.get_size()
		var scale_factor = target_size / texture_size.x

		sprite.scale = Vector2(scale_factor, scale_factor)
		
		# Random fall speed (slower but continuous)
		fall_speed = randf_range(120.0, 180.0)
		
		# Random spawn X position within container bounds
		var container_rect = p_container.get_rect()
		var sprite_width = sprite.texture.get_width() * sprite.scale.x
		var safe_x = randf_range(sprite_width / 2, container_rect.size.x - sprite_width / 2)
		
		sprite.position = Vector2(safe_x, -50)
		position_y = -50.0
		
		p_container.add_child(sprite)
	
	func update(delta: float) -> bool:
		if is_sliced:
			return true  # Mark for removal
		
		position_y += fall_speed * delta
		sprite.position.y = position_y
		
		# Check if fallen off screen (completed)
		if position_y > container_ref.get_rect().size.y + 50:
			return true  # Mark for removal
		
		return false
	
	func slice_at_position(slice_pos: Vector2) -> bool:
		if is_sliced:
			return false
		
		# Check if slice position intersects with sprite
		var sprite_rect = sprite.get_rect()
		sprite_rect.position += sprite.position
		
		if sprite_rect.has_point(slice_pos):
			is_sliced = true
			play_slice_animation()
			return true
		
		return false
	
	func play_slice_animation() -> void:
		var tween = sprite.create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_OUT)
		
		# Scale down and fade out
		tween.parallel().tween_property(sprite, "scale", Vector2.ZERO, 0.3)
		tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.3)
		
		await tween.finished
		sprite.queue_free()
	
	func cleanup() -> void:
		if sprite:
			sprite.queue_free()

# ==============================
# LIFECYCLE
# ==============================

func _ready() -> void:
	# Setup progress bars
	slice_count_bar.max_value = max_slices
	slice_count_bar.value = 0
	slice_count_bar.modulate = Color.GREEN
	
	fallen_count_bar.max_value = max_fallen
	fallen_count_bar.value = 0
	fallen_count_bar.modulate = Color.RED
	
	# Ensure container panel is visible and ready
	container_panel.clip_contents = true
	
	# Start game loop
	set_process(true)
	set_physics_process(true)

func _process(delta: float) -> void:
	if not is_processing or current_state != InjectionGameState.PLAYING:
		return
	
	# Spawn new items
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_falling_file()
		spawn_timer = spawn_interval
	
	# Update existing items
	var items_to_remove: Array[int] = []
	for i in range(falling_items.size()):
		var item = falling_items[i]
		if item.update(delta):
			# Item has reached the bottom
			if not item.is_sliced and item.is_corrupted:
				on_corrupted_file_fallen(item)
			items_to_remove.append(i)
	
	# Remove items in reverse order
	for i in range(items_to_remove.size() - 1, -1, -1):
		var item = falling_items[items_to_remove[i]]
		item.cleanup()
		falling_items.remove_at(items_to_remove[i])

func _input(event: InputEvent) -> void:
	if not is_processing or current_state != InjectionGameState.PLAYING:
		return
	
	# Handle touch input
	if event is InputEventScreenTouch:
		var screen_pos = event.position
		
		# Convert to container-relative position
		var container_rect = container_panel.get_global_rect()
		if not container_rect.has_point(screen_pos):
			return
		
		var local_pos = screen_pos - container_rect.position
		
		# Sort items by Y position (top to bottom) - slice the topmost one first
		var sorted_items = falling_items.duplicate()
		sorted_items.sort_custom(func(a, b): return a.sprite.position.y < b.sprite.position.y)
		
		# Perform slice on all items at this position (check topmost first)
		for item in sorted_items:
			if item.slice_at_position(local_pos):
				on_corrupted_file_sliced(item)
				create_slice_effect(screen_pos)
				break  # Only slice one item per touch
	
	# Handle mouse input for testing
	elif event is InputEventMouseButton and event.pressed:
		var screen_pos = event.position
		var container_rect = container_panel.get_global_rect()
		
		if not container_rect.has_point(screen_pos):
			return
		
		var local_pos = screen_pos - container_rect.position
		
		# Sort items by Y position (top to bottom) - slice the topmost one first
		var sorted_items = falling_items.duplicate()
		sorted_items.sort_custom(func(a, b): return a.sprite.position.y < b.sprite.position.y)
		
		for item in sorted_items:
			if item.slice_at_position(local_pos):
				on_corrupted_file_sliced(item)
				create_slice_effect(screen_pos)
				break

# ==============================
# GAME LOGIC
# ==============================

func spawn_falling_file() -> void:
	# 50% chance of corrupted file
	var is_corrupted = randf() < 0.5
	var texture_path = CORRUPTED_FILE_TEXTURE if is_corrupted else CLEAN_FILE_TEXTURE
	
	var item = FallingFile.new(texture_path, is_corrupted, container_panel)
	falling_items.append(item)

func on_corrupted_file_sliced(item: FallingFile) -> void:
	if not item.is_corrupted:
		return  # Don't count clean files
	
	slice_count += 1
	update_slice_bar()
	
	# Win condition
	if slice_count >= max_slices:
		end_game(true)

func on_corrupted_file_fallen(item: FallingFile) -> void:
	fallen_count += 1
	update_fallen_bar()
	
	# Lose condition
	if fallen_count >= max_fallen:
		end_game(false)

func update_slice_bar() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(slice_count_bar, "value", slice_count, 0.2)
	
	# Pulse animation
	tween.parallel().tween_callback(pulse_bar.bind(slice_count_bar, Color.GREEN))

func update_fallen_bar() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(fallen_count_bar, "value", fallen_count, 0.2)
	
	# Pulse animation
	tween.parallel().tween_callback(pulse_bar.bind(fallen_count_bar, Color.RED))

func pulse_bar(bar: ProgressBar, color: Color) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(bar, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(bar, "scale", Vector2(1.0, 1.0), 0.1)

# ==============================
# VISUAL EFFECTS
# ==============================

func create_slice_effect(screen_pos: Vector2) -> void:
	# Create a visual slash effect at the slice point
	var effect = Node2D.new()  # Changed from CanvasItem to Node2D (not abstract)
	container_panel.add_child(effect)
	
	# Draw a line that fades out
	var container_rect = container_panel.get_global_rect()
	var local_pos = screen_pos - container_rect.position
	
	var slash = Line2D.new()
	slash.add_point(local_pos + Vector2(-30, -30))
	slash.add_point(local_pos + Vector2(30, 30))
	slash.width = 3.0
	slash.default_color = Color(0.0, 1.0, 1.0, 0.8)  # Cyan
	
	effect.add_child(slash)
	
	# Animate the slash
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.parallel().tween_property(slash, "modulate:a", 0.0, 0.4)
	tween.parallel().tween_property(slash, "scale", Vector2(1.5, 1.5), 0.4)
	
	await tween.finished
	effect.queue_free()

# ==============================
# GAME END
# ==============================

func end_game(success: bool) -> void:
	if current_state != InjectionGameState.PLAYING:
		return
	
	current_state = InjectionGameState.WON if success else InjectionGameState.LOST
	is_processing = false
	
	# Disable input
	set_process_input(false)
	
	# Play end animation
	if success:
		play_victory_animation()
	else:
		play_game_over_animation()

func play_victory_animation() -> void:
	# Freeze all items
	for item in falling_items:
		item.fall_speed = 0.0
	
	# Green flash on container
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	# Flash effect
	var original_modulate = container_panel.modulate
	container_panel.modulate = Color.GREEN
	
	tween.tween_property(container_panel, "modulate", original_modulate, 0.3)
	tween.tween_callback(func():
		# Victory pulse
		var pulse_tween = create_tween()
		pulse_tween.set_trans(Tween.TRANS_ELASTIC)
		pulse_tween.set_ease(Tween.EASE_OUT)
		pulse_tween.tween_property(container_panel, "scale", Vector2(1.05, 1.05), 0.4)
		pulse_tween.tween_property(container_panel, "scale", Vector2(1.0, 1.0), 0.2)
	)
	
	await tween.finished
	await get_tree().create_timer(1.0).timeout
	
	# Emit success signal
	emit_signal("minigame_finished", true)
	queue_free()

func play_game_over_animation() -> void:
	# Freeze all items
	for item in falling_items:
		item.fall_speed = 0.0
	
	# Red flash on container
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	var original_modulate = container_panel.modulate
	container_panel.modulate = Color.RED
	
	tween.tween_property(container_panel, "modulate", original_modulate, 0.3)
	tween.tween_callback(func():
		# Shake effect
		for i in range(3):
			var shake_tween = create_tween()
			shake_tween.set_trans(Tween.TRANS_QUAD)
			shake_tween.set_ease(Tween.EASE_OUT)
			shake_tween.tween_property(container_panel, "position", 
				container_panel.position + Vector2(randf_range(-5, 5), 0), 0.1)
	)
	
	await tween.finished
	await get_tree().create_timer(1.0).timeout
	
	# Emit failure signal
	emit_signal("minigame_finished", false)
	queue_free()

# ==============================
# CALLBACKS (if you have buttons)
# ==============================

func _on_finished_pressed() -> void:
	if current_state == InjectionGameState.PLAYING:
		return  # Ignore if still playing
	emit_signal("minigame_finished", true)
	queue_free()

func _on_quit_pressed() -> void:
	is_processing = false
	emit_signal("minigame_finished", false)
	queue_free()
