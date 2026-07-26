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
@export var marker: Marker2D

func _ready() -> void:
	super()
	player = get_tree().get_first_node_in_group("player")

func interact() -> void:
	if player.held_item != null:
		held_item = player.held_item
		held_item.reparent(self)
		
		held_item.position = marker.position
		held_item.rotation = 0
		held_item.scale = Vector2(0.145, 0.145)
		player.held_item = null
		
		match station:
			Station.FRIDGE, Station.PANTRY:
				can_pickup = true
			Station.BAKING, Station.GRILLING, Station.SLICING:
				get_cooking()
			Station.ASSEMBLY:
				if held_item.name == "Cooked Rotten Meat" or held_item.name == "Heated Spoiled Milk":
					get_cooking()
			Station.SERVING:
				can_pickup = false
				serve_func()
				
		if should_lock:
			player.lock_movement(timer.time_left)
			player.is_cooking = true
	else:
		if station == Station.ASSEMBLY:
			assembly_func()
		elif held_item != null and can_pickup:
				player.pickup(held_item)
				held_item = null

func get_cooking() -> void:
	timer.start()
	can_pickup = false

func serve_func() -> void:
	match QuestManager.current_recipe_name:
		"Bread":	
			if held_item.name == "Bread":
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
	
	held_item.eat()
	held_item = null

func assembly_func() -> void:
	match held_item.name:
		# VEGETABLE SOUP
		"Cooked Vegetables":
			if player.held_item.name == "Cooked Chicken":
				get_cooking()
		"Cooked Chicken":
			if player.held_item.name == "Cooked Vegetables":
				get_cooking()
				
		# MEAT PIE
		"Sliced Meat":
			if player.held_item.name == "Bread":
				get_cooking()
				
		# FISH PIE
		"Sliced Fish":
			if player.held_item.name == "Bread":
				get_cooking()
				
		# MOLD TOAST
		"Moldy Cheese":
			if player.held_item.name == "Bread":
				get_cooking()
		
		# FLUTTER CHICKEN
		"Grilled Chicken":
			if player.held_item.name == "Butterflies":
				get_cooking()
		"Butterflies":
			if player.held_item.name == "Grilled Chicken":
				get_cooking()
				
		# BREAD
		"Bread":
			if player.held_item.name in [
				"Sliced Meat",
				"Sliced Fish",
				"Moldy Cheese"
			]:
				get_cooking()

func _on_timer_timeout() -> void:
	player.is_cooking = false
	if held_item == null:
		push_error("held_item is NULL")
		return
	can_pickup = true

	match station:
		Station.SLICING:
			match held_item.name:
				"Vegetables":
					held_item.name = "Sliced Vegetables"
				"Chicken":
					held_item.name = "Sliced Chicken"
				"Rotten Meat":
					held_item.name = "Sliced Rotten Meat"
				"Meat":
					held_item.name = "Sliced Meat"
				"Fish":
					held_item.name = "Sliced Fish"


		Station.GRILLING:
			match held_item.name:
				"Sliced Vegetables":
					held_item.name = "Cooked Vegetables"
				"Sliced Chicken":
					held_item.name = "Cooked Chicken"
				"Sliced Rotten Meat":
					held_item.name = "Cooked Rotten Meat"
				"Chicken":
					held_item.name = "Grilled Chicken"
				"Spoiled Milk":
					held_item.name = "Heated Spoiled Milk"
				"Bread":
					held_item.name = "Toast"


		Station.BAKING:
			match held_item.name:
				"Flour":
					held_item.name = "Bread"


		Station.ASSEMBLY:
			match held_item.name:

				# Vegetable Soup
				"Cooked Vegetables":
					if player.held_item.name == "Cooked Chicken":
						player.held_item.queue_free()
						held_item.name = "Vegetable Soup"

				"Cooked Chicken":
					if player.held_item.name == "Cooked Vegetables":
						player.held_item.queue_free()
						held_item.name = "Vegetable Soup"


				# Cream Soup
				"Heated Spoiled Milk":
					held_item.name = "Cream Soup"


				# Meat Stew
				"Cooked Rotten Meat":
					held_item.name = "Meat Stew"


				# Meat Pie
				"Sliced Meat":
					if player.held_item.name == "Bread":
						player.held_item.queue_free()
						held_item.name = "Meat Pie"

				"Bread":
					if player.held_item.name == "Sliced Meat":
						player.held_item.queue_free()
						held_item.name = "Meat Pie"


				# Fish Pie
				"Sliced Fish":
					if player.held_item.name == "Bread":
						player.held_item.queue_free()
						held_item.name = "Fish Pie"

				"Bread":
					if player.held_item.name == "Sliced Fish":
						player.held_item.queue_free()
						held_item.name = "Fish Pie"


				# Mold Toast
				"Moldy Cheese":
					if player.held_item.name == "Bread":
						player.held_item.queue_free()
						held_item.name = "Mold Toast"

				"Bread":
					if player.held_item.name == "Moldy Cheese":
						player.held_item.queue_free()
						held_item.name = "Mold Toast"


				# Flutter Chicken
				"Grilled Chicken":
					if player.held_item.name == "Butterflies":
						player.held_item.queue_free()
						held_item.name = "Flutter Chicken"

				"Butterflies":
					if player.held_item.name == "Grilled Chicken":
						player.held_item.queue_free()
						held_item.name = "Flutter Chicken"
	
	held_item.item_id = held_item.name
	QuestManager.update_recipe_progress(held_item.name)
