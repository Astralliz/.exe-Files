extends Control

@onready var resume: Button = $VBoxContainer/Button
@onready var buttonContainer: VBoxContainer = $VBoxContainer
@onready var audio_panel: Panel = $AudioPanel
@onready var information_menu: Panel =$InformationPanel
@onready var label: Label = $Label


# InformationMenu.gd
@onready var metadata_panel = $InformationPanel/MetdataPanel
@onready var level1_panel = $InformationPanel/Level1Panel
@onready var level2_panel = $InformationPanel/Level2Panel
@onready var level3_panel = $InformationPanel/Level3Panel

var is_minigame := false
var parent_day: Day = null
var parent_minigame: MiniGame = null

func _ready() -> void:
	audio_panel.hide()
	information_menu.hide()

func setup_pause(minigame_mode: bool, day_ref = null, minigame_ref = null):

	is_minigame = minigame_mode
	parent_day = day_ref
	parent_minigame = minigame_ref

	# Hide Information Menu in minigame
	if is_minigame:
		$VBoxContainer/Button3.hide()
	else:
		$VBoxContainer/Button3.show()

#--------------------------------------
# Resume
#--------------------------------------
func _on_button_pressed() -> void:
	hide()
	get_tree().paused = false

#----------------------------------------
# Audio Settings
#---------------------------------------
func _on_button_2_pressed() -> void:
	buttonContainer.hide()
	audio_panel.show()


func _on_general_bck_btn_pressed() -> void:
	audio_panel.hide()
	information_menu.hide()
	buttonContainer.show()
	label.show()

#----------------------------------------
# Information Menu
#----------------------------------------
func _on_button_3_pressed() -> void:
	buttonContainer.hide()
	information_menu.show()
	show_tab("metadata")

func show_tab(tab_name: String):
	# Hide all panels
	metadata_panel.visible = false
	level1_panel.visible = false
	level2_panel.visible = false
	level3_panel.visible = false
	
	# Show the selected panel
	match tab_name.to_lower():
		"metadata":
			metadata_panel.visible = true
		"level1":
			level1_panel.visible = true
		"level2":
			level2_panel.visible = true
		"level3":
			level3_panel.visible = true

# Connect buttons to these functions
func _on_metdata_pressed() -> void:
	show_tab("metadata")

func _on_level_1_pressed() -> void:
	show_tab("level1")

func _on_level_2_pressed() -> void:
	show_tab("level2")

func _on_level_3_pressed() -> void:
	show_tab("level3")

#-------------------------------------------
# Quit
#----------------------------------------
func _on_button_4_pressed() -> void:

	get_tree().paused = false
	hide()

	# =========================
	# MINIGAME QUIT
	# =========================
	if is_minigame:

		# Prevent achievement saving
		Player_Data.clear_pending_achievements()

		# Prevent minigame rewards
		if parent_minigame:
			parent_minigame.game_finished = true

		# Prevent day save progress
		if parent_day:
			parent_day.correct_today = 0

		# Remove minigame scene
		if parent_minigame:
			parent_minigame.queue_free()

		# Trigger game over immediately
		var game_over_scene = preload("res://Scenes/Finishing Scenes/game_over.tscn")
		var game_over_instance = game_over_scene.instantiate()

		get_tree().current_scene.add_child(game_over_instance)

		return

	# =========================
	# MAIN GAME QUIT
	# =========================
	Player_Data.clear_pending_achievements()

	var game_over_scene = preload("res://Scenes/Finishing Scenes/game_over.tscn")
	var game_over_instance = game_over_scene.instantiate()

	get_tree().current_scene.add_child(game_over_instance)
