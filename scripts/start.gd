extends Control
## Title / start screen: black background with a softly pulsing prompt.
## Any key, mouse click, or gamepad button starts the music and wakes the book.
## The first time the book is read and stowed in the corner, `dialogue_file` plays.

## Dialogue to play after the book closes.
@export_file("*.xml") var dialogue_file: String = "res://assets/dialogue/start.xml"

@onready var prompt: Label = $PromptLabel
@onready var book: Control = $Book
@onready var dialogue_box: Control = $DialogueBox

var _started := false
var _fade_in: Tween
var _pulse: Tween


func _ready() -> void:
	prompt.modulate.a = 0.0
	_fade_in = create_tween()
	_fade_in.tween_property(prompt, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE)
	_fade_in.finished.connect(_start_pulse)
	book.closed.connect(_on_book_closed, CONNECT_ONE_SHOT)


func _start_pulse() -> void:
	if _started:
		return
	_pulse = create_tween().set_loops()
	_pulse.tween_property(prompt, "modulate:a", 0.35, 1.4).set_trans(Tween.TRANS_SINE)
	_pulse.tween_property(prompt, "modulate:a", 1.0, 1.4).set_trans(Tween.TRANS_SINE)


func _unhandled_input(event: InputEvent) -> void:
	if _started or event.is_echo() or not event.is_pressed():
		return
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		get_viewport().set_input_as_handled()
		_start_game()


func _start_game() -> void:
	_started = true
	Music.play_bgm()
	# Stop the fade-in too, or it keeps pulling the prompt back to full opacity.
	_fade_in.kill()
	if _pulse:
		_pulse.kill()
	var fade_out := create_tween()
	fade_out.tween_property(prompt, "modulate:a", 0.0, 0.4)
	fade_out.finished.connect(prompt.hide)
	book.wake()


func _on_book_closed() -> void:
	dialogue_box.play_file(dialogue_file)
