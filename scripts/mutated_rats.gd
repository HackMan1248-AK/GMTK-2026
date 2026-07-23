# mutated_rat.gd
class_name MutatedRat
extends Enemy

@export var bite_range := 24

func _physics_process(delta):
	chase_target()

	if global_position.distance_to(target.global_position) < (bite_range + 110):
		attack()

func attack():
	target.take_knockback(global_position)
