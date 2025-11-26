class_name MoveComponent
extends Node

@export var actor: Node2D
var velocity: Vector2 = Vector2.ZERO

func move(direction: Vector2, speed: float):
	velocity = direction.normalized() * speed

func stop():
	velocity = Vector2.ZERO

func _process(delta: float):
	if velocity != Vector2.ZERO:
		actor.position += velocity * delta
