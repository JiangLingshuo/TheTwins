extends Control
## Collected rubbings on one notebook page of the Rubbings section: one row per
## rubbing, with the symbol on the left and its confirmed meaning on the right.
## Deciphered symbols get a small hand-drawn tick. Everything is drawn, so the
## copy on the turning sheet turns with the paper like the page text.
##
## The book fills it with show_entries(); the data comes from GameState.
##
## Every entry can be dragged out onto the scene (deciphered ones too, as they
## may still reveal clues): hovering one shows a hint and pressing + moving
## starts the drag. The sun and moon drag as on the Rise & Set page. Both are handled by the notebook
## tool's RubbingDrag (group "rubbing_drag"), shared by all entries.

const FONT: Font = preload("res://assets/fonts/ZhaohuaTypeWriter.ttf")
## Width of the symbol column.
const SYMBOL_COLUMN := 96.0
## Largest size a symbol is drawn at (it keeps its proportions).
const SYMBOL_BOX := Vector2(76, 76)
const MEANING_SIZE := 21
const UNKNOWN_TEXT := "Meaning unknown"
## How far the mouse moves with the button held before a drag starts.
const DRAG_THRESHOLD := 6.0

## Rows a page has room for (the book sets it from rubbings_per_page).
var rows := 4

var _ids: Array = []
var _ink := Color(0.17, 0.14, 0.12)
var _faded_ink := Color(_ink, 0.45)
## Whether the entries can be hovered and dragged (off for the turning sheet).
var interactive := true:
	set(value):
		interactive = value
		_update_mouse()
var _hovered := -1
var _pressed := -1
## Symbol textures by path. Drawing only stores a texture's RID, so the textures
## must stay referenced or an icon nothing else uses (the sky sun) is freed and
## draws as a solid square.
var _textures: Dictionary = {}
var _press_position := Vector2.ZERO


func _ready() -> void:
	_update_mouse()
	mouse_exited.connect(_set_hovered.bind(-1))
	visibility_changed.connect(_reset_pointer)


## Show these rubbing ids, top to bottom.
func show_entries(ids: Array) -> void:
	_ids = ids.duplicate()
	_reset_pointer()
	_update_mouse()
	queue_redraw()


func clear() -> void:
	show_entries([])


func set_ink(ink: Color, faded_alpha: float) -> void:
	_ink = ink
	_faded_ink = Color(ink, faded_alpha)
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var row := _row_at(event.position)
			_pressed = row if _is_draggable(row) else -1
			_press_position = event.position
			if _pressed >= 0:
				accept_event()
		else:
			_pressed = -1
	elif event is InputEventMouseMotion:
		if _pressed >= 0 and event.button_mask & MOUSE_BUTTON_MASK_LEFT \
				and event.position.distance_to(_press_position) > DRAG_THRESHOLD:
			var drag := _drag()
			if drag:
				drag.begin(str(_ids[_pressed]), event.global_position)
			_pressed = -1
			_set_hovered(-1)
			accept_event()
		elif _pressed < 0:
			_set_hovered(_row_at(event.position))


func _row_at(local: Vector2) -> int:
	if not Rect2(Vector2.ZERO, size).has_point(local):
		return -1
	var row := int(local.y / (size.y / maxi(1, rows)))
	return row if row < _ids.size() else -1


func _is_draggable(row: int) -> bool:
	if row < 0 or row >= _ids.size() or not GameState.rubbings.has(str(_ids[row])):
		return false
	# The sun and moon follow the Rise & Set rules (usable once Aurora explained them).
	return str(_ids[row]) not in ["sky_sun_rubbing", "infant_moon_rubbing"] or GameState.cycle_hint_heard


## Hint over draggable entries.
func _set_hovered(row: int) -> void:
	_hovered = row if _is_draggable(row) else -1
	mouse_default_cursor_shape = Control.CURSOR_DRAG if _hovered >= 0 else Control.CURSOR_ARROW
	var drag := _drag()
	if drag == null or drag.is_dragging():
		return
	if _hovered >= 0:
		drag.show_hint(get_global_mouse_position())
	else:
		drag.hide_hint()


func _reset_pointer() -> void:
	_pressed = -1
	if _hovered >= 0 or not is_visible_in_tree():
		_set_hovered(-1)


func _update_mouse() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP if interactive and not _ids.is_empty() \
		else Control.MOUSE_FILTER_IGNORE


func _drag() -> Control:
	return get_tree().get_first_node_in_group("rubbing_drag") if is_inside_tree() else null


func _draw() -> void:
	var row_height := size.y / maxi(1, rows)
	for i in _ids.size():
		var top := row_height * i
		_draw_entry(str(_ids[i]), Rect2(0, top, size.x, row_height))
		if i < _ids.size() - 1:
			var y := top + row_height
			draw_line(Vector2(0, y), Vector2(size.x, y), Color(_faded_ink, _faded_ink.a * 0.5), 1.0, true)


func _draw_entry(id: String, row: Rect2) -> void:
	# Symbol, centred in the left column.
	var box := Rect2(row.position + Vector2((SYMBOL_COLUMN - SYMBOL_BOX.x) / 2.0, (row.size.y - SYMBOL_BOX.y) / 2.0), SYMBOL_BOX)
	var path := GameState.get_rubbing_texture(id)
	if not _textures.has(path):
		_textures[path] = load(path) if not path.is_empty() and ResourceLoader.exists(path) else null
	var texture: Texture2D = _textures[path]
	if texture:
		var fit := minf(box.size.x / texture.get_width(), box.size.y / texture.get_height())
		var drawn := Vector2(texture.get_size()) * fit
		# The symbol art is white on transparent: modulating gives it the ink colour.
		draw_texture_rect(texture, Rect2(box.get_center() - drawn / 2.0, drawn), false, _ink)
	var meaning := GameState.get_rubbing_meaning(id)
	if not meaning.is_empty():
		draw_tick(self, box.end - Vector2(4, SYMBOL_BOX.y - 2), 18.0, _ink)
	# Meaning, in the right column.
	var x := SYMBOL_COLUMN + 12.0
	var width := row.size.x - x
	var text := meaning if not meaning.is_empty() else UNKNOWN_TEXT
	var color := _ink if not meaning.is_empty() else _faded_ink
	var line_height := FONT.get_height(MEANING_SIZE)
	var lines := mini(3, _line_count(text, width))
	var top := row.position.y + (row.size.y - line_height * lines) / 2.0 + FONT.get_ascent(MEANING_SIZE)
	draw_multiline_string(FONT, Vector2(x, top), text, HORIZONTAL_ALIGNMENT_LEFT, width,
		MEANING_SIZE, 3, color)


func _line_count(text: String, width: float) -> int:
	var paragraph := TextParagraph.new()
	paragraph.add_string(text, FONT, MEANING_SIZE)
	paragraph.width = width
	return maxi(1, paragraph.get_line_count())


## A small, slightly uneven hand-drawn tick of `length` with its top-left at `at`.
static func draw_tick(canvas: CanvasItem, at: Vector2, length: float, color: Color) -> void:
	var points := PackedVector2Array([
		at + Vector2(0.0, 0.52) * length,
		at + Vector2(0.14, 0.64) * length,
		at + Vector2(0.33, 0.95) * length,
		at + Vector2(0.58, 0.48) * length,
		at + Vector2(1.0, 0.02) * length,
	])
	canvas.draw_polyline(points, color, 2.2, true)
	# A second, thinner pass a little off the first, like a pen going over it.
	var offset := Vector2(0.7, -0.4)
	canvas.draw_polyline(PackedVector2Array([points[1] + offset, points[2] + offset, points[3] + offset]),
		Color(color, color.a * 0.6), 1.2, true)
