extends Control
## Title / start screen: black background with a softly pulsing prompt.
## The start input plays the silent epigraph before the music and book.
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
@onready var epigraph: Control = $Epigraph
@onready var book: Control = $Book
@onready var dialogue_box: Control = $DialogueBox

var _started := false
var _dialogue_played := false
var _fade_in: Tween
var _pulse: Tween
var _save_menu: CenterContainer


func _ready() -> void:
	if GameState.has_autosave():
		_show_save_menu()
	prompt.modulate.a = 0.0
	_fade_in = create_tween()
	_fade_in.tween_property(prompt, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE)
	_fade_in.finished.connect(_start_pulse)
	book.page_changed.connect(_on_page_changed)
	book.closed.connect(_on_book_closed)
	# Stow the book where the game's notebook button is, so the next scene picks up from it.
	var screen := get_viewport_rect().size
	book.icon_margin = screen - preload("res://scripts/notebook_tool.gd").button_center(screen)


func _show_save_menu() -> void:
	prompt.hide()
	_save_menu = CenterContainer.new()
	add_child(_save_menu)
	_save_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var buttons := VBoxContainer.new()
	buttons.add_theme_constant_override("separation", 12)
	_save_menu.add_child(buttons)
	var resume := _make_choice_button("继续调查" if GameState.chinese_playtest else "Continue", _continue_game)
	buttons.add_child(resume)
	var restart := _make_choice_button("开始新调查" if GameState.chinese_playtest else "New Game", _start_game)
	buttons.add_child(restart)
	resume.grab_focus()


## Same soft-edged, grainy choice box as the dialogue choices (see ending.gd),
## but a white box with black text so it stands out against the black background.
func _make_choice_button(text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(320, 70)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", preload("res://assets/fonts/IMFellEnglish-Regular.ttf"))
	button.add_theme_font_size_override("font_size", 23)
	var panel := StyleBoxEmpty.new()
	panel.set_content_margin_all(13.0)
	var backdrop := ColorRect.new()
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.show_behind_parent = true
	var material := ShaderMaterial.new()
	material.shader = preload("res://shaders/radio_static.gdshader")
	material.set_shader_parameter("choice_panel", true)
	material.set_shader_parameter("choice_art", preload("res://assets/Art/dialog/dialog box.png"))
	var normal_color := Color(0.96, 0.96, 0.95)
	var hover_color := Color(0.78, 0.78, 0.77)
	material.set_shader_parameter("base_color", normal_color)
	material.set_shader_parameter("body_alpha", 1.0)
	material.set_shader_parameter("bottom_alpha", 1.0)
	# Dark grain on the white box (the default grain is light, invisible on white).
	material.set_shader_parameter("noise_color", Color(0.25, 0.25, 0.25))
	button.mouse_entered.connect(func() -> void: material.set_shader_parameter("base_color", hover_color))
	button.mouse_exited.connect(func() -> void: material.set_shader_parameter("base_color", normal_color))
	button.focus_entered.connect(func() -> void: material.set_shader_parameter("base_color", hover_color))
	button.focus_exited.connect(func() -> void: material.set_shader_parameter("base_color", normal_color))
	backdrop.material = material
	button.add_child(backdrop)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.resized.connect(func() -> void: material.set_shader_parameter("panel_size", backdrop.size))
	material.set_shader_parameter("panel_size", backdrop.size)
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		button.add_theme_color_override(color_name, Color.BLACK)
	for style_name in ["normal", "hover", "pressed", "focus"]:
		button.add_theme_stylebox_override(style_name, panel)
	button.pressed.connect(action)
	return button

func _continue_game() -> void:
	if _started: return
	var scene := GameState.load_autosave()
	if scene.is_empty():
		_start_game()
		return
	_started = true
	Music.play_bgm()
	get_tree().change_scene_to_file.call_deferred(scene)

func _start_pulse() -> void:
	if _started:
		return
	_pulse = create_tween().set_loops()
	_pulse.tween_property(prompt, "modulate:a", 0.35, 1.4).set_trans(Tween.TRANS_SINE)
	_pulse.tween_property(prompt, "modulate:a", 1.0, 1.4).set_trans(Tween.TRANS_SINE)


func _unhandled_input(event: InputEvent) -> void:
	if _started or is_instance_valid(_save_menu) or event.is_echo() or not event.is_pressed():
		return
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		get_viewport().set_input_as_handled()
		_start_game()


func _start_game() -> void:
	if _started:
		return
	_started = true
	if is_instance_valid(_save_menu): _save_menu.hide()
	GameState.start_new_investigation()
	Music.stop_bgm(0.0)
	_fade_in.kill()
	if _pulse:
		_pulse.kill()
	var fade_prompt := create_tween()
	fade_prompt.tween_property(prompt, "modulate:a", 0.0, 0.4)
	await fade_prompt.finished
	prompt.hide()

	epigraph.modulate.a = 0.0
	epigraph.show()
	var show_quote := create_tween().set_trans(Tween.TRANS_SINE)
	show_quote.tween_property(epigraph, "modulate:a", 1.0, 0.7)
	show_quote.tween_interval(6.5)
	show_quote.tween_property(epigraph, "modulate:a", 0.0, 0.9)
	await show_quote.finished
	epigraph.hide()
	Music.play_bgm()
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
	# Everything fades except the stowed book: the next scene's notebook button
	# sits in the same spot and looks the same, so it carries straight over.
	var fade := create_tween().set_parallel(true)
	for child in get_children():
		if child != book and child is CanvasItem:
			fade.tween_property(child, "modulate:a", 0.0, scene_fade_time)
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
