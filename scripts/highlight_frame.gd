class_name HighlightFrame
extends Control
## A rounded frame that blinks around a rectangle on screen to point something
## out. Used by the Tutorial autoload; it follows its target while blinking.

## Emitted when the blinking has finished or was dismissed.
signal finished

@export var color: Color = Color(0.86, 0.72, 0.45)
@export var line_width: float = 3.0
@export var corner_radius: int = 8
## Space between the frame and the thing it surrounds.
@export var padding: float = 10.0
## How many times the frame blinks before it fades away.
@export var blinks: int = 3
## Seconds for one blink (on + off).
@export var blink_time: float = 0.5

var _target: Control
var _tween: Tween


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Blink around `target` (any Control on screen).
func blink_around(target: Control) -> void:
	dismiss(false)
	_target = target
	_follow_target()
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
	_target = null
	if visible:
		visible = false
		if emit:
			finished.emit()


func _process(_delta: float) -> void:
	if visible:
		_follow_target()


func _follow_target() -> void:
	if not is_instance_valid(_target) or not _target.is_visible_in_tree():
		dismiss()
		return
	var rect := _target.get_global_rect().grow(padding)
	global_position = rect.position
	size = rect.size


func _draw() -> void:
	var box := StyleBoxFlat.new()
	box.draw_center = false
	box.set_border_width_all(int(line_width))
	box.border_color = color
	box.set_corner_radius_all(corner_radius)
	box.anti_aliasing = true
	draw_style_box(box, Rect2(Vector2.ZERO, size))
