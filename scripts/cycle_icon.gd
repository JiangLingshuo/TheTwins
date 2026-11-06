extends Control
## The Rise & Set spread intentionally contains only one icon on each page.
const INVERT_SHADER: Shader = preload("res://shaders/portrait_invert.gdshader")
var rubbing_id := ""
var interactive := true
var ink := Color.WHITE
## Fit the drawing's visible part (without its transparent margin) to the icon:
## for the small corner icons, where the margin would make the moon a speck.
var trim := false
var _used := Rect2()
var _pressed := false
var _press_point := Vector2.ZERO
var _texture: Texture2D

## `inverted`: draw with the colours reversed (the moon on a dark Night page).
func setup(id: String, color: Color, can_interact: bool, inverted: bool) -> void:
	rubbing_id = id
	tooltip_text = GameState.rubbing_display(id) if GameState.rubbings.has(id) else "Not yet recorded"
	ink = color
	interactive = can_interact
	if inverted:
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
	# Each icon stays off the page until the tutorial drops it in: the crescent
	# after its rubbing, the sun once the moon has replaced it in the sky.
	if not GameState.cycle_hint_heard or not GameState.rubbings.has(rubbing_id):
		return
	var path := "res://assets/Art/symbols/sky_sun.svg" if rubbing_id == "sky_sun_rubbing" else "res://assets/Art/symbol/moon.png"
	# Keep the texture referenced: drawing only stores its RID, and an icon nothing
	# else uses (the sky sun) would otherwise be freed and draw as a solid square.
	if _texture == null or _texture.resource_path != path:
		_texture = load(path)
		_used = Rect2(Vector2.ZERO, _texture.get_size())
		if trim:
			var image := _texture.get_image()
			if image.is_compressed():
				image.decompress()
			var used := Rect2(image.get_used_rect())
			if used.has_area():
				# A hair of breathing room, kept inside the texture.
				_used = used.grow(used.size.x * 0.04).intersection(_used)
	var fit := minf(size.x / _used.size.x, size.y / _used.size.y)
	var drawn := _used.size * fit
	draw_texture_rect_region(_texture, Rect2((size - drawn) / 2, drawn), _used, ink)
