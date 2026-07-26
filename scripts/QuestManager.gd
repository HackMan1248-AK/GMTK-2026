extends Node

signal recipe_completed(recipe_name: String)

var current_recipe_index = 0
var current_recipe_name = ""

func _ready():
	assign_recipe()

func assign_recipe():
	if current_recipe_index >= RecipeDatabase.recipe_order.size():
		print("All recipes complete!")
		return

	current_recipe_name = RecipeDatabase.recipe_order[current_recipe_index]

func complete_recipe():
	recipe_completed.emit(current_recipe_name)
	current_recipe_index += 1
	assign_recipe()

func get_recipe():
	return RecipeDatabase.recipes[current_recipe_name]
