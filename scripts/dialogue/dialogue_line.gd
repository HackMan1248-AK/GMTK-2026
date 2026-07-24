extends Resource
class_name DialogueLine

@export var speaker: String = ""
@export_multiline var text: String = ""


func to_dictionary() -> Dictionary:
	# Optional helper for teams that prefer one Resource per line.
	return {
		"speaker": speaker,
		"text": text
	}
