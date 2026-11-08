extends Control
signal document_requested(id: String)
signal list_requested
## A gravestone chip of the manuscript filter was pressed ("" = All).
signal filter_requested(stone_id: String)
signal source_filter_requested(stone_id: String)
var source_filter_keys: Array = []
var source_filter_selected := ""
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
var list_notice := ""
var _back_text := ""
var _card_font_size := 23
## Manuscript cards: a gravestone thumbnail, a small title and a one-line subtitle,
## plus (on the left page) a row of gravestone chips that filters the list.
var _rich := false
## "manuscript" (gravestone thumbnails + subtitles) or "clue" (thumbnail of the tool that found it).
var _kind := "manuscript"
var _filter_stones: Array = []
var _filter_selected := ""
## 0 = no filter row, 1 = the row, 2 = blank space where the row is (keeps both pages' cards level).
var _filter_row_mode := 0
static var _thumbnails := {}

const TOOL_ICONS := {
	"rubbing": preload("res://assets/Art/symbols/rubbing_off.svg"),
	"searchlight": preload("res://assets/Art/symbols/flashlight_off.svg"),
	"camera": preload("res://assets/Art/symbols/camera.svg"),
	"finding": preload("res://assets/Art/symbols/finding.svg"),
}
const TOOL_NAMES := {
	"rubbing": "Rubbing",
	"searchlight": "Searchlight",
	"camera": "Camera",
	"finding": "Worked out in the notebook",
}

const SUBTITLES := {
	"designer_manuscript": "Designer's statement · infant's marker",
	"designer_journal": "Designer's journal · a student's plea",
	"infant_medical_record": "Day City medical file · the infant",
	"disappearance_inquiry": "Scholar's notes · dawn disappearances",
	"profession_record": "Day City record · the Scholar's work",
	"one_way_passage_order": "Day City order · the one-way passage",
	"twin_beast_account": "Legend · the twin-bodied creature",
	"crystal_god_prophecy": "Night City legend · Divine Messenger",
	"natural_collapse_record": "Old record · how the road was sealed",
	"skyway_history": "Night City account · the climb up",
	"day_city_history": "Banned book · Dayfolk and Nightfolk",
	"girl_diary": "Diary page · a carver's doubts",
}

## Heading and back button ("" = none) shown above the cards, and the cards'
## title size. The node is shared by several sections: set it before each setup().
func set_list_header(heading: String = "", back_text: String = "", card_font_size: int = 23) -> void:
	_heading = heading
	source_filter_keys = []
	list_notice = ""
	_back_text = back_text
	_card_font_size = card_font_size
	_rich = false
	_filter_row_mode = 0

## Turn on the manuscript card style. `stone_ids` are the gravestones that have
## manuscripts; `row_mode` says what to put in the filter row's place (see _filter_row_mode).
func set_manuscript_extras(stone_ids: Array, selected: String, row_mode: int, kind: String = "manuscript") -> void:
	_rich = true
	_kind = kind
	_filter_stones = stone_ids
	_filter_selected = selected
	_filter_row_mode = row_mode

## The gravestone's sketch cut down to its visible part, shared by all cards.
static func stone_thumbnail(stone_id: String) -> Texture2D:
	if _thumbnails.has(stone_id):
		return _thumbnails[stone_id]
	var path: String = "res://assets/Art/figure/aurora.png" if stone_id == "__other" else GameState.get_gravestone_info(stone_id).get("sketch", "")
	if stone_id == "__day": path = GameState.SUN_RUBBING_TEXTURE
	if stone_id == "__night": path = "res://assets/Art/symbol/moon.png"
	var atlas: AtlasTexture = null
	var texture := load(path) as Texture2D if not path.is_empty() and ResourceLoader.exists(path, "Texture2D") else null
	if texture:
		var image := texture.get_image()
		if image:
			if image.is_compressed():
				image.decompress()
			atlas = AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(image.get_used_rect())
	_thumbnails[stone_id] = atlas
	return atlas

## The key a card or chip is filed under: the gravestone (manuscripts) or the tool (clues).
func _entry_key(entry: Dictionary) -> String:
	return GameState.clue_tool(entry) if _kind == "clue" else str(entry.get("gravestone", ""))

func _thumbnail_rect(key: String, source: bool = false) -> TextureRect:
	var rect := TextureRect.new()
	if _kind == "clue" and not source:
		rect.texture = TOOL_ICONS.get(key)
		# Same soft, grainy finish as the tool buttons.
		SoftIcon.apply_tree(rect)
	else:
		rect.texture = stone_thumbnail(key)
		if key == "__other" and _ink.get_luminance() > 0.5:
			var invert := ShaderMaterial.new()
			invert.shader = preload("res://shaders/portrait_invert.gdshader")
			invert.set_shader_parameter("invert", 1.0)
			rect.material = invert
	if source: rect.modulate = Color(0.48, 0.65, 0.75, 0.95)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect

func _chip(stone_id: String, source: bool = false) -> Button:
	var chip := Button.new()
	chip.name = "Filter_" + (stone_id if not stone_id.is_empty() else "all")
	chip.custom_minimum_size = Vector2(40, 40)
	chip.disabled = not _interactive
	chip.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var selected := stone_id == (source_filter_selected if source else _filter_selected)
	var frame := StyleBoxFlat.new()
	frame.bg_color = Color(_ink, 0.16 if selected else 0.035)
	frame.border_color = Color(_ink, 0.9 if selected else 0.35)
	frame.set_border_width_all(2 if selected else 1)
	frame.set_corner_radius_all(3)
	chip.add_theme_stylebox_override("normal", frame)
	var hover := frame.duplicate() as StyleBoxFlat
	hover.bg_color = Color(_ink, 0.2)
	chip.add_theme_stylebox_override("hover", hover)
	chip.add_theme_stylebox_override("focus", hover)
	chip.add_theme_stylebox_override("disabled", frame)
	if stone_id.is_empty():
		chip.text = "All"
		chip.add_theme_font_override("font", _font)
		chip.add_theme_font_size_override("font_size", 17)
		for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
			chip.add_theme_color_override(state, _ink)
		chip.tooltip_text = GameState.zh_text("All tools" if _kind == "clue" else "All gravestones")
	else:
		if _kind == "clue" and not source:
			chip.tooltip_text = GameState.zh_text(TOOL_NAMES.get(stone_id, ""))
		else:
			chip.tooltip_text = GameState.fill_placeholders(str(GameState.get_gravestone_info(stone_id).get("title", "")))
		var thumbnail := _thumbnail_rect(stone_id, source)
		chip.add_child(thumbnail)
		thumbnail.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		for side in [SIDE_LEFT, SIDE_TOP]:
			thumbnail.set_offset(side, 4)
		for side in [SIDE_RIGHT, SIDE_BOTTOM]:
			thumbnail.set_offset(side, -4)
	if _kind == "manuscript" and not source and has_unread(stone_id):
		_add_unread_dot(chip)
	if source:
		chip.tooltip_text = GameState.zh_text("Day City · general" if stone_id == "__day" else ("Night City · general" if stone_id == "__night" else ("All sources" if stone_id.is_empty() else chip.tooltip_text)))
		chip.pressed.connect(func() -> void: source_filter_requested.emit(stone_id))
	else:
		chip.pressed.connect(func() -> void: filter_requested.emit(stone_id))
	return chip

## True if any delivered manuscript of `stone_id` ("" = any stone) has not been
## opened yet. Opening a manuscript marks it read (show_document).
static func has_unread(stone_id: String) -> bool:
	var read: Array = GameState.radio_progress.get("read_manuscripts", [])
	for entry in GameState.notebook_entries(3, false):
		if (stone_id.is_empty() or str(entry.get("gravestone", "")) == stone_id) and not read.has(entry["id"]):
			return true
	return false

## A small red dot in the top-right corner of a filter chip: something new inside.
func _add_unread_dot(chip: Button) -> void:
	var dot := Panel.new()
	dot.name = "UnreadDot"
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.88, 0.2, 0.18)
	style.border_color = Color(1.0, 0.96, 0.9, 0.9)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	dot.add_theme_stylebox_override("panel", style)
	chip.add_child(dot)
	dot.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	dot.offset_left = -13.0
	dot.offset_right = -1.0
	dot.offset_top = 1.0
	dot.offset_bottom = 13.0

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
	if not list_notice.is_empty():
		var notice := _label(list_notice, 14)
		notice.name = "ProgressNotice"
		notice.add_theme_color_override("font_color", Color("765044") if _ink.get_luminance() < 0.5 else Color("ddbd88"))
		_stack.add_child(notice)
	if not _heading.is_empty():
		_stack.add_child(_label(_heading, 22))
	if _entries.is_empty() and not _empty_text.is_empty():
		_stack.add_child(_label(_empty_text, 21))
	if _rich and _filter_row_mode != 0:
		var row := HBoxContainer.new()
		row.name = "StoneFilter"
		row.custom_minimum_size = Vector2(0, 40)
		row.add_theme_constant_override("separation", 6)
		_stack.add_child(row)
		if _filter_row_mode == 1:
			for stone_id in [""] + _filter_stones:
				row.add_child(_chip(stone_id))
		elif _kind == "clue":
			var scroll := ScrollContainer.new()
			scroll.name = "SourceFilter"
			scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
			row.add_child(scroll)
			var chips := HBoxContainer.new()
			chips.add_theme_constant_override("separation", 5)
			scroll.add_child(chips)
			for key: String in [""] + source_filter_keys:
				chips.add_child(_chip(key, true))
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
		var title := _label(entry["title"], 18 if _rich else _card_font_size)
		if _rich:
			# Thumbnail of the gravestone this manuscript belongs to, then title over subtitle.
			var thumbnail := _thumbnail_rect(_entry_key(entry))
			thumbnail.name = "StoneThumbnail"
			button.add_child(thumbnail)
			thumbnail.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
			thumbnail.offset_left = 10
			thumbnail.offset_right = 62
			thumbnail.offset_top = 8
			thumbnail.offset_bottom = -8
			var text_box := VBoxContainer.new()
			text_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
			text_box.alignment = BoxContainer.ALIGNMENT_CENTER
			text_box.add_theme_constant_override("separation", 1)
			button.add_child(text_box)
			text_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			text_box.offset_left = 72
			text_box.offset_right = -10
			text_box.offset_top = 6
			text_box.offset_bottom = -6
			text_box.add_child(title)
			if entry.has("progress"):
				text_box.offset_bottom = -25
				var progress := _label(str(entry["progress"]), 16)
				progress.name = "DialogueProgress"
				progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				button.add_child(progress)
				progress.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
				progress.offset_left = -78
				progress.offset_right = -10
				progress.offset_top = -25
				progress.offset_bottom = -5
			if _kind == "manuscript":
				var subtitle := _label(GameState.zh_text(SUBTITLES.get(entry["id"], "")), 13)
				subtitle.name = "Subtitle"
				subtitle.autowrap_mode = TextServer.AUTOWRAP_OFF
				subtitle.clip_text = true
				subtitle.add_theme_color_override("font_color", Color(_ink, 0.68))
				text_box.add_child(subtitle)
			if _kind == "clue":
				text_box.offset_right = -82
				var sources := HBoxContainer.new()
				sources.name = "SourceThumbnails"
				sources.mouse_filter = Control.MOUSE_FILTER_IGNORE
				button.add_child(sources)
				sources.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
				sources.offset_left = -76
				sources.offset_right = -8
				sources.offset_top = 27
				sources.offset_bottom = -8
				for key: String in GameState.clue_sources(entry):
					var origin := _thumbnail_rect(key, true)
					origin.custom_minimum_size = Vector2(20, 40)
					origin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					sources.add_child(origin)
			# An unread clue shows NEW in its top-right corner until it has been read.
			if _kind == "clue" and GameState.is_clue_unread(str(entry["id"])):
				text_box.offset_right = -82
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
			continue
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
	GameState.queue_autosave()
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
