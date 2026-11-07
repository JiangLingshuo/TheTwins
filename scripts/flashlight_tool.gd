extends Control
## Flashlight tool: a button on the right edge of the screen plus the year scale.
##
## Click the button, then a scene position to lock the beam there.
## Scroll over the scene to adjust the year; click another position to re-aim.
## The ring shows the selected year without moving the beam.
## Click the tool again or press Escape to put it away.

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
	_scale.set_year_range(flashlight.focus_min, flashlight.focus_max)
	_scale.value_changed.connect(flashlight.set_target_focus)
	_button.pressed.connect(_on_button_pressed)
	_catcher.gui_input.connect(_on_catcher_input)
	_button.tooltip_text = "Select a spot, then scroll or drag the year ring. Click another spot to re-aim. Shift + scroll: 10 years. Esc: put away."
	_set_state(State.OFF)


func _process(_delta: float) -> void:
	if state == State.OFF:
		return
	var icon: Control = _button
	var toolbox := get_parent().get_node_or_null("Toolbox")
	if toolbox and toolbox.button:
		icon = toolbox.proxy_for(_button) if toolbox.tray.visible else toolbox.button
	var icon_rect := icon.get_global_rect()
	var diameter := minf(icon_rect.size.x, icon_rect.size.y) + 24.0
	_scale.size = Vector2(diameter, diameter)
	_scale.global_position = icon_rect.get_center() - _scale.size * 0.5


func _unhandled_key_input(event: InputEvent) -> void:
	if state != State.OFF and event.is_action_pressed("ui_cancel"):
		turn_off()
		get_viewport().set_input_as_handled()


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


## Switch the flashlight off and close the scale.
func turn_off() -> void:
	if state != State.OFF:
		_set_state(State.OFF)


func _on_button_pressed() -> void:
	match state:
		State.OFF:
			_set_state(State.AIMING)
		_:
			_set_state(State.OFF)


func _on_catcher_input(event: InputEvent) -> void:
	if state == State.OFF or not (event is InputEventMouseButton) or not event.pressed:
		return
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			_catcher.accept_event()
			flashlight.turn_on_at(_catcher.get_global_transform() * event.position, true)
			_set_state(State.ON)
		MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN:
			_catcher.accept_event()
			if state == State.ON:
				_scale.adjust_with_wheel(event)


func _set_state(new_state: int) -> void:
	state = new_state
	_scale.visible = state != State.OFF
	# Keep accepting scene clicks and wheel input while the beam is locked.
	_catcher.visible = state != State.OFF
	flashlight.active = state == State.ON
	_button.texture_normal = icon_on if state == State.ON else icon_off
	_button.modulate = Color(1.2, 1.15, 1.0) if state == State.AIMING else Color.WHITE
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if state == State.OFF:
		flashlight.beam_locked = false
	state_changed.emit(state)
