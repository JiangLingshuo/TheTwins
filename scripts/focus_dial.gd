class_name FocusDial
extends Control
## A scrolling focus scale ("刻度") with a fixed needle in the middle.
## Drag it sideways or use the mouse wheel over it to change the value.

## Emitted when the player drags or scrolls the dial.
signal value_dragged(new_value: float)

@export var min_value: float = 0.0
@export var max_value: float = 100.0
## How many units of the scale are visible across the dial.
@export var visible_span: float = 30.0
## Units per mouse-wheel notch while hovering the dial.
@export var wheel_step: float = 1.0
@export var font: Font
@export var font_size: int = 18
@export var tick_color: Color = Color(0.92, 0.89, 0.82)
@export var needle_color: Color = Color(0.86, 0.72, 0.45)
@export var panel_color: Color = Color(0.03, 0.03, 0.035, 0.85)

var value: float = 0.0:
	set(v):
		value = v
		queue_redraw()

var _dragging := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_HSIZE


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_dragging = event.pressed
				accept_event()
			MOUSE_BUTTON_WHEEL_UP:
				if event.pressed:
					value_dragged.emit(clampf(value + wheel_step, min_value, max_value))
				accept_event()
			MOUSE_BUTTON_WHEEL_DOWN:
				if event.pressed:
					value_dragged.emit(clampf(value - wheel_step, min_value, max_value))
				accept_event()
	elif event is InputEventMouseMotion and _dragging:
		# Dragging right moves the scale right, i.e. lowers the value under the needle.
		var units: float = event.relative.x / _px_per_unit()
		value_dragged.emit(clampf(value - units, min_value, max_value))
		accept_event()


func _px_per_unit() -> float:
	return size.x / maxf(visible_span, 1.0)


func _draw() -> void:
	var w := size.x
	var h := size.y
	var cx := w / 2.0
	var ppu := _px_per_unit()
	var f := font if font else get_theme_default_font()

	# Panel.
	draw_rect(Rect2(Vector2.ZERO, size), panel_color)
	draw_rect(Rect2(Vector2.ZERO, size), Color(needle_color, 0.45), false, 1.0)

	# Ticks scroll past a fixed needle.
	var baseline := h * 0.62
	var first := int(floor(value - visible_span / 2.0)) - 1
	var last := int(ceil(value + visible_span / 2.0)) + 1
	for v in range(first, last + 1):
		if v < min_value or v > max_value:
			continue
		var x := cx + (v - value) * ppu
		if x < 2.0 or x > w - 2.0:
			continue
		# Fade towards the edges.
		var edge := 1.0 - absf(x - cx) / cx
		var alpha := clampf(edge * 1.6, 0.0, 1.0)
		var length := 6.0
		if v % 10 == 0:
			length = 18.0
		elif v % 5 == 0:
			length = 11.0
		draw_line(Vector2(x, baseline), Vector2(x, baseline - length), Color(tick_color, alpha * 0.85), 1.0, true)
		if v % 10 == 0:
			var label := str(v)
			var text_size := f.get_string_size(label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
			draw_string(f, Vector2(x - text_size.x / 2.0, h - 6.0), label,
				HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(tick_color, alpha * 0.8))

	# Needle.
	draw_line(Vector2(cx, 4.0), Vector2(cx, baseline + 2.0), needle_color, 2.0, true)
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 7.0, 0.0), Vector2(cx + 7.0, 0.0), Vector2(cx, 9.0)]), needle_color)
