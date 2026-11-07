extends Control
## Rubbing tool: a button on the right edge of the screen.
## Click it to pick up the charcoal, then drag over a tombstone: carved symbols
## (RubbingSymbol nodes) appear where you brush. Click the button again to put
## the charcoal down. Only the stone zoomed in on (SceneZoom) can be rubbed.

## Emitted when the tool is picked up / put down.
signal state_changed(is_active: bool)
## Emitted the first time a symbol is fully rubbed and recorded in GameState.
signal rubbing_collected(rubbing_id: String)

## Button art when the tool is off / on.
@export var icon_off: Texture2D
@export var icon_on: Texture2D
## Brush cursor drawn while the tool is active.
@export var cursor_color: Color = Color(0.95, 0.92, 0.84, 0.8)

var active := false

var _drawing := false
var _last_point := Vector2.ZERO
## Wiping sound: a long recording that plays only while the charcoal is moving.
const WIPE_SOUND: AudioStream = preload("res://assets/audio/擦拭.wav")
## Seconds without mouse movement before the wiping sound pauses.
const WIPE_IDLE := 0.09
var _wipe: AudioStreamPlayer
var _wipe_idle := 0.0

@onready var _button: TextureButton = $RubbingButton


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_wipe = AudioStreamPlayer.new()
	_wipe.stream = WIPE_SOUND
	_wipe.volume_db = -8.0
	add_child(_wipe)
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
	_wipe_stop()
	_button.texture_normal = icon_on if active else icon_off
	if not active:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	queue_redraw()
	state_changed.emit(active)


func turn_off() -> void:
	if active:
		set_active(false)


func _process(delta: float) -> void:
	if not active:
		return
	if _wipe.playing and not _wipe.stream_paused:
		_wipe_idle += delta
		if _wipe_idle > WIPE_IDLE:
			_wipe.stream_paused = true
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
		if not _drawing: _wipe_stop()
		if _drawing:
			_hint_zoom_in()
			_last_point = event.global_position
			_brush(_last_point, _last_point)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _drawing:
		_wipe_move(event.global_position.distance_to(_last_point))
		_brush(_last_point, event.global_position)
		_last_point = event.global_position
		get_viewport().set_input_as_handled()


func _wipe_move(distance: float) -> void:
	if distance < 0.5:
		return
	_wipe_idle = 0.0
	if not _wipe.playing:
		_wipe.play(randf() * maxf(WIPE_SOUND.get_length() - 2.0, 0.0))
	_wipe.stream_paused = false
	# Faster strokes sound firmer.
	_wipe.volume_db = lerpf(-16.0, -4.0, clampf(distance / 30.0, 0.0, 1.0))


func _wipe_stop() -> void:
	if _wipe and _wipe.playing:
		_wipe.stop()
	_wipe_idle = 0.0


func _brush(from_point: Vector2, to_point: Vector2) -> void:
	for symbol in get_tree().get_nodes_in_group("rubbing_symbols"):
		if symbol.is_visible_in_tree() and can_rub(symbol):
			symbol.brush(from_point, to_point)


## Rubbings are taken up close: only symbols on the stone the view is zoomed in
## on can be rubbed (SceneZoom; a scene without one allows every symbol).
func can_rub(symbol: Control) -> bool:
	var scene_zoom := get_tree().get_first_node_in_group("scene_zoom")
	if scene_zoom == null:
		return true
	var stone: Control = scene_zoom.get_zoomed()
	return stone != null and stone.is_ancestor_of(symbol)


func _hint_zoom_in() -> void:
	var scene_zoom := get_tree().get_first_node_in_group("scene_zoom")
	var toast := get_parent().get_node_or_null("Toast")
	if scene_zoom and not scene_zoom.is_zoomed() and toast:
		toast.show_message("Use a marker's magnifier to look closer before making a rubbing.", true)


func _connect_symbol(symbol: RubbingSymbol) -> void:
	if not symbol.rubbed.is_connected(_on_symbol_rubbed):
		symbol.rubbed.connect(_on_symbol_rubbed)


func _on_symbol_rubbed(rubbing_id: String) -> void:
	var gravestone_id := ""
	var texture_path := ""
	var target_id := ""
	for symbol in get_tree().get_nodes_in_group("rubbing_symbols"):
		if symbol.rubbing_id == rubbing_id:
			target_id = symbol.matching_target_id
			if symbol.texture:
				texture_path = symbol.texture.resource_path
			# The gravestone the symbol is carved on is one of its ancestors.
			var node: Node = symbol.get_parent()
			while node and gravestone_id.is_empty():
				gravestone_id = str(node.get("gravestone_id")) if node.get("gravestone_id") != null else ""
				node = node.get_parent()
			break
	if GameState.record_rubbing(rubbing_id, gravestone_id, texture_path, target_id):
		rubbing_collected.emit(rubbing_id)


func _draw() -> void:
	if not active or _button.get_global_rect().has_point(get_global_mouse_position()):
		return
	var p := get_local_mouse_position()
	draw_circle(p, 22.0, Color(cursor_color, 0.12))
	draw_arc(p, 22.0, 0.0, TAU, 40, cursor_color, 1.5, true)
	draw_circle(p, 2.0, cursor_color)
