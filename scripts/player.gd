extends CharacterBody2D

@export var speed : float = 300.0
@onready var flash_light: PointLight2D = $FlashLight
var interactable = null
var target_position: Vector2

func _ready():
	add_to_group("player")
	flash_light.enabled = false

func _unhandled_input(event):
	if event.is_action_pressed("Interact") and interactable:
		interactable.interact()
	
	if event.is_action_pressed("Left Click"):
		flash_light.enabled = not flash_light.enabled

func _process(_delta: float):
	target_position = get_global_mouse_position()

func _physics_process(_delta: float):
	if target_position:
		flash_light.look_at(target_position)
	var direction := Input.get_vector("Left", "Right", "Up", "Down")
	velocity = direction * speed
	move_and_slide()
