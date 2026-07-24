extends Node2D

@export var speed: float = 500.0
@export var damage: float = 10.0

var direction: Vector2 = Vector2.RIGHT

func _process(delta: float) -> void:
	position += direction.normalized() * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(damage)
	queue_free()
