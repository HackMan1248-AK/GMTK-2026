# spider_web.gd
class_name SpiderWeb
extends StaticBody2D

@export var slow_percent := 0.5
@export var max_health := 20
@export var speed := 100.0
@export var damage := 5
@export var target: Node2D

var health := max_health

func _ready():
	health = max_health

func take_damage(amount:int):
	health -= amount

	if health <= 0:
		die()

func die():
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("apply_slow"):
		body.apply_slow(slow_percent)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("remove_slow"):
		body.remove_slow()
