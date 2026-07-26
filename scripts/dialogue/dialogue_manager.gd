extends CanvasLayer
class_name DialogueManagerUI

signal dialogue_started
signal line_changed(speaker: String, text: String, line_index: int)
signal dialogue_finished
signal dialogue_queue_empty

@export var open_duration: float = 0.12
@export var close_duration: float = 0.08

@onready var panel: Panel = $Panel
@onready var speaker_name: Label = $Panel/SpeakerName
@onready var dialogue_text: RichTextLabel = $Panel/DialogueText
@onready var continue_label: Label = $Panel/ContinueLabel
@onready var dialogue_box: TextureRect = $BG
@onready var default_headshot: CanvasItem = $"Default Godot"

@onready var headshots := {
	"Butcher": $Butcher,
	"Dairy Farmer": $"Dairy Farmer",
	"Farmer": $Farmer,
	"Fisherman": $Fisherman,
	"Insect Keeper": $"Insect & Poultry Keeper",
	#"Creature": $Creature
}

var is_dialogue_active: bool = false
var current_line_index: int = 0
var current_dialogue: Array[Dictionary] = []
var dialogue_queue: Array[Dictionary] = []
var locked_player: Node = null
var previous_player_lock_state: Variant = false
var active_tween: Tween = null


func _ready() -> void:
	# The autoload exists from the first frame, but dialogue should stay hidden.
	hide_dialogue_immediately()


func _input(event: InputEvent) -> void:
	# Handle dialogue before player scripts see input, so E cannot retrigger interaction mid-dialogue.
	if not is_dialogue_active:
		return

	if event.is_action_pressed("DialogueNext") or event.is_action_pressed("ui_accept") or _is_space_pressed(event):
		get_viewport().set_input_as_handled()
		advance_dialogue()
		return

	if event.is_action_pressed("Interact"):
		get_viewport().set_input_as_handled()


func start_dialogue(dialogue_data: Variant, player: Node = null) -> void:
	# Start immediately if possible; otherwise add the new dialogue to the queue.
	var lines: Array[Dictionary] = _normalize_dialogue(dialogue_data)
	if lines.is_empty():
		return

	if is_dialogue_active:
		queue_dialogue(lines, player)
		return

	_begin_dialogue(lines, player)


func start_dialogue_file(dialogue_path: String, player: Node = null) -> void:
	# Load a JSON dialogue file and pass it through the same dialogue pipeline.
	start_dialogue(load_dialogue_file(dialogue_path), player)


func queue_dialogue(dialogue_data: Variant, player: Node = null) -> void:
	# Store dialogue for later. This supports intro chains and timed warning messages.
	var lines: Array[Dictionary] = _normalize_dialogue(dialogue_data)
	if lines.is_empty():
		return

	dialogue_queue.append({
		"lines": lines,
		"player": player
	})


func queue_dialogue_file(dialogue_path: String, player: Node = null) -> void:
	# Queue a JSON file without exposing JSON parsing to game systems.
	queue_dialogue(load_dialogue_file(dialogue_path), player)


func advance_dialogue() -> void:
	# Move forward one line, or finish the current block after the final line.
	if not is_dialogue_active:
		return

	current_line_index += 1

	if current_line_index >= current_dialogue.size():
		finish_dialogue()
		return

	_show_current_line()


func finish_dialogue() -> void:
	# Close the active block, then continue queued dialogue if one exists.
	if not is_dialogue_active:
		return

	is_dialogue_active = false
	current_dialogue.clear()
	current_line_index = 0

	await _close_panel()
	dialogue_finished.emit()

	if not dialogue_queue.is_empty():
		var next_dialogue: Dictionary = dialogue_queue.pop_front()
		var next_lines: Array[Dictionary] = next_dialogue.get("lines", [])
		var next_player: Node = next_dialogue.get("player", locked_player)
		_begin_dialogue(next_lines, next_player, true)
		return

	_unlock_player()
	dialogue_queue_empty.emit()


func clear_dialogue_queue() -> void:
	# Let scene changes or game-over states discard any pending conversation safely.
	dialogue_queue.clear()


func load_dialogue_file(dialogue_path: String) -> Array[Dictionary]:
	# Convert an external JSON file into the manager's internal line format.
	if not FileAccess.file_exists(dialogue_path):
		push_error("Dialogue file not found: %s" % dialogue_path)
		return []

	var file_text: String = FileAccess.get_file_as_string(dialogue_path)
	var parsed: Variant = JSON.parse_string(file_text)
	if parsed == null:
		push_error("Dialogue JSON could not be parsed: %s" % dialogue_path)
		return []

	return _normalize_dialogue(parsed)


func hide_dialogue_immediately() -> void:
	# Reset the UI without animation, used only during startup.
	default_headshot.visible = false

	for portrait in headshots.values():
		portrait.visible = false
		
	dialogue_box.visible = false
	
	if active_tween != null:
		active_tween.kill()
		active_tween = null

	if panel != null:
		panel.visible = false
		panel.modulate.a = 0.0
		panel.scale = Vector2(1.0, 0.96)
	if speaker_name != null:
		speaker_name.text = ""
	if dialogue_text != null:
		dialogue_text.text = ""
	if continue_label != null:
		continue_label.text = "Space - Next"

func _show_headshot(speaker: String) -> void:
	# Hide every portrait first.
	default_headshot.visible = false

	for portrait in headshots.values():
		portrait.visible = false

	# Show matching portrait or the default.
	if headshots.has(speaker):
		headshots[speaker].visible = true
	else:
		default_headshot.visible = true

func _begin_dialogue(lines: Array[Dictionary], player: Node = null, keep_existing_lock: bool = false) -> void:
	# Initialize a block of dialogue and lock movement once for the whole queue.
	if lines.is_empty():
		return

	current_dialogue = lines
	current_line_index = 0

	if not keep_existing_lock:
		_lock_player(player)

	is_dialogue_active = true
	_open_panel()

	dialogue_started.emit()
	_show_current_line()


func _show_current_line() -> void:
	# Copy the current dictionary line into the bottom dialogue panel.
	var line: Dictionary = current_dialogue[current_line_index]
	var speaker: String = str(line.get("speaker", ""))
	var text: String = str(line.get("text", ""))
	
	_show_headshot(speaker)

	dialogue_box.visible = true

	speaker_name.text = speaker
	dialogue_text.text = text
	continue_label.text = "Space - Next"

	line_changed.emit(speaker, text, current_line_index)


func _normalize_dialogue(dialogue_data: Variant) -> Array[Dictionary]:
	var normalized: Array[Dictionary] = []

	if dialogue_data == null:
		return normalized

	if dialogue_data is Resource and dialogue_data.has_method("to_dialogue_array"):
		return dialogue_data.to_dialogue_array()

	if dialogue_data is Dictionary:
		return _normalize_dialogue_dictionary(dialogue_data)

	if dialogue_data is Array:
		for entry: Variant in dialogue_data:
			if entry is Dictionary:
				normalized.append({
					"speaker": str(entry.get("speaker", "")),
					"text": str(entry.get("text", entry.get("line", "")))
				})

		return normalized

	return normalized


func _normalize_dialogue_dictionary(data: Dictionary) -> Array[Dictionary]:
	var normalized: Array[Dictionary] = []

	var default_speaker: String = str(data.get("speaker", ""))

	# Handle {"speaker":"Farmer","lines":[...]}
	if data.has("lines"):
		var lines: Variant = data["lines"]

		if lines is Array:
			for line_entry: Variant in lines:
				if line_entry is Dictionary:
					normalized.append({
						"speaker": str(line_entry.get("speaker", default_speaker)),
						"text": str(line_entry.get("text", line_entry.get("line", "")))
					})
				else:
					normalized.append({
						"speaker": default_speaker,
						"text": str(line_entry)
					})

		return normalized

	# Handle {"speaker":"Farmer","text":"Hello"}
	normalized.append({
		"speaker": default_speaker,
		"text": str(data.get("text", data.get("line", "")))
	})

	return normalized

func _open_panel() -> void:
	# Smoothly reveal the dialogue box.
	if active_tween != null:
		active_tween.kill()

	panel.visible = true
	panel.modulate.a = 0.0
	panel.scale = Vector2(1.0, 0.96)
	panel.pivot_offset = Vector2(panel.size.x * 0.5, panel.size.y)

	active_tween = create_tween()
	active_tween.set_parallel(true)
	active_tween.tween_property(panel, "modulate:a", 1.0, open_duration)
	active_tween.tween_property(panel, "scale", Vector2.ONE, open_duration)


func _close_panel() -> void:
	# Smoothly close the dialogue box before unlocking movement.
	if active_tween != null:
		active_tween.kill()

	active_tween = create_tween()
	active_tween.set_parallel(true)
	active_tween.tween_property(panel, "modulate:a", 0.0, close_duration)
	active_tween.tween_property(panel, "scale", Vector2(1.0, 0.96), close_duration)
	await active_tween.finished

	panel.visible = false
	default_headshot.visible = false
	for portrait in headshots.values():
		portrait.visible = false
	dialogue_box.visible = false
	speaker_name.text = ""
	dialogue_text.text = ""
	continue_label.text = "Space - Next"


func _lock_player(player: Node = null) -> void:
	# Use the provided player first, then fall back to the existing player group.
	locked_player = player
	if locked_player == null:
		locked_player = get_tree().get_first_node_in_group("player")
	if locked_player == null:
		locked_player = get_tree().get_first_node_in_group("Player")

	if locked_player != null and _object_has_property(locked_player, "movement_locked"):
		previous_player_lock_state = locked_player.get("movement_locked")
		locked_player.set("movement_locked", true)


func _unlock_player() -> void:
	# Restore the exact movement_locked value the player had before dialogue began.
	if locked_player != null and _object_has_property(locked_player, "movement_locked"):
		locked_player.set("movement_locked", previous_player_lock_state)

	locked_player = null
	previous_player_lock_state = false


func _object_has_property(object: Object, property_name: String) -> bool:
	# Avoid hard dependencies on the Player script while still using movement_locked when present.
	for property: Dictionary in object.get_property_list():
		if property.get("name") == property_name:
			return true

	return false


func _is_space_pressed(event: InputEvent) -> bool:
	# Space is required by the jam spec even if the Input Map is temporarily missing.
	return event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE
