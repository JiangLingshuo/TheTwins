extends Control
## Figure on the detail page of a clue revealed by a rubbing: the rubbing on the
## left, an arrow, and the scene object it matched on the right.
## Scene objects are full-screen layers (mostly transparent), so the object is
## cropped to its visible pixels before it is fitted into its box.

## Width of each picture's box; the arrow fills the gap between them.
const BOX_WIDTH := 120.0

var _rubbing: Texture2D
var _object: Texture2D
var _ink := Color(0.17, 0.14, 0.12)
## Cropped object textures by path (cropping reads the whole image once).
static var _cropped: Dictionary = {}


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func setup(rubbing_path: String, object_path: String, ink: Color) -> void:
	_rubbing = load(rubbing_path) if not rubbing_path.is_empty() and ResourceLoader.exists(rubbing_path) else null
	_object = _crop(object_path)
	_ink = ink
	queue_redraw()


static func _crop(path: String) -> Texture2D:
	if _cropped.has(path):
		return _cropped[path]
	var texture: Texture2D = load(path) if not path.is_empty() and ResourceLoader.exists(path) else null
	var result := texture
	if texture:
		var image := texture.get_image()
		if image:
			if image.is_compressed():
				image.decompress()
			var used := image.get_used_rect()
			if used.has_area() and used.size != image.get_size():
				var atlas := AtlasTexture.new()
				atlas.atlas = texture
				atlas.region = Rect2(used)
				result = atlas
	_cropped[path] = result
	return result


func _draw() -> void:
	var left := Rect2(Vector2.ZERO, Vector2(BOX_WIDTH, size.y))
	var right := Rect2(Vector2(size.x - BOX_WIDTH, 0), Vector2(BOX_WIDTH, size.y))
	# The rubbing art is white on transparent: modulating gives it the ink colour.
	_draw_fitted(_rubbing, left, _ink)
	_draw_fitted(_object, right, Color.WHITE)
	# Arrow from the rubbing to the object.
	var y := size.y / 2.0
	var from := Vector2(left.end.x + 12.0, y)
	var to := Vector2(right.position.x - 12.0, y)
	draw_line(from, to, _ink, 2.0, true)
	draw_polyline(PackedVector2Array([to + Vector2(-11, -8), to, to + Vector2(-11, 8)]), _ink, 2.0, true)


func _draw_fitted(texture: Texture2D, box: Rect2, color: Color) -> void:
	if texture == null:
		return
	var fit := minf(box.size.x / texture.get_width(), box.size.y / texture.get_height())
	var drawn := Vector2(texture.get_size()) * fit
	draw_texture_rect(texture, Rect2(box.get_center() - drawn / 2.0, drawn), false, color)
