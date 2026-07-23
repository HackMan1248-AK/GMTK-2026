extends Interactable

func interact():
	var player = get_tree().get_first_node_in_group("player")

	if player:
		$Area2D/CollisionShape2D.disabled = true
		player.pickup(self)
