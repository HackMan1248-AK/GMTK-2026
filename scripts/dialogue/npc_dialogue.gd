extends Interactable
class_name NPCDialogue

@export_file("*.json") var first_dialogue_file: String = ""
@export_file("*.json") var repeat_dialogue_file: String = ""
@export var fallback_lines: Array[Dictionary] = []
@export var player_group_name: StringName = &"player"

@export var reward_items: Array[String] = []
@export var reward_spawn: NodePath
var reward_index := 0

var has_spoken: bool = false

func interact() -> void:
	# NPCs remain normal Interactables; this method only delegates to the dialogue autoload.
	var dialogue_manager: Node = get_node_or_null("/root/DialogueManager")
	if dialogue_manager == null:
		push_error("DialogueManager autoload is missing. Add res://scenes/dialogue/dialogue_manager.tscn as DialogueManager.")
		return

	if bool(dialogue_manager.get("is_dialogue_active")):
		return

	var player: Node = get_tree().get_first_node_in_group(player_group_name)
	var selected_file: String = _get_selected_dialogue_file()
	
	dialogue_manager.reward_item = ""
	dialogue_manager.reward_spawn = null

	if has_spoken and not reward_items.is_empty():
		dialogue_manager.reward_item = reward_items[reward_index]
		reward_index = (reward_index + 1) % reward_items.size()
		dialogue_manager.reward_spawn = get_node_or_null(reward_spawn)

	if selected_file != "":
		dialogue_manager.call("start_dialogue_file", selected_file, player)
	else:
		dialogue_manager.call("start_dialogue", fallback_lines, player)

	has_spoken = true


func _get_selected_dialogue_file() -> String:
	# First interaction can be story-heavy; later interactions can be shorter repeat lines.
	if not has_spoken and first_dialogue_file != "":
		return first_dialogue_file

	if has_spoken and repeat_dialogue_file != "":
		return repeat_dialogue_file

	return first_dialogue_file
