extends Resource
class_name DialogueResource

@export var lines: Array[Dictionary] = []


func to_dialogue_array() -> Array[Dictionary]:
	# Return a clean copy so the manager can read dialogue without mutating the resource.
	var result: Array[Dictionary] = []

	for line in lines:
		result.append({
			"speaker": str(line.get("speaker", "")),
			"text": str(line.get("text", ""))
		})

	return result
