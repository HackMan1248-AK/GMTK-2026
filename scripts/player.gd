extends CharacterBody2D

@onready var active_timer: Timer = $ActiveTimer
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var flash_light: PointLight2D = $FlashLight
var can_flash_light = true
var flashlight_on = false

@export var speed : float = 300.0
@export var movement_locked : float = false
var interactable = null

@onready var ingredient_point: Marker2D = $Ingredient
var interactable_ingredient: Interactable
var held_item: Node2D = null

func _ready():
	add_to_group("player")
	flash_light.enabled = false

func _unhandled_input(event):
	if event.is_action_pressed("Interact") and interactable:
		interactable.interact()
	
	if event.is_action_pressed("Left Click") and can_flash_light:
		flashlight_on = !flashlight_on
		flash_light.enabled = flashlight_on

		if flashlight_on:
			active_timer.start()
		else:
			cooldown_timer.start()
			can_flash_light = false

func _physics_process(_delta: float):
	if movement_locked:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	flash_light.look_at(get_global_mouse_position())

	if flashlight_on:
		if active_timer.time_left <= 1.0:
			flash_light.enabled = int(Time.get_ticks_msec() / 100) % 2 == 0
		else:
			flash_light.enabled = true

	var direction := Input.get_vector("Left", "Right", "Up", "Down")
	velocity = direction * speed
	move_and_slide()

func pickup(item: Node2D):
	if held_item != null:
		return

	held_item = item

	# Remove from current parent
	item.get_parent().remove_child(item)

	# Attach to player
	ingredient_point.add_child(item)

	# Snap into place
	item.position = Vector2.ZERO
	item.rotation = 0
	
func lock_movement(duration: float):
	movement_locked = true
	await get_tree().create_timer(duration).timeout
	movement_locked = false

func _on_active_timer_timeout() -> void:
	flashlight_on = false
	flash_light.enabled = false
	cooldown_timer.start()
	can_flash_light = false

func _on_cooldown_timer_timeout() -> void:
	can_flash_light = true
