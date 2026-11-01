class_name Flashlight
extends Control
## Flashlight with a focus dial.
##
## The beam follows the mouse. Inside the beam, a hidden "clue" layer is shown as a
## circular picture-in-picture with a feathered edge and a warm, brightening filter.
## Turn the focus dial (mouse wheel, or drag the dial) to sharpen it: the clue is
## sharp at `perfect_focus` and gets equally blurrier the further you go either way,
## so it appears little by little as you approach the right setting.
##
## The hidden layer is either `hidden_scene` (any 2D/UI scene, drawn in the same
## screen coordinates as the scene underneath) or a plain `hidden_texture`.

## Emitted whenever the focus value changes.
signal focus_changed(value: float)
## Emitted when the focus enters or leaves the perfect range.
signal perfect_focus_changed(is_perfect: bool)

@export_group("Hidden layer")
## Scene with the hidden clues. Lay it out at the same size as the screen (1280x720).
@export var hidden_scene: PackedScene
## Alternative to `hidden_scene`: a full-screen image (1280x720) with transparency.
@export var hidden_texture: Texture2D

@export_group("Focus")
## Lowest and highest value on the dial.
@export var focus_min: float = 0.0
@export var focus_max: float = 100.0
## The dial setting that makes the clue perfectly sharp.
@export var perfect_focus: float = 63.0
## Distance from `perfect_focus` that still counts as perfectly sharp.
@export var perfect_tolerance: float = 1.0
## Distance from `perfect_focus` at which the blur reaches `max_blur`.
@export var blur_range: float = 30.0
## Blur radius (pixels) when completely out of focus.
@export var max_blur: float = 28.0
## Clue opacity when completely out of focus (1 = always fully visible, just blurry).
@export_range(0.0, 1.0, 0.05) var min_reveal: float = 0.15
## Focus change per mouse-wheel notch.
@export var wheel_step: float = 1.0
## Starting dial value.
@export var start_focus: float = 20.0

@export_group("Beam")
@export var radius: float = 150.0
@export var feather: float = 45.0
## How quickly the beam catches up with the mouse (higher = snappier).
@export var follow_speed: float = 14.0
@export_range(0.0, 1.0, 0.05) var darkness: float = 0.6
@export var light_tint: Color = Color(1.0, 0.86, 0.58)
@export var brightness: float = 1.35
## Hide the mouse cursor while the flashlight is on.
@export var hide_cursor: bool = true

@onready var _hidden_viewport: SubViewport = $HiddenLayer
@onready var _lens: ColorRect = $Lens
@onready var _dial: FocusDial = $FocusDial

var focus: float = 0.0:
	set(value):
		value = clampf(value, focus_min, focus_max)
		if is_equal_approx(value, focus):
			return
		focus = value
		_target_focus = value
		_apply_focus()
		focus_changed.emit(focus)

var _target_focus := 0.0
var _beam_center := Vector2.ZERO
var _was_perfect := false
var _material: ShaderMaterial


func _ready() -> void:
	_material = _lens.material as ShaderMaterial
	_setup_hidden_layer()

	_dial.min_value = focus_min
	_dial.max_value = focus_max
	_dial.value_dragged.connect(func(v: float) -> void: _target_focus = clampf(v, focus_min, focus_max))

	_beam_center = get_local_mouse_position()
	focus = start_focus
	_apply_focus()
	_apply_beam_settings()
	if hide_cursor:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _exit_tree() -> void:
	if hide_cursor:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(delta: float) -> void:
	# Beam follows the mouse with a little lag.
	var target := _lens.get_local_mouse_position()
	_beam_center = _beam_center.lerp(target, 1.0 - exp(-follow_speed * delta))
	_material.set_shader_parameter("center_px", _beam_center)
	_material.set_shader_parameter("rect_size", _lens.size)
	if hide_cursor:
		var over_dial := _dial.get_global_rect().has_point(get_global_mouse_position())
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if over_dial else Input.MOUSE_MODE_HIDDEN

	# Ease the focus towards the dial target, so focusing feels smooth.
	if not is_equal_approx(focus, _target_focus):
		var next := lerpf(focus, _target_focus, 1.0 - exp(-12.0 * delta))
		if absf(next - _target_focus) < 0.01:
			next = _target_focus
		var target_after := _target_focus
		focus = next
		_target_focus = target_after


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_target_focus = clampf(_target_focus + wheel_step, focus_min, focus_max)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_target_focus = clampf(_target_focus - wheel_step, focus_min, focus_max)
			get_viewport().set_input_as_handled()


## 0 = perfectly sharp, 1 = completely out of focus. Mirrored around `perfect_focus`.
func get_defocus() -> float:
	var off := absf(focus - perfect_focus) - perfect_tolerance
	return clampf(off / maxf(blur_range, 0.001), 0.0, 1.0)


func is_perfect_focus() -> bool:
	return absf(focus - perfect_focus) <= perfect_tolerance


## True if `global_point` is inside the beam and the focus is perfect.
func is_point_revealed(global_point: Vector2) -> bool:
	var local := _lens.get_global_transform().affine_inverse() * global_point
	return is_perfect_focus() and local.distance_to(_beam_center) <= radius - feather * 0.5


func _apply_focus() -> void:
	if _material == null:
		return
	var d := get_defocus()
	# Ease-in curve: blur fades out gently as you approach the perfect setting.
	var blur := max_blur * d * d * (3.0 - 2.0 * d)
	_material.set_shader_parameter("blur_px", blur)
	_material.set_shader_parameter("reveal", lerpf(1.0, min_reveal, d))
	if _dial:
		_dial.value = focus

	var perfect := is_perfect_focus()
	if perfect != _was_perfect:
		_was_perfect = perfect
		perfect_focus_changed.emit(perfect)


func _apply_beam_settings() -> void:
	_material.set_shader_parameter("radius_px", radius)
	_material.set_shader_parameter("feather_px", feather)
	_material.set_shader_parameter("darkness", darkness)
	_material.set_shader_parameter("light_tint", light_tint)
	_material.set_shader_parameter("brightness", brightness)


func _setup_hidden_layer() -> void:
	if hidden_texture:
		_material.set_shader_parameter("clue_tex", hidden_texture)
		_material.set_shader_parameter("clue_premultiplied", false)
		return
	var size_px := Vector2i(get_viewport_rect().size)
	_hidden_viewport.size = size_px
	_hidden_viewport.transparent_bg = true
	if hidden_scene:
		_hidden_viewport.add_child(hidden_scene.instantiate())
	_material.set_shader_parameter("clue_tex", _hidden_viewport.get_texture())
	_material.set_shader_parameter("clue_premultiplied", true)
