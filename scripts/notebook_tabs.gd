extends Control
## Index tabs along the sides of the open notebook, one per section. The current
## section and the ones before it sit on the left edge, later ones on the right.
## Tabs end at the paper edge and lie over the cover board. The active
## tab sticks out a little further and lies on top of its neighbours.

signal tab_pressed(section: int)

const FONT: Font = preload("res://assets/fonts/ZhaohuaTypeWriter.ttf")

## Tab colours, one per section id (provisional, from the art palette).
@export var colors: Array[Color] = [
	Color(0.18, 0.29, 0.42),  # deep blue
	Color(0.25, 0.54, 0.55),  # teal
	Color(0.66, 0.78, 0.85),  # pale blue
	Color(0.89, 0.57, 0.48),  # coral / peach
	Color(0.85, 0.76, 0.48),  # muted yellow
	Color(0.44, 0.39, 0.55),  # muted twilight violet (Rise & Set)
]
## Size of a tab: x is across the book's edge, y is along it.
@export var tab_size: Vector2 = Vector2(60, 112)
## Where the first tab starts below the top of the book, and the step between tabs
## (less than tab_size.y, so neighbouring tabs overlap a little).
@export var first_tab_y: float = 36.0
@export var tab_spacing: float = 102.0
## Distance from each side of the book to the outer edge of its paper.
@export var left_edge_inset: float = 31.0
@export var right_edge_inset: float = 36.0
## How far a tab sticks out past the paper edge: inactive / active.
@export var inactive_reach: float = 26.0
@export var active_reach: float = 36.0
@export var font_size: int = 17
## How much darker the inactive tabs are.
@export_range(0.0, 1.0, 0.05) var inactive_shade: float = 0.15

var _tabs: Array[Tab] = []
var _active := -1
var _turning_tabs: Array[Tab] = []
## Section ids in the order their tabs run down the book.
var _order: PackedInt32Array = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Create one tab per section title. `order` lists the section ids top to
## bottom (default: the order of `titles`); tabs keep their section id.
func setup(titles: PackedStringArray, order: PackedInt32Array = []) -> void:
	_order = order
	if _order.is_empty():
		for i in titles.size(): _order.append(i)
	if titles.size() > 1:
		tab_spacing = minf(tab_spacing, (size.y - first_tab_y - tab_size.y - 16) / (titles.size() - 1))
	for i in titles.size():
		var tab := Tab.new()
		tab.title = titles[i]
		tab.color = colors[i % colors.size()]
		tab.font_size = font_size
		tab.size = tab_size
		tab.gui_input.connect(_on_tab_input.bind(i))
		add_child(tab)
		_tabs.append(tab)


## Show `section` as the open one and move every tab to its side.
func set_active(section: int) -> void:
	for tab in _turning_tabs:
		tab.reparent(self, false)
		tab.mouse_filter = Control.MOUSE_FILTER_STOP
	_turning_tabs.clear()
	_active = section
	for rank in _order.size():
		var i := _order[rank]
		var tab := _tabs[i]
		tab.on_left = rank <= _rank(section)
		tab.shade = 0.0 if i == section else inactive_shade
		var reach := active_reach if i == section else inactive_reach
		tab.size.x = reach
		tab.text_inset = reach / 2.0
		tab.queue_redraw()
		tab.position = _tab_position(i)
	# On the left, lower tabs cover upper tabs; on the right, upper tabs cover lower tabs.
	for i in _order:
		if _tabs[i].on_left:
			move_child(_tabs[i], -1)
	for rank in range(_order.size() - 1, -1, -1):
		var tab := _tabs[_order[rank]]
		if not tab.on_left:
			move_child(tab, -1)


## Tabs crossing the spine belong to the actual turning sheet for both halves.
func begin_turn(section: int, sheet: Control) -> void:
	for i in _order:
		var tab := _tabs[i]
		if tab.on_left != (_rank(i) <= _rank(section)):
			_turning_tabs.append(tab)
			tab.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tab.reparent(sheet)


func place_turning_tabs(section: int, sheet: Control) -> void:
	for i in _order:
		var tab := _tabs[i]
		if tab not in _turning_tabs:
			continue
		tab.on_left = _rank(i) <= _rank(section)
		tab.shade = 0.0 if i == section else inactive_shade
		tab.size.x = active_reach if i == section else inactive_reach
		tab.text_inset = tab.size.x * 0.5
		tab.position = position + _tab_position(i, section) - sheet.position
		tab.queue_redraw()


## Place of section `i` down the book (0 = top).
func _rank(i: int) -> int:
	return _order.find(i)


func _tab_position(i: int, section: int = -1) -> Vector2:
	var current := _active if section < 0 else section
	var reach := active_reach if i == current else inactive_reach
	var y := first_tab_y + _rank(i) * tab_spacing
	if _rank(i) <= _rank(current):
		return Vector2(left_edge_inset - reach, y)
	return Vector2(size.x - right_edge_inset, y)


func _on_tab_input(event: InputEvent, section: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_tabs[section].accept_event()
		tab_pressed.emit(section)


## One paper tab, rounded on its outer end, with the section name running along it.
class Tab extends Control:
	var title := ""
	var color := Color.WHITE
	var font_size := 17
	var on_left := true
	var shade := 0.0
	## Distance of the name's centre line from the tab's outer end.
	var text_inset := 13.0
	var _surface: Panel

	func _ready() -> void:
		_surface = Panel.new()
		_surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_surface.show_behind_parent = true
		var foil := ShaderMaterial.new()
		foil.shader = preload("res://shaders/notebook_tab_foil.gdshader")
		_surface.material = foil
		add_child(_surface)
		_surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	func _draw() -> void:
		var fill := color.darkened(shade)
		var style := StyleBoxFlat.new()
		style.bg_color = fill
		style.border_color = fill.darkened(0.35)
		style.set_border_width_all(1)
		style.shadow_color = Color(0, 0, 0, 0.25)
		style.shadow_size = 3
		var radius := 8
		style.corner_radius_top_left = radius if on_left else 0
		style.corner_radius_bottom_left = radius if on_left else 0
		style.corner_radius_top_right = 0 if on_left else radius
		style.corner_radius_bottom_right = 0 if on_left else radius
		if _surface:
			_surface.add_theme_stylebox_override("panel", style)
			(_surface.material as ShaderMaterial).set_shader_parameter("tab_size", size)

		# The name reads upwards on the left edge and downwards on the right,
		# centred on the part of the tab that sticks out.
		var ink := Color(0.12, 0.1, 0.09) if fill.get_luminance() > 0.5 else Color(0.96, 0.95, 0.92)
		var font: Font = FONT
		var text_x := text_inset if on_left else size.x - text_inset
		draw_set_transform(Vector2(text_x, size.y / 2.0), -PI / 2.0 if on_left else PI / 2.0)
		var baseline := (font.get_ascent(font_size) - font.get_descent(font_size)) / 2.0
		draw_string(font, Vector2(-size.y / 2.0, baseline), title,
			HORIZONTAL_ALIGNMENT_CENTER, size.y, font_size, ink)
		draw_set_transform(Vector2.ZERO)
