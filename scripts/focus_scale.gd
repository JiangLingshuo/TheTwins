class_name FocusScale
extends Control
## Vertical "years ago" scale for the flashlight.
## The numbered strip slides behind a fixed needle; drag it up or down (the strip
## follows your mouse) or use the mouse wheel. Dragging up gives a larger number.

## Emitted whenever the player changes the value.
signal value_changed(value: float)

@export var min_value: float = 0.0
@export var max_value: float = 50.0
## How many units of the scale are visible at once.
@export var visible_span: float = 16.0
## Units per mouse-wheel notch.
@export var wheel_step: float = 1.0
## Panel artwork drawn behind the scale (the ticks and numbers are drawn on top).
@export var background: Texture2D
@export var font: Font
@export var number_font: Font
@export var caption: String = "years ago"
@export var tick_color: Color = Color(0.92, 0.89, 0.82)
@export var needle_color: Color = Color(0.86, 0.72, 0.45)

## Height reserved for the read-out at the top and the caption at the bottom.
const HEADER := 58.0
const FOOTER := 34.0

var value: float = 0.0:
	set(v):
		v = clampf(v, min_value, max_value)
		if is_equal_approx(v, value):
			return
		value = v
		queue_redraw()
		value_changed.emit(value)

var _dragging := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_VSIZE


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_dragging = event.pressed
			MOUSE_BUTTON_WHEEL_UP:
				if event.pressed:
					value += wheel_step
			MOUSE_BUTTON_WHEEL_DOWN:
				if event.pressed:
					value -= wheel_step
		accept_event()
	elif event is InputEventMouseMotion and _dragging:
		# The strip follows the mouse: dragging up brings larger numbers to the needle.
		var units: float = event.relative.y / _px_per_unit()
		value -= units
		accept_event()


func _px_per_unit() -> float:
	return _ruler_rect().size.y / maxf(visible_span, 1.0)


func _ruler_rect() -> Rect2:
	return Rect2(0, HEADER, size.x, size.y - HEADER - FOOTER)


func _draw() -> void:
	var f := font if font else get_theme_default_font()
	var nf := number_font if number_font else f
	if background:
		draw_texture_rect(background, Rect2(Vector2.ZERO, size), false)
	else:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.06, 0.055, 0.05, 0.9))

	var ruler := _ruler_rect()
	var cy := ruler.get_center().y
	var ppu := _px_per_unit()
	var tick_x := size.x * 0.34

	for v in range(int(ceil(min_value)), int(floor(max_value)) + 1):
		var y := cy + (v - value) * ppu
		if y < ruler.position.y + 2.0 or y > ruler.end.y - 2.0:
			continue
		var edge := 1.0 - absf(y - cy) / (ruler.size.y / 2.0)
		var alpha := clampf(edge * 1.7, 0.0, 1.0)
		var length := 8.0
		var width := 1.0
		if v % 10 == 0:
			length = 22.0
			width = 2.0
		elif v % 5 == 0:
			length = 14.0
		draw_line(Vector2(tick_x, y), Vector2(tick_x + length, y), Color(tick_color, alpha * 0.9), width, true)
		if v % 10 == 0:
			draw_string(f, Vector2(tick_x + 28.0, y + 6.0), str(v),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color(tick_color, alpha * 0.85))

	# Fixed needle on the left, pointing at the strip.
	var nx := tick_x - 6.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(nx - 12.0, cy - 7.0), Vector2(nx - 12.0, cy + 7.0), Vector2(nx, cy)]), needle_color)
	draw_line(Vector2(nx, cy), Vector2(tick_x + 26.0, cy), needle_color, 2.0, true)

	# Read-out and caption.
	var number := str(int(round(value)))
	var ns := nf.get_string_size(number, HORIZONTAL_ALIGNMENT_LEFT, -1, 34)
	draw_string(nf, Vector2((size.x - ns.x) / 2.0, HEADER - 14.0), number,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 34, tick_color)
	var cs := f.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 15)
	draw_string(f, Vector2((size.x - cs.x) / 2.0, size.y - 13.0), caption,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(tick_color, 0.7))
