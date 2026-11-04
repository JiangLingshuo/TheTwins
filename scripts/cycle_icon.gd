extends Control
## The Rise & Set spread intentionally contains only one icon on each page.
const INVERT_SHADER: Shader = preload("res://shaders/portrait_invert.gdshader")
var rubbing_id := ""
var interactive := true
var ink := Color.WHITE
var _pressed := false
var _press_point := Vector2.ZERO
var _texture: Texture2D

func setup(id: String, color: Color, can_interact: bool) -> void:
	rubbing_id = id
	tooltip_text = GameState.rubbing_display(id) if GameState.rubbings.has(id) else "Not yet recorded"
	ink = color
	interactive = can_interact
	# The moon is drawn with its colours reversed (the sun keeps its own).
	if id == "infant_moon_rubbing":
		if material == null:
			var invert := ShaderMaterial.new()
			invert.shader = INVERT_SHADER
			invert.set_shader_parameter("invert", 1.0)
			material = invert
	else:
		material = null
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
	var path := "res://assets/Art/symbols/sky_sun.svg" if rubbing_id == "sky_sun_rubbing" else "res://assets/Art/symbol/moon.png"
	# Keep the texture referenced: drawing only stores its RID, and an icon nothing
	# else uses (the sky sun) would otherwise be freed and draw as a solid square.
	if _texture == null or _texture.resource_path != path:
		_texture = load(path)
	var texture := _texture
	var fit := minf(size.x / texture.get_width(), size.y / texture.get_height())
	var drawn := Vector2(texture.get_size()) * fit
	draw_texture_rect(texture, Rect2((size - drawn) / 2, drawn), false, Color(ink, 1.0 if GameState.rubbings.has(rubbing_id) else 0.12))
