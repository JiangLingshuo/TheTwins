extends Control
## Main game scene with a day/night switch.
## Day shows the yellow Day City background, night the blue Night City one,
## with a short cross-fade between them.
##
## From other scripts: set_day(), set_night(), toggle_time(), or set `is_day`.
## While testing, press the `toggle_key` (F1 by default, a debug key) to switch.

## Emitted after the time of day changes.
signal time_changed(is_day: bool)

## Time of day when the scene starts.
@export_enum("Day", "Night") var start_time: int = 0
## Seconds for the cross-fade between backgrounds.
@export var transition_time: float = 0.8
## Seconds to fade in from black when the scene opens.
@export var fade_in_time: float = 0.8
## Key that switches day/night (for testing). Set to KEY_NONE to disable.
@export var toggle_key: Key = KEY_F1
## Message shown when a gravestone is recorded in the notebook.
@export var gravestone_recorded_message: String = "New gravestone recorded in the Notebook."
## Message shown when a rubbing is recorded in the notebook.
@export var rubbing_recorded_message: String = "New rubbing recorded in the Notebook."
## Message shown when a rubbing dropped on its scene object is deciphered.
@export var rubbing_deciphered_message: String = "Symbol deciphered! Notebook updated."
## Message shown when a rubbing is dropped on the wrong thing.
@export var rubbing_mismatch_message: String = "This symbol doesn't seem connected to that."

@onready var _day_background: TextureRect = $DayBackground
@onready var _night_background: TextureRect = $NightBackground
@onready var _flashlight_tool: Control = $FlashlightTool
@onready var _notebook_tool: Control = $NotebookTool
@onready var _rubbing_tool: Control = $RubbingTool
@onready var _day_cemetery: Control = $DayCemetery
@onready var _night_cemetery: Control = $NightCemetery
@onready var _toast: Control = $Toast

## True during the day, false at night.
var is_day: bool = true:
	set(value):
		if value == is_day:
			return
		is_day = value
		_fade_backgrounds()
		time_changed.emit(is_day)

var _fade: Tween


func _ready() -> void:
	is_day = start_time == 0
	# Show the starting background straight away, without cross-fading.
	_night_background.modulate.a = 0.0 if is_day else 1.0
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, fade_in_time)
	_day_cemetery.visible = is_day
	_night_cemetery.visible = not is_day
	time_changed.connect(func(day: bool) -> void:
		_day_cemetery.visible = day
		_night_cemetery.visible = not day)
	# One tool at a time: picking one up puts the other away; reading the
	# notebook puts both away.
	_notebook_tool.notebook_opened.connect(_flashlight_tool.turn_off)
	_notebook_tool.notebook_opened.connect(_rubbing_tool.turn_off)
	_rubbing_tool.state_changed.connect(func(on: bool) -> void:
		if on:
			_flashlight_tool.turn_off())
	_flashlight_tool.state_changed.connect(func(state: int) -> void:
		if state != 0:
			_rubbing_tool.turn_off())
	# The rubbing tool emits `rubbing_collected` once per symbol, after it is recorded.
	_rubbing_tool.rubbing_collected.connect(func(_id: String) -> void:
		_toast.show_message(rubbing_recorded_message))
	# Rubbings dragged from the notebook onto the scene.
	_notebook_tool.rubbing_drag.deciphered.connect(func(_id: String, _target: Control) -> void:
		_toast.show_message(rubbing_deciphered_message))
	_notebook_tool.rubbing_drag.mismatched.connect(func(_id: String, _target: Control) -> void:
		_toast.show_message(rubbing_mismatch_message))
	# A gravestone emits `recorded` once, after it is collected.
	for gravestone in get_tree().get_nodes_in_group("gravestones"):
		gravestone.recorded.connect(func(id: String) -> void:
			_notebook_tool.show_gravestone_next(id)
			_toast.show_message(gravestone_recorded_message))


func _unhandled_key_input(event: InputEvent) -> void:
	if toggle_key != KEY_NONE and event.is_pressed() and not event.is_echo() \
			and (event as InputEventKey).keycode == toggle_key:
		toggle_time()
		get_viewport().set_input_as_handled()


func set_day() -> void:
	is_day = true


func set_night() -> void:
	is_day = false


func toggle_time() -> void:
	is_day = not is_day


func _fade_backgrounds() -> void:
	if not is_node_ready():
		return
	if _fade:
		_fade.kill()
	# The night background sits on top; fading it in or out reveals the other.
	_fade = create_tween()
	_fade.tween_property(_night_background, "modulate:a", 0.0 if is_day else 1.0, transition_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
