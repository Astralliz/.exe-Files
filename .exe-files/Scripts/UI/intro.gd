class_name Intro
extends Node2D

@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer
@onready var fade_rect: ColorRect = $FadeRect

func _ready() -> void:
	GlobalMusic.stop()
	fade_rect.visible = false
	
	video_player.finished.connect(_on_video_finished)
	video_player.play()

func _on_video_finished() -> void:
	_fade_and_switch()

func switch_scene() -> void:
	SceneLoader.load_scene("res://Scenes/Menu Scenes/Story Scene/tutorial_scene.tscn")

func _fade_and_switch() -> void:
	fade_rect.visible = true
	fade_rect.modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.6)
	tween.finished.connect(func():
		switch_scene()
	)
