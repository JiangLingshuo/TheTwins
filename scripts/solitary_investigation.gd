extends "res://scripts/main.gd"
## Isolated F2 playtest of the final marker, using the ordinary investigation tools.
var _confront: Button

func _ready() -> void:
	# The normal tutorial expects the first six graves; it does not run here.
	var tutorial := get_node("SunMoonTutorial")
	remove_child(tutorial)
	tutorial.free()
	for cemetery in [$DayCemetery, $NightCemetery]:
		for child in cemetery.get_children():
			if child.name not in ["Sun", "Moon"]:
				child.hide()
	_add_girl()
	super._ready()
	_add_cover()
	_confront = Button.new()
	_confront.text = "Contact Aurora about the notebook"
	_confront.position = Vector2(32, 970)
	_confront.size = Vector2(440, 56)
	add_child(_confront)
	_confront.pressed.connect(func() -> void:
		GameState.open_ending(true, true, true))
	GameState.notebook_changed.connect(_refresh_final_step)
	_refresh_final_step()
	_toast.show_message("Inspect the solitary marker. Record its motif and compare it with your notebook cover. Use the searchlight at 45 years ago.")

func _add_girl() -> void:
	# The marker with its carved motif and parts (scenes/tombstones/girl_tomb.tscn),
	# and the same marker by night.
	$DayCemetery.add_child(preload("res://scenes/tombstones/girl_tomb.tscn").instantiate())
	$NightCemetery.add_child(preload("res://scenes/tombstones/girl_tomb_night.tscn").instantiate())

func _add_cover() -> void:
	var cover = TextureRect.new()
	cover.set_script(preload("res://scripts/decipher_target.gd"))
	cover.texture = preload("res://assets/Art/note/notebook_cover.png")
	cover.position = Vector2(100, 390)
	cover.size = Vector2(200, 300)
	cover.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cover.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cover.target_id = "notebook_cover"
	cover.meaning = "The same girl on the notebook cover"
	add_child(cover)
	GameState.record_evidence("notebook_cover")

func _refresh_final_step() -> void:
	_confront.visible = GameState.evidence_ids.has("girl_cover_correspondence")
