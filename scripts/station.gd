extends Interactable

var held_item = null
var player = get_tree().get_first_node_in_group("player")

enum Station {
	FRIDGE,
	PANTRY,
	ASSEMBLY,
	BAKING,
	GRILLING,
	SLICING
}

@export var station: Station

func interact() -> void:
	if player.held_item != null:
		held_item = player.held_item
		match station:
			Station.FRIDGE:
				held_item.reparent(self)
				
				held_item.position = Vector2.ZERO
				held_item.rotation = 0
				print("Freezing")
			Station.PANTRY:
				held_item.reparent(self)
				
				held_item.position = Vector2.ZERO
				held_item.rotation = 0
				print("Storing")
			Station.ASSEMBLY:
				held_item.reparent(self)
				
				held_item.position = Vector2.ZERO
				held_item.rotation = 0
				print("Assembling")
			Station.BAKING:
				held_item.reparent(self)
				
				held_item.position = Vector2.ZERO
				held_item.rotation = 0
				print("Baking")
			Station.GRILLING:
				held_item.reparent(self)
				
				held_item.position = Vector2.ZERO
				held_item.rotation = 0
				print("Grilling")
			Station.SLICING:
				held_item.reparent(self)
				
				held_item.position = Vector2.ZERO
				held_item.rotation = 0
				print("Slicing")
