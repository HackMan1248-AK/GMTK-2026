extends CanvasLayer

var progress := {}

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
#@onready var recipe_name = $Panel/MarginContainer/VBoxContainer/RecipeName
#@onready var ingredients = $Panel/MarginContainer/VBoxContainer/Ingredients
#@onready var steps = $Panel/MarginContainer/VBoxContainer/Steps

func _ready():
	QuestManager.recipe_progress.connect(_on_recipe_progress)
	QuestManager.recipe_changed.connect(_on_recipe_changed)

	_on_recipe_changed(QuestManager.current_recipe_name)
	
func _on_recipe_progress(item:String):
	progress[item] = true

	match QuestManager.current_recipe_name:

		"Bread":
			if progress.has("Bread"):
				sprite.frame = 1

		"Vegetable Soup":
			if progress.has("Sliced Vegetables") and sprite.frame < 2:
				sprite.frame = 2
			if progress.has("Cooked Vegetables") and sprite.frame < 3:
				sprite.frame = 3
			if progress.has("Vegetable Soup"):
				sprite.frame = 4


		"Cream Soup":

			if progress.has("Heated Spoiled Milk") and sprite.frame < 5:
				sprite.frame = 5

			if progress.has("Cream Soup"):
				sprite.frame = 6


		"Meat Stew":

			if progress.has("Sliced Rotten Meat") and sprite.frame < 7:
				sprite.frame = 7

			if progress.has("Cooked Rotten Meat") and sprite.frame < 8:
				sprite.frame = 8

			if progress.has("Meat Stew"):
				sprite.frame = 9


		"Meat Pie":

			if progress.has("Sliced Meat"):
				sprite.frame = 10

			if progress.has("Sliced Meat") and progress.has("Bread"):
				sprite.frame = 11

			if progress.has("Meat Pie"):
				sprite.frame = 12


		"Fish Pie":

			if progress.has("Sliced Fish"):
				sprite.frame = 13

			if progress.has("Sliced Fish") and progress.has("Bread"):
				sprite.frame = 14

			if progress.has("Fish Pie"):
				sprite.frame = 15


		"Mold Toast":

			if progress.has("Bread"):
				sprite.frame = 16

			if progress.has("Mold Toast"):
				sprite.frame = 17


		"Flutter Chicken":

			if progress.has("Grilled Chicken"):
				sprite.frame = 18

			if progress.has("Flutter Chicken"):
				sprite.frame = 19
				
func _on_recipe_changed(recipe_name: String):
	progress.clear()

	match recipe_name:
		"Bread":
			sprite.frame = 0

		"Vegetable Soup":
			sprite.frame = 2

		"Cream Soup":
			sprite.frame = 5

		"Meat Stew":
			sprite.frame = 7

		"Meat Pie":
			sprite.frame = 10

		"Fish Pie":
			sprite.frame = 13

		"Mold Toast":
			sprite.frame = 16

		"Flutter Chicken":
			sprite.frame = 18

func reset_recipe():
	progress.clear()
	sprite.frame = 0

#func _ready():
	#hide()

#func _process(_delta):
	#if visible:
		#update_recipe()
#
#func update_recipe():
	#var recipe = QuestManager.get_recipe()
#
	#recipe_name.text = QuestManager.current_recipe_name
#
	#ingredients.text = "Ingredients:\n"
#
	#for item in recipe["ingredients"]:
		#ingredients.text += "- %s\n" % item["item"]
#
	#steps.text = "\nSteps:\n"
#
	#for step in recipe["steps"]:
		#steps.text += "%s at %s\n" % [
			#step["action"],
			#step["station"]
		#]
#
#func _input(event):
	#if event.is_action_pressed("Show Recipe"):
		#visible = !visible
		#
		#if visible:
			#update_recipe()
