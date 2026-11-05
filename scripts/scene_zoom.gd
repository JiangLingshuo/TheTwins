class_name SceneZoom
extends Node
## Zooms the scene in on a tombstone, like a camera move, and back out.
## Every Tombstone's magnifier button calls toggle() through the "scene_zoom"
## group, so a new tombstone needs no wiring. Zooming scales and moves the
## `layers` (backgrounds and cemeteries) together; the tools, notebook and other
## UI stay as they are. Esc or right click zooms out, and so does switching
## day/night (the stone belongs to one city).

## Emitted when the view zooms in on `tombstone`, or back out (null).
signal zoom_changed(tombstone: Control)

## The layers that zoom together (the backgrounds and cemeteries).
@export var layers: Array[NodePath] = []
## Seconds for zooming in or back out.
@export var zoom_time: float = 0.6
## Largest zoom allowed.
@export var max_zoom: float = 4.0

var _base: Array[Dictionary] = []  # each layer with its unzoomed position and scale
var _zoom := 1.0  # current view: screen = unzoomed * _zoom + _offset
var _offset := Vector2.ZERO
var _tween: Tween
var _zoomed: Control


func _ready() -> void:
	add_to_group("scene_zoom")
	for path in layers:
		var layer: Control = get_node(path)
		_base.append({"node": layer, "position": layer.position, "scale": layer.scale})
	var main := get_parent()
	if main.has_signal("time_changed"):
		main.time_changed.connect(func(_day: bool) -> void:
			if is_zoomed():
				zoom_out())


func is_zoomed() -> bool:
	return _zoomed != null


## The tombstone zoomed in on, or null.
func get_zoomed() -> Control:
	return _zoomed


## Zoom in on `tombstone`, or back out if it is the one already zoomed in on.
func toggle(tombstone: Control) -> void:
	if tombstone == _zoomed:
		zoom_out()
	else:
		zoom_to(tombstone)


## Centre `tombstone` with its stone at its zoom_height_ratio of the screen
## height; the view never leaves the background.
func zoom_to(tombstone: Control) -> void:
	var screen: Vector2 = tombstone.get_viewport_rect().size
	var now: Rect2 = tombstone.get_stone_global_rect()
	var unzoomed := Rect2((now.position - _offset) / _zoom, now.size / _zoom)
	var target := clampf(screen.y * tombstone.zoom_height_ratio / unzoomed.size.y, 1.0, max_zoom)
	var offset := screen / 2.0 - unzoomed.get_center() * target
	offset = offset.clamp(screen - screen * target, Vector2.ZERO)
	if _zoomed and _zoomed != tombstone:
		_zoomed.zoomed = false
	_zoomed = tombstone
	tombstone.zoomed = true
	_tween_to(target, offset)
	zoom_changed.emit(tombstone)


## Zoom back out to the whole scene.
func zoom_out() -> void:
	if _zoomed == null:
		return
	if is_instance_valid(_zoomed):
		_zoomed.zoomed = false
	_zoomed = null
	_tween_to(1.0, Vector2.ZERO)
	zoom_changed.emit(null)


func _unhandled_input(event: InputEvent) -> void:
	if not is_zoomed():
		return
	var right_click: bool = event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_RIGHT
	var escape: bool = event is InputEventKey and event.pressed and not event.echo \
			and event.keycode == KEY_ESCAPE
	if right_click or escape:
		zoom_out()
		get_viewport().set_input_as_handled()


func _tween_to(target: float, offset: Vector2) -> void:
	if _tween:
		_tween.kill()
	var from_zoom := _zoom
	var from_offset := _offset
	_tween = create_tween()
	_tween.tween_method(func(t: float) -> void:
		_apply(lerpf(from_zoom, target, t), from_offset.lerp(offset, t)),
		0.0, 1.0, zoom_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _apply(zoom: float, offset: Vector2) -> void:
	_zoom = zoom
	_offset = offset
	for base in _base:
		base["node"].scale = base["scale"] * zoom
		base["node"].position = base["position"] * zoom + offset
