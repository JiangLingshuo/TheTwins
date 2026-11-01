class_name CornerHint
extends Control
## A rounded frame that blinks around another control to point it out
## (used to show the player where to click to turn the page).

## Emitted when the blinking has finished or was dismissed.
signal finished

@export var color: Color = Color(0.86, 0.72, 0.45)
@export var line_width: float = 3.0
@export var corner_radius: int = 8
## Space between the frame and the control it surrounds.
@export var padding: float = 10.0
## How many times the frame blinks before it fades away.
@export var blinks: int = 3
## Seconds for one blink (on + off).
@export var blink_time: float = 0.5

var _tween: Tween


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Blink a frame around `target` (a sibling in the same parent).
func show_around(target: Control) -> void:
	dismiss(false)
	position = target.position - Vector2(padding, padding)
	size = target.size + Vector2(padding, padding) * 2.0
	modulate.a = 0.0
	visible = true
	_tween = create_tween()
	for i in blinks:
		_tween.tween_property(self, "modulate:a", 1.0, blink_time * 0.4).set_trans(Tween.TRANS_SINE)
		_tween.tween_property(self, "modulate:a", 0.15, blink_time * 0.6).set_trans(Tween.TRANS_SINE)
	_tween.tween_property(self, "modulate:a", 0.0, blink_time * 0.4)
	_tween.finished.connect(dismiss)


## Stop blinking and hide the frame.
func dismiss(emit: bool = true) -> void:
	if _tween:
		_tween.kill()
		_tween = null
	if visible:
		visible = false
		if emit:
			finished.emit()


func _draw() -> void:
	var box := StyleBoxFlat.new()
	box.draw_center = false
	box.set_border_width_all(int(line_width))
	box.border_color = color
	box.set_corner_radius_all(corner_radius)
	box.anti_aliasing = true
	draw_style_box(box, Rect2(Vector2.ZERO, size))
