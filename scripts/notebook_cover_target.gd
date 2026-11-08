extends Control
## An invisible drop region on the real notebook's cover, active only while held.
var target_id := "notebook_cover"

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_to_group("decipher_targets")

func get_meaning() -> String:
	return "The same girl on the notebook cover"

func contains_point(point: Vector2) -> bool:
	var tool := get_parent()
	if not tool._cover_holding or not tool._cover_ready or tool._cover_releasing: return false
	var cover: Control = tool.book.cover
	if not cover.is_visible_in_tree(): return false
	# The girl-and-coffin image occupies the middle of the cover, below its title.
	var local := cover.get_global_transform().affine_inverse() * point
	return Rect2(cover.size * Vector2(0.12, 0.25), cover.size * Vector2(0.76, 0.56)).has_point(local)
