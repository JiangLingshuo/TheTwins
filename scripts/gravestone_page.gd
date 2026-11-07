extends Control
## One gravestone's single notebook page: a sketch of the stone (top left), the
## player's report form (bottom left), and its Description, Rubbings and Clues
## (right column). The book shows one on each page and one on the turning sheet.
##
## setup() fills it from the gravestone's info; what the player types is kept in
## GameState.gravestone_reports, so it survives page turns and closing the book.
## setup_unknown() shows the same page for a gravestone not yet recorded: a
## dashed "?" stone in place of the sketch and every section left blank.
##
## Clicking a collected rubbing in its slot emits rubbing_pressed, which the book
## uses to turn to that rubbing's entry in the Rubbings section.

## Emitted when a collected rubbing in a slot is clicked.
signal rubbing_pressed(rubbing_id: String)

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
const HANDWRITING := preload("res://assets/fonts/Kalam-Regular.ttf")
const PENCIL_SHADER := preload("res://shaders/notebook_pencil.gdshader")
const WRITING_SOUND := preload("res://assets/audio/写字声.wav")
var _answer_art: Dictionary = {}
var _pencil_material := ShaderMaterial.new()
var _pen: AudioStreamPlayer
var _pen_tween: Tween

## Sketches cut down to the visible part of their texture, by texture path.
static var _sketch_cache: Dictionary = {}

@onready var sketch: TextureRect = $Sketch
@onready var identity_input: OptionButton = $Form/IdentityInput
@onready var death_input: OptionButton = $Form/DeathInput
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
		slot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		slot.gui_input.connect(_on_slot_input.bind(i))
		rubbings_row.add_child(slot)
	for i in clue_slots:
		var line := Label.new()
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		clues_list.add_child(line)
	_pen = AudioStreamPlayer.new()
	_pen.stream = WRITING_SOUND
	_pen.volume_db = 6.0
	add_child(_pen)
	_prepare_answer_input(identity_input, "identity")
	_prepare_answer_input(death_input, "death")
	GameState.notebook_changed.connect(_refresh_options)
	rubbings_row.sort_children.connect(queue_redraw)  # symbols are drawn over the slots
	# The narrow information column needs scrolling for descriptions and clue text.
	var info: Control = $Info
	var reader := ScrollContainer.new()
	reader.name = "InfoReader"
	reader.position = info.position
	reader.size = Vector2(164, 430)
	reader.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(reader)
	reader.get_v_scroll_bar().value_changed.connect(func(_value: float) -> void: queue_redraw())
	info.reparent(reader)
	info.position = Vector2.ZERO
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
	_refresh_options()
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
	_refresh_options()
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
	for input: OptionButton in [identity_input, death_input]:
		if not value and input.has_focus():
			input.release_focus()
		input.disabled = not value
		input.focus_mode = Control.FOCUS_ALL if value else Control.FOCUS_NONE
		input.mouse_filter = Control.MOUSE_FILTER_STOP if value else Control.MOUSE_FILTER_IGNORE
	# Only slots holding a rubbing can be clicked.
	var count := 0 if _unknown else GameState.get_gravestone_rubbings(gravestone_id).size()
	var slots := rubbings_row.get_children()
	for i in slots.size():
		slots[i].mouse_filter = Control.MOUSE_FILTER_STOP if _interactive and i < count \
			else Control.MOUSE_FILTER_IGNORE


## A click (press and release on the slot) on a filled rubbing slot.
func _on_slot_input(event: InputEvent, slot: int) -> void:
	if not (event is InputEventMouseButton) or event.button_index != MOUSE_BUTTON_LEFT:
		return
	var slot_node: Control = rubbings_row.get_child(slot)
	slot_node.accept_event()
	if event.pressed or not Rect2(Vector2.ZERO, slot_node.size).has_point(event.position):
		return
	var ids := GameState.get_gravestone_rubbings(gravestone_id)
	if not _unknown and slot < ids.size():
		rubbing_pressed.emit(ids[slot])


## Colour everything on the page in `ink` (the page theme's text colour).
func set_ink(ink: Color) -> void:
	_ink = ink
	var faded := Color(ink, faded_alpha)
	for label: Label in find_children("*", "Label", true, false):
		if label.get_parent() is OptionButton:
			continue  # Answer labels are styled separately from page text.
		var heading := label.name.ends_with("Heading")
		label.add_theme_font_override("font", heading_font if heading else body_font)
		label.add_theme_font_size_override("font_size", heading_size if heading else body_size)
		label.add_theme_color_override("font_color", ink)
	for line: Label in clues_list.get_children():
		line.add_theme_color_override("font_color", ink if line.text != EMPTY_CLUE else faded)
	for input: OptionButton in [identity_input, death_input]:
		input.add_theme_font_override("font", body_font)
		for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
			input.add_theme_color_override(state, Color.TRANSPARENT)
		if _answer_art.has(input):
			_answer_art[input]["label"].add_theme_color_override("font_color", ink)
			_answer_art[input]["strike"].color = ink
		input.add_theme_font_size_override("font_size", 16)
	var frame := StyleBoxFlat.new()
	frame.draw_center = false
	frame.set_border_width_all(1)
	frame.border_color = faded
	for slot: Panel in rubbings_row.get_children():
		slot.add_theme_stylebox_override("panel", frame)
	queue_redraw()


func _draw() -> void:
	# A faint rule between the left column and the information column.
	var x := ($InfoReader as Control).position.x - 12.0
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
	var origin := get_global_transform().affine_inverse() * rubbings_row.global_position
	for i in mini(ids.size(), slots.size()):
		var full_box := Rect2(origin + slots[i].position, slots[i].size)
		if not ($InfoReader as Control).get_rect().encloses(full_box):
			continue
		var box := full_box.grow(-5.0)
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
	for child in clues_list.get_children():
		clues_list.remove_child(child)
		child.queue_free()
	for entry in clues:
		var line := Label.new()
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.text = str(entry.get("title", "")) + "\n" + str(entry.get("body", "")) if entry is Dictionary else str(entry)
		clues_list.add_child(line)
	if clues.is_empty():
		var line := Label.new()
		line.text = EMPTY_CLUE
		clues_list.add_child(line)
	set_ink(_ink)


func _refresh_options() -> void:
	if not is_node_ready(): return
	var report: Dictionary = GameState.gravestone_reports.get(gravestone_id, {})
	for pair in [[identity_input, "identities", "identity", GameState.IDENTITY_LABELS], [death_input, "causes", "death", GameState.CAUSE_LABELS]]:
		var input: OptionButton = pair[0]
		input.clip_text = true
		input.fit_to_longest_item = false
		input.custom_minimum_size = Vector2(0, 30)
		input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		input.clear()
		input.add_item(GameState.zh_text("Select…"))
		input.set_item_metadata(0, "")
		input.selected = 0
		for value in GameState.report_options(pair[1], gravestone_id):
			input.add_item(GameState.zh_text(pair[3].get(value, value)))
			var index := input.item_count - 1
			input.set_item_metadata(index, value)
			if report.get(pair[2], "") == value: input.selected = index
		_sync_answer_art(input)
		input.tooltip_text = (pair[3].get(report.get(pair[2], ""), "Select a collected term") as String) + "\nCollect underlined terms from records and radio replies. Identities can only be assigned once."


func _prepare_answer_input(input: OptionButton, field: String) -> void:
	_pencil_material.shader = PENCIL_SHADER
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", _ink)
	input.add_child(label)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 4
	label.offset_right = -22
	var strike := ColorRect.new()
	strike.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strike.color = _ink
	strike.material = _pencil_material
	strike.hide()
	label.add_child(strike)
	_answer_art[input] = {"label": label, "strike": strike, "stone": "", "tween": null}
	input.item_selected.connect(_write_answer.bind(input, field))

func _sync_answer_art(input: OptionButton) -> void:
	var art: Dictionary = _answer_art[input]
	var tween: Tween = art["tween"]
	if tween and tween.is_running() and art["stone"] == gravestone_id:
		return
	if tween and tween.is_valid():
		tween.kill()
		_stop_pen(tween)
	art["tween"] = null
	art["stone"] = gravestone_id
	art["strike"].hide()
	var label: Label = art["label"]
	label.modulate.a = 1.0
	label.visible_characters = -1
	label.text = input.get_item_text(input.selected) if input.selected >= 0 else ""
	_style_answer(label, input.selected > 0)

func _style_answer(label: Label, handwritten: bool) -> void:
	var face := HANDWRITING if handwritten and not GameState.chinese_playtest else body_font
	if face: label.add_theme_font_override("font", face)
	label.add_theme_font_size_override("font_size", 21 if handwritten else 16)
	label.material = _pencil_material if handwritten else null

func _write_answer(index: int, input: OptionButton, field: String) -> void:
	var art: Dictionary = _answer_art[input]
	var label: Label = art["label"]
	var previous: String = GameState.gravestone_reports.get(gravestone_id, {}).get(field, "")
	var next := str(input.get_item_metadata(index))
	if previous == next or not GameState.set_report_choice(gravestone_id, field, next):
		return
	var options: Dictionary = GameState.IDENTITY_LABELS if field == "identity" else GameState.CAUSE_LABELS
	var final_text := input.get_item_text(input.selected)
	var old_tween: Tween = art["tween"]
	if old_tween and old_tween.is_valid():
		old_tween.kill()
		_stop_pen(old_tween)
	var strike: ColorRect = art["strike"]
	var tween := create_tween()
	art["tween"] = tween
	art["stone"] = gravestone_id
	if not previous.is_empty():
		label.text = GameState.zh_text(options.get(previous, previous))
		label.visible_characters = -1
		label.modulate.a = 1.0
		_style_answer(label, true)
		strike.position = Vector2(0, label.size.y * 0.54)
		strike.size = Vector2(0, 1.5)
		strike.show()
		var width := label.get_theme_font("font").get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 21).x
		tween.tween_callback(_play_pen.bind(tween))
		tween.tween_property(strike, "size:x", minf(width, label.size.x), 0.26)
		tween.tween_callback(_stop_pen.bind(tween))
		tween.tween_property(label, "modulate:a", 0.0, 0.18)
	tween.tween_callback(func() -> void:
		strike.hide()
		label.modulate.a = 1.0
		label.text = final_text
		label.visible_characters = -1 if next.is_empty() else 0
		_style_answer(label, not next.is_empty())
		if not next.is_empty(): _play_pen(tween))
	if not next.is_empty():
		tween.tween_property(label, "visible_characters", final_text.length(), clampf(final_text.length() * 0.11, 0.35, 2.4))
		tween.tween_callback(_stop_pen.bind(tween))
	tween.tween_callback(func() -> void: label.visible_characters = -1)

func _play_pen(tween: Tween) -> void:
	_pen_tween = tween
	_pen.play()


func _stop_pen(tween: Tween) -> void:
	if _pen_tween == tween:
		_pen.stop()
		_pen_tween = null


## The texture cut down to its visible (non-transparent) part, so a stone drawn
## on a full-screen canvas fills the sketch box.
func _sketch(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if not _sketch_cache.has(path):
		var texture := load(path) as Texture2D if ResourceLoader.exists(path, "Texture2D") else null
		if not texture: return null
		var image := texture.get_image()
		if not image: return null
		if image.is_compressed():
			image.decompress()
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(image.get_used_rect())
		_sketch_cache[path] = atlas
	return _sketch_cache[path]
