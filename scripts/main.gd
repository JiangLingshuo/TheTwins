extends Control
## Main game scene with a day/night switch.
## Day shows the yellow Day City background, night the blue Night City one,
## with a short cross-fade between them.
##
## From other scripts: set_day(), set_night(), toggle_time(), or set `is_day`.
## While testing, press the `toggle_key` (F1 by default, a debug key) to switch.

## Emitted after the time of day changes.
signal time_changed(is_day: bool)

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
		if is_node_ready():
			# The bell rings A#. Going to night it drops a semitone to A; going back to
			# day it rises two semitones to C (the music sits in D minor: A, F, C, D).
			_church_bell.pitch_scale = pow(2.0, (2.0 if is_day else -1.0) / 12.0)
			_church_bell.play()
		GameState.current_city_day = is_day
		time_changed.emit(is_day)

var _fade: Tween
## Church bell that tolls whenever day and night swap.
var _church_bell := AudioStreamPlayer.new()
var _submit_report: Button


func _ready() -> void:
	_church_bell.stream = preload("res://assets/audio/教堂钟声.wav")
	_church_bell.volume_db = -22.0
	add_child(_church_bell)
	is_day = GameState.current_city_day if GameState.resume_saved_city else start_time == 0
	GameState.resume_saved_city = false
	GameState.current_city_day = is_day
	_add_investigation_targets()
	# Show the starting background straight away, without cross-fading.
	_night_background.modulate.a = 0.0 if is_day else 1.0
	_fade_in_from_black()
	_day_cemetery.visible = is_day
	_night_cemetery.visible = not is_day
	time_changed.connect(func(day: bool) -> void:
		_day_cemetery.visible = day
		_night_cemetery.visible = not day)
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
	_add_report_submission()
	# A gravestone emits `recorded` once, after it is collected.
	for gravestone in get_tree().get_nodes_in_group("gravestones"):
		gravestone.recorded.connect(func(_id: String) -> void:
			_toast.show_message(gravestone_recorded_message))


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


func _add_report_submission() -> void:
	_submit_report = Button.new()
	var submit := _submit_report
	submit.text = "Submit investigation reports"
	submit.add_theme_font_size_override("font_size", 22)
	add_child(submit)
	submit.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	submit.offset_left = 24
	submit.offset_top = -66
	submit.offset_right = 286
	submit.offset_bottom = -24
	submit.pressed.connect(func() -> void:
		if GameState.ending_report_complete():
			GameState.open_ending(GameState.ending_report_passed()))
	GameState.notebook_changed.connect(_update_report_submission)
	_update_report_submission()


func _update_report_submission() -> void:
	_submit_report.visible = GameState.investigation_tutorial_completed and GameState.ending_report_complete()


func _on_evidence_recorded(id: String) -> void:
	if id == "infant_medical_record" and not GameState.notebook_preview:
		_toast.show_message("New manuscript received from Aurora: Day City Medical Record.")
	elif GameState.is_clue(id) and not GameState.notebook_preview:
		_toast.show_message(GameState.zh_text(clue_recorded_message) % GameState.fill_placeholders(GameState.get_evidence(id).get("title", id)))


func _unhandled_key_input(event: InputEvent) -> void:
	if GameState.radio_modal_open or GameState.camera_modal_open:
		return
	if OS.is_debug_build() and event.is_pressed() and not event.is_echo() and event is InputEventKey and event.keycode == KEY_F8:
		GameState.preview_notebook_content()
		_toast.show_message("DEV: all notebook text unlocked for this session")
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
	var max_year: float = _flashlight_tool.flashlight.focus_min
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
			if spec.has("region"):
				# Part of a larger drawing, e.g. the detail that differs in a "past" version.
				var atlas := AtlasTexture.new()
				atlas.atlas = target.texture
				var r: Array = spec["region"]
				atlas.region = Rect2(r[0], r[1], r[2], r[3])
				target.texture = atlas
			elif spec.get("crop", false):
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
		for year: float in target.scan_years:
			max_year = maxf(max_year, year)
		(_day_cemetery if spec["city"] == "day" else _night_cemetery).add_child(target)
	_flashlight_tool.flashlight.focus_max = max_year
	_flashlight_tool.get_node("FocusScale").set_year_range(_flashlight_tool.flashlight.focus_min, max_year)
