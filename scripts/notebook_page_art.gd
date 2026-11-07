extends Control
## Drawn content of one notebook page (placeholders for the notebook sections).
## The book keeps one on each page and one on the turning sheet, so the drawing
## turns with the paper the same way the page text does.

const FONT: Font = preload("res://assets/fonts/ZhaohuaTypeWriter.ttf")
const INK := Color(0.17, 0.14, 0.12)
const FADED_ALPHA := 0.45
## Size of the gravestone silhouette.
const STONE_SIZE := Vector2(170, 240)

enum Kind { NONE, GRAVESTONE, TITLE, NOTE }

var _kind := Kind.NONE
var _text := ""
var _collected := false
## Ink of the drawing; the book changes it for Day / Night pages.
var _ink := INK
var _faded_ink := Color(INK, FADED_ALPHA)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Draw in `ink`, with the faint linework at `faded_alpha` opacity.
func set_ink(ink: Color, faded_alpha: float) -> void:
	_ink = ink
	_faded_ink = Color(ink, faded_alpha)
	queue_redraw()


## Back to the normal paper ink.
func reset_ink() -> void:
	set_ink(INK, FADED_ALPHA)


func clear() -> void:
	_show(Kind.NONE)


## A gravestone slot: a dashed outline with a question mark until it is collected.
func show_gravestone(collected: bool) -> void:
	_show(Kind.GRAVESTONE, "", collected)


## A section's opening page.
func show_title(title: String) -> void:
	_show(Kind.TITLE, title)


## A short faded line in the middle of the page.
func show_note(text: String) -> void:
	_show(Kind.NOTE, text)


func _show(kind: Kind, text: String = "", collected: bool = false) -> void:
	_kind = kind
	_text = text
	_collected = collected
	queue_redraw()


func _draw() -> void:
	match _kind:
		Kind.GRAVESTONE:
			_draw_gravestone()
		Kind.TITLE:
			_draw_centered_text(_text, 38, _ink, size.y * 0.4)
			var rule_y := size.y * 0.4 + 26.0
			draw_line(Vector2(size.x / 2.0 - 60.0, rule_y), Vector2(size.x / 2.0 + 60.0, rule_y), _faded_ink, 1.5, true)
		Kind.NOTE:
			_draw_centered_text(_text, 22, _faded_ink, size.y / 2.0)


func _draw_gravestone() -> void:
	var outline := _stone_outline()
	if _collected:
		# Placeholder until collected gravestones show their real content.
		draw_colored_polygon(outline, Color(_ink, 0.06))
		draw_polyline(outline, _faded_ink, 2.0, true)
	else:
		_draw_dashed_polyline(outline, _faded_ink, 2.0, 10.0, 7.0)
		_draw_centered_text("?", 84, _faded_ink, size.y / 2.0 + 10.0)
	# The ground the stone stands on.
	var ground_y := (size.y + STONE_SIZE.y) / 2.0
	_draw_dashed_polyline(PackedVector2Array([
		Vector2(size.x / 2.0 - STONE_SIZE.x * 0.75, ground_y),
		Vector2(size.x / 2.0 + STONE_SIZE.x * 0.75, ground_y),
	]), _faded_ink, 2.0, 10.0, 7.0)


## Closed outline of a round-topped headstone, centred on the page.
func _stone_outline() -> PackedVector2Array:
	var radius := STONE_SIZE.x / 2.0
	var left := size.x / 2.0 - radius
	var right := size.x / 2.0 + radius
	var top := (size.y - STONE_SIZE.y) / 2.0
	var bottom := top + STONE_SIZE.y
	var points := PackedVector2Array([Vector2(left, bottom)])
	var centre := Vector2(size.x / 2.0, top + radius)
	var steps := 24
	for i in steps + 1:
		var angle := PI + PI * i / steps
		points.append(centre + Vector2(cos(angle), sin(angle)) * radius)
	points.append(Vector2(right, bottom))
	points.append(Vector2(left, bottom))
	return points


func _draw_dashed_polyline(points: PackedVector2Array, color: Color, width: float,
		dash: float, gap: float) -> void:
	var drawing := true
	var left := dash
	for i in points.size() - 1:
		var a := points[i]
		var b := points[i + 1]
		var length := a.distance_to(b)
		var t := 0.0
		while t < length:
			var step := minf(left, length - t)
			if drawing:
				draw_line(a.lerp(b, t / length), a.lerp(b, (t + step) / length), color, width, true)
			t += step
			left -= step
			if left <= 0.0:
				drawing = not drawing
				left = dash if drawing else gap


func _draw_centered_text(text: String, font_size: int, color: Color, centre_y: float) -> void:
	var baseline := centre_y + (FONT.get_ascent(font_size) - FONT.get_descent(font_size)) / 2.0
	draw_string(FONT, Vector2(0, baseline), text, HORIZONTAL_ALIGNMENT_CENTER, size.x, font_size, color)
