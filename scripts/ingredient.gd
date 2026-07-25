# ingredient.gd
extends Interactable

@export var item_id := ""

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const ITEM_FRAMES := {
	"Flour": 0,
	"Bread": 1,

	"Sliced Vegetables": 2,
	"Cooked Vegetables": 3,

	"Chicken": 4,
	"Sliced Chicken": 5,
	"Cooked Chicken": 6,
	"Grilled Chicken": 7,

	"Spoiled Milk": 8,
	"Heated Spoiled Milk": 9,

	"Rotten Meat": 10,
	"Sliced Rotten Meat": 11,
	"Cooked Rotten Meat": 12,

	"Meat": 13,
	"Sliced Meat": 14,

	"Fish": 15,
	"Sliced Fish": 16,

	"Moldy Fish": 17,
	"Butterflies": 18,

	"Vegetable Soup": 19,
	"Cream Soup": 20,
	"Meat Stew": 21,
	"Meat Pie": 22,
	"Fish Pie": 23,
	"Mold Toast": 24,
	"Flutter Chicken": 25
}

func _ready() -> void:
	super()

	sprite.play("default")
	sprite.pause()
	update_sprite()

func _process(delta: float) -> void:
	item_id = self.name
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
