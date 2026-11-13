extends TextureRect
## A scene object that deciphers rubbings: drop a rubbing from the notebook on
## it, and if the rubbing's matching_target_id equals `target_id`, its meaning
## is confirmed. Attach to any TextureRect in the scene and set `target_id`.
##
## The meaning shown in the notebook is `meaning`, or the texture's file name
## without extension (moon.png -> "moon") while `meaning` is empty.

## Id that RubbingSymbol.matching_target_id refers to (e.g. "moon").
@export var target_id: String = ""
## Meaning confirmed for a matching rubbing ("" = the texture's file name).
@export var meaning: String = ""
## Only drops on visible pixels count (otherwise the whole rect counts).
@export var hit_by_alpha: bool = false
@export_range(0.0, 1.0, 0.05) var hit_alpha: float = 0.5
## Local-pixel tolerance around narrow painted target lines.
@export var hit_padding: float = 0.0
## Optional mask (same size as the texture) that decides what counts as a hit, instead of
## the texture's own alpha: white = counts. Lets a faint drawing be the target while the
## wash of colour around it is not.
@export var hit_mask: Texture2D

var _image: Image
var _hit_bounds := Rect2()  # the mask's used area, in its own pixels


func _ready() -> void:
	add_to_group("decipher_targets")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var source: Texture2D = hit_mask if hit_mask else texture
	if (hit_by_alpha or hit_mask) and source:
		_image = source.get_image()
		if _image and _image.is_compressed():
			_image.decompress()
		if _image:
			_hit_bounds = Rect2(_image.get_used_rect())


## Meaning to confirm for a rubbing dropped here.
func get_meaning() -> String:
	if not meaning.is_empty():
		return meaning
	var source := texture
	if source is AtlasTexture:
		source = (source as AtlasTexture).atlas
	return source.resource_path.get_file().get_basename() if source else ""


## The part of this object that counts as a hit, on screen (the mask's used area,
## or the whole object without a mask).
func get_hit_global_rect() -> Rect2:
	var rect := get_global_rect()
	if _image == null or not _hit_bounds.has_area():
		return rect
	var to_screen := get_global_transform()
	var scale_to_local := size / Vector2(_image.get_size())
	return to_screen * Rect2(_hit_bounds.position * scale_to_local, _hit_bounds.size * scale_to_local)


## True if a screen position is on this object (and it is showing).
func contains_point(global_point: Vector2) -> bool:
	if not is_visible_in_tree():
		return false
	var local := get_global_transform().affine_inverse() * global_point
	if not Rect2(Vector2.ZERO, size).has_point(local):
		return false
	if _image == null:
		return true
	var pixel := Vector2i(local / size * Vector2(_image.get_size()))
	pixel = pixel.clamp(Vector2i.ZERO, _image.get_size() - Vector2i.ONE)
	if _image.get_pixelv(pixel).a >= hit_alpha: return true
	var radius := int(ceil(hit_padding * _image.get_width() / maxf(1.0, size.x)))
	for y in range(-radius, radius + 1):
		for x in range(-radius, radius + 1):
			if x * x + y * y > radius * radius: continue
			var nearby := pixel + Vector2i(x, y)
			if nearby.x < 0 or nearby.y < 0 or nearby.x >= _image.get_width() or nearby.y >= _image.get_height(): continue
			if _image.get_pixelv(nearby).a >= hit_alpha: return true
	return false
