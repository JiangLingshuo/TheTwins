class_name TrimmedTexture
extends RefCounted
## A symbol texture cut down to its visible (non-transparent) part.
##
## The carved-symbol textures are big squares with wide transparent margins, and
## the drawing is rarely centred in them. Drawn whole into a small slot, a symbol
## comes out tiny and off-centre; drawn trimmed, it fills and centres in the slot.

static var _cache: Dictionary = {}


## The visible part of the texture at `path`, or null if it cannot be loaded.
static func of(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if _cache.has(path):
		return _cache[path]
	var result: Texture2D = null
	if ResourceLoader.exists(path, "Texture2D"):
		var texture := load(path) as Texture2D
		if texture:
			result = texture
			var image := texture.get_image()
			if image:
				if image.is_compressed():
					image.decompress()
				var used := image.get_used_rect()
				if used.size.x > 0 and used.size.y > 0 and used.size != image.get_size():
					var atlas := AtlasTexture.new()
					atlas.atlas = texture
					atlas.region = Rect2(used)
					result = atlas
	_cache[path] = result
	return result
