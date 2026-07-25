extends Interactable
@export var timer: Timer

var held_item = null
var can_pickup = false
var player: CharacterBody2D

enum Station {
	FRIDGE,
	PANTRY,
	ASSEMBLY,
	BAKING,
	GRILLING,
	SLICING,
	SERVING
}

@export var station: Station
@export var should_lock: bool

func _ready() -> void:
	super()
	player = get_tree().get_first_node_in_group("player")

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
				can_pickup = true
			Station.ASSEMBLY, Station.BAKING, Station.GRILLING, Station.SLICING:
				timer.start()
				can_pickup = false
			Station.SERVING:
				can_pickup = false
				serve_func()
				
		if should_lock:
			player.lock_movement(timer.time_left)
	else:
		if station == Station.ASSEMBLY:
			match held_item.name:
				# VEGETABLE SOUP
				"Cooked Vegetables":
					if player.held_item.name == "Cooked Chicken":
						pass
				"Cooked Chicken":
					if player.held_item.name == "Cooked Vegetables":
						pass
						
				# MEAT PIE
				"Sliced Meat":
					if player.held_item.name == "Bread":
						pass
				"Bread":
					if player.held_item.name == "Sliced Meat":
						pass
						
				# FISH PIE
				"Sliced Fish":
					if player.held_item.name == "Bread":
						pass
				"Bread":
					if player.held_item.name == "Sliced Fish":
						pass
						
				# MOLD TOAST
				"Moldy Fish":
					if player.held_item.name == "Bread":
						pass
				"Bread":
					if player.held_item.name == "Moldy Fish":
						pass
						
				"Grilled Chicken":
					if player.held_item.name == "Butterflies":
						pass
				"Butterflies":
					if player.held_item.name == "Grilled Chicken":
						pass
		
		if held_item != null and can_pickup:
			player.pickup(held_item)
			held_item = null

func serve_func() -> void:
	match QuestManager.current_recipe_name:
		"Bread":	
			if held_item.name == "Flour" and held_item.get_node("AnimatedSprite2D").frame == 3:
				QuestManager.complete_recipe()

		"Vegetable Soup":
			if held_item.name == "Vegetable Soup":
				QuestManager.complete_recipe()

		"Cream Soup":
			if held_item.name == "Cream Soup":
				QuestManager.complete_recipe()

		"Meat Stew":
			if held_item.name == "Meat Stew":
				QuestManager.complete_recipe()

		"Meat Pie":
			if held_item.name == "Meat Pie":
				QuestManager.complete_recipe()

		"Fish Pie":
			if held_item.name == "Fish Pie":
				QuestManager.complete_recipe()

		"Mold Toast":
			if held_item.name == "Mold Toast":
				QuestManager.complete_recipe()

		"Flutter Chicken":
			if held_item.name == "Flutter Chicken":
				QuestManager.complete_recipe()

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
