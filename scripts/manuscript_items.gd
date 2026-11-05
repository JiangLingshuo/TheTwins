extends Control
signal document_requested(id: String)
signal list_requested
## A notebook page of folded entries (manuscripts, clues or radio logs), one
## card per entry showing its title. Clicking a card opens its full text.

var _entries: Array[Dictionary] = []
var _selected := ""
var _page_key := -1
var _font: Font
var _ink := Color(0.17, 0.14, 0.12)
var _interactive := true
var _stack: VBoxContainer
## Ink of the NEW sign on unread clues (the notebook's keyword red).
const NEW_COLOR := Color("843c42")
## Manuscripts track which documents were read (Aurora's tutorial uses it); clues do not.
var _manuscript := true
var _empty_text := "No documents received yet."
## Optional heading and back button above the cards (set_list_header()).
var _heading := ""
var _back_text := ""
var _card_font_size := 23

## Heading and back button ("" = none) shown above the cards, and the cards'
## title size. The node is shared by several sections: set it before each setup().
func set_list_header(heading: String = "", back_text: String = "", card_font_size: int = 23) -> void:
	_heading = heading
	_back_text = back_text
	_card_font_size = card_font_size

func setup(entries: Array[Dictionary], page_key: int, font: Font, ink: Color, interactive: bool, manuscript: bool = true, empty_text: String = "No documents received yet.") -> void:
	_manuscript = manuscript
	_empty_text = empty_text
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
	if not _back_text.is_empty():
		var back := Button.new()
		back.name = "BackButton"
		back.text = _back_text
		back.flat = true
		back.alignment = HORIZONTAL_ALIGNMENT_LEFT
		back.disabled = not _interactive
		back.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		back.add_theme_font_override("font", _font)
		back.add_theme_font_size_override("font_size", 19)
		for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
			back.add_theme_color_override(state, _ink)
		back.pressed.connect(func() -> void: list_requested.emit())
		_stack.add_child(back)
	if not _heading.is_empty():
		_stack.add_child(_label(_heading, 22))
	if _entries.is_empty() and not _empty_text.is_empty():
		_stack.add_child(_label(_empty_text, 21))
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
		var title := _label(entry["title"], _card_font_size)
		button.add_child(title)
		title.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		title.offset_left = 12
		title.offset_top = 8
		title.offset_bottom = -8
		title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		# An unread clue shows NEW in its top-right corner until it has been read.
		var unread := not _manuscript and GameState.is_clue_unread(str(entry["id"]))
		title.offset_right = -58 if unread else -12
		if unread:
			var badge := _label("NEW", 15)
			badge.name = "NewBadge"
			badge.add_theme_color_override("font_color", NEW_COLOR)
			badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			button.add_child(badge)
			badge.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
			badge.offset_left = -60
			badge.offset_right = -8
			badge.offset_top = 4
			badge.offset_bottom = 24
		button.pressed.connect(show_document.bind(entry["id"]))

func show_document(id: String) -> void:
	if not _interactive or not _entries.any(func(entry: Dictionary) -> bool: return entry["id"] == id):
		return
	_selected = id
	if not _manuscript:
		document_requested.emit(id)
		return
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
