extends Interactable

func _ready() -> void:
	super()

	$AnimatedSprite2D.play("default")
	$AnimatedSprite2D.pause()
	$AnimatedSprite2D.frame = 0

	for child in get_children():
		print(child.name)

func interact():
	var player = get_tree().get_first_node_in_group("player")

	if player:
		$Area2D/CollisionShape2D.disabled = true
		player.pickup(self)
