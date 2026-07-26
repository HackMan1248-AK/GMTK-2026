extends CharacterBody2D

@onready var active_timer: Timer = $ActiveTimer
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var flash_light: PointLight2D = $FlashLight

#audio walk
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


#walking particle variable
@onready var dust = $WalkingTrail


var can_flash_light = true
var flashlight_on = false

@export var speed : float = 300.0
@export var movement_locked : float = false
var is_cooking := false
@export var knockback_friction := 1800.0
var interactable = null
var current_speed : float
var knockback_velocity: Vector2 = Vector2.ZERO

@onready var ingredient_point: Marker2D = $Ingredient
var interactable_ingredient: Interactable
var held_item: Node2D = null

@export var knife_scene: PackedScene
@onready var knife_position: Marker2D = $"Knife Position"
var is_attacking = false
var last_direction: Vector2 = Vector2.RIGHT

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	add_to_group("player")
	flash_light.enabled = false
	current_speed = speed

func _unhandled_input(event):
	if event.is_action_pressed("Interact") and interactable:
		interactable.interact()
	
	if event.is_action_pressed("Right Click") and can_flash_light:
		flashlight_on = !flashlight_on
		flash_light.enabled = flashlight_on

		if flashlight_on:
			active_timer.start()
		else:
			cooldown_timer.start()
			can_flash_light = false
	
	if event.is_action_pressed("Left Click"):
		attack()

func _physics_process(_delta: float):
	
	
	if movement_locked:
		velocity = Vector2.ZERO

		if is_cooking:
			anim.play("cook")
		else:
			var dir_name = get_direction_name(last_direction)
			anim.play("idle_" + dir_name)

		move_and_slide()
		return
	
	flash_light.look_at(get_global_mouse_position())

	if flashlight_on:
		if active_timer.time_left <= 1.0:
			flash_light.enabled = int(Time.get_ticks_msec() / 100) % 2 == 0
		else:
			flash_light.enabled = true

	var direction := Input.get_vector("Left", "Right", "Up", "Down")
	
	#DUST PARTICLES
	dust.emitting = direction!= Vector2.ZERO
	
	if direction != Vector2.ZERO:
		
		last_direction = direction.normalized()
	
	if !is_attacking:
		var dir_name = get_direction_name(last_direction)
		
		

		if direction == Vector2.ZERO:
			anim.play("idle_" + dir_name)
		else:
			anim.play("walk_" + dir_name)
			audio_stream_player_2d.play()
			
			
	
	velocity = direction * current_speed

	velocity += knockback_velocity

	knockback_velocity = knockback_velocity.move_toward(
		Vector2.ZERO,
		knockback_friction * _delta
	)

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
	
func apply_slow(percent):
	current_speed = speed * percent

func remove_slow():
	current_speed = speed
	
func take_knockback(kb_position: Vector2, kb_effect: float):
	var dir = (global_position - kb_position).normalized()
	knockback_velocity = dir * kb_effect

func attack():
	if is_attacking:
		return

	is_attacking = true

	last_direction = (get_global_mouse_position() - global_position).normalized()
	play_attack_animation()

func play_attack_animation():
	var dir = get_direction_name(last_direction)
	anim.play("attack_" + dir)

	await anim.animation_finished

	var knife = knife_scene.instantiate()
	knife.global_position = knife_position.global_position
	#knife.direction = last_direction
	knife.direction = (get_global_mouse_position() - global_position - Vector2(0, -110)).normalized()
	get_tree().current_scene.add_child(knife)

	is_attacking = false
	
func get_direction_name(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	else:
		return "down" if dir.y > 0 else "up"

func _on_active_timer_timeout() -> void:
	flashlight_on = false
	flash_light.enabled = false
	cooldown_timer.start()
	can_flash_light = false

func _on_cooldown_timer_timeout() -> void:
	can_flash_light = true
	

	
