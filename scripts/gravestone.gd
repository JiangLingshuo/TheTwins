extends TextureRect
## A gravestone in the cemetery that can be recorded in the notebook.
## Hovering the stone itself (its visible pixels, not the whole texture rect)
## lights it up; clicking it records `gravestone_id` in GameState.gravestones,
## which fills its fixed page in the notebook's Gravestones section.
##
## Input is read in _unhandled_input, so the rubbing tool, the flashlight and
## any UI on top keep the clicks they use.

## Emitted the first time the gravestone is recorded.
signal recorded(gravestone_id: String)

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

var _image: Image
var _material: ShaderMaterial
var _hovered := false
var _tween: Tween


func _ready() -> void:
	add_to_group("gravestones")
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # clicks are read in _unhandled_input
	if texture:
		_image = texture.get_image()
		if _image and _image.is_compressed():
			_image.decompress()
	_material = ShaderMaterial.new()
	_material.shader = SHADER
	_material.set_shader_parameter("glow_color", glow_color)
	_material.set_shader_parameter("glow_width", glow_width)
	_material.set_shader_parameter("brighten", brighten)
	_material.set_shader_parameter("highlight", 0.0)
	material = _material
	visibility_changed.connect(func() -> void: _set_hovered(false))


func is_recorded() -> bool:
	return GameState.gravestones.has(gravestone_id)


## Record the gravestone in the notebook (only the first time counts).
func record() -> void:
	if gravestone_id.is_empty() or is_recorded():
		return
	GameState.gravestones.append(gravestone_id)
	recorded.emit(gravestone_id)


func _input(event: InputEvent) -> void:
	# Hover follows the mouse, but only where no UI (the open notebook, a
	# button, the flashlight's aiming layer) is under the cursor.
	if event is InputEventMouseMotion:
		_set_hovered(_is_on_stone(event) and get_viewport().gui_get_hovered_control() == null)


func _unhandled_input(event: InputEvent) -> void:
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
