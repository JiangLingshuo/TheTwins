class_name FocusScale
extends Control
## Compact year dial around the active searchlight button.

signal value_changed(value: float)

@export var min_value: float = 0.0
@export var max_value: float = 50.0
@export var wheel_step: float = 1.0
@export var font: Font
@export var number_font: Font
@export var caption := "years ago"

const START_ANGLE := TAU / 3.0
const SWEEP := TAU * 5.0 / 6.0
const INK := Color(0.98, 0.92, 0.77)
const GOLD := Color(1.0, 0.77, 0.34)

var _dragging := false

var value: float = 0.0:
	set(v):
		v = clampf(v, min_value, max_value)
		if is_equal_approx(v, value):
			return
		value = v
		queue_redraw()
		value_changed.emit(value)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	visibility_changed.connect(func() -> void:
		if not is_visible_in_tree(): _dragging = false)

func set_year_range(first: float, last: float) -> void:
	min_value = first
	max_value = last
	queue_redraw()

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event is InputEventMouseMotion and _dragging:
		_set_year_at(get_global_transform().affine_inverse() * event.position)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		var point: Vector2 = get_global_transform().affine_inverse() * event.position
		var distance := (point - size * 0.5).length()
		var over_ring := absf(distance - _radius()) <= 8.0
		if event.button_index == MOUSE_BUTTON_LEFT and (_dragging or (event.pressed and over_ring)):
			_dragging = event.pressed
			if _dragging: _set_year_at(point)
			get_viewport().set_input_as_handled()
		elif event.pressed and over_ring and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			adjust_with_wheel(event)
			get_viewport().set_input_as_handled()

func _radius() -> float:
	return minf(size.x, size.y) * 0.5 - 4.0

func _set_year_at(point: Vector2) -> void:
	var angle := fposmod((point - size * 0.5).angle() - START_ANGLE, TAU)
	if angle > SWEEP:
		angle = 0.0 if angle > (SWEEP + TAU) * 0.5 else SWEEP
	value = roundf(lerpf(min_value, max_value, angle / SWEEP))

func adjust_with_wheel(event: InputEventMouseButton) -> void:
	var direction := 1.0 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -1.0
	value += direction * wheel_step * (10.0 if event.shift_pressed else 1.0) * maxf(event.factor, 1.0)

func _draw() -> void:
	var center := size * 0.5
	var radius := _radius()
	var ratio := inverse_lerp(min_value, maxf(min_value + 1.0, max_value), value)
	var end := START_ANGLE + SWEEP * ratio
	draw_arc(center, radius, START_ANGLE, START_ANGLE + SWEEP, 64, Color(0.13, 0.10, 0.07, 0.85), 5.0, true)
	if ratio > 0.0:
		draw_arc(center, radius, START_ANGLE, end, 64, GOLD, 2.5, true)
	for i in range(31):
		var direction := Vector2.from_angle(START_ANGLE + SWEEP * i / 30.0)
		var length := 6.0 if i % 5 == 0 else 3.0
		draw_line(center + direction * (radius - length), center + direction * radius, INK, 1.0, true)
	var handle := center + Vector2.from_angle(end) * radius
	draw_circle(handle, 7.0, Color(0.13, 0.10, 0.07), true, -1.0, true)
	draw_circle(handle, 5.0, GOLD, true, -1.0, true)

	var label_font := number_font if number_font else (font if font else get_theme_default_font())
	var label := "%d %s" % [int(round(value)), GameState.zh_text(caption)]
	var measured := label_font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 19)
	var badge := Rect2(Vector2(center.x - measured.x * 0.5 - 7.0, size.y - 13.0), Vector2(measured.x + 14.0, 23.0))
	var paper := StyleBoxFlat.new()
	paper.bg_color = Color(0.13, 0.10, 0.07, 0.94)
	paper.set_corner_radius_all(7)
	draw_style_box(paper, badge)
	draw_string(label_font, badge.position + Vector2(7.0, 17.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, INK)
