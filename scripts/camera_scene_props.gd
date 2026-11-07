extends Control
## Camera-only markings on the day cemetery: the twin-beast motifs the camera
## tutorial asks the player to compare. Every twin-beast mark in the game is the
## same footprint (day/footprint.png, also the searchlight's 250-year trace and
## the scholar's beast rubbing). The three tombs and their shared base are real
## scene art (Tombstone instances and the Pedestal layer).

## Top-left corners of the beast icons, in cemetery (1920×1080 art) pixels:
## the crystal monument's base, the sun-shaped monument's stand, the fountain.
const BEAST_SPOTS := [Vector2(560, 690), Vector2(1110, 690), Vector2(1430, 560)]
## The drawn footprint inside its full-canvas layer.
const FOOTPRINT_REGION := Rect2(1244, 871, 285, 189)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var beast := AtlasTexture.new()
	beast.atlas = load("res://assets/Art/day/footprint.png")
	beast.region = FOOTPRINT_REGION
	for at in BEAST_SPOTS:
		var icon := TextureRect.new()
		icon.texture = beast
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE  # before size, or the art's own size wins
		icon.position = at + Vector2(0, 3)
		icon.size = Vector2(65, 43)  # the footprint's own proportions
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(icon)
