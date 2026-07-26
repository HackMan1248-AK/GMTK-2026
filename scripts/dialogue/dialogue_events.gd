extends Node

const INTRO: String = "res://dialogues/intro.json"
const TUTORIAL: String = "res://dialogues/tutorial.json"
const CREATURE: String = "res://dialogues/creature.json"
const SUCCESS: String = "res://dialogues/success.json"
const FAILURE: String = "res://dialogues/failure.json"
const GAME_OVER: String = "res://dialogues/game_over.json"
const VICTORY: String = "res://dialogues/victory.json"
const TIMER_LOW: String = "res://dialogues/timer_low.json"
const RECIPE_GUIDE: String = "res://dialogues/recipe_guide.json"


func play_intro(player: Node = null) -> void:
	# Starts the story before normal play begins.
	var manager: Node = _dialogue_manager()
	if manager != null:
		manager.call("start_dialogue_file", INTRO, player)


func queue_tutorial(player: Node = null) -> void:
	# Queues tutorial guidance after any active intro dialogue.
	var manager: Node = _dialogue_manager()
	if manager != null:
		manager.call("queue_dialogue_file", TUTORIAL, player)


func queue_recipe_guide(player: Node = null) -> void:
	# Queues recipe guidance after the basic controls tutorial.
	var manager: Node = _dialogue_manager()
	if manager != null:
		manager.call("queue_dialogue_file", RECIPE_GUIDE, player)


func play_creature_request(player: Node = null) -> void:
	# Use when the creature assigns a dish.
	var manager: Node = _dialogue_manager()
	if manager != null:
		manager.call("start_dialogue_file", CREATURE, player)


func play_correct_meal(player: Node = null) -> void:
	# Use after the cooking system accepts a correct dish.
	var manager: Node = _dialogue_manager()
	if manager != null:
		manager.call("start_dialogue_file", SUCCESS, player)


func play_wrong_meal(player: Node = null) -> void:
	# Use after the cooking system rejects a dish.
	var manager: Node = _dialogue_manager()
	if manager != null:
		manager.call("start_dialogue_file", FAILURE, player)


func play_timer_low(player: Node = null) -> void:
	# Use when the countdown reaches a low-time warning threshold.
	var manager: Node = _dialogue_manager()
	if manager != null:
		manager.call("start_dialogue_file", TIMER_LOW, player)


func play_game_over(player: Node = null) -> void:
	# Use when the countdown reaches zero.
	var manager: Node = _dialogue_manager()
	if manager != null:
		manager.call("clear_dialogue_queue")
		manager.call("start_dialogue_file", GAME_OVER, player)


func play_victory(player: Node = null) -> void:
	# Use when the player completes the final objective.
	var manager: Node = _dialogue_manager()
	if manager != null:
		manager.call("clear_dialogue_queue")
		manager.call("start_dialogue_file", VICTORY, player)


func _dialogue_manager() -> Node:
	var manager: Node = get_node_or_null("/root/DialogueManager")
	if manager == null:
		push_error("DialogueManager autoload is missing.")
	return manager
