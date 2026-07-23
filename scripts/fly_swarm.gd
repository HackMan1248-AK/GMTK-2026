# fly_swarm.gd
class_name FlySwarm
extends Enemy

@export var wobble_strength := 50.0
@export var range := 100.0

var time := 0.0

func _physics_process(delta):
	time += delta

	var to_target = target.global_position - global_position
	var dir = to_target.normalized()

	var wobble = Vector2(
		sin(time * 8.0),
		cos(time * 8.0)
	) * wobble_strength

	if to_target.length() > range:
		# Chase the player
		velocity = dir * speed + wobble
	else:
		# Circle clockwise
		var tangent = Vector2(-dir.y, dir.x)
		velocity = tangent * speed

	move_and_slide()
