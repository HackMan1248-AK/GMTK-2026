# enemy.gd
class_name Enemy
extends CharacterBody2D

@export var max_health := 20
@export var speed := 100.0
@export var damage := 5
@export var target: Node2D
@export var space_from_target: float

var can_move := true
var health := max_health

func _ready():
	health = max_health

func take_damage(amount: int):
	health -= amount

	can_move = false
	#$AnimatedSprite2D.play("hit")

	if health <= 0:
		#$AnimatedSprite2D.play("die")
		#await $AnimatedSprite2D.animation_finished
		die()
		return

	#await $AnimatedSprite2D.animation_finished
	can_move = true

func die():
	queue_free()

func chase_target():
	if target == null:
		return

	var dir = (target.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()
