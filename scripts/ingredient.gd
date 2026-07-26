# ingredient.gd
extends Interactable

@export var item_id := ""

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const ITEM_FRAMES := {
	"Flour": 0,
	"Bread": 1,

	"Vegetables": 2,
	"Sliced Vegetables": 3,
	"Cooked Vegetables": 4,

	"Chicken": 5,
	"Sliced Chicken": 6,
	"Cooked Chicken": 7,
	"Grilled Chicken": 8,

	"Spoiled Milk": 9,
	"Heated Spoiled Milk": 10,

	"Rotten Meat": 11,
	"Sliced Rotten Meat": 12,
	"Cooked Rotten Meat": 13,

	"Meat": 14,
	"Sliced Meat": 15,

	"Fish": 16,
	"Sliced Fish": 17,

	"Moldy Cheese": 18,
	"Butterflies": 19,

	"Vegetable Soup": 20,
	"Cream Soup": 21,
	"Meat Stew": 22,
	"Meat Pie": 23,
	"Fish Pie": 24,
	"Mold Toast": 25,
	"Flutter Chicken": 26
}

func _ready() -> void:
	super()

	sprite.play("default")
	sprite.pause()
	update_sprite()

func _process(delta: float) -> void:
	var regex = RegEx.new()
	regex.compile("\\d+$")

	var item_id = regex.sub(self.name, "", true)
	update_sprite()

func update_sprite():
	if ITEM_FRAMES.has(item_id):
		sprite.frame = ITEM_FRAMES[item_id]
	else:
		push_warning("Unknown item: " + item_id)

func set_item(new_item:String):
	item_id = new_item
	name = new_item
	update_sprite()

func interact():
	var player = get_tree().get_first_node_in_group("player")

	if player:
		$Area2D/CollisionShape2D.disabled = true
		player.pickup(self)

func eat():
	queue_free()
