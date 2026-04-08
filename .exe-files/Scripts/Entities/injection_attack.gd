# ==============================
# INJECTION ATTACK MINIGAME
# ==============================
extends Control

signal minigame_finished(success: bool)

# Add your injection-specific game logic here

func _on_finished_pressed() -> void:
	emit_signal("minigame_finished", true)
	queue_free()

func _on_quit_pressed() -> void:
	emit_signal("minigame_finished", false)
	queue_free()
