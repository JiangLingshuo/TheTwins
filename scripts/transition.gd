extends Control
## Transition scene: black screen + dialogue box that plays `dialogue_file`.

## Dialogue to play.
@export_file("*.xml") var dialogue_file: String = "res://assets/dialogue/start.xml"
## Scene to load after the last line. Leave empty to stay here.
@export_file("*.tscn") var next_scene: String = ""

@onready var dialogue_box: Control = $DialogueBox


func _ready() -> void:
	modulate.a = 0.0
	var fade_in := create_tween()
	fade_in.tween_property(self, "modulate:a", 1.0, 0.8)
	await fade_in.finished

	dialogue_box.play_file(dialogue_file)
	await dialogue_box.finished

	if next_scene.is_empty():
		return
	var fade_out := create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, 0.8)
	await fade_out.finished
	get_tree().change_scene_to_file(next_scene)
