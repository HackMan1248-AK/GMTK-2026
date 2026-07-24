# Dialogue System

## Folder Structure

```text
res://
	dialogues/
		farmer.json
		fisherman.json
		dairy_farmer.json
		butcher.json
		insect_keeper.json
		creature.json
		tutorial.json
		intro.json
		success.json
		failure.json
		game_over.json
		victory.json
		timer_low.json
	scenes/dialogue/
		dialogue_manager.tscn
	scenes/npc/
		farmer.tscn
		fisherman.tscn
		dairy_farmer.tscn
		butcher.tscn
		insect_keeper.tscn
		creature.tscn
	scripts/dialogue/
		dialogue_manager.gd
		dialogue_events.gd
		dialogue_event_trigger.gd
		dialogue_resource.gd
		dialogue_line.gd
		npc_dialogue.gd
```

## Autoloads

`project.godot` contains:

```text
DialogueManager = res://scenes/dialogue/dialogue_manager.tscn
DialogueEvents = res://scripts/dialogue/dialogue_events.gd
```

## Dialogue UI

`res://scenes/dialogue/dialogue_manager.tscn`

```text
DialogueManager (CanvasLayer)
	Panel (Panel)
		SpeakerName (Label)
		DialogueText (RichTextLabel)
		ContinueLabel (Label)
```

The panel is anchored to the bottom of the screen and opens/closes with a short tween.

## Input Map

`DialogueNext` is mapped to Space.

The manager also accepts `ui_accept` and a direct Space fallback.

## JSON Format

Single-speaker file:

```json
{
  "speaker": "Farmer",
  "lines": [
    "Welcome traveler.",
    "I need your help preparing today's meal."
  ]
}
```

Multi-speaker file:

```json
{
  "lines": [
    {
      "speaker": "Farmer",
      "text": "The pact was made decades ago."
    },
    {
      "speaker": "Creature",
      "text": "Cook for me."
    }
  ]
}
```

## Runtime Behavior

- E still uses the existing `player.gd -> interactable.interact()` flow.
- NPCs extend `Interactable` through `npc_dialogue.gd`.
- Space advances dialogue.
- Player movement locks while dialogue is open.
- E is consumed while dialogue is active so interactions cannot stack.
- Dialogue can be started from NPCs or from game events.
- Queued dialogue plays in order.

## NPC Setup

Every NPC scene root has `npc_dialogue.gd` attached and contains:

```text
Area2D
	CollisionShape2D
```

Each NPC uses JSON paths:

```text
first_dialogue_file = res://dialogues/farmer.json
repeat_dialogue_file = res://dialogues/farmer_repeat.json
```

To duplicate Farmer for another NPC:

1. Duplicate `res://scenes/npc/farmer.tscn`.
2. Rename the scene and root node.
3. Duplicate or create a JSON file in `res://dialogues/`.
4. Change `first_dialogue_file` and `repeat_dialogue_file`.
5. Do not edit `DialogueManager`.

## Intro And Tutorial

`DialogueStartTrigger` is added to `res://scenes/levels/game_scene.tscn`.

On level start it calls:

```gdscript
DialogueEvents.play_intro(player)
DialogueEvents.queue_tutorial(player)
```

Gameplay movement is locked during the intro/tutorial queue and restored afterward.

## Event Dialogue API

Other systems should call these methods when their game state happens:

```gdscript
DialogueEvents.play_creature_request(player)
DialogueEvents.play_correct_meal(player)
DialogueEvents.play_wrong_meal(player)
DialogueEvents.play_timer_low(player)
DialogueEvents.play_game_over(player)
DialogueEvents.play_victory(player)
```

These are ready for the cooking, timer, and win/loss systems to connect without changing the dialogue manager.

## Signals

No manual signal connections are required.

The manager emits:

```gdscript
dialogue_started
line_changed(speaker: String, text: String, line_index: int)
dialogue_finished
dialogue_queue_empty
```

Use these later for audio, portraits, quest flags, or screen effects.
