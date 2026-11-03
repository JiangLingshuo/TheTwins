extends Control
signal document_requested(id: String)
signal list_requested
## A notebook page of manuscript cards. Clicking a card opens its full text.

var _entries: Array[Dictionary] = []
var _selected := ""
var _page_key := -1
var _font: Font
var _ink := Color(0.17, 0.14, 0.12)
var _interactive := true
var _stack: VBoxContainer

func setup(entries: Array[Dictionary], page_key: int, font: Font, ink: Color, interactive: bool) -> void:
	if _page_key != page_key:
		_selected = ""
	_page_key = page_key
	_entries = entries
	_font = font
	_ink = ink
	_interactive = interactive
	_rebuild()

func _label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = GameState.fill_placeholders(text)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font", _font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", _ink)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _rebuild() -> void:
	if _stack != null:
		remove_child(_stack)
		_stack.queue_free()
	_stack = VBoxContainer.new()
	_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_stack.add_theme_constant_override("separation", 12)
	add_child(_stack)
	_stack.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_stack.add_child(_label("Manuscripts", 26))
	if _entries.is_empty():
		_stack.add_child(_label("No documents received yet.", 21))
	for entry in _entries:
		var button := Button.new()
		button.name = entry["id"]
		button.custom_minimum_size = Vector2(0, 86)
		button.disabled = not _interactive
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.tooltip_text = entry["title"]
		var frame := StyleBoxFlat.new()
		frame.bg_color = Color(_ink, 0.035)
		frame.border_color = Color(_ink, 0.45)
		frame.set_border_width_all(1)
		frame.set_corner_radius_all(3)
		button.add_theme_stylebox_override("normal", frame)
		var hover := frame.duplicate() as StyleBoxFlat
		hover.bg_color = Color(_ink, 0.12)
		button.add_theme_stylebox_override("hover", hover)
		button.add_theme_stylebox_override("focus", hover)
		_stack.add_child(button)
		var title := _label(entry["title"], 23)
		button.add_child(title)
		title.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		title.offset_left = 12
		title.offset_right = -12
		title.offset_top = 8
		title.offset_bottom = -8
		title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		button.pressed.connect(show_document.bind(entry["id"]))

func show_document(id: String) -> void:
	if not _interactive or not _entries.any(func(entry: Dictionary) -> bool: return entry["id"] == id):
		return
	_selected = id
	GameState.radio_progress["active_manuscript"] = id
	var read: Array = GameState.radio_progress.get("read_manuscripts", [])
	if not read.has(id): read.append(id)
	GameState.radio_progress["read_manuscripts"] = read
	document_requested.emit(id)

func show_list() -> void:
	list_requested.emit()
	GameState.finish_current_manuscript()
	_selected = ""
	_rebuild()


func _collect_keyword(meta: Variant) -> void:
	if not _interactive: return
	var id := str(meta)
	var notes: Array = GameState.radio_progress.get("manuscript_keywords", [])
	if not notes.has(id): notes.append(id)
	GameState.radio_progress["manuscript_keywords"] = notes
	GameState.collect_term(id)
