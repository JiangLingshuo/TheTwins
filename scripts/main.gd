extends Control
## Main game scene with a day/night switch.
## Day shows the yellow Day City background, night the blue Night City one,
## with a short cross-fade between them.
##
## From other scripts: set_day(), set_night(), toggle_time(), or set `is_day`.
## While testing, press the `toggle_key` (F1 by default, a debug key) to switch.

## Emitted after the time of day changes.
signal time_changed(is_day: bool)
## Emitted when the view zooms in on a gravestone (`gravestone`) or back out (null).
signal zoom_changed(gravestone: Control)

## Time of day when the scene starts.
@export_enum("Day", "Night") var start_time: int = 0
## Seconds for the cross-fade between backgrounds.
@export var transition_time: float = 0.8
## Seconds to fade in from black when the scene opens.
@export var fade_in_time: float = 0.8
## Key that switches day/night (for testing). Set to KEY_NONE to disable.
@export var toggle_key: Key = KEY_F1
## Message shown when a gravestone is recorded in the notebook.
@export var gravestone_recorded_message: String = "New gravestone recorded in the Notebook."
## Message shown when a rubbing is recorded in the notebook.
@export var rubbing_recorded_message: String = "New rubbing recorded in the Notebook."
## Message shown when a rubbing dropped on its scene object is deciphered.
@export var rubbing_deciphered_message: String = "Symbol deciphered! Notebook updated."
## Message shown when a rubbing is dropped on the wrong thing.
@export var rubbing_mismatch_message: String = "This symbol doesn't seem connected to that."
## Message shown when a decipher or clue reveal is repeated.
@export var already_noted_message: String = "We have already taken note of this."
## Message shown whenever a clue is recorded; %s is the clue's title.
@export var clue_recorded_message: String = "New clue: %s has been added to the notebook."
## Seconds for zooming in on a gravestone or back out.
@export var zoom_time: float = 0.6
## Largest zoom allowed on a gravestone.
@export var max_zoom: float = 4.0

@onready var _day_background: TextureRect = $DayBackground
@onready var _night_background: TextureRect = $NightBackground
@onready var _flashlight_tool: Control = $FlashlightTool
@onready var _notebook_tool: Control = $NotebookTool
@onready var _rubbing_tool: Control = $RubbingTool
@onready var _day_cemetery: Control = $DayCemetery
@onready var _night_cemetery: Control = $NightCemetery
@onready var _toast: Control = $Toast

## True during the day, false at night.
var is_day: bool = true:
	set(value):
		if value == is_day:
			return
		is_day = value
		_fade_backgrounds()
		GameState.current_city_day = is_day
		time_changed.emit(is_day)

var _fade: Tween
## The scene layers that zoom together, with their unzoomed position and scale.
var _world_base: Array[Dictionary] = []
var _zoom := 1.0  # current view: screen = base * _zoom + _zoom_offset
var _zoom_offset := Vector2.ZERO
var _zoom_tween: Tween
var _zoomed_stone: Control


func _ready() -> void:
	is_day = start_time == 0
	GameState.current_city_day = is_day
	_add_investigation_targets()
	# Show the starting background straight away, without cross-fading.
	_night_background.modulate.a = 0.0 if is_day else 1.0
	_fade_in_from_black()
	_day_cemetery.visible = is_day
	_night_cemetery.visible = not is_day
	time_changed.connect(func(day: bool) -> void:
		_day_cemetery.visible = day
		_night_cemetery.visible = not day
		# The zoomed stone belongs to one city; switching the time shows the whole scene.
		if is_zoomed():
			zoom_out())
	# One tool at a time: picking one up puts the other away; reading the
	# notebook puts both away.
	_notebook_tool.notebook_opened.connect(_flashlight_tool.turn_off)
	_notebook_tool.notebook_opened.connect(_rubbing_tool.turn_off)
	_rubbing_tool.state_changed.connect(func(on: bool) -> void:
		if on:
			_flashlight_tool.turn_off())
	_flashlight_tool.state_changed.connect(func(state: int) -> void:
		if state != 0:
			_rubbing_tool.turn_off())
	# The rubbing tool emits `rubbing_collected` once per symbol, after it is recorded.
	_rubbing_tool.rubbing_collected.connect(func(id: String) -> void:
		# The tutorial announces the crescent itself, after Aurora's line.
		if id != "infant_moon_rubbing":
			_toast.show_message(rubbing_recorded_message))
	# Rubbings dragged from the notebook onto the scene.
	_notebook_tool.rubbing_drag.deciphered.connect(func(_id: String, _target: Control) -> void:
		_toast.show_message(rubbing_deciphered_message))
	_notebook_tool.rubbing_drag.mismatched.connect(func(_id: String, _target: Control) -> void:
		_toast.show_message(rubbing_mismatch_message))
	_notebook_tool.rubbing_drag.already_noted.connect(func(_id: String, _target: Control) -> void:
		_toast.show_message(already_noted_message))
	# Every new clue is announced (a revealed one too), queued after other messages.
	GameState.evidence_recorded.connect(_on_evidence_recorded)
	# A gravestone emits `recorded` once, after it is collected.
	for gravestone in get_tree().get_nodes_in_group("gravestones"):
		gravestone.recorded.connect(func(id: String) -> void:
			_notebook_tool.show_gravestone_next(id)
			_toast.show_message(gravestone_recorded_message))
		gravestone.zoom_requested.connect(func(stone: Control) -> void:
			if stone == _zoomed_stone:
				zoom_out()
			else:
				zoom_to(stone))
	for layer in [_day_background, _night_background, _day_cemetery, _night_cemetery]:
		_world_base.append({"node": layer, "position": layer.position, "scale": layer.scale})


## Zoom the view in so `gravestone` is centred and fills its zoom_height_ratio
## of the screen height (the view never leaves the background).
func zoom_to(gravestone: Control) -> void:
	var screen := get_viewport_rect().size
	var now: Rect2 = gravestone.get_stone_global_rect()
	var base := Rect2((now.position - _zoom_offset) / _zoom, now.size / _zoom)
	var target := clampf(screen.y * gravestone.zoom_height_ratio / base.size.y, 1.0, max_zoom)
	var offset := screen / 2.0 - base.get_center() * target
	offset = offset.clamp(screen - screen * target, Vector2.ZERO)
	if _zoomed_stone and _zoomed_stone != gravestone:
		_zoomed_stone.zoomed = false
	_zoomed_stone = gravestone
	gravestone.zoomed = true
	_tween_zoom(target, offset)
	zoom_changed.emit(gravestone)


## Zoom back out to the whole scene.
func zoom_out() -> void:
	if _zoomed_stone:
		_zoomed_stone.zoomed = false
	_zoomed_stone = null
	_tween_zoom(1.0, Vector2.ZERO)
	zoom_changed.emit(null)


func is_zoomed() -> bool:
	return _zoomed_stone != null


func _tween_zoom(target: float, offset: Vector2) -> void:
	if _zoom_tween:
		_zoom_tween.kill()
	var from_zoom := _zoom
	var from_offset := _zoom_offset
	_zoom_tween = create_tween()
	_zoom_tween.tween_method(func(t: float) -> void:
		_apply_zoom(lerpf(from_zoom, target, t), from_offset.lerp(offset, t)),
		0.0, 1.0, zoom_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _apply_zoom(zoom: float, offset: Vector2) -> void:
	_zoom = zoom
	_zoom_offset = offset
	for base in _world_base:
		base["node"].scale = base["scale"] * zoom
		base["node"].position = base["position"] * zoom + offset


func _unhandled_input(event: InputEvent) -> void:
	if is_zoomed() and event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_RIGHT:
		zoom_out()
		get_viewport().set_input_as_handled()


## Fade in from black, all but the notebook button: it shows the book the start
## screen just put away in that same spot, so it stays in view throughout.
func _fade_in_from_black() -> void:
	var black := ColorRect.new()
	black.color = Color.BLACK
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	black.z_index = 90
	add_child(black)
	black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var button: Control = _notebook_tool.get_node("NotebookButton")
	button.z_index = 91
	var t := create_tween()
	t.tween_property(black, "color:a", 0.0, fade_in_time)
	t.tween_callback(func() -> void:
		button.z_index = 0
		black.queue_free())


func _on_evidence_recorded(id: String) -> void:
	if GameState.is_clue(id) and not GameState.notebook_preview:
		_toast.show_message(clue_recorded_message % GameState.fill_placeholders(GameState.get_evidence(id).get("title", id)))


func _unhandled_key_input(event: InputEvent) -> void:
	if GameState.radio_modal_open or GameState.camera_modal_open:
		return
	if OS.is_debug_build() and event.is_pressed() and not event.is_echo() and event is InputEventKey and event.keycode == KEY_F8:
		GameState.preview_notebook_content()
		_toast.show_message("DEV: all notebook text unlocked for this session")
		get_viewport().set_input_as_handled()
		return
	if is_zoomed() and event.is_pressed() and (event as InputEventKey).keycode == KEY_ESCAPE:
		zoom_out()
		get_viewport().set_input_as_handled()
		return
	if toggle_key != KEY_NONE and event.is_pressed() and not event.is_echo() \
			and (event as InputEventKey).keycode == toggle_key:
		toggle_time()
		get_viewport().set_input_as_handled()


func set_day() -> void:
	is_day = true


func set_night() -> void:
	is_day = false


func toggle_time() -> void:
	is_day = not is_day


func _fade_backgrounds() -> void:
	if not is_node_ready():
		return
	if _fade:
		_fade.kill()
	# The night background sits on top; fading it in or out reveals the other.
	_fade = create_tween()
	_fade.tween_property(_night_background, "modulate:a", 0.0 if is_day else 1.0, transition_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## The part of `texture` that is not transparent, so drawn art fills its target box.
func _crop_to_used(texture: Texture2D) -> Texture2D:
	var image := texture.get_image()
	if image.is_compressed():
		image.decompress()
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(image.get_used_rect())
	return atlas


func _add_investigation_targets() -> void:
	# Source dates come from evidence metadata; positions are editable layout placeholders.
	var target_script = load("res://scripts/historical_target.gd")
	var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/dialogue/searchlight_placeholders.json"))
	var max_year := 50.0
	for spec in layout["records"]:
		var target = TextureRect.new()
		target.set_script(target_script)
		target.name = spec["node"]
		target.evidence_id = spec["evidence_id"]
		target.target_id = spec["target_id"]
		var metadata: Dictionary = GameState.get_evidence(spec["evidence_id"]).get("metadata", {})
		target.years_ago = float(metadata.get("searchlight_years_ago", [spec["years_ago"]])[0])
		target.position = Vector2(spec["position"][0], spec["position"][1])
		target.size = Vector2(310, 110)
		target.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		if spec.has("texture"):
			# A bare file name is a placeholder in assets/Art/symbols; finished art gives a res:// path.
			var texture_path: String = spec["texture"]
			if not texture_path.begins_with("res://"):
				texture_path = "res://assets/Art/symbols/" + texture_path
			target.texture = load(texture_path)
			if spec.get("crop", false):
				target.texture = _crop_to_used(target.texture)
		if spec.has("size"):
			target.size = Vector2(spec["size"][0], spec["size"][1])
		if spec["evidence_id"] == "infant_graffiti": target.extra_aim_rect = Rect2(760, 480, 220, 300)
		target.caption = spec["caption"]
		target.meaning = spec["meaning"]
		target.required_grave = spec.get("required_grave", "")
		target.date_status = metadata.get("searchlight_date_status", [spec.get("date_status", "")])[0]
		if metadata.has("searchlight_scan_years_ago_min"):
			target.scan_years.append(float(metadata["searchlight_scan_years_ago_min"][0]))
			target.scan_years.append(float(metadata["searchlight_scan_years_ago_max"][0]))
		max_year = maxf(max_year, target.years_ago)
		(_day_cemetery if spec["city"] == "day" else _night_cemetery).add_child(target)
	var symbol := TextureRect.new()
	symbol.set_script(load("res://scripts/rubbing_symbol.gd"))
	symbol.name = "SunMarkerSymbol"
	symbol.position = Vector2(220, 680)
	symbol.size = Vector2(100, 100)
	symbol.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	symbol.texture = load("res://assets/Art/symbol/coin&sun.png")
	symbol.rubbing_id = "sun_shaped_marker_rubbing"
	symbol.matching_target_id = "day_city_coin"
	_day_cemetery.add_child(symbol)
	_flashlight_tool.flashlight.focus_max = max_year
	_flashlight_tool.get_node("FocusScale").max_value = max_year
