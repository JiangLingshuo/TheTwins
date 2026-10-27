extends Control
## Reusable visual-novel style dialogue box.
## Call play_file("res://...xml") or play(lines); it emits `finished` after the last line.
## Text is revealed one character at a time. "#PLAYER#" (or "{name}") is replaced with the player's name.
##
## Controls: Space / Enter / left click
##   - while text is typing: show the whole line at once
##   - when the line is finished: go to the next line

signal finished

## Typing speed, in characters per second.
@export_range(5.0, 200.0, 1.0) var chars_per_second: float = 35.0
## Extra pause (seconds) after punctuation, for a more natural rhythm.
@export var punctuation_pause: float = 0.18
## How dark the screen behind the box gets while it is open (0 = no dimming).
@export_range(0.0, 1.0, 0.05) var dim_alpha: float = 0.5
## Seconds for the box to fade in / out.
@export var fade_time: float = 0.3

const PAUSE_CHARS := ".,!?;:…—"

@onready var dim: ColorRect = $Dim
@onready var panel: PanelContainer = $Panel
@onready var speaker_label: Label = $Panel/Margin/VBox/SpeakerLabel
@onready var content_label: Label = $Panel/Margin/VBox/ContentLabel
@onready var continue_indicator: Label = $Panel/Margin/ContinueIndicator

var _lines: Array[Dictionary] = []
var _index := -1
var _active := false
var _accept_input := false
var _typing := false
var _char_timer := 0.0
var _indicator_tween: Tween


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	continue_indicator.visible = false


func is_playing() -> bool:
	return _active


func play_file(path: String) -> void:
	play(DialogueLoader.load_xml(path))


func play(lines: Array[Dictionary]) -> void:
	_lines = lines
	_index = -1
	_active = true
	_accept_input = false
	speaker_label.text = ""
	content_label.text = ""
	_stop_indicator()

	# Block clicks to anything underneath while the dialogue is open.
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = true
	dim.color = Color(0, 0, 0, dim_alpha)
	modulate.a = 0.0
	var t := create_tween()
	t.tween_property(self, "modulate:a", 1.0, fade_time)
	await t.finished

	_accept_input = true
	_next_line()


func _process(delta: float) -> void:
	if not _typing:
		return
	_char_timer -= delta
	while _char_timer <= 0.0 and _typing:
		content_label.visible_characters += 1
		var shown := content_label.visible_characters
		if shown >= content_label.text.length():
			_finish_line()
			break
		_char_timer += 1.0 / chars_per_second
		if PAUSE_CHARS.contains(content_label.text[shown - 1]):
			_char_timer += punctuation_pause


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		_advance()


func _unhandled_input(event: InputEvent) -> void:
	if _active and event.is_action_pressed("ui_accept") and not event.is_echo():
		get_viewport().set_input_as_handled()
		_advance()


func _advance() -> void:
	if not _accept_input:
		return
	if _typing:
		_finish_line()
	else:
		_next_line()


func _next_line() -> void:
	_index += 1
	if _index >= _lines.size():
		_close()
		return

	var line := _lines[_index]
	var speaker: String = line["speaker"]
	var content: String = line["content"]
	speaker_label.text = GameState.fill_placeholders(speaker)
	speaker_label.visible = not speaker.is_empty()
	content_label.text = GameState.fill_placeholders(content)
	content_label.visible_characters = 0

	_stop_indicator()
	_char_timer = 0.0
	_typing = true


func _finish_line() -> void:
	_typing = false
	content_label.visible_characters = -1
	_start_indicator()


func _close() -> void:
	_accept_input = false
	_stop_indicator()
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, fade_time)
	await t.finished
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_active = false
	finished.emit()


func _start_indicator() -> void:
	continue_indicator.visible = true
	continue_indicator.modulate.a = 1.0
	_indicator_tween = create_tween().set_loops()
	_indicator_tween.tween_property(continue_indicator, "modulate:a", 0.2, 0.6).set_trans(Tween.TRANS_SINE)
	_indicator_tween.tween_property(continue_indicator, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)


func _stop_indicator() -> void:
	if _indicator_tween:
		_indicator_tween.kill()
		_indicator_tween = null
	continue_indicator.visible = false
