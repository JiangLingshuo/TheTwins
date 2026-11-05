extends Control
## Drags a collected rubbing (deciphered or not) from the notebook onto the scene.
## The notebook's Rubbings pages start it with begin(); the symbol then follows
## the mouse. Leaving the book closes the notebook (the drag goes on). Releasing
## over a DecipherTarget has one of three results:
##   1. the target is the rubbing's own object: its meaning is confirmed
##      (GameState.confirm_rubbing_meaning) -> `deciphered`;
##   2. the pair is listed in rubbing_reveals.json: its clue is recorded -> `clue_revealed`;
##   3. anything else -> `mismatched`.
## Results 1 and 2 happen once; repeating them emits `already_noted` instead.
## Rubbings can also be deciphered by asking Aurora over the radio.
## The sun and moon icons drag as on the Rise & Set page (begin_cycle()).
## It also shows the hover hint for the Rubbings entries. One drag at a time;
## it lives in the notebook tool.
##
## Input is read in _input, so it keeps working while the book's pages are
## hidden and the dark overlay is still fading.

## Emitted when a dropped rubbing matched the object under it.
signal deciphered(rubbing_id: String, target: Control)
## Sky substitution changes location/time, not the symbol’s funerary meaning.
signal sky_replaced(rubbing_id: String, target: Control)
## Emitted when a dropped rubbing revealed a clue (already recorded in GameState).
signal clue_revealed(rubbing_id: String, target: Control, clue_id: String)
## Emitted when a decipher or reveal that already happened is repeated.
signal already_noted(rubbing_id: String, target: Control)
## Emitted when a rubbing was dropped on the scene but not on its object
## (`target` is the object under it, or null).
signal mismatched(rubbing_id: String, target: Control)

const FONT: Font = preload("res://assets/fonts/CormorantGaramond-Regular.ttf")

@export var hint_text: String = "Drag this symbol onto an object in the scene to uncover its meaning or a new clue. You can also ask Aurora about it over the radio."
## Largest size of the dragged symbol, in screen pixels.
@export var symbol_size: Vector2 = Vector2(64, 64)
@export var symbol_color: Color = Color(0.98, 0.96, 0.9)
@export var shadow_color: Color = Color(0.1, 0.08, 0.06, 0.7)
@export var hint_paper: Color = Color(0.96, 0.92, 0.82, 0.96)
@export var hint_ink: Color = Color(0.2, 0.15, 0.11)
@export var hint_font_size: int = 17

## Id of the rubbing being dragged ("" when there is no drag).
var rubbing_id := ""

var _cycle_drag := false
var _texture: Texture2D
var _pointer := Vector2.ZERO
var _left_book := false
var _hint: PanelContainer

@onready var _tool: Control = get_parent()


func _ready() -> void:
	add_to_group("rubbing_drag")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_as_relative = false
	z_index = 100  # above the scene, the notebook and the toast
	_build_hint()


func is_dragging() -> bool:
	return not rubbing_id.is_empty()


## Start dragging a collected rubbing from screen position `pointer`.
## Returns false if no drag started.
func begin(id: String, pointer: Vector2) -> bool:
	if id in ["sky_sun_rubbing", "infant_moon_rubbing"]:
		return begin_cycle(id, pointer)
	if is_dragging() or not GameState.rubbings.has(id):
		return false
	rubbing_id = id
	var path := GameState.get_rubbing_texture(id)
	_texture = load(path) if not path.is_empty() and ResourceLoader.exists(path) else null
	_pointer = pointer
	_left_book = false
	hide_hint()
	queue_redraw()
	return true


## Sky icons remain reusable after the tutorial and after ordinary deciphering.
func begin_cycle(id: String, pointer: Vector2) -> bool:
	if is_dragging() or not GameState.cycle_hint_heard or id not in ["sky_sun_rubbing", "infant_moon_rubbing"]:
		return false
	# The moon is in the notebook before the sun (which it brings down from the sky).
	if not GameState.rubbings.has(id):
		return false
	rubbing_id = id
	_cycle_drag = true
	var path := GameState.get_rubbing_texture(id)
	_texture = load(path) if not path.is_empty() and ResourceLoader.exists(path) else null
	_pointer = pointer
	_left_book = false
	hide_hint()
	queue_redraw()
	return true


## Stop the drag without changing anything.
func cancel() -> void:
	_cycle_drag = false
	rubbing_id = ""
	_texture = null
	_left_book = false
	queue_redraw()


## Show the hover hint next to screen position `pointer`.
func show_hint(pointer: Vector2) -> void:
	if is_dragging():
		return
	_hint.visible = true
	_hint.reset_size()
	var screen := get_viewport_rect().size
	var at := pointer + Vector2(18, 22)
	at.x = minf(at.x, screen.x - _hint.size.x - 8.0)
	at.y = minf(at.y, screen.y - _hint.size.y - 8.0)
	_hint.global_position = at


func hide_hint() -> void:
	_hint.visible = false


func _input(event: InputEvent) -> void:
	if not is_dragging():
		return
	if event is InputEventMouseMotion:
		_pointer = event.global_position
		if not _left_book and not _over_book(_pointer):
			_left_book = true
		if _left_book and _tool.is_open():
			_tool.close()  # ignored while a page is turning; tried again on the next move
		queue_redraw()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_drop(event.global_position)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		cancel()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT and is_dragging():
		cancel()


func _drop(pointer: Vector2) -> void:
	var id := rubbing_id
	var cycle_drop := _cycle_drag
	var in_scene := _left_book and get_viewport_rect().has_point(pointer)
	cancel()
	if not in_scene:
		return  # released inside the book or outside the window: just cancelled
	var target := _target_at(pointer)
	if cycle_drop:
		if target and ((id == "infant_moon_rubbing" and target.target_id == "sky_sun") or (id == "sky_sun_rubbing" and target.target_id == "moon" and GameState.cycle_tutorial_completed)):
			sky_replaced.emit(id, target)
		else:
			mismatched.emit(id, target)
		return
	if target == null:
		mismatched.emit(id, null)
		return
	# 2. A match that reveals a clue.
	var reveal := GameState.find_rubbing_reveal(id, target.target_id)
	if not reveal.is_empty():
		var clue: String = reveal.get("clue", "")
		if GameState.evidence_ids.has(clue):
			already_noted.emit(id, target)
		elif GameState.record_evidence(clue):
			clue_revealed.emit(id, target, clue)
		return
	# 1. A match that deciphers the rubbing (it may already be deciphered, e.g. by Aurora).
	var wanted := GameState.get_rubbing_target(id)
	if not wanted.is_empty() and target.target_id == wanted:
		if GameState.is_rubbing_deciphered(id):
			already_noted.emit(id, target)
		elif GameState.confirm_rubbing_meaning(id, target.get_meaning()):
			deciphered.emit(id, target)
		return
	# 3. No match.
	mismatched.emit(id, target)


## The topmost DecipherTarget showing at a screen position, or null.
func _target_at(pointer: Vector2) -> Control:
	var targets := get_tree().get_nodes_in_group("decipher_targets")
	targets.reverse()  # later in the tree = drawn on top
	for target in targets:
		if target.contains_point(pointer):
			return target
	return null


func _over_book(pointer: Vector2) -> bool:
	var book: Control = _tool.book
	if not book.visible:
		return false
	return book.left_page.get_global_rect().merge(book.right_page.get_global_rect()).has_point(pointer)


func _draw() -> void:
	if not is_dragging() or _texture == null:
		return
	var fit := minf(symbol_size.x / _texture.get_width(), symbol_size.y / _texture.get_height())
	var drawn := Vector2(_texture.get_size()) * fit
	var centre := get_global_transform().affine_inverse() * _pointer
	var rect := Rect2(centre - drawn / 2.0, drawn)
	# A soft dark copy underneath keeps the light symbol readable on any background.
	for offset in [Vector2(2, 2), Vector2(-1, 1), Vector2(1, -1)]:
		draw_texture_rect(_texture, Rect2(rect.position + offset, rect.size), false, shadow_color)
	draw_texture_rect(_texture, rect, false, symbol_color)


func _build_hint() -> void:
	_hint = PanelContainer.new()
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hint.top_level = true
	_hint.z_index = 100
	var style := StyleBoxFlat.new()
	style.bg_color = hint_paper
	style.border_color = Color(hint_ink, 0.5)
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.set_content_margin_all(8)
	style.content_margin_left = 12
	style.content_margin_right = 12
	_hint.add_theme_stylebox_override("panel", style)
	var label := Label.new()
	label.text = hint_text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(250, 0)
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", hint_font_size)
	label.add_theme_color_override("font_color", hint_ink)
	_hint.add_child(label)
	add_child(_hint)
	_hint.visible = false
