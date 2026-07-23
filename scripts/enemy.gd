# enemy.gd
class_name Enemy
extends CharacterBody2D

@export var max_health := 20
@export var speed := 100.0
@export var damage := 5
@export var target: Node2D
@export var space_from_target: float

var health := max_health

func _ready():
	health = max_health

func take_damage(amount:int):
	health -= amount

	if health <= 0:
		die()

func die():
	queue_free()

func chase_target():
	if target == null:
		return

	var dir = (target.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()
