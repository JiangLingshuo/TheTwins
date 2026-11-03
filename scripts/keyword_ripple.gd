extends Control
var elapsed := 0.0
var tint := Color(0.75, 0.52, 0.17)
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()
func _draw() -> void:
	# Rings and a pulsing underline cue visually invite clicking the highlighted terms.
	var phase := fmod(elapsed * 0.65, 1.0)
	var center := Vector2(14, 14)
	for offset in [0.0, 0.5]:
		var wave := fmod(phase + offset, 1.0)
		draw_arc(center, 4 + wave * 16, 0, TAU, 40, Color(tint, (1.0 - wave) * 0.7), 1.5, true)
	draw_line(Vector2(38, 21), Vector2(size.x - 8, 21), Color(tint, 0.3 + 0.3 * sin(elapsed * 3.0)), 1.5)
