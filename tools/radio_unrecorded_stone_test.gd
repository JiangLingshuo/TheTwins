extends SceneTree
## Instant radio calls are not held back by an unrecorded stone, and any interaction
## on a stone (a click with or without a tool, or zooming in on it) records it.
##   godot --path . --audio-driver Dummy --resolution 1280x720 -s tools/radio_unrecorded_stone_test.gd
var failures := 0
var state
func _initialize() -> void: _run.call_deferred()
func check(label: String, ok: bool) -> void:
	print(("PASS " if ok else "FAIL ") + label)
	if not ok: failures += 1
func wait(seconds: float) -> void: await create_timer(seconds).timeout

func _stone(id: String) -> Control:
	for stone in root.get_tree().get_nodes_in_group("gravestones"):
		if stone.gravestone_id == id and stone.is_visible_in_tree(): return stone
	return null

## A screen point on the stone's visible pixels.
func _point_on(stone: Control) -> Vector2:
	var rect: Rect2 = stone.get_stone_global_rect()
	for y in range(8):
		for x in range(8):
			var p := rect.position + rect.size * Vector2((x + 0.5) / 8.0, (y + 0.5) / 8.0)
			if stone.is_point_on_stone(p): return p
	return rect.get_center()

## `point` is in canvas coordinates; push_input takes window coordinates.
func _click(canvas_point: Vector2) -> void:
	var point: Vector2 = root.get_final_transform() * canvas_point
	var motion := InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	root.push_input(motion)
	await process_frame
	for pressed in [true, false]:
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = pressed
		click.position = point
		click.global_position = point
		root.push_input(click)
		await process_frame

func _run() -> void:
	await process_frame
	state = root.get_node("GameState")
	state._autosave_path = "user://test_radio_unrecorded_stone.autosave"  # never touch the real save
	state.investigation_tutorial_completed = true
	state.cycle_tutorial_completed = true
	state.camera_tutorial_completed = true
	state.tutorial_radio_intro_heard = true
	state.current_city_day = true
	state.resume_saved_city = false
	change_scene_to_file("res://scenes/main.tscn")
	await wait(0.8)
	var main = current_scene
	var radio = main.get_node("RadioTool")
	# The flags above skip the tutorial without walking it, so its click gate is switched off.
	var guide := main.get_node_or_null("SunMoonTutorial")
	if guide: guide.set_process_input(false)
	state.record_gravestone("baby_tomb")
	# The Scholar's stone is never clicked: its comparison alone makes Aurora call.
	state.record_evidence("profession_record")
	state.record_rubbing("crystal_marker_rubbing", "scholar_tomb", "res://assets/Art/symbol/spar.png", "crystal_lamp")
	state.confirm_rubbing_meaning("crystal_marker_rubbing", "Crystal")
	check("the Scholar's stone is not recorded", "scholar_tomb" not in state.gravestones)
	await wait(2.0)
	check("the instant call rings without the stone recorded", radio.is_open() and radio._question.get("id", "") == "scholar:test_answer_scholar_8")
	radio.close(false)
	await wait(0.3)

	var sun := _stone("sun_tomb")
	check("the sun stone is in the Day City", sun != null)
	if sun:
		check("the sun stone starts unrecorded", "sun_tomb" not in state.gravestones)
		main.get_node("FlashlightTool")._on_button_pressed()  # aiming the searchlight
		await process_frame
		await _click(_point_on(sun))
		check("aiming the searchlight at a stone records it", "sun_tomb" in state.gravestones)
		main.get_node("FlashlightTool").turn_off()
	var scholar := _stone("scholar_tomb")
	if scholar:
		get_first_node_in_group("scene_zoom").zoom_to(scholar)
		check("zooming in on a stone records it", "scholar_tomb" in state.gravestones)
		get_first_node_in_group("scene_zoom").zoom_out()
		await wait(1.2)
	print("radio unrecorded stone failures: ", failures)
	quit(1 if failures else 0)
