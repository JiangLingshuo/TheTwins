class_name TrailerClips
extends RefCounted
## Developer shortcuts (F2 menu) that play a chosen stretch of dialogue over the
## current scene, for capturing trailer footage. Nothing is granted, saved or
## logged: each clip runs on a throw-away copy of the radio state.

# Loaded when a clip is played, not at compile time: these scripts use the GameState
# autoload, which is itself the script that builds the menu that lists the clips.
const BOX_PATH := "res://scenes/dialogue_box.tscn"
const MODEL_PATH := "res://scripts/radio_model.gd"

## id, label, and where the lines come from:
##   "xml"     a dialogue file, played as is;
##   "program" a radio/ending program (Ink knot), played up to its first choice,
##             with the stone and the record "handed in" (tomb, submitted).
## "night" picks the city shown behind the dialogue.
const CLIPS := [
	{"id": "opening", "scene": "start", "label": "Opening call: the voice on the radio", "xml": "res://assets/dialogue/start.xml", "night": false},
	{"id": "skin", "scene": "main", "label": "Scholar: the message written on skin", "program": "test_answer_scholar_35", "tomb": "scholar", "night": false},
	{"id": "decision", "scene": "main", "label": "Scholar: \"I made that decision\"", "program": "test_answer_scholar_31", "tomb": "scholar", "night": false},
	{"id": "blessing", "scene": "main", "label": "Altar: a blessing for the unending journey", "program": "test_answer_altar_8", "tomb": "altar", "submitted": "altar_blessing_glyph", "night": true},
	{"id": "path", "scene": "main", "label": "Altar: the path that does not return", "program": "query_night_unending_path", "tomb": "altar", "night": true},
	{"id": "last", "scene": "main", "label": "Holy Mother: the last survivor", "program": "test_answer_mother_21", "tomb": "mother", "submitted": "night_mother_no_traces", "night": true},
	{"id": "wind", "scene": "ending_true", "label": "Ending: the wind and the question", "program": "test_confrontation", "night": false},
	{"id": "dream", "scene": "ending_true", "label": "Ending: Day Aurora's dream", "program": "test_ending_day_dream", "night": false},
	{"id": "hangup", "scene": "ending_true", "label": "Ending: she hangs up (wind and busy tone)", "program": "test_ending_day_goodbye", "night": false},
	{"id": "flower", "scene": "ending_true", "label": "Ending: Night Aurora and the flower", "program": "test_ending_night_childhood", "night": true},
	{"id": "false", "scene": "ending_false", "label": "False ending: Aurora fades from memory", "program": "ending_false", "night": false},
]

static func find(id: String) -> Dictionary:
	for clip in CLIPS:
		if clip["id"] == id:
			return clip
	return {}


## The dialogue lines of a clip.
static func lines_for(clip: Dictionary) -> Array[Dictionary]:
	var lines: Array[Dictionary] = []
	if clip.has("xml"):
		return DialogueLoader.load_xml(clip["xml"])
	var model = load(MODEL_PATH).new()
	model.progress = model.progress.duplicate(true)  # never touch the live investigation
	model.preview_only = true
	model._ending_preview_evidence.assign(["girl_teddy_bear", "family_photo", "girl_painted_flower", "mother_daughter_flower_meaning"])
	model.tomb = str(clip.get("tomb", "")) + "_tomb" if clip.has("tomb") else ""
	model.submitted_id = str(clip.get("submitted", ""))
	model._context = {"active_tomb": str(clip.get("tomb", "")), "supported": false}
	model._depth = 0
	var result := {"lines": [], "choices": []}
	model._program(str(clip["program"]), result)
	for line in result["lines"]:
		lines.append(line)
	return lines


const SCENES := {
	"start": "res://scenes/start.tscn",
	"main": "res://scenes/main.tscn",
	"ending_true": "res://scenes/ending.tscn",
	"ending_false": "res://scenes/ending.tscn",
}


## Jump to the scene the clip belongs to (the title book for the opening call, the
## cemetery for a radio answer, the ending scene for the ending), with that moment's
## city and music, then play it. The GameState and Music autoloads are looked up by
## name because this script is compiled while GameState itself is being compiled.
static func start(id: String, tree: SceneTree) -> void:
	var clip := find(id)
	if clip.is_empty():
		return
	var state := tree.root.get_node("GameState")
	var music := tree.root.get_node("Music")
	var kind: String = clip.get("scene", "main")
	var path: String = SCENES[kind]
	var night: bool = clip.get("night", false)
	var lines := lines_for(clip)
	if lines.is_empty() and kind != "start":
		push_warning("Trailer clip has no lines: " + id)
		return
	var reload := kind != "main" or tree.current_scene == null or tree.current_scene.scene_file_path != path
	if reload:
		state.clip_mode = true  # the ending scene must not start its own sequence
		if kind == "main" or kind == "start":
			# Back out of any ending preview, so saving works again.
			state.ending_preview = false
			state.ending_true = false
			state.final_marker_phase = false
		if kind == "main":
			# Arriving from elsewhere: skip the tutorial, in the right city.
			state.investigation_tutorial_completed = true
			state.cycle_tutorial_completed = true
			state.camera_tutorial_completed = true
			state.current_city_day = not night
			state.resume_saved_city = false
		elif kind != "start":
			state.ending_true = kind == "ending_true"
			state.ending_preview = true
			state.ending_marker_investigated = kind == "ending_true"
			state.solitary_report_preview = false
			state.final_marker_phase = false
		tree.change_scene_to_file(path)
		for frame in 180:
			await tree.process_frame
			if tree.current_scene != null and tree.current_scene.scene_file_path == path and tree.current_scene.is_node_ready():
				break
		await tree.process_frame
		await tree.process_frame
		state.clip_mode = false
	var scene := tree.current_scene
	# The music of that moment: the opening theme on the title book, the second stage after it.
	if kind == "start":
		music._player.stop()
		music.play_bgm(music.BGM_MAIN)
	else:
		music._player.stop()
		music.play_bgm(music.BGM_STAGE_TWO)
	match kind:
		"start":
			scene._started = true
			if is_instance_valid(scene._save_menu):
				scene._save_menu.queue_free()
			scene.prompt.hide()
			scene.epigraph.hide()
			if scene._fade_in:
				scene._fade_in.kill()
			# The book opens on the spread where the call begins, as in a real run.
			await scene.book.open_saved(PackedStringArray(), 1)
			if not scene._dialogue_played:
				scene._play_dialogue()
		"main":
			if scene.has_method("set_time_for_clip"):
				scene.set_time_for_clip(not night)
			await _play_over(scene, lines, null)
		_:
			scene._night.modulate.a = 1.0 if night else 0.0
			scene._stone.visible = kind == "ending_true"
			scene._stone.disabled = true
			await _play_over(scene, lines, scene._dialogue)


static func _play_over(scene: Node, lines: Array[Dictionary], box: Control) -> void:
	if box == null:
		box = load(BOX_PATH).instantiate()
		box.name = "TrailerClip"
		box.z_index = 200
		scene.add_child(box)
		box.play(lines, "")
		await box.finished
		box.queue_free()
		return
	box.play(lines, "")
	await box.finished
