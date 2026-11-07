extends Control
signal tutorial_finished
signal pattern_completed(evidence_id: String)
var _button: TextureButton
var _overlay: Control
var _photo: TextureRect
var _flash: ColorRect
var _caption: Label
var _dialogue: Control
var _sound: AudioStreamPlayer
var _props: Control
var _spots: Array[Dictionary] = []
var _marks: Control
var _snapshot: ImageTexture
var _photo_day := true
var _tutorial := false
var _running := false
var _completing := false
var _capturing := false
var _elapsed := 0.0
const GROUPS := {"base": {"ids": ["base_scholar", "base_infant", "base_sun"], "evidence": "shared_family_base", "label": "Gravestone correspondence"}, "beast": {"ids": ["beast_a", "beast_b", "beast_c"], "evidence": "repeated_beast_motifs", "label": "Local repetition"}, "blessing": {"ids": ["blessing_altar", "blessing_mother", "blessing_father"], "evidence": "altar_blessing_glyph", "label": "Local repetition"}}

func _ready() -> void:
	z_index = 110
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_button = TextureButton.new()
	_button.name = "CameraButton"
	_button.texture_normal = preload("res://assets/Art/symbols/camera.svg")
	_button.ignore_texture_size = true
	_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	_button.tooltip_text = "Photograph the scene, then mark repeated details."
	add_child(_button)
	_button.pressed.connect(_on_button)
	_button.hide()
	_overlay = Control.new()
	_overlay.name = "CameraPhoto"
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)
	var back := ColorRect.new()
	back.color = Color(0.01, 0.015, 0.02, 0.96)
	back.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(back)
	_photo = TextureRect.new()
	_photo.position = Vector2(76, 68)
	_photo.size = get_viewport_rect().size - Vector2(152, 136)
	_photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_photo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var grain := ShaderMaterial.new()
	grain.shader = preload("res://shaders/camera_photo.gdshader")
	_photo.material = grain
	_overlay.add_child(_photo)
	_caption = Label.new()
	_caption.position = Vector2(76, 18)
	_caption.add_theme_font_size_override("font_size", 20)
	_overlay.add_child(_caption)
	var close := Button.new()
	close.name = "ClosePhoto"
	close.text = "Put away photo"
	close.position = Vector2(76, get_viewport_rect().size.y - 48)
	close.pressed.connect(close_photo)
	_overlay.add_child(close)
	_marks = Control.new()
	_marks.name = "PhotoMarks"
	_marks.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_marks.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(_marks)
	_marks.draw.connect(_draw_marks)
	_overlay.hide()
	_flash = ColorRect.new()
	_flash.name = "CameraFlash"
	_flash.color = Color.WHITE
	_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.z_index = 40
	_flash.hide()
	add_child(_flash)
	_dialogue = preload("res://scenes/dialogue_box.tscn").instantiate()
	_dialogue.z_index = 50
	add_child(_dialogue)
	_sound = AudioStreamPlayer.new()
	_sound.stream = preload("res://assets/audio/camera_shutter.wav")
	add_child(_sound)
	_props = Control.new()
	_props.name = "CameraCemeteryProps"
	_props.set_script(preload("res://scripts/camera_scene_props.gd"))
	get_parent().get_node("DayCemetery").add_child(_props)
	_props.visible = GameState.investigation_tutorial_completed
	if GameState.camera_tutorial_pending: play_tutorial.call_deferred()

func _process(delta: float) -> void:
	_button.disabled = not GameState.investigation_tutorial_completed or _running or GameState.radio_modal_open or GameState.camera_modal_open
	_elapsed += delta
	if _marks: _marks.queue_redraw()

func _on_button() -> void:
	if not GameState.investigation_tutorial_completed or _running: return
	if not GameState.camera_tutorial_completed: play_tutorial()
	else: take_photo(false)

func play_tutorial() -> void:
	if _running or GameState.camera_tutorial_completed: return
	_running = true
	_tutorial = true
	GameState.camera_tutorial_pending = true
	GameState.camera_modal_open = true
	_prepare()
	await get_tree().create_timer(0.9).timeout
	_dialogue.play_file("res://assets/dialogue/tutorial_camera_intro.xml")
	await _dialogue.finished
	await take_photo(true)
	_dialogue.play_file("res://assets/dialogue/tutorial_camera_connections.xml")
	await _dialogue.finished
	_caption.text = "Click the three blue-lit base segments · 0 / 3"
	await tutorial_finished

func _prepare() -> void:
	get_parent().get_node("RubbingTool").turn_off()
	get_parent().get_node("FlashlightTool").turn_off()
	get_parent().get_node("NotebookTool").rubbing_drag.cancel()
	get_parent().get_node("NotebookTool").close()
	var radio := get_parent().get_node("RadioTool")
	if radio.is_open(): radio.close()
	_props.show()

func take_photo(guided: bool = false) -> void:
	if _capturing: return
	_capturing = true
	_tutorial = guided
	GameState.camera_modal_open = true
	_prepare()
	await get_tree().create_timer(0.9).timeout
	# Capture before showing the frame/flash; none of these temporary photos become evidence.
	var hidden: Array[CanvasItem] = []
	for item in [get_parent().get_node("Toolbox"), get_parent().get_node("NotebookTool"), get_parent().get_node("RadioTool"), get_parent().get_node("Toast")]:
		if item.visible: hidden.append(item); item.hide()
	for target in get_tree().get_nodes_in_group("flashlight_targets"):
		if is_instance_valid(target.marker) and target.marker.visible: hidden.append(target.marker); target.marker.hide()
	var picture: Image
	if DisplayServer.get_name() == "headless":
		picture = Image.create(1280, 720, false, Image.FORMAT_RGBA8)
		picture.fill(Color(0.25, 0.3, 0.3))
	else:
		await RenderingServer.frame_post_draw
		picture = get_viewport().get_texture().get_image()
	for item in hidden: item.show()
	_snapshot = ImageTexture.create_from_image(picture)
	_photo.texture = _snapshot
	_photo_day = get_parent().is_day
	_sound.play()
	_flash.modulate.a = 1.0
	_flash.show()
	var flash_tween := create_tween()
	flash_tween.tween_property(_flash, "modulate:a", 0.0, 0.25)
	await flash_tween.finished
	_flash.hide()
	_overlay.show()
	_capturing = false
	_build_spots()
	_caption.text = "Field photograph · mark repeated details" if not guided else "Three tombs, one continuous base"

func _image_rect() -> Rect2:
	var scale_factor := minf(_photo.size.x / _snapshot.get_width(), _photo.size.y / _snapshot.get_height())
	var image_size := Vector2(_snapshot.get_width(), _snapshot.get_height()) * scale_factor
	return Rect2(_photo.position + (_photo.size - image_size) / 2, image_size)

func _build_spots() -> void:
	for spot in _spots:
		if is_instance_valid(spot["button"]): spot["button"].queue_free()
	_spots.clear()
	var specs: Array = [["base_scholar", "base", Rect2(440, 735, 285, 60)], ["base_infant", "base", Rect2(725, 735, 290, 60)], ["base_sun", "base", Rect2(1015, 735, 270, 60)], ["beast_a", "beast", Rect2(550, 680, 85, 70)], ["beast_b", "beast", Rect2(1100, 680, 85, 70)], ["beast_c", "beast", Rect2(1420, 550, 85, 70)]] if _photo_day else [["blessing_altar", "blessing", Rect2(895, 372, 76, 66)], ["blessing_mother", "blessing", Rect2(563, 713, 40, 40)], ["blessing_father", "blessing", Rect2(1172, 735, 50, 50)]]
	var cemetery: Control = get_parent().get_node("DayCemetery" if _photo_day else "NightCemetery")
	var image_rect := _image_rect()
	var screen_size := get_viewport_rect().size
	for spec in specs:
		var source: Rect2 = spec[2]
		var point: Vector2 = cemetery.get_global_transform() * source.position
		var dimensions: Vector2 = source.size * cemetery.scale
		var rect := Rect2(image_rect.position + point / screen_size * image_rect.size, dimensions / screen_size * image_rect.size)
		var button := Button.new()
		button.name = spec[0]
		button.flat = true
		button.mouse_default_cursor_shape = Control.CURSOR_CROSS
		button.position = rect.position
		button.size = rect.size
		for state in ["normal", "hover", "pressed", "focus"]: button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
		button.pressed.connect(_select_spot.bind(spec[0]), CONNECT_DEFERRED)
		_overlay.add_child(button)
		_spots.append({"id": spec[0], "group": spec[1], "rect": rect, "button": button})

func _select_spot(id: String) -> void:
	if not _overlay.visible or _dialogue.is_playing() or _completing: return
	var chosen: Dictionary = {}
	for spot in _spots:
		if spot["id"] == id: chosen = spot; break
	if chosen.is_empty() or (_tutorial and chosen["group"] != "base"): return
	var group: String = chosen["group"]
	var selections: Array = GameState.camera_observations.get(group, [])
	if not selections.has(id): selections.append(id)
	GameState.camera_observations[group] = selections
	var rule: Dictionary = GROUPS[group]
	var complete := true
	for required in rule["ids"]:
		if not selections.has(required): complete = false
	_caption.text = GameState.zh_text("Marked %d / %d matching details") % [selections.size(), rule["ids"].size()]
	if complete:
		GameState.record_evidence(rule["evidence"])
		_caption.text = GameState.zh_text(rule["label"]) + " · " + GameState.get_evidence(rule["evidence"]).get("title", "")
		pattern_completed.emit(rule["evidence"])
		if _tutorial: _finish_tutorial()

func _draw_marks() -> void:
	if not _overlay or not _overlay.visible: return
	for spot in _spots:
		var selected: bool = spot["id"] in GameState.camera_observations.get(spot["group"], [])
		if selected or (_tutorial and spot["group"] == "base"):
			var alpha := 0.45 + 0.25 * sin(_elapsed * 3.2)
			var color := Color(0.3, 0.78, 1.0, alpha) if not selected else Color(0.6, 0.92, 0.84, 0.95)
			_marks.draw_rect(spot["rect"].grow(3), color, false, 2.5)
			_marks.draw_circle(spot["rect"].get_center(), 5 + 2 * sin(_elapsed * 3), color)

func _finish_tutorial() -> void:
	_completing = true
	await get_tree().create_timer(0.3).timeout
	_dialogue.play_file("res://assets/dialogue/tutorial_camera_outro.xml")
	await _dialogue.finished
	_tutorial = false
	_running = false
	_completing = false
	GameState.camera_tutorial_completed = true
	GameState.formal_investigation_started = true
	GameState.camera_tutorial_pending = false
	close_photo()
	tutorial_finished.emit()

func close_photo() -> void:
	if _tutorial or _capturing: return
	_overlay.hide()
	GameState.camera_modal_open = false

func _unhandled_key_input(event: InputEvent) -> void:
	if GameState.camera_modal_open and event.is_action_pressed("ui_cancel"):
		close_photo()
		get_viewport().set_input_as_handled()
