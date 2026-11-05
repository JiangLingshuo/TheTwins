extends TextureRect
## A gravestone in the cemetery that can be recorded in the notebook.
## Hovering the stone itself (its visible pixels, not the whole texture rect)
## lights it up; clicking it records `gravestone_id` in GameState.gravestones,
## which fills its fixed page in the notebook's Gravestones section.
##
## Hovering also shows a magnifier button beside the stone; clicking it emits
## `zoom_requested`, and the main scene zooms the view in on the stone (the
## same button, or Esc / right click, zooms back out).
##
## Input is read in _unhandled_input, so the rubbing tool, the flashlight and
## any UI on top keep the clicks they use.

## Emitted the first time the gravestone is recorded.
signal recorded(gravestone_id: String)
## Emitted when the magnifier button is clicked (to zoom in, or out when `zoomed`).
signal zoom_requested(gravestone: Control)

const SHADER: Shader = preload("res://shaders/tomb_highlight.gdshader")

## Id of the gravestone (one of the ids in the notebook's Gravestones slots).
@export var gravestone_id: String = ""
## Alpha above which a texture pixel counts as part of the stone.
@export_range(0.0, 1.0, 0.05) var hit_alpha: float = 0.5
## Seconds for the highlight to fade in or out.
@export var highlight_time: float = 0.15
@export var glow_color: Color = Color(1.0, 0.92, 0.66, 0.85)
## Width of the glow around the stone, in texture pixels.
@export var glow_width: float = 10.0
## Extra brightness on the stone while hovered (0.08 = 8% brighter).
@export_range(0.0, 0.5, 0.01) var brighten: float = 0.08
## Height of the stone on screen when zoomed in, as a share of the screen height.
@export_range(0.2, 1.0, 0.05) var zoom_height_ratio: float = 0.8
## The stone itself, in texture pixels, for zooming (leave empty to use every
## visible pixel; set it when the texture also holds ground or shadow).
@export var zoom_rect: Rect2 = Rect2()
## Seconds the magnifier stays after the mouse leaves the stone (time to reach it).
@export var zoom_button_linger: float = 0.4

## True while the view is zoomed in on this stone (set by the main scene).
var zoomed := false:
	set(value):
		zoomed = value
		if _zoom_button:
			_zoom_button.tooltip_text = "Zoom out" if zoomed else "Zoom in"
			_zoom_button.queue_redraw()

var _image: Image
var _material: ShaderMaterial
var _hovered := false
var _tween: Tween
var _stone_rect := Rect2()  # visible part of the stone, in local coordinates
var _head_rect := Rect2()  # its top part; the magnifier sits to the right of it
var _zoom_button: Button
var _last_hover_msec := -100000


func _ready() -> void:
	add_to_group("gravestones")
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # clicks are read in _unhandled_input
	if texture:
		_image = texture.get_image()
		if _image and _image.is_compressed():
			_image.decompress()
		_measure_stone()
	_material = ShaderMaterial.new()
	_material.shader = SHADER
	_material.set_shader_parameter("glow_color", glow_color)
	_material.set_shader_parameter("glow_width", glow_width)
	_material.set_shader_parameter("brighten", brighten)
	_material.set_shader_parameter("highlight", 0.0)
	material = _material
	visibility_changed.connect(func() -> void: _set_hovered(false))
	_build_zoom_button()


func is_recorded() -> bool:
	return GameState.gravestones.has(gravestone_id)


## Record the gravestone in the notebook (only the first time counts).
func record() -> void:
	if gravestone_id.is_empty() or is_recorded():
		return
	GameState.record_gravestone(gravestone_id)
	recorded.emit(gravestone_id)


## The visible stone in screen (viewport) coordinates.
func get_stone_global_rect() -> Rect2:
	return get_global_transform() * _stone_rect


func _input(event: InputEvent) -> void:
	# Hover follows the mouse, but only where no UI (the open notebook, a
	# button, the flashlight's aiming layer) is under the cursor.
	if event is InputEventMouseMotion:
		var hovered_control := get_viewport().gui_get_hovered_control()
		var over_button := _zoom_button.visible and _zoom_button.get_global_rect().has_point(event.position)
		var on_stone := _is_on_stone(event) and (hovered_control == null or hovered_control == _zoom_button)
		_set_hovered(on_stone or over_button)
		if _hovered:
			_last_hover_msec = Time.get_ticks_msec()


func _process(_delta: float) -> void:
	var lingering := _hovered or Time.get_ticks_msec() - _last_hover_msec < zoom_button_linger * 1000.0
	_zoom_button.visible = is_visible_in_tree() and _interaction_allowed() and (zoomed or lingering)
	if _zoom_button.visible:
		_place_zoom_button()


## Before the guided rubbing/open-notebook sequence registers the first marker,
## the baby tomb ignores clicks (and offers no zoom).
func _interaction_allowed() -> bool:
	return not (gravestone_id == "baby_tomb" and not GameState.tutorial_record_intro_heard \
			and not GameState.investigation_tutorial_completed)


func _unhandled_input(event: InputEvent) -> void:
	if not _interaction_allowed():
		return
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT and _is_on_stone(event):
		get_viewport().set_input_as_handled()
		record()


## True if a mouse event is over a visible pixel of the stone.
func _is_on_stone(event: InputEvent) -> bool:
	if _image == null or not is_visible_in_tree():
		return false
	var local: Vector2 = make_input_local(event).position
	if not Rect2(Vector2.ZERO, size).has_point(local):
		return false
	var pixel := Vector2i(local / size * Vector2(_image.get_size()))
	pixel = pixel.clamp(Vector2i.ZERO, _image.get_size() - Vector2i.ONE)
	return _image.get_pixelv(pixel).a >= hit_alpha


func _set_hovered(value: bool) -> void:
	if value == _hovered:
		return
	_hovered = value
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(func(v: float) -> void: _material.set_shader_parameter("highlight", v),
		_material.get_shader_parameter("highlight"), 1.0 if value else 0.0, highlight_time)


## Finds the stone's visible pixels and its top part (the "head"), in local coordinates.
func _measure_stone() -> void:
	var used := Rect2i(zoom_rect) if zoom_rect.has_area() else _image.get_used_rect()
	if not used.has_area():
		return
	var to_local := size / Vector2(_image.get_size())
	_stone_rect = Rect2(Vector2(used.position) * to_local, Vector2(used.size) * to_local)
	var head_bottom := used.position.y + int(used.size.y * 0.3)
	var left := used.end.x
	var right := used.position.x
	for y in range(used.position.y, head_bottom, 4):
		for x in range(used.position.x, used.end.x, 4):
			if _image.get_pixel(x, y).a >= hit_alpha:
				left = mini(left, x)
				right = maxi(right, x)
	if right < left:
		_head_rect = _stone_rect
	else:
		_head_rect = Rect2(Vector2(left, used.position.y) * to_local,
				Vector2(right - left, head_bottom - used.position.y) * to_local)


func _build_zoom_button() -> void:
	_zoom_button = Button.new()
	_zoom_button.name = "ZoomButton"
	_zoom_button.top_level = true  # screen-sized whatever the zoom
	_zoom_button.custom_minimum_size = Vector2(44, 44)
	_zoom_button.size = Vector2(44, 44)
	_zoom_button.focus_mode = Control.FOCUS_NONE
	_zoom_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_zoom_button.tooltip_text = "Zoom in"
	for state in ["normal", "hover", "pressed"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.09, 0.08, 0.88 if state == "normal" else 0.96)
		style.border_color = Color(0.86, 0.73, 0.46) if state == "normal" else Color(1.0, 0.9, 0.66)
		style.set_border_width_all(2)
		style.set_corner_radius_all(22)
		style.shadow_color = Color(0, 0, 0, 0.35)
		style.shadow_size = 4
		_zoom_button.add_theme_stylebox_override(state, style)
	_zoom_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	_zoom_button.draw.connect(_draw_magnifier)
	_zoom_button.pressed.connect(func() -> void: zoom_requested.emit(self))
	_zoom_button.visible = false
	add_child(_zoom_button)


## A magnifying glass with + (zoom in) or − (zoom out).
func _draw_magnifier() -> void:
	var ink := Color(0.98, 0.94, 0.84)
	var lens := Vector2(19, 19)
	_zoom_button.draw_arc(lens, 9.5, 0, TAU, 32, ink, 2.5, true)
	_zoom_button.draw_line(lens + Vector2(7, 7), Vector2(33, 33), ink, 4.0, true)
	_zoom_button.draw_line(lens - Vector2(4.5, 0), lens + Vector2(4.5, 0), ink, 2.0, true)
	if not zoomed:
		_zoom_button.draw_line(lens - Vector2(0, 4.5), lens + Vector2(0, 4.5), ink, 2.0, true)


## To the right of the stone's head, kept on screen.
func _place_zoom_button() -> void:
	var head := get_global_transform() * _head_rect
	var at := Vector2(head.end.x + 10.0, head.get_center().y - _zoom_button.size.y / 2.0)
	var screen := get_viewport_rect().size
	at.x = clampf(at.x, 8.0, screen.x - _zoom_button.size.x - 8.0)
	at.y = clampf(at.y, 8.0, screen.y - _zoom_button.size.y - 8.0)
	_zoom_button.global_position = at
