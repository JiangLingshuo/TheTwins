extends Control
## Camera-only markings on the day cemetery: the twin-beast motifs the camera
## tutorial asks the player to compare (placeholder icons until they are drawn
## into the tomb art). The three tombs and their shared base are real scene
## art (Tombstone instances and the Pedestal layer).

## Top-left corners of the beast icons, in cemetery (1920×1080 art) pixels:
## the crystal monument's base, the sun-shaped monument's stand, the fountain.
const BEAST_SPOTS := [Vector2(560, 690), Vector2(1110, 690), Vector2(1430, 560)]

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var beast: Texture2D = load("res://assets/Art/symbols/beast_camera.svg")
	for at in BEAST_SPOTS:
		var icon := TextureRect.new()
		icon.texture = beast
		icon.position = at
		icon.size = Vector2(65, 50)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(icon)
