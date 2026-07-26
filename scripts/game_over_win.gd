extends CanvasLayer

@onready var video: VideoStreamPlayer = $VideoStreamPlayer

func _ready():
	visible = false
	QuestManager.game_won.connect(_on_game_won)

func _on_game_won():
	visible = true

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)
		player.set_process_input(false)

	video.play()

func _on_video_stream_player_finished():
	$Button.visible = true

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/main_menu.tscn")
