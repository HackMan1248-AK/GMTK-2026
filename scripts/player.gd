extends CharacterBody2D

@export var speed : float = 450.0
var interactable = null

func _ready():
	add_to_group("player")

func _unhandled_input(event):
	if event.is_action_pressed("Interact") and interactable:
		interactable.interact()

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("Left", "Right", "Up", "Down")
	velocity = direction * speed
	move_and_slide()
