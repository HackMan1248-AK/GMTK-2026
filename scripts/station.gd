extends Interactable
@onready var player: CharacterBody2D = $"../../Player"

@onready var slicing_timer: Timer = $Timers/SlicingTimer
@onready var assembling_timer: Timer = $Timers/AssemblingTimer
@onready var baking_timer: Timer = $Timers/BakingTimer
@onready var grilling_timer: Timer = $Timers/GrillingTimer
@onready var freezing_timer: Timer = $Timers/FreezingTimer

var held_item = null
var can_pickup = false
var active_timer : Timer

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
		held_item = player.held_item
		held_item.reparent(self)
		
		held_item.position = Vector2.ZERO
		held_item.rotation = 0
		player.held_item = null
		
		match station:
			Station.FRIDGE:
				freezing_timer.start()
				active_timer = freezing_timer
			Station.PANTRY:
				print("Storing")
			Station.ASSEMBLY:
				assembling_timer.start()
				active_timer = assembling_timer
			Station.BAKING:
				baking_timer.start()
				active_timer = baking_timer
			Station.GRILLING:
				grilling_timer.start()
				active_timer = grilling_timer
			Station.SLICING:
				slicing_timer.start()
				active_timer = slicing_timer
				
		if should_lock:
			print(active_timer.time_left)
			player.lock_movement(active_timer.time_left)
	else:
		if held_item != null:
			player.pickup(held_item)
			held_item = null
