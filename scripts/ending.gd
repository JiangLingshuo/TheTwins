extends Control

const DAY := preload("res://assets/Art/day/BG_day.png")
const NIGHT := preload("res://assets/Art/night/BG_night.png")
const STONE := preload("res://assets/Art/tombstone/girl_day_scene.png")
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
	# Use the same full-scene art layer and placement as the solitary investigation.
	_stone.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
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

	if GameState.solitary_report_preview:
		_discover_marker.call_deferred()
	elif GameState.ending_true:
		if GameState.ending_marker_investigated or (not GameState.ending_preview and "girl_tomb" in GameState.gravestones):
			_stone.show()
			_stone.disabled = true
			_play_result.call_deferred(_model.begin_ending(true, GameState.ending_preview))
		else:
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
	cover.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	var art := AtlasTexture.new()
	art.atlas = COVER
	var image := COVER.get_image()
	if image.is_compressed(): image.decompress()
	art.region = Rect2(image.get_used_rect())
	cover.texture = art
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
	if GameState.solitary_report_preview:
		intro.assign(_model.begin_report_walk().get("lines", []))
	var reveal_at := -1
	if GameState.solitary_report_preview:
		for i in intro.size():
			if str(intro[i].get("content", "")).to_lower().contains("extends to a single"):
				reveal_at = i
				break
	if reveal_at > 0:
		# Finish the reflection on the book, then reveal the marker before its line.
		var before: Array[Dictionary] = []
		before.assign(intro.slice(0, reveal_at))
		_dialogue.play(before)
		await _dialogue.finished
		await _reveal_marker_scene(cover)
		var after: Array[Dictionary] = []
		after.assign(intro.slice(reveal_at))
		_dialogue.play(after)
		await _dialogue.finished
	else:
		_dialogue.play(intro)
		await _dialogue.finished
		await _reveal_marker_scene(cover)
	cover.queue_free()
	_stone.disabled = false
	_stone.grab_focus()
	await _stone.pressed
	_stone.disabled = true
	if GameState.solitary_report_preview:
		# The real route finds the marker for good before investigating it.
		if not GameState.ending_preview:
			GameState.record_gravestone("girl_tomb")
		GameState.open_solitary_investigation(false, not GameState.ending_preview)
		return
	if not GameState.ending_preview:
		GameState.record_gravestone("girl_tomb")
	var discovery: Array[Dictionary] = [{"speaker": "", "content": "(The figure on the cover. You turn the notebook over in your hands. Aurora gave it to you before you ever set foot here.)"}]
	_dialogue.play(discovery)
	await _dialogue.finished
	_play_result(_model.begin_ending(true, GameState.ending_preview))

func _reveal_marker_scene(cover: Control) -> void:
	_stone.disabled = true
	_stone.modulate.a = 0.0
	_stone.show()
	var transition := create_tween().set_parallel(true)
	transition.tween_property(cover, "modulate:a", 0.0, 0.45).set_trans(Tween.TRANS_SINE)
	transition.tween_property(cover, "position:y", cover.position.y + 28.0, 0.45).set_trans(Tween.TRANS_SINE)
	transition.tween_property(_stone, "modulate:a", 1.0, 0.85).set_delay(0.2).set_trans(Tween.TRANS_SINE)
	await transition.finished
	cover.hide()

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
	button.add_theme_font_override("font", GameState.playtest_font(preload("res://assets/fonts/IMFellEnglish-Regular.ttf")))
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
