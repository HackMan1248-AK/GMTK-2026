extends CanvasLayer

@onready var recipe_name = $Panel/MarginContainer/VBoxContainer/RecipeName
@onready var ingredients = $Panel/MarginContainer/VBoxContainer/Ingredients
@onready var steps = $Panel/MarginContainer/VBoxContainer/Steps

func _ready():
	hide()

func update_recipe():
	var recipe = QuestManager.get_recipe()

	recipe_name.text = QuestManager.current_recipe_name

	ingredients.text = "Ingredients:\n"

	for item in recipe["ingredients"]:
		ingredients.text += "- %s\n" % item["item"]

	steps.text = "\nSteps:\n"

	for step in recipe["steps"]:
		steps.text += "%s at %s\n" % [
			step["action"],
			step["station"]
		]

func _input(event):
	if event.is_action_pressed("Show Recipe"):
		visible = !visible
		
		if visible:
			update_recipe()
