extends Control
## Toolbox button on the right edge. Click it to open the tool tray; click it
## again, or anywhere outside, to close it. Choosing a tool presses that tool's
## own button (the tools keep their activation logic) and closes the tray.
## While closed, the button shows the active tool's icon with a highlight ring;
## the icon follows the tools' real state, so it never goes out of sync.

## Emitted when the tray opens (true) or closes (false). The tray starts closed.
signal tray_toggled(expanded: bool)

## Ring drawn around the active tool (collapsed button and tray entry).
const ACTIVE_RING := Color(1.0, 0.86, 0.52, 0.95)
const TOOLBOX_ICON := preload("res://assets/Art/symbols/toolbox.svg")

var button: TextureButton
var tray: PanelContainer
var _proxies: Dictionary = {}
var _active_record: Dictionary = {}
func _ready() -> void:
	await get_tree().process_frame
	# Layering comes from the node order in main.tscn: above the scene tools,
	# below the notebook, radio, camera, tutorial and dialogue boxes.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button = TextureButton.new()
	button.name = "ToolboxButton"
	button.texture_normal = TOOLBOX_ICON
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	add_child(button)
	button.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	# The three right-edge buttons (toolbox, notebook, radio) are 96 px circles
	# centred 92 px from the right edge, 120 px apart around the middle.
	button.offset_left = -140; button.offset_right = -44
	button.offset_top = -168; button.offset_bottom = -72
	button.tooltip_text = "Tools — rubbing, searchlight, camera"
	button.pressed.connect(toggle)
	button.draw.connect(func() -> void:
		if not _active_record.is_empty() and not tray.visible: _draw_ring(button))
	tray = PanelContainer.new()
	tray.name = "ToolsTray"
	add_child(tray)
	tray.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	tray.offset_left = -250; tray.offset_right = -152
	tray.offset_top = -174; tray.offset_bottom = 90
	# A soft rounded strip behind the light tool circles.
	var frame := StyleBoxFlat.new()
	frame.bg_color = Color(0.16, 0.13, 0.1, 0.32)
	frame.border_color = Color(0.66, 0.54, 0.32, 0.6)
	frame.set_border_width_all(1)
	frame.set_corner_radius_all(48)
	frame.set_content_margin_all(6)
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
		proxy.pressed.connect(func() -> void: _select(tool))
		proxy.draw.connect(func() -> void:
			if _active_record.get("source") == tool: _draw_ring(proxy))
		_proxies[tool.get_instance_id()] = {"source": tool, "button": proxy}
		tool.hide()
	collapse()
	# Opening the notebook (button, Tab / N, or scripted) closes the tray.
	# The radio has no signal; _process watches GameState.radio_modal_open.
	var notebook := get_parent().get_node_or_null("NotebookTool")
	if notebook: notebook.notebook_opened.connect(collapse)
	var guide := get_parent().get_node_or_null("SunMoonTutorial")
	if guide: guide.refresh.call_deferred()
## Open the tray (expand).
func reveal() -> void:
	var notebook := get_parent().get_node_or_null("NotebookTool")
	if notebook and notebook.is_open(): return
	if tray and not tray.visible and not GameState.camera_modal_open and not GameState.radio_modal_open:
		tray.show()
		_refresh_button()
		tray_toggled.emit(true)

## Close the tray. Never changes which tool is active.
func collapse() -> void:
	if tray and tray.visible:
		tray.hide()
		_refresh_button()
		tray_toggled.emit(false)

func toggle() -> void:
	if tray.visible: collapse()
	else: reveal()

func proxy_for(target: Control) -> Control:
	return _proxies.get(target.get_instance_id(), {}).get("button", target)

func reveal_for(target: Control) -> void:
	if tray and tray.is_ancestor_of(target): reveal()

func _select(tool: TextureButton) -> void:
	# The tool's own button toggles it; picking the active tool again puts it away.
	tool.pressed.emit()
	collapse()

func _input(event: InputEvent) -> void:
	# A press anywhere outside the tray and button closes the tray. The click
	# itself still reaches whatever is under it.
	if not tray or not tray.visible or _tutorial_holds_tray(): return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var point: Vector2 = event.position
		if not tray.get_global_rect().has_point(point) and not button.get_global_rect().has_point(point):
			collapse()

func _tutorial_holds_tray() -> bool:
	# The tutorial may point at a tool inside the tray; keep it open meanwhile.
	var guide := get_parent().get_node_or_null("SunMoonTutorial")
	var target = guide.get("_highlight_target") if guide else null
	return is_instance_valid(target) and tray.is_ancestor_of(target)

func _process(_delta: float) -> void:
	for record in _proxies.values():
		record["button"].disabled = record["source"].disabled
		record["button"].modulate = record["source"].modulate
		record["button"].tooltip_text = record["source"].tooltip_text
		# Tool icons change with their state (e.g. icon_on / icon_off).
		if record["button"].texture_normal != record["source"].texture_normal:
			record["button"].texture_normal = record["source"].texture_normal
	if tray and tray.visible and (GameState.camera_modal_open or GameState.radio_modal_open):
		collapse()
	_refresh_button()

## Show the active tool on the collapsed button; the toolbox icon otherwise.
func _refresh_button() -> void:
	if not button: return
	var active := {}
	for record in _proxies.values():
		if _is_active(record["source"].get_parent()):
			active = record
			break
	var changed: bool = active.get("source") != _active_record.get("source")
	_active_record = active
	var icon: Texture2D = TOOLBOX_ICON if active.is_empty() or tray.visible else active["source"].texture_normal
	if button.texture_normal != icon or changed:
		button.texture_normal = icon
		button.queue_redraw()
		for record in _proxies.values(): record["button"].queue_redraw()

func _is_active(tool: Node) -> bool:
	if tool.get("active") == true: return true # RubbingTool
	if tool.get("state") is int and tool.get("state") != 0: return true # FlashlightTool (AIMING or ON)
	return tool.name == "CameraTool" and GameState.camera_modal_open

func _draw_ring(target: Control) -> void:
	var centre := target.size * 0.5
	var radius := minf(target.size.x, target.size.y) * 0.5
	target.draw_arc(centre, radius + 6.0, 0.0, TAU, 64, Color(ACTIVE_RING, 0.18), 8.0, true)
	target.draw_arc(centre, radius + 3.0, 0.0, TAU, 64, ACTIVE_RING, 2.5, true)
