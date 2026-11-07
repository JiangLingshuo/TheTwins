extends Control
## Camera-only markings on the day cemetery: the twin-beast footprint by the
## fountain. (The ones on the crystal and sun-shaped monuments are carved
## rubbing symbols in their tombstone scenes.) The three tombs and their shared base are real scene
## art (Tombstone instances and the Pedestal layer).

## Top-left corners of the footprints, in cemetery (1920×1080 art) pixels.
const BEAST_SPOTS := [Vector2(1430, 560)]

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var beast: Texture2D = load("res://assets/Art/figure/twin_beast_footprint.png")
	for at in BEAST_SPOTS:
		var icon := TextureRect.new()
		icon.texture = beast
		icon.position = at
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(icon)
		icon.size = Vector2(68, 67)  # once in the tree, or the texture's own size wins
