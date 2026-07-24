extends Node
class_name DialogueEventTrigger

@export var play_intro_on_ready: bool = true
@export var queue_tutorial_after_intro: bool = true
@export var player_group_name: StringName = &"player"


func _ready() -> void:
	# Start-of-level trigger: intro first, tutorial queued after it.
	if not play_intro_on_ready:
		return

	await get_tree().process_frame

	var player: Node = get_tree().get_first_node_in_group(player_group_name)
	var events: Node = get_node_or_null("/root/DialogueEvents")
	if events == null:
		push_error("DialogueEvents autoload is missing.")
		return

	events.call("play_intro", player)

	if queue_tutorial_after_intro:
		events.call("queue_tutorial", player)
