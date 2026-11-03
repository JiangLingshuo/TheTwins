extends Control
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for path in ["scholar.png", "the rich.png"]:
		var image := TextureRect.new()
		image.texture = load("res://assets/Art/day/草稿/" + path)
		image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(image)
	var beast: Texture2D = load("res://assets/Art/symbols/beast_camera.svg")
	for at in [Vector2(440, 720), Vector2(1140, 720), Vector2(1430, 560)]:
		var icon := TextureRect.new()
		icon.texture = beast
		icon.position = at
		icon.size = Vector2(65, 50)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(icon)
func _draw() -> void:
	draw_style_box(_base_style(), Rect2(310, 845, 1030, 42))
	draw_line(Vector2(310, 858), Vector2(1340, 858), Color(0.75, 0.7, 0.58), 3)
func _base_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.5, 0.48, 0.41)
	style.border_color = Color(0.23, 0.24, 0.22)
	style.set_border_width_all(3)
	return style
