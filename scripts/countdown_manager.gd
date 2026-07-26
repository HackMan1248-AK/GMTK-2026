extends CanvasLayer
class_name CountdownManagerUI

signal countdown_started
signal countdown_finished
signal time_added(seconds: float)

@export var starting_seconds: float = 60.0
@export var seconds_added_per_served_food: float = 30.0
@export var game_scene_name: String = "GameScene"
@export var main_menu_path: String = "res://scenes/levels/main_menu.tscn"
@export var game_scene_path: String = "res://scenes/levels/game_scene.tscn"

@onready var timer_label: Label = $TimerLabel
@onready var added_time_label: Label = $AddedTimeLabel
@onready var game_over_panel: Panel = $GameOverPanel
@onready var restart_button: Button = $GameOverPanel/VBoxContainer/RestartButton
@onready var main_menu_button: Button = $GameOverPanel/VBoxContainer/MainMenuButton

var time_left: float = 0.0
var countdown_running: bool = false
var game_over: bool = false
var active_game_scene_id: int = 0
var added_time_tween: Tween = null


func _ready() -> void:
	# Keep countdown UI alive even when game over pauses the tree.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_buttons()
	_connect_recipe_signal()
	if countdown_running:
		show()
		_update_timer_label()
	else:
		hide()


func _process(delta: float) -> void:
	# Autoload watches for the gameplay scene so menus do not show the timer.
	_update_scene_state()

	if not countdown_running or game_over:
		return

	time_left = maxf(time_left - delta, 0.0)
	_update_timer_label()

	if time_left <= 0.0:
		_show_game_over()


func start_countdown() -> void:
	# Reset and start a fresh countdown whenever a new game scene is entered.
	time_left = starting_seconds
	countdown_running = true
	game_over = false
	show()
	if game_over_panel != null:
		game_over_panel.visible = false
	if added_time_label != null:
		added_time_label.visible = false
	_update_timer_label()
	countdown_started.emit()


func add_time(seconds: float) -> void:
	# Successful served food gives the player more time.
	if not countdown_running or game_over:
		return

	time_left += seconds
	_update_timer_label()
	_show_added_time(seconds)
	time_added.emit(seconds)


func stop_countdown() -> void:
	# Used when leaving gameplay scenes.
	countdown_running = false
	game_over = false
	hide()


func _update_scene_state() -> void:
	var current_scene: Node = get_tree().current_scene

	if current_scene == null:
		return

	if current_scene.name == game_scene_name:
		var scene_id: int = current_scene.get_instance_id()
		if scene_id != active_game_scene_id:
			active_game_scene_id = scene_id
			start_countdown()
		return

	if active_game_scene_id != 0:
		active_game_scene_id = 0
		stop_countdown()


func _connect_recipe_signal() -> void:
	# QuestManager owns recipe completion; countdown only listens to that event.
	if not QuestManager.recipe_completed.is_connected(_on_recipe_completed):
		QuestManager.recipe_completed.connect(_on_recipe_completed)


func _setup_buttons() -> void:
	if restart_button != null:
		restart_button.pressed.connect(_on_restart_pressed)
	if main_menu_button != null:
		main_menu_button.pressed.connect(_on_main_menu_pressed)


func _on_recipe_completed(_recipe_name: String) -> void:
	add_time(seconds_added_per_served_food)


func _show_game_over() -> void:
	countdown_running = false
	game_over = true
	time_left = 0.0
	_update_timer_label()
	if game_over_panel != null:
		game_over_panel.visible = true
	get_tree().paused = true
	countdown_finished.emit()


func _on_restart_pressed() -> void:
	get_tree().paused = false
	active_game_scene_id = 0
	get_tree().change_scene_to_file(game_scene_path)


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	active_game_scene_id = 0
	stop_countdown()
	get_tree().change_scene_to_file(main_menu_path)


func _update_timer_label() -> void:
	if timer_label == null:
		return

	var total_seconds: int = ceili(time_left)
	var minutes: int = floori(float(total_seconds) / 60.0)
	var seconds: int = total_seconds % 60
	timer_label.text = "COUNTDOWN  %02d:%02d" % [minutes, seconds]


func _show_added_time(seconds: float) -> void:
	if added_time_label == null:
		return

	if added_time_tween != null:
		added_time_tween.kill()

	added_time_label.text = "+%d SECONDS" % int(seconds)
	added_time_label.visible = true
	added_time_label.modulate.a = 1.0
	added_time_label.position.y = 78.0

	added_time_tween = create_tween()
	added_time_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	added_time_tween.set_parallel(true)
	added_time_tween.tween_property(added_time_label, "modulate:a", 0.0, 1.2)
	added_time_tween.tween_property(added_time_label, "position:y", 54.0, 1.2)
	await added_time_tween.finished
	added_time_label.visible = false
