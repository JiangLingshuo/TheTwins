extends SceneTree
var failures := 0
var state
var main
var tutorial
var radio
func _initialize() -> void: _run.call_deferred()
func check(message: String, ok: bool) -> void:
	print(("PASS " if ok else "FAIL ") + message)
	if not ok: failures += 1
func wait(seconds: float) -> void: await create_timer(seconds).timeout
func drain(box) -> void:
	for i in 140:
		if box.is_playing() and box._accept_input:
			box._finish_line()
			box._advance()
		await wait(0.04)
		if not box.is_playing() and not tutorial._speaking: break
	await wait(0.1)
func brush(tool, symbol) -> void:
	var rect: Rect2 = symbol.get_global_rect()
	for pass_index in 8:
		for row in 10:
			var y := rect.position.y + rect.size.y * row / 9.0
			tool._brush(Vector2(rect.position.x, y), Vector2(rect.end.x, y))
func send(target: String, evidence: String) -> void:
	var item: Dictionary = {}
	for q in radio.model.data["questions"]:
		if q["target"] == target: item = q
	radio._select_question(item)
	radio._slot = radio.model.data["evidence_groups"].get(evidence, "")
	radio._send()
	await drain(radio._reply_box)
func shot(name: String) -> void:
	if not OS.get_cmdline_user_args().has("--shots"): return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://test_output/manuscript_flow"))
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://test_output/manuscript_flow/" + name + ".png"))
func _run() -> void:
	await process_frame
	state = root.get_node("GameState")
	# Return from the already verified sky-switch section, with no recorded grave.
	state.record_rubbing("sky_sun_rubbing", "", "res://assets/Art/symbols/sky_sun.svg")
	state.record_rubbing("infant_moon_rubbing", "baby_tomb", "res://assets/Art/symbols/moon.png", "moon")
	state.confirm_rubbing_meaning("infant_moon_rubbing", "Moon")
	state.cycle_tutorial_completed = true
	state.cycle_hint_heard = true
	state.tutorial_night_heard = true
	change_scene_to_file("res://scenes/main.tscn")
	await wait(0.2)
	main = current_scene
	tutorial = main.get_node("SunMoonTutorial")
	radio = main.get_node("RadioTool")
	await drain(tutorial._dialogue)
	check("daylight return transition plays", state.tutorial_day_return_heard)
	check("radio waits for manuscript teaching", not radio._can_open())
	var notebook = main.get_node("NotebookTool")
	var tool = main.get_node("RubbingTool")
	tool.set_active(true)
	brush(tool, main.get_node("DayCemetery/BabyTomb/HumanSymbol"))
	await wait(0.3)
	check("human rubbing actually collected", state.rubbings.has("infant_figure_rubbing"))
	await drain(tutorial._dialogue)
	await drain(tutorial._dialogue)
	check("rubbing automatically records grave", state.gravestones.has("baby_tomb"))
	check("notebook opens on recorded baby page", notebook.is_open() and notebook.book.get_section() == 0 and notebook.book.is_gravestone_collected(0))
	check("recorded introduction plays", state.tutorial_record_intro_heard)
	check("only infant manuscripts initially delivered", state.notebook_entries(3).size() == 2)
	await shot("01_recorded_marker")
	notebook.book.jump_to_section(3)
	await wait(1.0)
	var items = notebook.book.left_page.get_node("ManuscriptItems")
	items.show_document("designer_manuscript")
	await wait(0.1)
	var bodies: Array = [notebook.book.left_page.get_node("SpreadReader").body, notebook.book.right_page.get_node("SpreadReader").body]
	check("manuscript preserves underlined interactive keyword", not bodies.is_empty() and bodies[0].text.contains("[url=infant]") and bodies[0].text.contains("[wave"))
	await shot("02_keyword_wave")
	bodies[0].meta_clicked.emit("infant")
	await drain(tutorial._dialogue)
	check("keyword comes from manuscript into identity pool", "infant" in state.radio_progress.get("identities", []) and "infant" in state.radio_progress.get("manuscript_keywords", []))
	check("player acknowledges keyword", state.tutorial_keyword_ack_heard)
	items.show_list()
	await wait(0.1)
	items.show_document("designer_journal")
	await wait(0.2)
	var journal_body = notebook.book.left_page.get_node("SpreadReader").body
	journal_body.meta_clicked.emit("student")
	await wait(0.1)
	check("student collects as clue without type error", "student" in state.radio_progress.get("clue_terms", []) and "student" not in state.radio_progress.get("identities", []))
	check("opening journal does not interrupt reading with radio dialogue", not tutorial._speaking and not state.tutorial_radio_intro_heard)
	items.show_list()
	await drain(tutorial._dialogue)
	check("reading both documents introduces radio", state.tutorial_radio_intro_heard and radio._can_open())
	radio.open()
	radio._start_call("baby_tomb")
	check("no more empty recorded-gravestone radio state", radio._tomb == "baby_tomb")
	await send("test_answer_baby_8", "infant_moon_rubbing")
	radio._collect_term("natural")
	await send("test_answer_baby_17", "designer_manuscript")
	if not radio._followups.is_empty():
		radio._follow(radio._followups[0])
		await drain(radio._reply_box)
	radio.close()
	var lamp = main.get_node("FlashlightTool/Flashlight")
	var sketch = main.get_node("DayCemetery/InfantSketch")
	lamp.focus = 50.0
	lamp._target_focus = 50.0
	lamp.turn_on_at(sketch.get_global_rect().get_center(), true)
	await wait(1.0)
	await drain(tutorial._dialogue)
	check("searchlight and hidden-question teaching reached", state.evidence_ids.has("infant_graffiti") and state.tutorial_hidden_heard)
	radio.open()
	radio._start_call("baby_tomb")
	radio._set_slot(radio.model.data["evidence_groups"]["infant_graffiti"])
	check("evidence reveals hidden question", radio.model.questions_for("baby_tomb", radio._slot).any(func(q: Dictionary) -> bool: return q["target"] == "test_answer_baby_21"))
	await send("test_answer_baby_21", "infant_graffiti")
	await send("test_answer_baby_8", "designer_journal")
	radio._collect_term("unexplained death")
	radio.close()
	state.set_report_choice("baby_tomb", "identity", "infant")
	state.set_report_choice("baby_tomb", "death", "unexplained")
	tutorial.refresh()
	await drain(tutorial._dialogue)
	check("closing dialogue completes tutorial", state.tutorial_end_heard and state.investigation_tutorial_completed)
	check("all eight Day manuscripts delivered", state.notebook_entries(3).size() == 8)
	check("Night manuscripts remain locked", not state.evidence_ids.has("crystal_god_prophecy") and not state.evidence_ids.has("skyway_history") and not state.evidence_ids.has("natural_collapse_record"))
	# Reproduce the user's pre-existing state: rubbing present, grave absent.
	state.gravestones.erase("baby_tomb")
	state.investigation_tutorial_completed = false
	state.tutorial_record_intro_heard = false
	tutorial.refresh()
	await drain(tutorial._dialogue)
	await drain(tutorial._dialogue)
	check("existing rubbing with missing grave recovers automatically", state.gravestones.has("baby_tomb") and state.tutorial_record_intro_heard)
	print("TUTORIAL MANUSCRIPT FLOW: " + ("ALL PASSED" if failures == 0 else str(failures) + " FAILED"))
	quit(0 if failures == 0 else 1)
