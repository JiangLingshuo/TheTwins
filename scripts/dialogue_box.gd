extends Control
## Reusable visual-novel style dialogue box.
## Call play_file("res://...xml") or play(lines); it emits `finished` after the last line.
## Text is revealed one character at a time. "#PLAYER#" (or "{name}") is replaced with the player's name.
##
## Controls: Space / Enter / left click
##   - while text is typing: show the whole line at once
##   - when the line is finished: go to the next line

signal finished
signal term_selected(term_id: String)

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
@onready var content_label: RichTextLabel = $Panel/Margin/VBox/ContentLabel
@onready var continue_indicator: Label = $Panel/Margin/ContinueIndicator

var _lines: Array[Dictionary] = []
var _log_session: String = ""
var _index := -1
var _active := false
var _accept_input := false
var _typing := false
var _char_timer := 0.0
var _indicator_tween: Tween
var _hovered_meta := ""
var _feedback_kind := ""


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	continue_indicator.visible = false
	content_label.meta_clicked.connect(func(meta: Variant) -> void: term_selected.emit(str(meta)))
	content_label.meta_hover_started.connect(func(meta: Variant) -> void: _hovered_meta = str(meta))
	content_label.meta_hover_ended.connect(func(_meta: Variant) -> void: _hovered_meta = "")
	content_label.gui_input.connect(_on_content_input)


func is_playing() -> bool:
	return _active


func play_file(path: String) -> void:
	var session := "opening" if path == "res://assets/dialogue/start.xml" else path.get_file().get_basename()
	set_feedback("")
	play(DialogueLoader.load_xml(path), session)


func play(lines: Array[Dictionary], log_session: String = "") -> void:
	speaker_label.show()
	content_label.show()
	_log_session = log_session
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
		if shown >= content_label.get_total_character_count():
			_finish_line()
			break
		_char_timer += 1.0 / chars_per_second
		if shown > 0 and shown <= content_label.get_parsed_text().length() and PAUSE_CHARS.contains(content_label.get_parsed_text()[shown - 1]):
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
	var log_line: Dictionary = line.duplicate()
	log_line["content"] = RegEx.create_from_string('<link="[^"]+">([^<]+)</link>').sub(content, "$1", true)
	GameState.append_radio_line(_log_session, log_line)
	speaker_label.text = GameState.fill_placeholders(speaker)
	speaker_label.visible = not speaker.is_empty()
	_hovered_meta = ""
	content_label.text = _rich_content(GameState.fill_placeholders(content))
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


func _rich_content(text: String) -> String:
	# Authoring remains Ink <link="id">word</link>; escape literal BBCode brackets.
	text = text.replace("[", "[lb]")
	return RegEx.create_from_string('<link="([^\"]+)">([^<]+)</link>').sub(text, '[url=$1][u]$2[/u][/url]', true)

func _on_content_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		content_label.accept_event()
		# A term click collects it and stays on the same line.
		if _hovered_meta.is_empty(): _advance()

func set_feedback(kind: String) -> void:
	_feedback_kind = kind
	var frame := panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	frame.border_color = Color(1.0, 0.8, 0.35, 0.95) if kind == "hidden" else Color(0.92, 0.89, 0.82, 0.45)
	frame.set_border_width_all(2 if kind == "hidden" else 1)
	panel.add_theme_stylebox_override("panel", frame)


## Use the same panel, margins, dimmer and fonts for interactive radio menus.
## Menu controls handle their own input; this is not a playing dialogue line.
func show_menu() -> void:
	_active = false
	_accept_input = false
	_typing = false
	speaker_label.hide()
	content_label.hide()
	_stop_indicator()
	dim.color = Color(0, 0, 0, dim_alpha)
	mouse_filter = Control.MOUSE_FILTER_STOP
	modulate.a = 1.0
	show()
