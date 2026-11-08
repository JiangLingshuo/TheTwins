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
				if used.has_area():
					# Rubbings are ink masks, not coloured artwork. Some source
					# glyphs are black; multiplication alone cannot lighten them.
					# Preserve their alpha and let each page's text colour tint RGB.
					var mask := image.get_region(used)
					mask.convert(Image.FORMAT_RGBA8)
					var pixels := mask.get_data()
					for pixel in range(0, pixels.size(), 4):
						pixels[pixel] = 255
						pixels[pixel + 1] = 255
						pixels[pixel + 2] = 255
					mask = Image.create_from_data(mask.get_width(), mask.get_height(), false, Image.FORMAT_RGBA8, pixels)
					result = ImageTexture.create_from_image(mask)
	_cache[path] = result
	return result
