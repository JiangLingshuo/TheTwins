extends Control
## Index tabs along the sides of the open notebook, one per section. The current
## section and the ones before it sit on the left edge, later ones on the right.
## The tabs are drawn behind the pages, so only their ends stick out; the active
## tab sticks out a little further and lies on top of its neighbours.

signal tab_pressed(section: int)

const FONT: Font = preload("res://assets/fonts/CormorantGaramond-Regular.ttf")

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
## Distance from each side of the book to the visible edge of the cover board.
@export var left_edge_inset: float = 14.0
@export var right_edge_inset: float = 6.0
## How far a tab sticks out past the cover board: inactive / active.
@export var inactive_reach: float = 26.0
@export var active_reach: float = 36.0
@export var font_size: int = 17
## How much darker the inactive tabs are.
@export_range(0.0, 1.0, 0.05) var inactive_shade: float = 0.15
## Seconds for a tab to slide to its new place.
@export var move_time: float = 0.3

var _tabs: Array[Tab] = []
var _active := -1
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
	var instant := _active < 0
	_active = section
	for rank in _order.size():
		var i := _order[rank]
		var tab := _tabs[i]
		tab.on_left = rank <= _rank(section)
		tab.shade = 0.0 if i == section else inactive_shade
		tab.text_inset = (active_reach if i == section else inactive_reach) / 2.0
		tab.queue_redraw()
		move_child(tab, rank)  # lower tabs overlap the ones above them...
		var target := _tab_position(i)
		if instant:
			tab.position = target
		elif tab.position != target:
			create_tween().tween_property(tab, "position", target, move_time) \
				.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if section >= 0 and section < _tabs.size():
		move_child(_tabs[section], -1)  # ...and the active one lies on top.


## Place of section `i` down the book (0 = top).
func _rank(i: int) -> int:
	return _order.find(i)


func _tab_position(i: int) -> Vector2:
	var reach := active_reach if i == _active else inactive_reach
	var y := first_tab_y + _rank(i) * tab_spacing
	if _rank(i) <= _rank(_active):
		return Vector2(left_edge_inset - reach, y)
	return Vector2(size.x - right_edge_inset + reach - tab_size.x, y)


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
		draw_style_box(style, Rect2(Vector2.ZERO, size))

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
