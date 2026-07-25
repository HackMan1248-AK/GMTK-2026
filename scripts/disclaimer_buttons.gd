extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.





func _on_disclaimer_quit_button_down() -> void:
	get_tree().quit(0)


func _on_disclaimer_continue_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/main_menu.tscn") 
	
