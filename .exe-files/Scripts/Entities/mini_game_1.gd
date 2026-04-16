extends Control

# ==============================
# SIGNALS
# ==============================
signal minigame_finished(success: bool)


# ==============================
# BUTTON HANDLERS (optional)
# ==============================
func _on_finished_pressed() -> void:
	emit_signal("minigame_finished", true)
	queue_free()
func _on_quit_pressed() -> void:
	emit_signal("minigame_finished", false)
	queue_free()
