@tool
class_name PageCorner
extends Control
## A clickable page corner that curls up (dog-ears) while the mouse hovers over it.
## Place it so its outer corner sits exactly on the page's bottom corner.

signal pressed

## True for the bottom-left corner of a left page, false for the bottom-right corner.
@export var left_side: bool = false:
	set(value):
		left_side = value
		queue_redraw()
## Colour of the back of the paper, shown on the folded flap.
@export var flap_color: Color = Color(0.17, 0.17, 0.18):
	set(value):
		flap_color = value
		queue_redraw()
## Colour behind the book (shown where the corner has folded away).
@export var backdrop_color: Color = Color(0, 0, 0):
	set(value):
		backdrop_color = value
		queue_redraw()
## How far the corner folds on hover, in pixels.
@export var max_fold: float = 64.0
## Seconds for the fold animation.
@export var fold_time: float = 0.18

## Current fold size in pixels (animated).
var fold: float = 0.0:
	set(value):
		fold = value
		queue_redraw()

var _tween: Tween


func _ready() -> void:
	if Engine.is_editor_hint():
		fold = max_fold * 0.5  # preview the fold in the editor
		return
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(_animate_to.bind(1.0))
	mouse_exited.connect(_animate_to.bind(0.0))


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		pressed.emit()


## Snap back to flat with no animation (used when the page flips).
func reset() -> void:
	if _tween:
		_tween.kill()
	fold = 0.0


func _animate_to(amount: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "fold", max_fold * amount, fold_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _draw() -> void:
	var s := minf(fold, minf(size.x, size.y))
	if s < 0.5:
		return
	var w := size.x
	var h := size.y
	# Points for a bottom-right corner; mirrored for the left side.
	var a := _p(w - s, h)        # where the fold meets the bottom edge
	var b := _p(w, h - s)        # where the fold meets the side edge
	var c := _p(w, h)            # the original corner
	var tip := _p(w - s, h - s)  # the folded-over corner
	var shadow := PackedVector2Array([
		_p(w - s * 1.08, h),
		_p(w - s * 1.04, h - s * 1.04),
		_p(w, h - s * 1.08),
		b, a,
	])
	draw_colored_polygon(shadow, Color(0, 0, 0, 0.2))
	draw_colored_polygon(PackedVector2Array([a, c, b]), backdrop_color)
	draw_colored_polygon(PackedVector2Array([a, tip, b]), flap_color)
	draw_line(a, b, Color(1, 1, 1, 0.22), 1.0, true)


func _p(x: float, y: float) -> Vector2:
	return Vector2(size.x - x, y) if left_side else Vector2(x, y)
