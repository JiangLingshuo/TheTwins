extends Control
## One gravestone's single notebook page: a sketch of the stone (top left), the
## player's report form (bottom left), and its Description, Rubbings and Clues
## (right column). The book shows one on each page and one on the turning sheet.
##
## setup() fills it from the gravestone's info; what the player types is kept in
## GameState.gravestone_reports, so it survives page turns and closing the book.
## setup_unknown() shows the same page for a gravestone not yet recorded: a
## dashed "?" stone in place of the sketch and every section left blank.

@export var body_font: Font
@export var heading_font: Font
@export var body_size: int = 15
@export var heading_size: int = 17
## Number of reference slots shown under Rubbings and Clues.
@export var rubbing_slots: int = 3
@export var clue_slots: int = 3
## Size of one rubbing slot.
@export var rubbing_slot_size: Vector2 = Vector2(44, 44)
## Opacity of the faint parts (slot frames, empty slots, divider).
@export_range(0.0, 1.0, 0.05) var faded_alpha: float = 0.45

const DESCRIPTION_PLACEHOLDER := "Not yet described."
const EMPTY_CLUE := "—"

## Sketches cut down to the visible part of their texture, by texture path.
static var _sketch_cache: Dictionary = {}

@onready var sketch: TextureRect = $Sketch
@onready var identity_input: LineEdit = $Form/IdentityInput
@onready var death_input: LineEdit = $Form/DeathInput
@onready var description: Label = $Info/Description
@onready var rubbings_row: HBoxContainer = $Info/Rubbings
@onready var clues_list: VBoxContainer = $Info/Clues

var gravestone_id := ""
var _ink := Color(0.17, 0.14, 0.12)
var _filling := false
var _interactive := true
## True while the page stands for a gravestone not yet recorded.
var _unknown := false


func _ready() -> void:
	for i in rubbing_slots:
		var slot := Panel.new()
		slot.custom_minimum_size = rubbing_slot_size
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rubbings_row.add_child(slot)
	for i in clue_slots:
		var line := Label.new()
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		clues_list.add_child(line)
	for input: LineEdit in [identity_input, death_input]:
		input.text_changed.connect(func(_text: String) -> void: _save_report())
		input.text_submitted.connect(func(_text: String) -> void: input.release_focus())
	rubbings_row.sort_children.connect(queue_redraw)  # symbols are drawn over the slots
	set_ink(_ink)


## Show gravestone `id` using its notebook info: "sketch" (texture path),
## "description" (text), "rubbings" and "clues" (lists of entry names).
func setup(id: String, info: Dictionary) -> void:
	gravestone_id = id
	_unknown = false
	sketch.texture = _sketch(info.get("sketch", ""))
	var text: String = info.get("description", "")
	description.text = text if not text.is_empty() else DESCRIPTION_PLACEHOLDER
	_fill_slots(info.get("rubbings", []), info.get("clues", []))
	var report: Dictionary = GameState.gravestone_reports.get(id, {})
	_filling = true
	identity_input.text = report.get("identity", "")
	death_input.text = report.get("death", "")
	_filling = false
	_update_inputs()
	queue_redraw()


## The page of a gravestone not yet recorded: "?" sketch, blank sections and a
## form that cannot be filled in yet.
func setup_unknown() -> void:
	gravestone_id = ""
	_unknown = true
	sketch.texture = null
	description.text = ""
	_filling = true
	identity_input.text = ""
	death_input.text = ""
	_filling = false
	for line: Label in clues_list.get_children():
		line.text = ""
	_update_inputs()
	queue_redraw()


## Whether the form can be typed in (off for the copy on the turning sheet).
func set_interactive(value: bool) -> void:
	_interactive = value
	_update_inputs()


func _update_inputs() -> void:
	var value := _interactive and not _unknown
	for input: LineEdit in [identity_input, death_input]:
		if not value and input.has_focus():
			input.release_focus()
		input.editable = value
		input.focus_mode = Control.FOCUS_ALL if value else Control.FOCUS_NONE
		input.mouse_filter = Control.MOUSE_FILTER_STOP if value else Control.MOUSE_FILTER_IGNORE


## Colour everything on the page in `ink` (the page theme's text colour).
func set_ink(ink: Color) -> void:
	_ink = ink
	var faded := Color(ink, faded_alpha)
	for label: Label in find_children("*", "Label", true, false):
		var heading := label.name.ends_with("Heading")
		label.add_theme_font_override("font", heading_font if heading else body_font)
		label.add_theme_font_size_override("font_size", heading_size if heading else body_size)
		label.add_theme_color_override("font_color", ink)
	for line: Label in clues_list.get_children():
		line.add_theme_color_override("font_color", ink if line.text != EMPTY_CLUE else faded)
	for input: LineEdit in [identity_input, death_input]:
		input.add_theme_font_override("font", body_font)
		input.add_theme_color_override("font_color", ink)
		input.add_theme_color_override("font_uneditable_color", ink)
		input.add_theme_color_override("caret_color", ink)
		input.add_theme_color_override("selection_color", Color(ink, 0.25))
		var underline: StyleBoxFlat = input.get_theme_stylebox("normal").duplicate()
		underline.border_color = Color(ink, 0.6)
		for style in ["normal", "read_only", "focus"]:
			input.add_theme_stylebox_override(style, underline)
	var frame := StyleBoxFlat.new()
	frame.draw_center = false
	frame.set_border_width_all(1)
	frame.border_color = faded
	for slot: Panel in rubbings_row.get_children():
		slot.add_theme_stylebox_override("panel", frame)
	queue_redraw()


func _draw() -> void:
	# A faint rule between the left column and the information column.
	var x := ($Info as Control).position.x - 12.0
	draw_line(Vector2(x, 4.0), Vector2(x, size.y - 4.0), Color(_ink, faded_alpha * 0.6), 1.0, true)
	if _unknown:
		_draw_unknown_stone(sketch.get_rect())
	else:
		_draw_rubbings()


## The gravestone's collected rubbings in its slots, in collection order, with a
## tick on the deciphered ones (state from GameState, shared with the Rubbings tab).
func _draw_rubbings() -> void:
	var ids := GameState.get_gravestone_rubbings(gravestone_id)
	var slots := rubbings_row.get_children()
	var origin := ($Info as Control).position + rubbings_row.position
	for i in mini(ids.size(), slots.size()):
		var box := Rect2(origin + slots[i].position, slots[i].size).grow(-5.0)
		var path := GameState.get_rubbing_texture(ids[i])
		if not path.is_empty() and ResourceLoader.exists(path):
			var texture: Texture2D = load(path)
			var fit := minf(box.size.x / texture.get_width(), box.size.y / texture.get_height())
			var drawn := Vector2(texture.get_size()) * fit
			# White symbol art, drawn in the page's ink.
			draw_texture_rect(texture, Rect2(box.get_center() - drawn / 2.0, drawn), false, _ink)
		if GameState.is_rubbing_deciphered(ids[i]):
			_draw_tick(origin + slots[i].position + Vector2(slots[i].size.x - 13.0, 2.0), 11.0)


## A small, slightly uneven hand-drawn tick (same as on the Rubbings pages).
func _draw_tick(at: Vector2, length: float) -> void:
	var points := PackedVector2Array([
		at + Vector2(0.0, 0.52) * length,
		at + Vector2(0.14, 0.64) * length,
		at + Vector2(0.33, 0.95) * length,
		at + Vector2(0.58, 0.48) * length,
		at + Vector2(1.0, 0.02) * length,
	])
	draw_polyline(points, _ink, 2.0, true)
	var offset := Vector2(0.7, -0.4)
	draw_polyline(PackedVector2Array([points[1] + offset, points[2] + offset, points[3] + offset]),
		Color(_ink, 0.6), 1.1, true)


## A dashed round-topped stone with a question mark, standing in for the sketch.
func _draw_unknown_stone(box: Rect2) -> void:
	var faded := Color(_ink, faded_alpha)
	var radius := box.size.x * 0.36
	var centre_x := box.get_center().x
	var bottom := box.end.y - 14.0
	var top := box.position.y + 10.0
	var arc_centre := Vector2(centre_x, top + radius)
	var outline := PackedVector2Array([Vector2(centre_x - radius, bottom)])
	for i in 25:
		var angle := PI + PI * i / 24.0
		outline.append(arc_centre + Vector2(cos(angle), sin(angle)) * radius)
	outline.append(Vector2(centre_x + radius, bottom))
	outline.append(Vector2(centre_x - radius, bottom))
	_draw_dashed(outline, faded)
	_draw_dashed(PackedVector2Array([
		Vector2(box.position.x + 4.0, bottom), Vector2(box.end.x - 4.0, bottom)]), faded)
	var font := heading_font if heading_font else get_theme_default_font()
	var font_size := 64
	var baseline := (top + bottom) / 2.0 + (font.get_ascent(font_size) - font.get_descent(font_size)) / 2.0
	draw_string(font, Vector2(box.position.x, baseline), "?", HORIZONTAL_ALIGNMENT_CENTER, box.size.x, font_size, faded)


func _draw_dashed(points: PackedVector2Array, color: Color, dash := 8.0, gap := 6.0) -> void:
	var drawing := true
	var left := dash
	for i in points.size() - 1:
		var a := points[i]
		var b := points[i + 1]
		var length := a.distance_to(b)
		var t := 0.0
		while t < length:
			var step := minf(left, length - t)
			if drawing:
				draw_line(a.lerp(b, t / length), a.lerp(b, (t + step) / length), color, 1.5, true)
			t += step
			left -= step
			if left <= 0.0:
				drawing = not drawing
				left = dash if drawing else gap


## Clue lines. The rubbing slots are drawn from GameState in _draw_rubbings().
func _fill_slots(_rubbings: Array, clues: Array) -> void:
	var lines := clues_list.get_children()
	for i in lines.size():
		lines[i].text = str(clues[i]) if i < clues.size() else EMPTY_CLUE
	set_ink(_ink)


func _save_report() -> void:
	if _filling or gravestone_id.is_empty():
		return
	GameState.gravestone_reports[gravestone_id] = {
		"identity": identity_input.text,
		"death": death_input.text,
	}


## The texture cut down to its visible (non-transparent) part, so a stone drawn
## on a full-screen canvas fills the sketch box.
func _sketch(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if not _sketch_cache.has(path):
		var texture: Texture2D = load(path)
		var image := texture.get_image()
		if image.is_compressed():
			image.decompress()
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(image.get_used_rect())
		_sketch_cache[path] = atlas
	return _sketch_cache[path]
