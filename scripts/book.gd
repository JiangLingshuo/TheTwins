extends Control
## Book overlay.
## 1. wake(): the closed book flies in from the bottom-right corner to the centre.
## 2. The player writes a name on the cover and presses Enter.
## 3. The cover swings open to the first spread (dark left page, ivory right page).
## 4. Hover a bottom corner to curl it; click it to turn the page.
## 5. Turning past the last page closes the book and shrinks it into a
##    bottom-right corner icon, then `closed` is emitted.
## 6. Clicking the icon brings the book back, open at the spread it was left on.

signal opened(player_name: String)
signal page_changed(spread: int)
signal closed

const PAGE_SIZE := Vector2(440, 580)
const INK_ON_DARK := Color(0.86, 0.83, 0.76)
const INK_ON_IVORY := Color(0.17, 0.14, 0.12)
const FOLDED_TINT := Color(0.55, 0.55, 0.55)

## Page texts, in reading order. Page 0 is the inside of the cover (left),
## page 1 is the first right-hand page, and so on. "#PLAYER#" (or "{name}") becomes the player's name.
@export_multiline var pages: PackedStringArray = ["", "", "", "", "", ""]
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

@onready var left_page: Panel = $LeftPage
@onready var left_text: Label = $LeftPage/Text
@onready var left_number: Label = $LeftPage/Number
@onready var right_page: Panel = $RightPage
@onready var right_text: Label = $RightPage/Text
@onready var right_number: Label = $RightPage/Number
@onready var spine: ColorRect = $Spine
@onready var left_corner: PageCorner = $LeftCorner
@onready var right_corner: PageCorner = $RightCorner
@onready var flip_sheet: Panel = $FlipSheet
@onready var flip_text: Label = $FlipSheet/Text
@onready var flip_number: Label = $FlipSheet/Number
@onready var cover: Panel = $Cover
@onready var name_input: LineEdit = $Cover/Content/NameRow/NameInput
@onready var hint_label: Label = $Cover/Content/Hint

var _spread := 0
var _busy := true
var _locked := false
var _stowed := false
var _home_position := Vector2.ZERO
var _style_dark: StyleBox
var _style_ivory: StyleBox


func _ready() -> void:
	visible = false
	_style_dark = left_page.get_theme_stylebox("panel")
	_style_ivory = right_page.get_theme_stylebox("panel")
	left_page.visible = false
	spine.visible = false
	flip_sheet.visible = false
	_set_corners_visible(false)
	left_corner.pressed.connect(flip_backward)
	right_corner.pressed.connect(flip_forward)
	name_input.text_submitted.connect(_on_name_submitted)
	cover.gui_input.connect(_on_cover_gui_input)


## Fly the closed book in from the bottom-right corner.
func wake() -> void:
	await get_tree().process_frame  # make sure the layout is ready
	_home_position = position
	var closed_position := _home_position - Vector2(PAGE_SIZE.x / 2.0, 0)
	var screen := get_viewport_rect().size

	position = Vector2(screen.x - 120.0, screen.y - 80.0) - pivot_offset
	scale = Vector2.ONE * 0.12
	rotation_degrees = 28.0
	modulate.a = 0.0
	visible = true

	var t := create_tween().set_parallel(true)
	t.tween_property(self, "position", closed_position, wake_time) \
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
	_busy = true
	_set_corners_visible(false)
	var next := _spread + 1
	# The current right page lifts and turns over the spine...
	_prepare_sheet(false, _spread * 2 + 1)
	_fill(right_text, right_number, next * 2 + 1)
	await _fold_sheet(true)
	# ...and lands on the left, showing its back.
	_prepare_sheet(true, next * 2)
	await _fold_sheet(false)
	_fill(left_text, left_number, next * 2)
	_finish_flip(next)


func flip_backward() -> void:
	if _busy or _locked or not _can_flip_backward():
		return
	_busy = true
	_set_corners_visible(false)
	var prev := _spread - 1
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
	_set_corners_visible(false)
	hint_label.visible = false

	# Slide back so the closed book is centred.
	var closed_position := _home_position - Vector2(PAGE_SIZE.x / 2.0, 0)
	create_tween().tween_property(self, "position", closed_position, flip_time * 2.0) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# The left page folds onto the spine...
	_prepare_sheet(true, _spread * 2)
	left_page.visible = false
	await _fold_sheet(true)
	flip_sheet.visible = false
	spine.visible = false

	# ...and comes down on the right as the front cover.
	cover.visible = true
	cover.pivot_offset = Vector2(0, PAGE_SIZE.y / 2.0)
	cover.scale.x = 0.0
	cover.modulate = FOLDED_TINT
	var t := create_tween().set_parallel(true)
	t.tween_property(cover, "scale:x", 1.0, flip_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(cover, "modulate", Color.WHITE, flip_time)
	await t.finished

	# Shrink into the corner. The closed book is the right half, so offset by
	# its distance from the pivot to centre it on the icon spot.
	var screen := get_viewport_rect().size
	var cover_offset := Vector2(PAGE_SIZE.x / 2.0, 0) * icon_scale
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


## Bring the book back from the corner icon and open it where it was left.
func open_from_icon() -> void:
	if not _stowed:
		return
	_stowed = false
	cover.mouse_default_cursor_shape = Control.CURSOR_ARROW

	var closed_position := _home_position - Vector2(PAGE_SIZE.x / 2.0, 0)
	var t := create_tween().set_parallel(true)
	t.tween_property(self, "position", closed_position, stow_time) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "scale", Vector2.ONE, stow_time) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "rotation_degrees", 0.0, stow_time) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await t.finished
	_open_cover()


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
	await _open_cover()
	opened.emit(GameState.player_name)


## Swing the cover open onto the current spread.
func _open_cover() -> void:
	_busy = true
	_fill(right_text, right_number, _spread * 2 + 1)
	right_page.visible = true

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
	spine.visible = true

	# ...its inside becomes the left page.
	_prepare_sheet(true, _spread * 2)
	await _fold_sheet(false)
	_fill(left_text, left_number, _spread * 2)
	left_page.visible = true
	_finish_flip(_spread)


# --- Page turning helpers ---------------------------------------------------

## Put the turning sheet over the left or right half, showing the given page.
func _prepare_sheet(on_left: bool, page_index: int) -> void:
	flip_sheet.visible = true
	flip_sheet.position = Vector2(0.0 if on_left else PAGE_SIZE.x, 0.0)
	flip_sheet.pivot_offset = Vector2(PAGE_SIZE.x if on_left else 0.0, PAGE_SIZE.y / 2.0)
	flip_sheet.add_theme_stylebox_override("panel", _style_dark if on_left else _style_ivory)
	var ink := INK_ON_DARK if on_left else INK_ON_IVORY
	flip_text.add_theme_color_override("font_color", ink)
	flip_number.add_theme_color_override("font_color", ink)
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
	page_changed.emit(_spread)


func _fill(text_label: Label, number_label: Label, page_index: int) -> void:
	var content: String = pages[page_index] if page_index < pages.size() else ""
	text_label.text = GameState.fill_placeholders(content)
	number_label.text = str(page_index) if page_index > 0 and not content.is_empty() else ""


func _can_flip_forward() -> bool:
	return (_spread + 1) * 2 < pages.size()


func _can_flip_backward() -> bool:
	return _spread > 0


func _set_corners_visible(enabled: bool) -> void:
	left_corner.reset()
	right_corner.reset()
	left_corner.visible = enabled and not _locked and _can_flip_backward()
	# On the last spread the right corner closes the book.
	right_corner.visible = enabled and not _locked


func _nudge_hint() -> void:
	hint_label.text = "Please write your name first"
	var t := create_tween()
	for i in 2:
		t.tween_property(hint_label, "modulate:a", 0.2, 0.12)
		t.tween_property(hint_label, "modulate:a", 1.0, 0.12)
	name_input.grab_focus()
