class_name Flashlight
extends Control
## Flashlight beam: lights everything drawn before it with a warm, brightening
## circle that follows the mouse, and darkens the rest of the screen.
##
## Turn it on and off with `active`. `focus` is the year setting ("years ago");
## hidden clues read it to decide how sharp they look: a clue is sharp when the
## focus matches its year and equally blurrier the further it is either way.
## Any node in the "flashlight_targets" group gets apply_flashlight(self) every
## frame while the flashlight exists (check `active` to know if it is on).
##
## Place this node above the scene it lights (later in the scene tree).

## Emitted when the flashlight is switched on or off.
signal active_changed(is_on: bool)
## Emitted whenever the focus value changes.
signal focus_changed(years_ago: float)

@export_group("Focus")
@export var focus_min: float = 0.0
@export var focus_max: float = 50.0
## Distance from a clue's year that still counts as perfectly sharp.
@export var perfect_tolerance: float = 1.0
## Distance from a clue's year at which it is fully blurred / faded.
@export var blur_range: float = 15.0
## Blur radius (pixels) when completely out of focus.
@export var max_blur: float = 24.0
## Clue opacity when completely out of focus (0 = invisible).
@export_range(0.0, 1.0, 0.05) var min_reveal: float = 0.0

@export_group("Beam")
@export var radius: float = 150.0
@export var feather: float = 45.0
## How quickly the beam catches up with the mouse (higher = snappier).
@export var follow_speed: float = 14.0
@export_range(0.0, 1.0, 0.05) var darkness: float = 0.6
@export var light_tint: Color = Color(1.0, 0.86, 0.58)
@export var brightness: float = 1.35

## True while the flashlight is on.
var active: bool = false:
	set(value):
		if value == active:
			return
		active = value
		if _lens:
			_lens.visible = active
		active_changed.emit(active)

## Current year setting, in years ago (eases towards the target set with set_target_focus()).
var focus: float = 0.0:
	set(value):
		value = clampf(value, focus_min, focus_max)
		if is_equal_approx(value, focus):
			return
		focus = value
		focus_changed.emit(focus)

var _target_focus := 0.0
var _beam_center := Vector2.ZERO

@onready var _lens: ColorRect = $Lens
@onready var _material: ShaderMaterial = _lens.material as ShaderMaterial


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lens.visible = active
	_target_focus = focus
	_material.set_shader_parameter("radius_px", radius)
	_material.set_shader_parameter("feather_px", feather)
	_material.set_shader_parameter("darkness", darkness)
	_material.set_shader_parameter("light_tint", light_tint)
	_material.set_shader_parameter("brightness", brightness)


func _process(delta: float) -> void:
	if active:
		var target := _lens.get_local_mouse_position()
		_beam_center = _beam_center.lerp(target, 1.0 - exp(-follow_speed * delta))
		_material.set_shader_parameter("center_px", _beam_center)
		_material.set_shader_parameter("rect_size", _lens.size)

	# Ease the focus towards its target so focusing feels smooth.
	if focus != _target_focus:
		var next := lerpf(focus, _target_focus, 1.0 - exp(-12.0 * delta))
		focus = _target_focus if absf(next - _target_focus) < 0.01 else next

	for target_node in get_tree().get_nodes_in_group("flashlight_targets"):
		target_node.apply_flashlight(self)


## Turn the flashlight on with the beam starting at `global_position`.
func turn_on_at(global_point: Vector2) -> void:
	_beam_center = _lens.get_global_transform().affine_inverse() * global_point
	_material.set_shader_parameter("center_px", _beam_center)
	_material.set_shader_parameter("rect_size", _lens.size)
	active = true


## Set the year the flashlight should focus on (it eases there smoothly).
func set_target_focus(value: float) -> void:
	_target_focus = clampf(value, focus_min, focus_max)


func get_beam_global_position() -> Vector2:
	return _lens.get_global_transform() * _beam_center


## 0 = perfectly sharp, 1 = completely out of focus, for a clue of the given year.
## Mirrored around the year: 5 years too early or too late looks the same.
func get_defocus_for(year_ago: float) -> float:
	var off := absf(focus - year_ago) - perfect_tolerance
	return clampf(off / maxf(blur_range, 0.001), 0.0, 1.0)


func is_perfect_for(year_ago: float) -> bool:
	return active and absf(focus - year_ago) <= perfect_tolerance


## Blur radius for a given defocus (eases away as the focus approaches the year).
func get_blur_for(defocus: float) -> float:
	return max_blur * defocus * defocus * (3.0 - 2.0 * defocus)


## Clue opacity for a given defocus.
func get_reveal_for(defocus: float) -> float:
	return lerpf(1.0, min_reveal, defocus) if active else 0.0
