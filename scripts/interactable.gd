extends Node2D

@onready var area = $Area2D

func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.interactable = self

func _on_body_exited(body):
	if body.is_in_group("player") and body.interactable == self:
		body.interactable = null

func interact():
	print("Chest opened!")
