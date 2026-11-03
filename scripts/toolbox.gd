extends Control
var button: TextureButton
var tray: PanelContainer
var _elapsed := 0.0
var _proxies: Dictionary = {}
func _ready() -> void:
	await get_tree().process_frame
	z_index = 50
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button = TextureButton.new()
	button.name = "ToolboxButton"
	button.texture_normal = preload("res://assets/Art/symbols/toolbox.svg")
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	add_child(button)
	button.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	button.offset_left = -148; button.offset_right = -36
	button.offset_top = -184; button.offset_bottom = -72
	button.tooltip_text = "Tools — rubbing, searchlight, camera"
	button.mouse_entered.connect(reveal)
	button.pressed.connect(reveal)
	tray = PanelContainer.new()
	tray.name = "ToolsTray"
	add_child(tray)
	tray.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	tray.offset_left = -258; tray.offset_right = -160
	tray.offset_top = -190; tray.offset_bottom = 74
	var frame := StyleBoxFlat.new()
	frame.bg_color = Color(0.03, 0.04, 0.045, 0.94)
	frame.border_color = Color(0.7, 0.66, 0.49)
	frame.set_border_width_all(1)
	tray.add_theme_stylebox_override("panel", frame)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	tray.add_child(column)
	for path in ["RubbingTool/RubbingButton", "FlashlightTool/FlashlightButton", "CameraTool/CameraButton"]:
		var tool: Control = get_parent().get_node(path)
		var proxy := TextureButton.new()
		proxy.name = tool.name
		proxy.texture_normal = tool.texture_normal
		proxy.ignore_texture_size = true
		proxy.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		proxy.custom_minimum_size = Vector2(84, 80)
		proxy.size_flags_vertical = Control.SIZE_EXPAND_FILL
		column.add_child(proxy)
		proxy.pressed.connect(func() -> void: tool.pressed.emit(); tray.hide())
		_proxies[tool.get_instance_id()] = {"source": tool, "button": proxy}
		tool.hide()
	tray.hide()
	var guide := get_parent().get_node_or_null("SunMoonTutorial")
	if guide: guide.refresh.call_deferred()
func reveal() -> void:
	if tray and not GameState.camera_modal_open and not GameState.radio_modal_open:
		tray.show()
		_elapsed = 0.0
func proxy_for(target: Control) -> Control:
	return _proxies.get(target.get_instance_id(), {}).get("button", target)

func reveal_for(target: Control) -> void:
	if tray and tray.is_ancestor_of(target): reveal()
func _process(delta: float) -> void:
	for record in _proxies.values():
		record["button"].disabled = record["source"].disabled
		record["button"].modulate = record["source"].modulate
		record["button"].tooltip_text = record["source"].tooltip_text
	if not tray or not tray.visible: return
	var guide := get_parent().get_node_or_null("SunMoonTutorial")
	if guide and guide.get("_highlight_target") and tray.is_ancestor_of(guide.get("_highlight_target")): return
	var region := tray.get_global_rect().merge(button.get_global_rect()).grow(14)
	_elapsed = 0.0 if region.has_point(get_global_mouse_position()) else _elapsed + delta
	if _elapsed > 0.35: tray.hide()
