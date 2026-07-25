extends CharacterBody2D

@export var speed = 400
@onready var dust = $WalkingTrail

func get_input():
	var input_direction = Input.get_vector("move_left","move_right", "move_up", "move_down")
	velocity = input_direction * speed

func _physics_process(delta):
	get_input()
	move_and_slide()
	
	if velocity.length()> 0: 
		dust.emitting=true
	else: 
		dust.emitting = false
		
	dust.emitting = velocity.x !=0
