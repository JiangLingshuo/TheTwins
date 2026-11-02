extends Control
## Book overlay.
## 1. wake(): the closed book flies in from the bottom-right corner to the centre.
## 2. The player writes a name on the cover and presses Enter.
## 3. The cover swings open to the first spread.
## 4. Hover a bottom corner to curl it; click it to turn the page.
## 5. Turning past the last page closes the book and shrinks it into a
##    bottom-right corner icon, then `closed` is emitted.
## 6. Clicking the icon brings the book back, open at the spread it was left on.
##
## Use write() to add text to a page: the book opens and turns to that page by
## itself, then the text appears letter by letter with the writing sound.
##
## With use_sections on (the in-game notebook), the spreads are split into the
## sections in SECTION_TITLES, with an index tab for each. Turning back past the
## first spread closes the book as well.

signal opened(player_name: String)
signal page_changed(spread: int)
signal closed
## Emitted when write() has finished writing on a page.
signal written(page_index: int)

const SOUND_FLIP: AudioStream = preload("res://assets/audio/翻书声.wav")
const SOUND_WRITE: AudioStream = preload("res://assets/audio/写字声.wav")
const PAPER_SHADER: Shader = preload("res://shaders/notebook_paper.gdshader")
const PAGE_SIZE := Vector2(420, 584)
const FOLDED_TINT := Color(0.55, 0.55, 0.55)
## Notebook sections, in order (only used when use_sections is on).
const SECTION_TITLES: PackedStringArray = ["Gravestones", "Rubbings", "Clues", "Manuscripts", "Radio Logs"]
## Fixed single-page slots in the Gravestones section (two per spread).
const GRAVESTONE_SLOTS := 6
## Gravestone id on each Gravestones slot, in page order: even slots are the
## Day pages on the left, odd slots the Night pages on the right. "" = not set yet.
const GRAVESTONE_SLOT_IDS: PackedStringArray = ["baby_tomb", "", "", "", "", ""]
## Notebook page info for each gravestone id (see gravestone_page.gd setup()).
const GRAVESTONE_INFO := {
	"baby_tomb": {
		"sketch": "res://assets/Art/day/baby.png",
		"description": "",
		"rubbings": [],
		"clues": [],
	},
}

## Page texts, in reading order. Page 0 is the inside of the cover (left),
## page 1 is the first right-hand page, and so on. "#PLAYER#" (or "{name}") becomes the player's name.
@export_multiline var pages: PackedStringArray = ["", "", "", "", "", ""]
## Split the book into sections with index tabs (the in-game notebook).
@export var use_sections: bool = false
## Seconds for each half of a page turn.
@export var flip_time: float = 0.28
## Seconds for the book to fly in.
@export var wake_time: float = 0.9
## Seconds for the closed book to shrink into the corner icon.
@export var stow_time: float = 0.8
## Size of the corner icon, relative to the full book.
@export var icon_scale: float = 0.12
## Distance of the icon's centre from the bottom-right corner of the screen.
@export var icon_margin: Vector2 = Vector2(70, 70)
## Writing speed of write(), in characters per second.
@export_range(1.0, 100.0, 1.0) var write_chars_per_second: float = 18.0
## Loudness of the page turn sound, in decibels (0 = original level).
@export_range(-40.0, 6.0, 0.5) var flip_volume_db: float = 0.0
## Loudness of the writing sound, in decibels (0 = original level).
@export_range(-40.0, 6.0, 0.5) var write_volume_db: float = 0.0

@export_group("Day/Night pages")
## Sections (indices into SECTION_TITLES) whose spreads show a Day page on the
## left and a Night page on the right. Other sections keep the normal paper.
@export var day_night_sections: PackedInt32Array = [0]
@export var day_paper: Color = Color(0.96, 0.92, 0.82)
@export var day_ink: Color = Color(0.2, 0.15, 0.11)
@export var night_paper: Color = Color(0.14, 0.16, 0.22)
@export var night_ink: Color = Color(0.94, 0.91, 0.84)
## Opacity of the faint linework (placeholders, notes) on each page theme.
@export_range(0.0, 1.0, 0.05) var day_faded_alpha: float = 0.45
@export_range(0.0, 1.0, 0.05) var night_faded_alpha: float = 0.7

@onready var left_page: Panel = $LeftPage
@onready var left_text: Label = $LeftPage/Text
@onready var left_number: Label = $LeftPage/Number
@onready var right_page: Panel = $RightPage
@onready var right_text: Label = $RightPage/Text
@onready var right_number: Label = $RightPage/Number
@onready var left_corner: PageCorner = $LeftCorner
@onready var right_corner: PageCorner = $RightCorner
@onready var flip_sheet: Panel = $FlipSheet
@onready var flip_text: Label = $FlipSheet/Text
@onready var flip_number: Label = $FlipSheet/Number
@onready var cover: Panel = $Cover
@onready var name_input: LineEdit = $Cover/NameInput
@onready var hint_label: Label = $Cover/Hint
@onready var tabs: Control = $Tabs

var _spread := 0
var _busy := true
var _locked := false
var _stowed := false
var _opened := false
var _writing := false
var _home_position := Vector2.ZERO
var _style_left: StyleBox
var _style_right: StyleBox
var _flip_player: AudioStreamPlayer
var _write_player: AudioStreamPlayer
## Spreads in each section, in SECTION_TITLES order. The current section and the
## spread within it are worked out from _spread, so there is one position only.
var section_spreads: PackedInt32Array = [GRAVESTONE_SLOTS / 2, 1, 1, 1, 1]
var _day_material: ShaderMaterial
var _night_material: ShaderMaterial
var _normal_ink: Color
var _normal_number_ink: Color


func _ready() -> void:
	visible = false
	_style_left = left_page.get_theme_stylebox("panel")
	_style_right = right_page.get_theme_stylebox("panel")
	_setup_page_themes()
	left_page.visible = false
	right_page.visible = false  # would stick out around the closed cover
	flip_sheet.visible = false
	_set_corners_visible(false)
	tabs.visible = false
	flip_sheet.get_node("Gravestone").set_interactive(false)  # a picture of the page
	if use_sections:
		tabs.setup(SECTION_TITLES)
		tabs.tab_pressed.connect(jump_to_section)
	left_corner.pressed.connect(flip_backward)
	right_corner.pressed.connect(flip_forward)
	name_input.text_submitted.connect(_on_name_submitted)
	cover.gui_input.connect(_on_cover_gui_input)

	_flip_player = _make_player(SOUND_FLIP, flip_volume_db)
	_flip_player.max_polyphony = 3  # let the tail ring out when pages turn quickly
	_write_player = _make_player(SOUND_WRITE, write_volume_db)
	_write_player.finished.connect(_on_write_sound_finished)


## Fly the closed book in from the bottom-right corner.
func wake() -> void:
	await get_tree().process_frame  # make sure the layout is ready
	_home_position = position
	var screen := get_viewport_rect().size

	position = Vector2(screen.x - 120.0, screen.y - 80.0) - pivot_offset
	scale = Vector2.ONE * 0.12
	rotation_degrees = 28.0
	modulate.a = 0.0
	visible = true

	var t := create_tween().set_parallel(true)
	t.tween_property(self, "position", _closed_position(), wake_time) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "scale", Vector2.ONE, wake_time) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "rotation_degrees", 0.0, wake_time) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "modulate:a", 1.0, wake_time * 0.4)
	await t.finished
	name_input.grab_focus()


func flip_forward() -> void:
	if _busy or _locked:
		return
	if not _can_flip_forward():
		close_to_icon()
		return
	_turn_forward()


func flip_backward() -> void:
	if _busy or _locked:
		return
	if not _can_flip_backward():
		# The sectioned notebook closes from its first spread too.
		if use_sections:
			close_to_icon()
		return
	_turn_backward()


## Turn straight to the first spread of a section, in a single page turn.
func jump_to_section(section: int) -> void:
	if _busy or _locked or _stowed or not _opened or not use_sections:
		return
	var target := _section_start(clampi(section, 0, section_spreads.size() - 1))
	if target > _spread:
		_turn_forward(target)
	elif target < _spread:
		_turn_backward(target)


## Section the current spread belongs to (index into SECTION_TITLES).
func get_section() -> int:
	return _section_of(_spread)


## Which spread of its section is showing (0 = the section's first spread).
func get_section_spread() -> int:
	return _spread - _section_start(get_section())


## True if the gravestone on a slot (0 to GRAVESTONE_SLOTS - 1) has been
## recorded (GameState.gravestones).
func is_gravestone_collected(slot: int) -> bool:
	if slot < 0 or slot >= GRAVESTONE_SLOT_IDS.size():
		return false
	var id := GRAVESTONE_SLOT_IDS[slot]
	return not id.is_empty() and GameState.gravestones.has(id)


## Write `text` on a page. The book opens and turns to that page by itself, and
## the next page is written once the current one is done. By default the text
## goes on a new line after what the page already holds; pass append = false to
## replace it. Before the book is first opened the text is just stored.
func write(page_index: int, text: String, append: bool = true) -> void:
	if page_index < 0:
		push_error("Book: cannot write on page %d" % page_index)
		return
	if page_index >= pages.size():
		pages.resize(page_index + 1)
	if not _opened:
		pages[page_index] = _merge_text(pages[page_index], text, append)
		return

	while _busy and not _stowed:
		await get_tree().process_frame
	if _stowed:
		await open_from_icon()
	await _turn_to(page_index / 2)
	_busy = true
	_set_corners_visible(false)

	var on_left := page_index % 2 == 0
	var text_label := left_text if on_left else right_text
	var number_label := left_number if on_left else right_number
	var written_length := text_label.text.length() if append else 0
	pages[page_index] = _merge_text(pages[page_index], text, append)
	_fill(text_label, number_label, page_index)

	var total_length := text_label.text.length()
	text_label.visible_characters = written_length
	_writing = true
	_write_player.play()
	var t := create_tween()
	t.tween_property(text_label, "visible_characters", total_length,
		(total_length - written_length) / write_chars_per_second)
	await t.finished
	_writing = false
	_write_player.stop()
	text_label.visible_characters = -1

	_busy = false
	_set_corners_visible(true)
	written.emit(page_index)


func _merge_text(existing: String, text: String, append: bool) -> String:
	if append and not existing.is_empty():
		return existing + "\n" + text
	return text


## Turn page by page until the given spread is showing.
func _turn_to(spread: int) -> void:
	while _spread < spread:
		await _turn_forward()
	while _spread > spread:
		await _turn_backward()


## Turn one page forward, or to spread `to` in a single turn.
func _turn_forward(to: int = -1) -> void:
	_busy = true
	_release_page_focus()
	_set_corners_visible(false)
	_flip_player.play()
	var next := _spread + 1 if to < 0 else to
	# The current right page lifts and turns over the spine...
	_prepare_sheet(false, _spread * 2 + 1)
	_fill(right_text, right_number, next * 2 + 1)
	await _fold_sheet(true)
	# ...and lands on the left, showing its back.
	_prepare_sheet(true, next * 2)
	await _fold_sheet(false)
	_fill(left_text, left_number, next * 2)
	_finish_flip(next)


## Turn one page back, or to spread `to` in a single turn.
func _turn_backward(to: int = -1) -> void:
	_busy = true
	_release_page_focus()
	_set_corners_visible(false)
	_flip_player.play()
	var prev := _spread - 1 if to < 0 else to
	_prepare_sheet(true, _spread * 2)
	_fill(left_text, left_number, prev * 2)
	await _fold_sheet(true)
	_prepare_sheet(false, prev * 2 + 1)
	await _fold_sheet(false)
	_fill(right_text, right_number, prev * 2 + 1)
	_finish_flip(prev)


## Close the cover over the current spread, then shrink the book into the
## bottom-right corner, where it stays as an icon.
func close_to_icon() -> void:
	_busy = true
	_release_page_focus()
	_set_corners_visible(false)
	tabs.visible = false
	hint_label.visible = false
	_flip_player.play()

	# Slide back so the closed book is centred.
	create_tween().tween_property(self, "position", _closed_position(), flip_time * 2.0) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# The left page folds onto the spine...
	_prepare_sheet(true, _spread * 2)
	left_page.visible = false
	await _fold_sheet(true)
	flip_sheet.visible = false

	# ...and comes down on the right as the front cover.
	cover.visible = true
	cover.pivot_offset = Vector2(0, PAGE_SIZE.y / 2.0)
	cover.scale.x = 0.0
	cover.modulate = FOLDED_TINT
	var t := create_tween().set_parallel(true)
	t.tween_property(cover, "scale:x", 1.0, flip_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(cover, "modulate", Color.WHITE, flip_time)
	await t.finished
	right_page.visible = false

	# Shrink into the corner. The closed book is the right half, so offset by
	# its distance from the pivot to centre it on the icon spot.
	var screen := get_viewport_rect().size
	var cover_offset := Vector2(cover.size.x / 2.0, 0) * icon_scale
	var icon_position := screen - icon_margin - pivot_offset - cover_offset
	var s := create_tween().set_parallel(true)
	s.tween_property(self, "position", icon_position, stow_time) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	s.tween_property(self, "scale", Vector2.ONE * icon_scale, stow_time) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	s.tween_property(self, "rotation_degrees", -8.0, stow_time) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await s.finished
	_stowed = true
	cover.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	closed.emit()


## Open an already-named book in a new scene: it flies in closed, then the cover
## swings open on `spread`. `saved_pages` restores what was written earlier.
func open_saved(saved_pages: PackedStringArray, spread: int) -> void:
	if not saved_pages.is_empty():
		pages = saved_pages
	_opened = true
	_spread = clampi(spread, 0, maxi(0, _spread_count() - 1))
	name_input.text = GameState.player_name
	name_input.editable = false
	name_input.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint_label.visible = false
	await wake()
	name_input.release_focus()
	await _open_cover()
	opened.emit(GameState.player_name)


## Close the book into its icon spot (does nothing while a page is turning).
func close() -> void:
	if _busy or _stowed or not visible:
		return
	await close_to_icon()


## True while the book is out and open (not stowed as an icon).
func is_open() -> bool:
	return visible and _opened and not _stowed


## Which spread is showing (0 = inside cover + page 1).
func get_spread() -> int:
	return _spread


## Choose the spread a put-away book opens on next (ignored while it is open).
func set_closed_spread(spread: int) -> void:
	if _stowed or not _opened:
		_spread = clampi(spread, 0, maxi(0, _spread_count() - 1))


## Spread holding gravestone `id`'s page in the Gravestones section, or -1.
func get_gravestone_spread(id: String) -> int:
	var slot := GRAVESTONE_SLOT_IDS.find(id)
	if not use_sections or id.is_empty() or slot < 0:
		return -1
	return _section_start(0) + slot / 2


## Bring the book back from the corner icon and open it where it was left.
func open_from_icon() -> void:
	if not _stowed:
		return
	_stowed = false
	cover.mouse_default_cursor_shape = Control.CURSOR_ARROW

	var t := create_tween().set_parallel(true)
	t.tween_property(self, "position", _closed_position(), stow_time) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "scale", Vector2.ONE, stow_time) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "rotation_degrees", 0.0, stow_time) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await t.finished
	await _open_cover()


## Where the book sits so the closed cover is in the centre of the screen.
func _closed_position() -> Vector2:
	return _home_position - Vector2(cover.size.x / 2.0, 0)


func _on_cover_gui_input(event: InputEvent) -> void:
	if _stowed and event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		cover.accept_event()
		open_from_icon()


## Lock or unlock page turning (used while a dialogue is showing).
func set_locked(value: bool) -> void:
	_locked = value
	if not _busy:
		_set_corners_visible(true)


func _on_name_submitted(text: String) -> void:
	var player_name := text.strip_edges()
	if player_name.is_empty():
		_nudge_hint()
		return
	GameState.player_name = player_name
	name_input.editable = false
	name_input.release_focus()
	# Let clicks on the name fall through to the cover (for the corner icon).
	name_input.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_spread = 0
	_opened = true
	await _open_cover()
	Tutorial.show_once(Tutorial.TURN_PAGE, right_corner)
	opened.emit(GameState.player_name)


## Swing the cover open onto the current spread.
func _open_cover() -> void:
	_busy = true
	_fill(right_text, right_number, _spread * 2 + 1)
	right_page.visible = true
	_flip_player.play()

	# Slide the book so the open spread ends up centred.
	create_tween().tween_property(self, "position", _home_position, flip_time * 2.0) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Swing the cover over the spine...
	cover.pivot_offset = Vector2(0, PAGE_SIZE.y / 2.0)
	var t := create_tween().set_parallel(true)
	t.tween_property(cover, "scale:x", 0.0, flip_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	t.tween_property(cover, "modulate", FOLDED_TINT, flip_time)
	await t.finished
	cover.visible = false

	# ...its inside becomes the left page.
	_prepare_sheet(true, _spread * 2)
	await _fold_sheet(false)
	_fill(left_text, left_number, _spread * 2)
	left_page.visible = true
	_finish_flip(_spread)


# --- Sound helpers -----------------------------------------------------------

func _make_player(stream: AudioStream, volume_db: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	add_child(player)
	return player


## Keep the writing sound going if a long text outlasts the recording.
func _on_write_sound_finished() -> void:
	if _writing:
		_write_player.play()


# --- Page turning helpers ---------------------------------------------------

## Put the turning sheet over the left or right half, showing the given page.
func _prepare_sheet(on_left: bool, page_index: int) -> void:
	flip_sheet.visible = true
	flip_sheet.position = Vector2(0.0 if on_left else PAGE_SIZE.x, 0.0)
	flip_sheet.pivot_offset = Vector2(PAGE_SIZE.x if on_left else 0.0, PAGE_SIZE.y / 2.0)
	flip_sheet.add_theme_stylebox_override("panel", _style_left if on_left else _style_right)
	# The text sits at a different spot on each side, to stay centred on the paper.
	flip_text.position = (left_text if on_left else right_text).position
	flip_number.position = (left_number if on_left else right_number).position
	flip_sheet.get_node("Art").position = (left_page if on_left else right_page).get_node("Art").position
	flip_sheet.get_node("Gravestone").position = (left_page if on_left else right_page).get_node("Gravestone").position
	_fill(flip_text, flip_number, page_index)


## Squash the sheet towards the spine (folding = true) or open it out from the spine.
func _fold_sheet(folding: bool) -> void:
	flip_sheet.scale.x = 1.0 if folding else 0.0
	flip_sheet.modulate = Color.WHITE if folding else FOLDED_TINT
	var t := create_tween().set_parallel(true)
	t.tween_property(flip_sheet, "scale:x", 0.0 if folding else 1.0, flip_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN if folding else Tween.EASE_OUT)
	t.tween_property(flip_sheet, "modulate", FOLDED_TINT if folding else Color.WHITE, flip_time)
	await t.finished


func _finish_flip(spread: int) -> void:
	flip_sheet.visible = false
	_spread = spread
	_busy = false
	_set_corners_visible(true)
	if use_sections:
		tabs.visible = true
		tabs.set_active(get_section())
	page_changed.emit(_spread)


func _fill(text_label: Label, number_label: Label, page_index: int) -> void:
	var content: String = pages[page_index] if page_index < pages.size() else ""
	text_label.text = GameState.fill_placeholders(content)
	number_label.text = str(page_index) if page_index > 0 and not content.is_empty() else ""
	# Each page (and the turning sheet) has an Art node next to its labels.
	_fill_art(text_label.get_parent().get_node("Art"), page_index)
	_fill_gravestone(text_label.get_parent().get_node("Gravestone"), page_index)
	_apply_page_theme(text_label, number_label, page_index)


## Show the gravestone page on a Gravestones slot (a blank one with a "?" sketch
## until its gravestone is recorded), or hide it on other pages.
func _fill_gravestone(gravestone_page: Control, page_index: int) -> void:
	var slot := _gravestone_slot(page_index)
	gravestone_page.visible = slot >= 0
	if is_gravestone_collected(slot):
		var id := GRAVESTONE_SLOT_IDS[slot]
		gravestone_page.setup(id, GRAVESTONE_INFO.get(id, {}))
	elif slot >= 0:
		gravestone_page.setup_unknown()


## Gravestones slot shown on a page, or -1 if the page is not a gravestone slot.
func _gravestone_slot(page_index: int) -> int:
	if not use_sections or page_index / 2 >= _spread_count() or _section_of(page_index / 2) != 0:
		return -1
	var slot := page_index - _section_start(0) * 2
	return slot if slot < GRAVESTONE_SLOTS else -1


## Take the keyboard away from the page's text fields before it turns or closes.
func _release_page_focus() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	if focused and is_ancestor_of(focused):
		focused.release_focus()


# --- Day / Night page themes -------------------------------------------------

func _setup_page_themes() -> void:
	_day_material = _make_paper_material(day_paper)
	_night_material = _make_paper_material(night_paper)
	# The labels share their LabelSettings in the scene; give each its own copy
	# so a Night page can have light ink without changing the other pages.
	for label: Label in [left_text, left_number, right_text, right_number, flip_text, flip_number]:
		label.label_settings = label.label_settings.duplicate()
	_normal_ink = left_text.label_settings.font_color
	_normal_number_ink = left_number.label_settings.font_color


func _make_paper_material(paper: Color) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = PAPER_SHADER
	material.set_shader_parameter("paper_color", paper)
	return material


## Colour a page (its paper, text, number and drawing) for the theme of
## page_index. The turning sheet is coloured per face the same way.
func _apply_page_theme(text_label: Label, number_label: Label, page_index: int) -> void:
	var page: Panel = text_label.get_parent()
	var art := page.get_node("Art")
	var gravestone_page := page.get_node("Gravestone")
	var day_night := use_sections and page_index / 2 < _spread_count() \
		and day_night_sections.has(_section_of(page_index / 2))
	if not day_night:
		page.material = null
		text_label.label_settings.font_color = _normal_ink
		number_label.label_settings.font_color = _normal_number_ink
		art.reset_ink()
		gravestone_page.set_ink(_normal_ink)
		return
	var is_day := page_index % 2 == 0  # Day on the left, Night on the right
	var ink := day_ink if is_day else night_ink
	page.material = _day_material if is_day else _night_material
	text_label.label_settings.font_color = ink
	number_label.label_settings.font_color = Color(ink, 0.8)
	art.set_ink(ink, day_faded_alpha if is_day else night_faded_alpha)
	gravestone_page.set_ink(ink)


## Draw the section placeholder for a page (nothing without sections).
func _fill_art(art: Control, page_index: int) -> void:
	var spread := page_index / 2
	if not use_sections or spread >= _spread_count():
		art.clear()
		return
	var section := _section_of(spread)
	var first_page := _section_start(section) * 2
	if section == 0:
		art.clear()  # every slot shows a gravestone page instead
	elif page_index == first_page:
		art.show_title(SECTION_TITLES[section])
	elif page_index == first_page + 1:
		art.show_note("No entries yet")
	else:
		art.clear()


## Number of spreads the book has.
func _spread_count() -> int:
	if use_sections:
		var total := 0
		for count in section_spreads:
			total += count
		return total
	return (pages.size() + 1) / 2


## First spread of a section.
func _section_start(section: int) -> int:
	var start := 0
	for i in section:
		start += section_spreads[i]
	return start


## Section a spread belongs to.
func _section_of(spread: int) -> int:
	var end := 0
	for i in section_spreads.size():
		end += section_spreads[i]
		if spread < end:
			return i
	return section_spreads.size() - 1


func _can_flip_forward() -> bool:
	return _spread + 1 < _spread_count()


func _can_flip_backward() -> bool:
	return _spread > 0


func _set_corners_visible(enabled: bool) -> void:
	left_corner.reset()
	right_corner.reset()
	# With sections, the left corner on the first spread closes the book.
	left_corner.visible = enabled and not _locked and (use_sections or _can_flip_backward())
	# On the last spread the right corner closes the book.
	right_corner.visible = enabled and not _locked


func _nudge_hint() -> void:
	hint_label.text = "Please write your name first"
	var t := create_tween()
	for i in 2:
		t.tween_property(hint_label, "modulate:a", 0.2, 0.12)
		t.tween_property(hint_label, "modulate:a", 1.0, 0.12)
	name_input.grab_focus()
