extends Control
## Rubbing tool: a button on the right edge of the screen.
## Click it to pick up the charcoal, then drag over a tombstone: carved symbols
## (RubbingSymbol nodes) appear where you brush. Click the button again to put
## the charcoal down.

## Emitted when the tool is picked up / put down.
signal state_changed(is_active: bool)
## Emitted when a symbol has been fully rubbed.
signal rubbing_collected(rubbing_id: String)

## Button art when the tool is off / on.
@export var icon_off: Texture2D
@export var icon_on: Texture2D
## Brush cursor drawn while the tool is active.
@export var cursor_color: Color = Color(0.95, 0.92, 0.84, 0.8)

var active := false

var _drawing := false
var _last_point := Vector2.ZERO

@onready var _button: TextureButton = $RubbingButton


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_button.pressed.connect(func() -> void: set_active(not active))
	for symbol in get_tree().get_nodes_in_group("rubbing_symbols"):
		_connect_symbol(symbol)
	get_tree().node_added.connect(func(node: Node) -> void:
		if node is RubbingSymbol:
			_connect_symbol.call_deferred(node))
	set_active(false)


func set_active(value: bool) -> void:
	active = value
	_drawing = false
	_button.texture_normal = icon_on if active else icon_off
	if not active:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	queue_redraw()
	state_changed.emit(active)


func turn_off() -> void:
	if active:
		set_active(false)


func _process(_delta: float) -> void:
	if not active:
		return
	# Show the brush instead of the arrow, except over the button.
	var over_button := _button.get_global_rect().has_point(get_global_mouse_position())
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if over_button else Input.MOUSE_MODE_HIDDEN
	queue_redraw()


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_drawing = event.pressed
		if _drawing:
			_last_point = event.global_position
			_brush(_last_point, _last_point)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _drawing:
		_brush(_last_point, event.global_position)
		_last_point = event.global_position
		get_viewport().set_input_as_handled()


func _brush(from_point: Vector2, to_point: Vector2) -> void:
	for symbol in get_tree().get_nodes_in_group("rubbing_symbols"):
		if symbol.is_visible_in_tree():
			symbol.brush(from_point, to_point)


func _connect_symbol(symbol: RubbingSymbol) -> void:
	if not symbol.rubbed.is_connected(_on_symbol_rubbed):
		symbol.rubbed.connect(_on_symbol_rubbed)


func _on_symbol_rubbed(rubbing_id: String) -> void:
	if not GameState.rubbings.has(rubbing_id):
		GameState.rubbings.append(rubbing_id)
	rubbing_collected.emit(rubbing_id)


func _draw() -> void:
	if not active or _button.get_global_rect().has_point(get_global_mouse_position()):
		return
	var p := get_local_mouse_position()
	draw_circle(p, 22.0, Color(cursor_color, 0.12))
	draw_arc(p, 22.0, 0.0, TAU, 40, cursor_color, 1.5, true)
	draw_circle(p, 2.0, cursor_color)
