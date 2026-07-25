# RecipeDatabase.gd
extends Node

var recipes = {}
var recipe_order = []

func _ready():
	load_recipes()

func load_recipes():
	var file = FileAccess.open("res://misc/recipes.json", FileAccess.READ)
	recipes = JSON.parse_string(file.get_as_text())

	recipe_order = recipes.keys()
