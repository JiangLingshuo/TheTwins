extends Control

const DAY := preload("res://assets/Art/day/BG_day.png")
const NIGHT := preload("res://assets/Art/night/BG_night.png")
const STONE := preload("res://assets/Art/day/草稿/girl.png")
const COVER := preload("res://assets/Art/note/notebook_cover.png")
const CHOICE_ART := preload("res://assets/Art/dialog/dialog box.png")
const RADIO_STATIC := preload("res://shaders/radio_static.gdshader")
const DIALOGUE := preload("res://scenes/dialogue_box.tscn")

@export_multiline var credits_text := ""

var _model = preload("res://scripts/radio_model.gd").new()
var _night: TextureRect
var _stone: TextureButton
var _dialogue: Control
var _choices: CenterContainer
var _options: VBoxContainer
var _is_night := false

func _ready() -> void:
	_background(DAY)
	_night = _background(NIGHT)
	_night.modulate.a = 0.0

	_stone = TextureButton.new()
	_stone.texture_normal = STONE
	_stone.ignore_texture_size = true
	_stone.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	_stone.tooltip_text = "Inspect the solitary marker"
	_stone.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	add_child(_stone)
	_stone.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_stone.offset_left = -128
	_stone.offset_right = 128
	_stone.offset_top = -150
	_stone.offset_bottom = 145
	_stone.hide()

	_dialogue = DIALOGUE.instantiate()
	add_child(_dialogue)
	_choices = CenterContainer.new()
	_choices.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_choices)
	_choices.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_options = VBoxContainer.new()
	_options.add_theme_constant_override("separation", 14)
	_choices.add_child(_options)
	_choices.hide()

	if GameState.ending_true:
		_discover_marker.call_deferred()
	else:
		_play_result.call_deferred(_model.begin_ending(false, GameState.ending_preview))

func _background(texture: Texture2D) -> TextureRect:
	var image := TextureRect.new()
	image.texture = texture
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(image)
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return image

func _discover_marker() -> void:
	var cover := TextureRect.new()
	cover.texture = COVER
	cover.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cover.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cover)
	move_child(cover, _dialogue.get_index())
	cover.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	cover.offset_left = -110
	cover.offset_right = 110
	cover.offset_top = -170
	cover.offset_bottom = 105
	var intro: Array[Dictionary] = [
		{"speaker": "", "content": "(The report is on its way. You close the notebook and look at the figure on its cover.)"},
		{"speaker": "", "content": "(You take the path back through the cemetery. Just off it, a stone stands alone. There is something familiar about the way the figure is framed.)"}
	]
	_dialogue.play(intro)
	await _dialogue.finished
	cover.queue_free()
	_stone.show()
	_stone.modulate.a = 0
	await create_tween().tween_property(_stone, "modulate:a", 1.0, 0.6).finished
	_stone.grab_focus()
	await _stone.pressed
	_stone.disabled = true
	var discovery: Array[Dictionary] = [{"speaker": "", "content": "(The figure on the cover. You turn the notebook over in your hands. Aurora gave it to you before you ever set foot here.)"}]
	_dialogue.play(discovery)
	await _dialogue.finished
	_play_result(_model.begin_ending(true, GameState.ending_preview))

func _play_result(result: Dictionary) -> void:
	_choices.hide()
	if result.get("city") == "night" and not _is_night:
		_is_night = true
		await create_tween().tween_property(_night, "modulate:a", 1.0, 0.75).finished
	var lines: Array[Dictionary] = []
	lines.assign(result.get("lines", []))
	if not lines.is_empty():
		_dialogue.play(lines)
		await _dialogue.finished
	var choices: Array = result.get("choices", [])
	_clear_choices()
	for choice in choices:
		_add_choice(choice["label"], func() -> void:
			_choices.hide()
			_play_result(_model.choose(choice)))
	if choices.is_empty():
		await _play_credits()
		return
	_choices.show()

func _play_credits() -> void:
	var curtain := ColorRect.new()
	curtain.color = Color.BLACK
	curtain.modulate.a = 0.0
	add_child(curtain)
	curtain.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await create_tween().tween_property(curtain, "modulate:a", 1.0, 1.6).finished

	var heading := Label.new()
	heading.name = "CreditsHeading"
	heading.text = GameState.zh_text("Credits")
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 36)
	heading.modulate.a = 0.0
	curtain.add_child(heading)
	heading.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await create_tween().tween_property(heading, "modulate:a", 1.0, 0.65).finished
	if credits_text.strip_edges().is_empty():
		return

	await get_tree().create_timer(1.2).timeout
	await create_tween().tween_property(heading, "modulate:a", 0.0, 0.5).finished
	var names := Label.new()
	names.text = credits_text
	names.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	names.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	names.add_theme_font_size_override("font_size", 27)
	curtain.add_child(names)
	names.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	names.offset_left = 48
	names.offset_right = -48
	names.position.y = curtain.size.y
	await get_tree().process_frame
	var distance := curtain.size.y + names.size.y
	await create_tween().tween_property(names, "position:y", -names.size.y, distance / 50.0).finished
	names.hide()

func _clear_choices() -> void:
	for child in _options.get_children():
		_options.remove_child(child)
		child.queue_free()

func _add_choice(text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = GameState.zh_text(text)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.custom_minimum_size = Vector2(minf(680.0, get_viewport_rect().size.x * 0.76), 70)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 23)
	var panel := StyleBoxEmpty.new()
	panel.set_content_margin_all(13.0)
	var backdrop := ColorRect.new()
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.show_behind_parent = true
	var material := ShaderMaterial.new()
	material.shader = RADIO_STATIC
	material.set_shader_parameter("choice_panel", true)
	material.set_shader_parameter("choice_art", CHOICE_ART)
	var normal_color := Color(0.012, 0.014, 0.02)
	var hover_color := Color("#55565d")
	button.mouse_entered.connect(func() -> void:
		material.set_shader_parameter("base_color", hover_color))
	button.mouse_exited.connect(func() -> void:
		material.set_shader_parameter("base_color", normal_color))
	backdrop.material = material
	button.add_child(backdrop)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.resized.connect(func() -> void:
		material.set_shader_parameter("panel_size", backdrop.size))
	material.set_shader_parameter("panel_size", backdrop.size)
	button.add_theme_color_override("font_color", Color("#f4ead6"))
	button.add_theme_color_override("font_hover_color", Color("#ffd795"))
	button.add_theme_color_override("font_pressed_color", Color("#ffd795"))
	button.add_theme_stylebox_override("normal", panel)
	button.add_theme_stylebox_override("hover", panel)
	button.add_theme_stylebox_override("pressed", panel)
	button.add_theme_color_override("font_focus_color", Color("#ffd795"))
	button.add_theme_stylebox_override("focus", panel)
	button.pressed.connect(action)
	_options.add_child(button)
