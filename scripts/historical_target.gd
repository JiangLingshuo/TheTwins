extends "res://scripts/decipher_target.gd"
## Text layout proxy. Acquisition still requires the lamp, the correct year and a stable aim.
## Historical objects persist after discovery so notebook drag/drop can reach them.
@export var evidence_id := ""
@export var years_ago := 50.0
@export var caption := "Historical trace"
@export var scan_years: Array[float] = []
@export var required_grave := ""
@export var date_status := ""
@export var extra_aim_rect := Rect2()
var discovered := false
var exposure := 0.0
var _sample := -1
var label: Label
var marker: PanelContainer

func _ready() -> void:
	super._ready()
	add_to_group("flashlight_targets")
	marker = PanelContainer.new()
	marker.name = name + "Placeholder"
	marker.position = position
	marker.size = Vector2(310, 110)
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var frame := StyleBoxFlat.new()
	frame.bg_color = Color(0.04, 0.09, 0.12, 0.84)
	frame.border_color = Color(0.65, 0.76, 0.73, 0.8)
	frame.set_border_width_all(1)
	frame.set_content_margin_all(8)
	marker.add_theme_stylebox_override("panel", frame)
	get_parent().add_child.call_deferred(marker)
	# The cards are a development overlay (F2).
	marker.visible = GameState.debug_overlay
	GameState.debug_overlay_changed.connect(func(shown: bool) -> void: marker.visible = shown)
	label = Label.new()
	label.custom_minimum_size.x = 294
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color(0.96, 0.94, 0.83))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marker.add_child(label)
	discovered = GameState.evidence_ids.has(evidence_id)
	visible = discovered
	modulate.a = 0.8
	_update_label()

func _unlocked() -> bool:
	return required_grave.is_empty() or required_grave in GameState.gravestones

func _update_label() -> void:
	if not is_instance_valid(label): return
	var date := GameState.zh_text("%d · %d years ago") % [int(2050 - years_ago), int(years_ago)]
	if not scan_years.is_empty():
		date = GameState.zh_text("2005–2050 · scan 45 and 0 years ago")
	if date_status == "provisional_ancient_date": date += " · " + GameState.zh_text("provisional")
	var status := "Recorded" if discovered else "Searchlight placeholder"
	if not _unlocked(): status = "Locked: record the girl's marker first"
	elif not scan_years.is_empty() and not discovered:
		var checked: Array = GameState.searchlight_scan_progress.get(evidence_id, [])
		status = GameState.zh_text("Scan endpoints: %d/%d") % [checked.size(), scan_years.size()]
	label.text = GameState.zh_text(caption) + "\n" + date + "\n" + GameState.zh_text(status)

func apply_flashlight(lamp: Flashlight) -> void:
	_update_label()
	if discovered: return
	var point := lamp._locked_global_point if lamp.beam_locked else get_global_mouse_position()
	var illuminated: bool = lamp.active and get_parent().is_visible_in_tree() and _unlocked()
	# Use the text card's area as the aim target so adjacent same-year cards do not auto-collect.
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
			_update_label()
			return
	discovered = true
	modulate.a = 1.0
	if GameState.record_evidence(evidence_id):
		GameState.write_autosave()
	_update_label()
	_toast(GameState.zh_text("Recorded: %s") % GameState.zh_text(caption))

func _toast(message: String) -> void:
	var main := get_parent().get_parent()
	if main.has_node("Toast"): main.get_node("Toast").show_message(message)

func contains_point(point: Vector2) -> bool:
	return discovered and scan_years.is_empty() and super.contains_point(point)
