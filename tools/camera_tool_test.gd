extends SceneTree
var failures := 0
func _initialize() -> void: _run.call_deferred()
func check(message: String, ok: bool) -> void:
	print(("PASS " if ok else "FAIL ") + message)
	if not ok: failures += 1
func wait(seconds: float) -> void: await create_timer(seconds).timeout
func drain(box) -> void:
	await wait(0.4)
	for i in 40:
		if not box.is_playing(): break
		if box._accept_input: box._finish_line(); box._advance()
		await wait(0.04)
	await wait(0.4)
func _run() -> void:
	await process_frame
	var state := root.get_node("GameState")
	state.investigation_tutorial_completed = true
	state.cycle_tutorial_completed = true
	change_scene_to_file("res://scenes/main.tscn")
	await wait(0.3)
	var main = current_scene
	var camera = main.get_node("CameraTool")
	var box = main.get_node("Toolbox")
	check("toolbox has three tools", box._proxies.size() == 3)
	box.reveal()
	check("hover opens tools on the left", box.tray.visible and box.tray.get_global_rect().end.x < box.button.get_global_rect().position.x)
	var rubbing = main.get_node("RubbingTool")
	box.proxy_for(rubbing._button).pressed.emit()
	check("proxy selects original rubbing tool", rubbing.active)
	rubbing.turn_off()
	var before: int = state.evidence_ids.size()
	camera.play_tutorial()
	await wait(1.0)
	await drain(camera._dialogue)
	await wait(1.3)
	await drain(camera._dialogue)
	check("camera exposes framed photo with noise shader", camera._overlay.visible and camera._photo.texture != null and camera._photo.material != null)
	check("photo itself grants no evidence", state.evidence_ids.size() == before)
	camera._select_spot("base_scholar")
	camera._select_spot("base_scholar")
	camera._select_spot("base_infant")
	check("unique marks required before conclusion", not state.evidence_ids.has("shared_family_base") and state.camera_observations["base"].size() == 2)
	if OS.get_cmdline_user_args().has("--shots"):
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://test_output/camera"))
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://test_output/camera/tutorial_photo.png"))
	camera._select_spot("base_sun")
	await wait(0.4)
	await drain(camera._dialogue)
	check("three bases grant one conclusion", state.evidence_ids.count("shared_family_base") == 1 and state.evidence_ids.size() == before + 1)
	check("camera tutorial opens formal investigation", state.camera_tutorial_completed and state.formal_investigation_started and not state.camera_modal_open)
	await camera.take_photo(false)
	check("ordinary photo has no automatic blue hints", not camera._tutorial)
	for id in ["beast_a", "beast_b", "beast_c"]: camera._select_spot(id)
	check("manual repeated motifs yield local observation", state.evidence_ids.has("repeated_beast_motifs"))
	camera.close_photo()
	main.set_night()
	await camera.take_photo(false)
	check("night photo has blessing and child targets and no moon target", camera._spots.size() == 6 and not camera.GROUPS.has("moon"))
	camera._select_spot("blessing_altar")
	camera._select_spot("blessing_mother")
	check("two blessing marks do not grant the clue", not state.evidence_ids.has("altar_blessing_glyph"))
	camera._select_spot("blessing_mother")
	check("a duplicate does not count as the third sign", not state.evidence_ids.has("altar_blessing_glyph"))
	camera._select_spot("blessing_father")
	check("three graves grant one repeated blessing clue", state.evidence_ids.count("altar_blessing_glyph") == 1)
	camera._select_spot("child_altar")
	camera._select_spot("child_mother")
	check("two child marks do not grant the clue", not state.evidence_ids.has("repeated_child_figures"))
	camera._select_spot("child_father")
	check("three stones grant the repeated child clue", state.evidence_ids.count("repeated_child_figures") == 1)
	camera.close_photo()
	var model = load("res://scripts/radio_model.gd").new()
	state.record_gravestone("altar_tomb")
	var slot: String = model.data["evidence_groups"]["altar_blessing_glyph"]
	check("no symbol question without submitted record", not model.questions_for("altar_tomb").any(func(q: Dictionary) -> bool: return q["target"] == "test_answer_altar_8"))
	var questions: Array = model.questions_for("altar_tomb", slot)
	var symbol_question: Dictionary = {}
	for q in questions:
		if q["target"] == "test_answer_altar_8": symbol_question = q
	check("record reveals symbol meaning question", not symbol_question.is_empty())
	check("custom question waits for interpretation", not questions.any(func(q: Dictionary) -> bool: return q["target"] == "test_answer_repeated_blessing"))
	var reply: Dictionary = model.send(symbol_question, slot)
	check("interpretation grants separate translation", not reply.has("error") and state.evidence_ids.has("altar_blessing_translation"))
	check("interpretation reveals the custom question with the record", model.questions_for("altar_tomb", slot).any(func(q: Dictionary) -> bool: return q["target"] == "test_answer_repeated_blessing"))
	check("custom question hides when evidence removed", not model.questions_for("altar_tomb").any(func(q: Dictionary) -> bool: return q["target"] == "test_answer_repeated_blessing"))

	print("CAMERA TOOL: " + ("ALL PASSED" if failures == 0 else str(failures) + " FAILED"))
	quit(0 if failures == 0 else 1)
