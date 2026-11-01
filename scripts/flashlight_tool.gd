extends Control
## Flashlight tool: a button on the right edge of the screen plus the year scale.
##
## 1. Click the flashlight button: the year scale opens beside it.
## 2. Drag the scale up/down (or scroll) to pick 0–50 years ago.
## 3. Click anywhere else: the flashlight turns on there and follows the mouse.
##    The scale stays open, so the year can still be adjusted while lighting.
## 4. Click the flashlight button again: the flashlight turns off.

## Emitted when the tool changes state (see the State values).
signal state_changed(state: int)

enum State { OFF, AIMING, ON }

## Button art when the flashlight is off / on.
@export var icon_off: Texture2D
@export var icon_on: Texture2D

var state: int = State.OFF

@onready var flashlight: Flashlight = $Flashlight
@onready var _catcher: Control = $ClickCatcher
@onready var _scale: FocusScale = $FocusScale
@onready var _button: TextureButton = $FlashlightButton


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scale.min_value = flashlight.focus_min
	_scale.max_value = flashlight.focus_max
	_scale.value_changed.connect(flashlight.set_target_focus)
	_button.pressed.connect(_on_button_pressed)
	_catcher.gui_input.connect(_on_catcher_input)
	_set_state(State.OFF)


func _process(_delta: float) -> void:
	# Hide the cursor while lighting, except over the button and the scale.
	if state == State.ON:
		var mouse := get_global_mouse_position()
		var over_ui := _button.get_global_rect().has_point(mouse) \
			or _scale.get_global_rect().has_point(mouse)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if over_ui else Input.MOUSE_MODE_HIDDEN


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_button_pressed() -> void:
	match state:
		State.OFF:
			_set_state(State.AIMING)
		_:
			_set_state(State.OFF)


func _on_catcher_input(event: InputEvent) -> void:
	if state == State.AIMING and event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		_catcher.accept_event()
		flashlight.turn_on_at(_catcher.get_global_transform() * event.position)
		_set_state(State.ON)


func _set_state(new_state: int) -> void:
	state = new_state
	_scale.visible = state != State.OFF
	# The click catcher only waits for the "turn on" click while aiming.
	_catcher.visible = state == State.AIMING
	flashlight.active = state == State.ON
	_button.texture_normal = icon_on if state == State.ON else icon_off
	_button.modulate = Color(1.2, 1.15, 1.0) if state == State.AIMING else Color.WHITE
	if state != State.ON:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	state_changed.emit(state)
