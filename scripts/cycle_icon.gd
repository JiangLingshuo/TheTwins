extends Control
## The Rise & Set spread intentionally contains only one icon on each page.
var rubbing_id := ""
var interactive := true
var ink := Color.WHITE
var _pressed := false
var _press_point := Vector2.ZERO

func setup(id: String, color: Color, can_interact: bool) -> void:
	rubbing_id = id
	tooltip_text = GameState.rubbing_display(id) if GameState.rubbings.has(id) else "Not yet recorded"
	ink = color
	interactive = can_interact
	mouse_filter = Control.MOUSE_FILTER_STOP if interactive else Control.MOUSE_FILTER_IGNORE
	mouse_default_cursor_shape = Control.CURSOR_DRAG if GameState.rubbings.has(id) else Control.CURSOR_ARROW
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if not interactive or not GameState.rubbings.has(rubbing_id):
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_pressed = event.pressed
		_press_point = event.position
		accept_event()
	elif event is InputEventMouseMotion and _pressed and event.button_mask & MOUSE_BUTTON_MASK_LEFT and event.position.distance_to(_press_point) > 6:
		var drag := get_tree().get_first_node_in_group("rubbing_drag")
		if drag:
			drag.begin_cycle(rubbing_id, event.global_position)
		_pressed = false
		accept_event()

func _draw() -> void:
	var path := "res://assets/Art/symbols/sky_sun.svg" if rubbing_id == "sky_sun_rubbing" else "res://assets/Art/symbols/moon.png"
	var texture: Texture2D = load(path)
	var fit := minf(size.x / texture.get_width(), size.y / texture.get_height())
	var drawn := Vector2(texture.get_size()) * fit
	draw_texture_rect(texture, Rect2((size - drawn) / 2, drawn), false, Color(ink, 1.0 if GameState.rubbings.has(rubbing_id) else 0.12))
