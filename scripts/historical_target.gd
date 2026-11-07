extends "res://scripts/decipher_target.gd"
## A historical trace found with the lamp, the correct year and a stable aim.
## Historical objects persist after discovery so notebook drag/drop can reach them.
@export var evidence_id := ""
@export var years_ago := 50.0
@export var caption := "Historical trace"
@export var scan_years: Array[float] = []
@export var required_grave := ""
@export var date_status := ""
@export var extra_aim_rect := Rect2()
## Once found, hovering shows a magnifier that zooms the view in on it, the
## same camera move as for a tombstone (SceneZoom; its zoom-out magnifier
## brings the scene back).
@export var inspectable := false
## Height on screen when zoomed in, as a share of the screen height. Small
## finds stay small (about 20%); each one sets its own ("zoom_height" in
## searchlight_placeholders.json), roughly by its size.
@export_range(0.05, 1.0, 0.01) var zoom_height_ratio: float = 0.2
## Small objects need a closer camera than a tombstone.
@export var zoom_max_zoom: float = 12.0
## True while the view is zoomed in on this object (set by SceneZoom).
var zoomed := false
var discovered := false
var exposure := 0.0
var _sample := -1
var _inspect_button: Button
var _last_hover_msec := -100000
var _hovered := false

func _ready() -> void:
	super._ready()
	add_to_group("flashlight_targets")
	discovered = GameState.evidence_ids.has(evidence_id)
	visible = discovered
	modulate.a = 0.8
	if inspectable:
		_inspect_button = _magnifier_button(44)
		_inspect_button.tooltip_text = "Look closer"
		_inspect_button.pressed.connect(func() -> void: get_tree().call_group("scene_zoom", "zoom_to", self))
		_inspect_button.visible = false
		add_child(_inspect_button)

func _unlocked() -> bool:
	return required_grave.is_empty() or required_grave in GameState.gravestones

func apply_flashlight(lamp: Flashlight) -> void:
	if discovered: return
	var point := lamp._locked_global_point if lamp.beam_locked else get_global_mouse_position()
	var illuminated: bool = lamp.active and get_parent().is_visible_in_tree() and _unlocked()
	# Aim at the trace's scene rectangle so adjacent same-year traces do not auto-collect.
	var local_point: Vector2 = get_parent().get_global_transform().affine_inverse() * point
	illuminated = illuminated and (get_global_rect().grow(16).has_point(point) or (extra_aim_rect.has_area() and extra_aim_rect.has_point(local_point)))
	var sample := -1
	if scan_years.is_empty():
		if absf(lamp.focus - years_ago) <= lamp.perfect_tolerance: sample = 0
	else:
		for i in scan_years.size():
			if absf(lamp.focus - scan_years[i]) <= lamp.perfect_tolerance: sample = i
	if not illuminated or sample == -1:
		exposure = 0.0
		_sample = -1
		visible = false
		return
	if sample != _sample: exposure = 0.0
	_sample = sample
	exposure += get_process_delta_time()
	visible = true
	modulate.a = 0.65
	if exposure < 0.7: return
	if not scan_years.is_empty():
		var checked: Array = GameState.searchlight_scan_progress.get(evidence_id, [])
		if not checked.has(sample):
			checked.append(sample)
			GameState.searchlight_scan_progress[evidence_id] = checked
			_toast(GameState.zh_text("Scan endpoint checked: %d") % int(2050 - scan_years[sample]))
		if checked.size() < scan_years.size():
			return
	discovered = true
	modulate.a = 1.0
	if GameState.record_evidence(evidence_id):
		GameState.write_autosave()
	_toast(GameState.zh_text("Recorded: %s") % GameState.zh_text(caption))

func _toast(message: String) -> void:
	var main := get_parent().get_parent()
	if main.has_node("Toast"): main.get_node("Toast").show_message(message)

func contains_point(point: Vector2) -> bool:
	return discovered and scan_years.is_empty() and super.contains_point(point)


func _input(event: InputEvent) -> void:
	if _inspect_button and event is InputEventMouseMotion:
		var hovered := get_viewport().gui_get_hovered_control()
		var over_button := _inspect_button.visible and _inspect_button.get_global_rect().has_point(event.position)
		var over_me := get_global_rect().has_point(event.position) and (hovered == null or hovered == _inspect_button)
		_hovered = discovered and is_visible_in_tree() and (over_me or over_button)
		if _hovered:
			_last_hover_msec = Time.get_ticks_msec()


func _process(_delta: float) -> void:
	if _inspect_button == null:
		return
	var lingering := _hovered or Time.get_ticks_msec() - _last_hover_msec < 400
	var scene_zoom := get_tree().get_first_node_in_group("scene_zoom")
	var scene_zoomed: bool = scene_zoom != null and scene_zoom.is_zoomed()
	_inspect_button.visible = discovered and is_visible_in_tree() and lingering and not scene_zoomed
	if _inspect_button.visible:
		var rect := get_global_rect()
		var screen := get_viewport_rect().size
		var at := Vector2(rect.end.x + 6.0, rect.position.y - 6.0)
		at.x = clampf(at.x, 8.0, screen.x - _inspect_button.size.x - 8.0)
		at.y = clampf(at.y, 8.0, screen.y - _inspect_button.size.y - 8.0)
		_inspect_button.global_position = at


## What SceneZoom frames: the drawing's rect on screen.
func get_stone_global_rect() -> Rect2:
	return get_global_rect()


## A round + magnifier like the tombstones'.
func _magnifier_button(diameter: int) -> Button:
	var button := Button.new()
	button.top_level = true  # beside the trace, screen-sized whatever the zoom
	button.size = Vector2(diameter, diameter)
	button.custom_minimum_size = button.size
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for state in ["normal", "hover", "pressed"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.09, 0.08, 0.9 if state == "normal" else 0.97)
		style.border_color = Color(1.0, 0.9, 0.66) if state == "hover" else Color(0.86, 0.73, 0.46)
		style.set_border_width_all(2)
		style.set_corner_radius_all(diameter / 2)
		button.add_theme_stylebox_override(state, style)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	var k := diameter / 44.0
	button.draw.connect(func() -> void:
		var ink := Color(0.98, 0.94, 0.84)
		var lens := Vector2(19, 19) * k
		button.draw_arc(lens, 9.5 * k, 0, TAU, 32, ink, 2.5 * k, true)
		button.draw_line(lens + Vector2(7, 7) * k, Vector2(33, 33) * k, ink, 4.0 * k, true)
		button.draw_line(lens - Vector2(4.5 * k, 0), lens + Vector2(4.5 * k, 0), ink, 2.0 * k, true)
		button.draw_line(lens - Vector2(0, 4.5 * k), lens + Vector2(0, 4.5 * k), ink, 2.0 * k, true))
	return button
