# res://Scripts/MiniGameTutorialManager.gd
# 
# This script manages the tutorial flow for the MiniGame.
# Add this as an autoload or instantiate it in your MiniGame scene.
# 
# Usage:
#   1. In your MiniGame._ready(), call: await MiniGameTutorialManager.start_tutorial(self, minigame_scene, day)
#   2. It will check achievements and run the appropriate tutorial
#   3. When tutorial is complete, the minigame will be visible and playable

class_name MiniGameTutorialManager
extends Node

const MINIGAME_TUTORIAL_PANEL_SCENE = preload("res://Scenes/UI/tutorial_panels/mini_game_tutorial_panel.tscn")
const MINIGAME_TUTORIAL_PANELS_SCENE = preload("res://Scenes/UI/tutorial_panels/mini_game_Panel.tscn")

# Check if tutorial should run and start it
func start_tutorial(minigame: MiniGame, minigame_ui_parent: Node, day: int) -> bool:
	# Check if player has already completed the "Threat Neutralizer" achievement
	if Player_Data.data["achievements"].has("Threat Neutralizer"):
		print("Tutorial skipped: Already have 'Threat Neutralizer' achievement")
		return false
	
	# Check if minigame has already been used today
	if not Player_Data.can_use_minigame(day):
		print("Tutorial skipped: Minigame already used today for this day")
		return false
	
	# Mark minigame as used for today
	Player_Data.mark_minigame_used(day)
	
	print("Starting MiniGame tutorial for day", day)
	
	# Hide the minigame initially
	minigame.visible = false
	
	# Step 1: Show the initial dialogue tutorial
	await _show_dialogue_tutorial(minigame_ui_parent)
	
	# Step 2: Show the interactive panel tutorial
	await _show_panel_tutorial(minigame_ui_parent)
	
	# Step 3: Show the minigame and let it run
	minigame.visible = true
	
	print("Tutorial completed, minigame is now visible and running")
	return true

func _show_dialogue_tutorial(parent: Node) -> void:
	var tutorial_dialogue = MINIGAME_TUTORIAL_PANEL_SCENE.instantiate() as MiniGameTutorialPanel
	parent.add_child(tutorial_dialogue)
	
	# Wait for the tutorial to finish
	await tutorial_dialogue.tutorial_finished

func _show_panel_tutorial(parent: Node) -> void:
	var tutorial_panels = MINIGAME_TUTORIAL_PANELS_SCENE.instantiate() as MiniGameTutorialPanels
	parent.add_child(tutorial_panels)
	
	# Wait for the tutorial to finish
	await tutorial_panels.tutorial_completed

# Optional: Manually skip all tutorials
func skip_all_tutorials() -> void:
	print("All tutorials skipped by user")
