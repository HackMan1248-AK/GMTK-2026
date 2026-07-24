extends Interactable
@onready var player: CharacterBody2D = $"../../Player"

@export var timer: Timer

var held_item = null
var can_pickup = false

enum Station {
	FRIDGE,
	PANTRY,
	ASSEMBLY,
	BAKING,
	GRILLING,
	SLICING
}

@export var station: Station
@export var should_lock: bool

func interact() -> void:
	if player.held_item != null:
		print(player.held_item)
		held_item = player.held_item
		held_item.reparent(self)
		
		held_item.position = Vector2.ZERO
		held_item.rotation = 0
		player.held_item = null
		
		match station:
			Station.FRIDGE, Station.PANTRY:
				print("Storing")
			Station.ASSEMBLY, Station.BAKING, Station.GRILLING, Station.SLICING:
				timer.start()
				
		if should_lock:
			player.lock_movement(timer.time_left)
			
		can_pickup = false
	else:
		if held_item != null and can_pickup:
			player.pickup(held_item)
			held_item = null


func _on_timer_timeout() -> void:
	can_pickup = true
	if held_item.get_node("AnimatedSprite2D"):
		match station:
			Station.SLICING:
				held_item.get_node("AnimatedSprite2D").frame = 1
			Station.GRILLING:
				held_item.get_node("AnimatedSprite2D").frame = 2
			Station.BAKING:
				held_item.get_node("AnimatedSprite2D").frame = 3
			Station.ASSEMBLY:
				held_item.get_node("AnimatedSprite2D").frame = 4
