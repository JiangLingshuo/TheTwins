class_name SceneZoom
extends Node
## Zooms the scene in on a tombstone (or a searchlight find), like a camera
## move, and back out.
## Every Tombstone's magnifier button calls toggle() through the "scene_zoom"
## group, so a new tombstone needs no wiring. Zooming scales and moves the
## `layers` (backgrounds and cemeteries) together; the tools, notebook and other
## UI stay as they are. While zoomed in, letterbox bars and a soft vignette frame
## the view, and a zoom-out magnifier button in the corner brings the whole scene
## back (so does switching day/night: the stone belongs to one city).

## Emitted when the view zooms in on `tombstone`, or back out (null).
signal zoom_changed(tombstone: Control)

const SHADER_CODE := """
shader_type canvas_item;
uniform float strength = 0.0;
void fragment() {
	vec2 d = (UV - 0.5) * vec2(1.6, 1.25);
	COLOR = vec4(0.0, 0.0, 0.0, smoothstep(0.35, 0.9, length(d)) * strength);
}
"""

## The layers that zoom together (the backgrounds and cemeteries).
@export var layers: Array[NodePath] = []
## Seconds for the camera move in or out.
@export var zoom_time: float = 0.9
## Largest zoom allowed.
@export var max_zoom: float = 4.0
## Height of each letterbox bar while zoomed in, in screen pixels.
@export var letterbox_height: float = 46.0
## Darkness of the vignette while zoomed in (0 = none).
@export_range(0.0, 1.0, 0.05) var vignette_strength: float = 0.55
## Where the zoom-out button sits (top-left corner of the button, screen pixels).
@export var zoom_out_position: Vector2 = Vector2(24, 64)

var _base: Array[Dictionary] = []  # each layer with its unzoomed position and scale
var _zoom := 1.0  # current view: screen = unzoomed * _zoom + _offset
var _offset := Vector2.ZERO
var _framing := 0.0  # 0 = whole scene, 1 = bars and vignette fully in
var _tween: Tween
var _zoomed: Control
var _overlay: Control
var _bars: Array[ColorRect] = []
var _vignette: ColorRect
var _zoom_out_button: Button


func _ready() -> void:
	add_to_group("scene_zoom")
	for path in layers:
		var layer: Control = get_node(path)
		_base.append({"node": layer, "position": layer.position, "scale": layer.scale})
	_build_overlay()
	_build_zoom_out_button()
	_apply(1.0, Vector2.ZERO, 0.0)
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


## True while the camera is moving in or out.
func is_moving() -> bool:
	return _tween != null and _tween.is_running()


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
	# A small object (a searchlight find) may allow a closer camera than a tombstone.
	var limit: float = tombstone.get("zoom_max_zoom") if tombstone.get("zoom_max_zoom") != null else max_zoom
	var target := clampf(screen.y * tombstone.zoom_height_ratio / unzoomed.size.y, 1.0, limit)
	var offset := screen / 2.0 - unzoomed.get_center() * target
	offset = offset.clamp(screen - screen * target, Vector2.ZERO)
	if _zoomed and _zoomed != tombstone:
		_zoomed.zoomed = false
	_zoomed = tombstone
	tombstone.zoomed = true
	_tween_to(target, offset, 1.0)
	zoom_changed.emit(tombstone)


## Zoom back out to the whole scene.
func zoom_out() -> void:
	if _zoomed == null:
		return
	if is_instance_valid(_zoomed):
		_zoomed.zoomed = false
	_zoomed = null
	_tween_to(1.0, Vector2.ZERO, 0.0)
	zoom_changed.emit(null)


## A camera move: slow start, quick middle, gentle settle; the framing leads in
## and trails out so the bars close before the push and open after the pull.
func _tween_to(target: float, offset: Vector2, framing: float) -> void:
	if _tween:
		_tween.kill()
	var from_zoom := _zoom
	var from_offset := _offset
	var from_framing := _framing
	var going_in := framing > from_framing
	_tween = create_tween()
	_tween.tween_method(func(t: float) -> void:
		var move := ease(t, -2.6)  # in-out
		var frame_t := clampf(t * 1.6, 0.0, 1.0) if going_in else clampf(t * 1.6 - 0.6, 0.0, 1.0)
		_apply(lerpf(from_zoom, target, move), from_offset.lerp(offset, move),
				lerpf(from_framing, framing, ease(frame_t, -2.0))),
		0.0, 1.0, zoom_time)


func _apply(zoom: float, offset: Vector2, framing: float) -> void:
	_zoom = zoom
	_offset = offset
	_framing = framing
	for base in _base:
		base["node"].scale = base["scale"] * zoom
		base["node"].position = base["position"] * zoom + offset
	var screen := _overlay.get_viewport_rect().size
	var bar := letterbox_height * framing
	_bars[0].position = Vector2(0, bar - letterbox_height)
	_bars[1].position = Vector2(0, screen.y - bar)
	for b in _bars:
		b.size = Vector2(screen.x, letterbox_height)
	(_vignette.material as ShaderMaterial).set_shader_parameter("strength", vignette_strength * framing)
	_overlay.visible = framing > 0.001
	_zoom_out_button.modulate.a = framing
	_zoom_out_button.visible = framing > 0.001
	_zoom_out_button.disabled = _zoomed == null


## Bars and vignette sit above the scene and below the tools (this node comes
## before them in the scene tree).
func _build_overlay() -> void:
	_overlay = Control.new()
	_overlay.name = "ZoomFraming"
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)
	_vignette = ColorRect.new()
	_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shader := Shader.new()
	shader.code = SHADER_CODE
	var material := ShaderMaterial.new()
	material.shader = shader
	_vignette.material = material
	_overlay.add_child(_vignette)
	for i in 2:
		var b := ColorRect.new()
		b.color = Color(0.03, 0.025, 0.02, 0.92)
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_overlay.add_child(b)
		_bars.append(b)


## The zoom-out magnifier, above everything in the scene so it is always clickable.
func _build_zoom_out_button() -> void:
	_zoom_out_button = Button.new()
	_zoom_out_button.name = "ZoomOutButton"
	_zoom_out_button.size = Vector2(64, 64)
	_zoom_out_button.position = zoom_out_position
	_zoom_out_button.focus_mode = Control.FOCUS_NONE
	_zoom_out_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_zoom_out_button.tooltip_text = "Zoom out"
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.09, 0.08, 0.9 if state == "normal" else 0.97)
		style.border_color = Color(1.0, 0.9, 0.66) if state == "hover" else Color(0.86, 0.73, 0.46)
		style.set_border_width_all(3)
		style.set_corner_radius_all(32)
		style.shadow_color = Color(0, 0, 0, 0.4)
		style.shadow_size = 6
		_zoom_out_button.add_theme_stylebox_override(state, style)
	_zoom_out_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	_zoom_out_button.draw.connect(func() -> void:
		var ink := Color(0.98, 0.94, 0.84)
		var lens := Vector2(28, 28)
		_zoom_out_button.draw_arc(lens, 14.0, 0, TAU, 40, ink, 3.5, true)
		_zoom_out_button.draw_line(lens + Vector2(10, 10), Vector2(49, 49), ink, 6.0, true)
		_zoom_out_button.draw_line(lens - Vector2(7, 0), lens + Vector2(7, 0), ink, 3.0, true))
	_zoom_out_button.pressed.connect(zoom_out)
	get_parent().add_child.call_deferred(_zoom_out_button)
