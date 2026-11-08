class_name ConcludeButton
extends Control
## "Conclude Investigation": a paper button across the notebook's spine that
## appears on the Gravestones pages once all six reports are filled in.
##
## It is torn paper like the notebook's own pages and split down the middle with
## the colours swapped: the half over the Day page (left) is Night paper with
## pale ink, the half over the Night page (right) is Day paper with dark ink, so
## the button reads as the two cities pressed together.

signal pressed

@export var day_paper: Color = Color(0.96, 0.92, 0.82)
@export var day_ink: Color = Color(0.2, 0.15, 0.11)
@export var night_paper: Color = Color(0.14, 0.16, 0.22)
@export var night_ink: Color = Color(0.94, 0.91, 0.84)
@export var font: Font
@export var font_size: int = 20
## How far the cut edge wanders, in pixels: a sticky note, nearly straight.
@export var roughness: float = 0.8

const LINES := ["Conclude", "Investigation"]

var _halves: Array[Control] = []
var _outline := PackedVector2Array()
var _hovered := false


func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE
	custom_minimum_size = Vector2(230, 70)
	size = custom_minimum_size
	for index in 2:
		var half := Control.new()
		half.name = "Left" if index == 0 else "Right"
		half.clip_contents = true
		half.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(half)
		half.draw.connect(_draw_half.bind(half, index))
		_halves.append(half)
	mouse_entered.connect(func() -> void: _set_hovered(true))
	mouse_exited.connect(func() -> void: _set_hovered(false))
	resized.connect(_rebuild)
	_rebuild()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		pressed.emit()


func _set_hovered(value: bool) -> void:
	_hovered = value
	for half in _halves:
		half.queue_redraw()
	queue_redraw()


func _rebuild() -> void:
	_outline = _torn_outline(Rect2(Vector2(8, 4), size - Vector2(16, 14)))
	var half_width := size.x / 2.0
	_halves[0].position = Vector2.ZERO
	_halves[0].size = Vector2(half_width, size.y)
	_halves[1].position = Vector2(half_width, 0)
	_halves[1].size = Vector2(size.x - half_width, size.y)
	for half in _halves:
		half.queue_redraw()
	queue_redraw()


## A rectangle whose edges wander a little, the way a torn page does. Seeded, so
## the same button always has the same edge.
func _torn_outline(rect: Rect2) -> PackedVector2Array:
	var noise := RandomNumberGenerator.new()
	noise.seed = 20260108
	var points := PackedVector2Array()
	var step := 22.0
	var x := rect.position.x
	while x < rect.end.x:
		points.append(Vector2(x, rect.position.y + noise.randf_range(-roughness, roughness)))
		x += step * noise.randf_range(0.7, 1.3)
	var y := rect.position.y
	while y < rect.end.y:
		points.append(Vector2(rect.end.x + noise.randf_range(-roughness, roughness), y))
		y += step * noise.randf_range(0.7, 1.3)
	x = rect.end.x
	while x > rect.position.x:
		points.append(Vector2(x, rect.end.y + noise.randf_range(-roughness, roughness)))
		x -= step * noise.randf_range(0.7, 1.3)
	y = rect.end.y
	while y > rect.position.y:
		points.append(Vector2(rect.position.x + noise.randf_range(-roughness, roughness), y))
		y -= step * noise.randf_range(0.7, 1.3)
	return points


func _draw() -> void:
	# A soft shadow under the note: a few stacked layers, each a little larger and fainter.
	if _outline.size() > 2:
		var center := size / 2.0
		for layer in 5:
			var grow := 1.0 + layer * 1.6
			var shadow := PackedVector2Array()
			for point in _outline:
				var away := (point - center).normalized()
				shadow.append(point + away * grow + Vector2(0, 3.0 + layer * 0.8))
			draw_colored_polygon(shadow, Color(0, 0, 0, 0.11))


func _draw_half(half: Control, index: int) -> void:
	if _outline.size() < 3:
		return
	# Left half sits on the Day page and wears Night colours; the right half the reverse.
	var paper := night_paper if index == 0 else day_paper
	var ink := night_ink if index == 0 else day_ink
	# Hover: the dark half brightens and the light half deepens, so both visibly respond.
	if _hovered:
		paper = paper.lightened(0.14) if index == 0 else paper.darkened(0.11)
	var offset := -half.position
	var local_outline := PackedVector2Array()
	for point in _outline:
		local_outline.append(point + offset)
	half.draw_colored_polygon(local_outline, paper)
	var rim := local_outline.duplicate()
	rim.append(local_outline[0])
	# A little shading along the cut edges, so the note sits up off the page.
	half.draw_polyline(rim, Color(0, 0, 0, 0.16), 4.0, true)
	half.draw_polyline(rim, Color(ink, 0.28), 1.0, true)
	if font == null:
		return
	var center := Vector2(size.x / 2.0, size.y / 2.0 - 3.0) + offset
	var line_height := font.get_height(font_size)
	var top := center.y - line_height * LINES.size() / 2.0
	for line_index in LINES.size():
		var text := GameState.zh_text(LINES[line_index])
		var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		var baseline := Vector2(center.x - width / 2.0, top + line_height * (line_index + 1) - font.get_descent(font_size))
		half.draw_string(font, baseline, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, ink)

