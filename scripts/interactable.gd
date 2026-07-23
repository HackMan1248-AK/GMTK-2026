extends Node2D
class_name Interactable

@onready var area: Area2D = $Area2D

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.interactable = self

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player") and body.interactable == self:
		body.interactable = null

func interact() -> void:
	# Override in child classes
	pass
