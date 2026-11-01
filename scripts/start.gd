extends Control
## Title / start screen: black background with a softly pulsing prompt.
## Any key, mouse click, or gamepad button starts the music and wakes the book.
## When the book is first turned to page `dialogue_page`, `dialogue_file` plays
## over the book, and page turning is locked until the dialogue ends.

## Dialogue to play.
@export_file("*.xml") var dialogue_file: String = "res://assets/dialogue/start.xml"
## Page number (as printed at the bottom of the page) that starts the dialogue.
## Page 0 is the inside of the cover, page 1 the first right-hand page.
## Set to -1 to play the dialogue when the book is closed into the corner instead.
@export var dialogue_page: int = 2
## Seconds to wait after the page turn before the dialogue starts.
@export var dialogue_delay: float = 0.4
## Scene to load once the book has been closed into the corner (it starts in daytime).
## Leave empty to stay on this screen.
@export_file("*.tscn") var scene_after_close: String = "res://scenes/main.tscn"
## Seconds for the fade to black before the next scene loads.
@export var scene_fade_time: float = 0.8

@onready var prompt: Label = $PromptLabel
@onready var book: Control = $Book
@onready var dialogue_box: Control = $DialogueBox

var _started := false
var _dialogue_played := false
var _fade_in: Tween
var _pulse: Tween


func _ready() -> void:
	prompt.modulate.a = 0.0
	_fade_in = create_tween()
	_fade_in.tween_property(prompt, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE)
	_fade_in.finished.connect(_start_pulse)
	book.page_changed.connect(_on_page_changed)
	book.closed.connect(_on_book_closed)


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


func _on_page_changed(spread: int) -> void:
	# A spread shows two pages: the left one (spread * 2) and the right one (spread * 2 + 1).
	if dialogue_page == spread * 2 or dialogue_page == spread * 2 + 1:
		_play_dialogue()


func _on_book_closed() -> void:
	if dialogue_page == -1:
		await _play_dialogue()
	_go_to_next_scene()


func _go_to_next_scene() -> void:
	if scene_after_close.is_empty():
		return
	# The notebook continues in the next scene with the same pages.
	GameState.notebook_pages = book.pages
	GameState.notebook_spread = book.get_spread()
	var fade := create_tween()
	fade.tween_property(self, "modulate:a", 0.0, scene_fade_time)
	await fade.finished
	get_tree().change_scene_to_file(scene_after_close)


func _play_dialogue() -> void:
	if _dialogue_played:
		return
	_dialogue_played = true
	book.set_locked(true)
	await get_tree().create_timer(dialogue_delay).timeout
	dialogue_box.play_file(dialogue_file)
	await dialogue_box.finished
	book.set_locked(false)
