extends Control
## Reusable visual-novel style dialogue box.
## Call play_file("res://...xml") or play(lines); it emits `finished` after the last line.
## Text is revealed one character at a time. "#PLAYER#" (or "{name}") is replaced with the player's name.
##
## Controls: Space / Enter / left click
##   - while text is typing: show the whole line at once
##   - when the line is finished: go to the next line

signal line_started(line: Dictionary)
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
## Strength of the animated radio static behind the text (0 = plain dark panel).
## Finer settings are uniforms on Panel/RadioStatic's material (shaders/radio_static.gdshader).
@export_range(0.0, 2.0, 0.05) var static_intensity: float = 1.0:
	set(value):
		static_intensity = value
		if is_node_ready():
			_apply_static_intensity()
## Frame drawn around the panel; transparent by default so the soft edges show.
@export var frame_color: Color = Color(0.92, 0.89, 0.82, 0.0)
## Frame shown when a reply is marked "hidden" (radio feedback).
@export var hidden_frame_color: Color = Color(1.0, 0.8, 0.35, 0.7)
## Speaker whose lines bring in the Portrait (compared ignoring case).
@export var portrait_speaker: String = "Aurora"
## Seconds for the portrait to fade in / out.
@export var portrait_fade_time: float = 0.35
## Invert the portrait's colours when the screen behind it is dark.
@export var portrait_auto_invert: bool = true
## Below this brightness (0–1, measured without the Dim layer) the background counts as dark.
@export_range(0.0, 1.0, 0.05) var dark_background_threshold: float = 0.35

const PAUSE_CHARS := ".,!?;:…—"

@onready var dim: ColorRect = $Dim
@onready var panel: PanelContainer = $Panel
@onready var speaker_label: Label = $Panel/Margin/VBox/SpeakerLabel
@onready var content_label: RichTextLabel = $Panel/Margin/VBox/ContentLabel
@onready var continue_indicator: Label = $Panel/Margin/ContinueIndicator
@onready var portrait: TextureRect = $Portrait

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
var _term_notice: Label
var _term_notice_tween: Tween
var _portrait_tween: Tween
var _radio_noise: AudioStreamPlayer
## One-shot sounds a line can ask for: "sfx" as it starts, "sfx_after" when the
## player moves past it (or the dialogue closes). Authored in the dialogue text.
const CUES := {
	"busy": {"stream": preload("res://assets/audio/忙音.wav"), "volume_db": -4.0},
	# A long quiet recording of wind in grass: only the start is used, faded out.
	"wind": {"stream": preload("res://assets/audio/风声.mp3"), "volume_db": -17.0, "seconds": 14.0, "fade": 3.0},
	"hangup": {"stream": preload("res://assets/audio/无线电挂断.wav"), "volume_db": 0.0},
}
var _cue_player: AudioStreamPlayer
var _cue_tween: Tween


func _ready() -> void:
	if GameState.chinese_playtest:
		speaker_label.add_theme_font_override("font", GameState.playtest_font(speaker_label.get_theme_font("font")))
		content_label.add_theme_font_override("normal_font", GameState.playtest_font(content_label.get_theme_font("normal_font")))
	var noise: AudioStreamMP3 = preload("res://assets/audio/雪花噪音.mp3").duplicate()
	noise.loop = true
	_radio_noise = AudioStreamPlayer.new()
	_radio_noise.stream = noise
	_radio_noise.volume_db = -20.0
	add_child(_radio_noise)
	_cue_player = AudioStreamPlayer.new()
	add_child(_cue_player)
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	continue_indicator.visible = false
	_apply_static_intensity()
	content_label.meta_clicked.connect(_on_term_clicked)
	_term_notice = Label.new()
	_term_notice.name = "TermNotice"
	_term_notice.add_theme_font_override("font", content_label.get_theme_font("normal_font"))
	_term_notice.add_theme_font_size_override("font_size", 20)
	_term_notice.add_theme_color_override("font_color", Color("e1b3b5"))
	_term_notice.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.get_node("Margin/VBox").add_child(_term_notice)
	_term_notice.hide()
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
	if is_instance_valid(_term_notice): _term_notice.hide()
	_log_session = log_session
	# Logged dialogue is also kept in the radio history. Radio replies open their
	# exchange themselves (with their question), everything else is a transmission.
	if not log_session.is_empty() and not log_session.begins_with("radio:") \
			and not GameState.has_radio_exchange(log_session):
		GameState.begin_radio_exchange(log_session, {}, _transmission_title(log_session))
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


func _play_cue(cue: String) -> void:
	if not CUES.has(cue):
		return
	var spec: Dictionary = CUES[cue]
	if _cue_tween:
		_cue_tween.kill()
	_cue_player.stream = spec["stream"]
	_cue_player.volume_db = spec["volume_db"]
	_cue_player.play()
	if spec.has("seconds"):
		var fade: float = spec.get("fade", 2.0)
		_cue_tween = create_tween()
		_cue_tween.tween_interval(maxf(0.0, spec["seconds"] - fade))
		_cue_tween.tween_property(_cue_player, "volume_db", -60.0, fade)
		_cue_tween.tween_callback(_cue_player.stop)


func _next_line() -> void:
	if _index >= 0 and _index < _lines.size() and _lines[_index].has("sfx_after"):
		_play_cue(_lines[_index]["sfx_after"])
	_index += 1
	if _index >= _lines.size():
		_close()
		return

	var line := _lines[_index]
	if line.has("sfx"):
		_play_cue(line["sfx"])
	var speaker: String = line["speaker"]
	var content: String = line["content"]
	var log_line: Dictionary = line.duplicate()
	log_line.erase("sfx")
	log_line.erase("sfx_after")
	log_line["content"] = RegEx.create_from_string('<link="[^"]+">([^<]+)</link>').sub(content, "$1", true)
	GameState.append_radio_line(_log_session, log_line)
	speaker_label.text = GameState.fill_placeholders(speaker)
	speaker_label.visible = not speaker.is_empty()
	var aurora_speaking := speaker.strip_edges().to_lower() == portrait_speaker.to_lower()
	_show_portrait(aurora_speaking)
	if aurora_speaking:
		if not _radio_noise.playing: _radio_noise.play()
	else:
		# Narration and player lines should not carry an endless static bed.
		_radio_noise.stop()
	_hovered_meta = ""
	content_label.text = _rich_content(GameState.fill_placeholders(content))
	content_label.visible_characters = 0

	_stop_indicator()
	_char_timer = 0.0
	_typing = true
	line_started.emit(line)


func _finish_line() -> void:
	_typing = false
	content_label.visible_characters = -1
	_start_indicator()


func _close() -> void:
	_accept_input = false
	_stop_indicator()
	_show_portrait(false)
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, fade_time)
	await t.finished
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_active = false
	_radio_noise.stop()
	GameState.end_radio_exchange(_log_session)
	finished.emit()


## Title of a non-question transmission, from its log session (the XML file name).
static func _transmission_title(session: String) -> String:
	return "Opening Call" if session == "opening" else session.capitalize()


## Fade the portrait in while its speaker talks and out for everyone else.
func _show_portrait(shown: bool) -> void:
	# Pick the colours as it appears, while the portrait isn't on screen yet.
	if shown and portrait.modulate.a < 0.01 and portrait.material is ShaderMaterial:
		var dark := portrait_auto_invert and _background_brightness() < dark_background_threshold
		(portrait.material as ShaderMaterial).set_shader_parameter("invert", 1.0 if dark else 0.0)
	if _portrait_tween:
		_portrait_tween.kill()
	_portrait_tween = create_tween()
	_portrait_tween.tween_property(portrait, "modulate:a", 1.0 if shown else 0.0, portrait_fade_time) \
		.set_trans(Tween.TRANS_SINE)


## Average brightness (0–1) of the last rendered frame behind the portrait,
## above the text panel and with the Dim layer taken out. 1.0 if it can't be read.
func _background_brightness() -> float:
	if DisplayServer.get_name() == "headless":
		return 1.0  # nothing is rendered, so there is no frame to read
	var frame := get_viewport().get_texture().get_image()
	if frame == null or frame.is_empty():
		return 1.0
	var area := portrait.get_global_rect()
	area.end.y = minf(area.end.y, panel.get_global_rect().position.y)
	var to_pixels := Vector2(frame.get_size()) / get_viewport_rect().size
	var region := Rect2i(Rect2(area.position * to_pixels, area.size * to_pixels)) \
		.intersection(Rect2i(Vector2i.ZERO, frame.get_size()))
	if region.size.x <= 0 or region.size.y <= 0:
		return 1.0
	var sample := frame.get_region(region)
	sample.resize(16, 16, Image.INTERPOLATE_BILINEAR)
	var total := 0.0
	for y in 16:
		for x in 16:
			total += sample.get_pixel(x, y).get_luminance()
	var undimmed := 1.0 - (dim.color.a if dim.visible else 0.0)
	return total / 256.0 / maxf(undimmed, 0.05)


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
	return RegEx.create_from_string('<link="([^\"]+)">([^<]+)</link>').sub(text, '[url=$1][color=#d18b8e][u]$2[/u][/color][/url]', true)

func _on_content_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		content_label.accept_event()
		# A term click collects it and stays on the same line.
		if _hovered_meta.is_empty(): _advance()
		else: _on_term_clicked(_hovered_meta)

func set_feedback(kind: String) -> void:
	_feedback_kind = kind
	var frame := panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	frame.border_color = hidden_frame_color if kind == "hidden" else frame_color
	frame.set_border_width_all(2 if kind == "hidden" else 0)
	panel.add_theme_stylebox_override("panel", frame)


func _apply_static_intensity() -> void:
	var static_rect := panel.get_node_or_null("RadioStatic") as Control
	if static_rect and static_rect.material is ShaderMaterial:
		var mat := static_rect.material as ShaderMaterial
		mat.set_shader_parameter("intensity", static_intensity)
		mat.set_shader_parameter("panel_size", static_rect.size)
		# The shader grows the band from the panel's size, so keep it current.
		if not static_rect.resized.is_connected(_apply_static_intensity):
			static_rect.resized.connect(_apply_static_intensity)


## Use the same panel, margins, dimmer and fonts for interactive radio menus.
## Menu controls handle their own input; this is not a playing dialogue line.
func show_menu() -> void:
	_radio_noise.stop()
	_active = false
	_accept_input = false
	_typing = false
	speaker_label.hide()
	content_label.hide()
	_stop_indicator()
	_show_portrait(false)
	dim.color = Color(0, 0, 0, dim_alpha)
	mouse_filter = Control.MOUSE_FILTER_STOP
	modulate.a = 1.0
	show()


func _on_term_clicked(meta: Variant) -> void:
	var id := str(meta)
	term_selected.emit(id)
	var text := id
	for match in RegEx.create_from_string('<link="([^\"]+)">([^<]+)</link>').search_all(GameState.zh_text(_lines[_index].get("content", "")) if _index >= 0 else ""):
		if match.get_string(1) == id: text = match.get_string(2)
	_term_notice.text = GameState.zh_text("✓ Recorded: %s") % text
	_term_notice.show()
	_term_notice.modulate.a = 1.0
	if _term_notice_tween: _term_notice_tween.kill()
	_term_notice_tween = create_tween()
	_term_notice_tween.tween_interval(2.0)
	_term_notice_tween.tween_property(_term_notice, "modulate:a", 0.0, 0.4)
