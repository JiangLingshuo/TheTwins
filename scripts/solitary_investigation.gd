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
	Music.enter_final_stage()  # the final marker begins the last stage of the music
	_confront = Button.new()
	_confront.text = "Contact Aurora about the notebook"
	_confront.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	_confront.offset_left = 24
	_confront.offset_right = 464
	_confront.offset_top = -72
	_confront.offset_bottom = -24
	add_child(_confront)
	_confront.pressed.connect(func() -> void:
		GameState.open_ending(true, GameState.ending_preview, true))
	GameState.notebook_changed.connect(_refresh_final_step)
	_refresh_final_step()
	_toast.show_message("Drag the complete motif out of the notebook, then onto the figure on its cover.")

func _add_girl() -> void:
	# The marker with its carved motif and parts (scenes/tombstones/girl_tomb.tscn),
	# and the same marker by night.
	$DayCemetery.add_child(preload("res://scenes/tombstones/girl_tomb.tscn").instantiate())
	$NightCemetery.add_child(preload("res://scenes/tombstones/girl_tomb_night.tscn").instantiate())


func _refresh_final_step() -> void:
	_confront.visible = GameState.evidence_ids.has("girl_cover_correspondence")
