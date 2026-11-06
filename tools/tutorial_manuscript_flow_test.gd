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
	state.record_rubbing("infant_moon_rubbing", "baby_tomb", "res://assets/Art/symbol/moon.png", "moon")
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
	check("manuscripts wait for the human-shape comparison", not state.tutorial_record_intro_heard and not state.evidence_ids.has("designer_manuscript"))
	notebook.book.show_rubbing("infant_figure_rubbing")
	await wait(1.0)
	check("person-shaped slot opens its Rubbings page", notebook.book.get_section() == 1)
	var drag = notebook.rubbing_drag
	var figure = main.get_node("DayCemetery/AppearanceOfTheDayfolk")
	var drop_point := Vector2.ZERO
	for y in range(0, 720, 4):
		for x in range(0, 1280, 4):
			var point := Vector2(x, y)
			if drag._target_at(point) == figure:
				drop_point = point
				break
		if drop_point != Vector2.ZERO: break
	check("background figure has a usable hit area", drop_point != Vector2.ZERO)
	check("human rubbing starts drag", drag.begin("infant_figure_rubbing", Vector2(480, 320)))
	drag._left_book = true
	drag._drop(drop_point)
	await drain(tutorial._dialogue)
	check("scene drop unlocks the recorded introduction", state.evidence_ids.has("dayfolk_appearance") and state.tutorial_record_intro_heard)
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
	check("student is plain text in the designer journal", journal_body.text.contains("student") and not journal_body.text.contains("[url"))
	check("opening journal does not interrupt reading with radio dialogue", not tutorial._speaking and not state.tutorial_radio_intro_heard)
	items.show_list()
	await drain(tutorial._dialogue)
	check("reading both documents introduces searchlight first", state.tutorial_searchlight_intro_heard and not state.tutorial_radio_intro_heard and not radio._can_open())
	notebook.close()
	await wait(0.8)
	var lamp = main.get_node("FlashlightTool/Flashlight")
	lamp.focus = 40.0
	lamp._target_focus = 40.0
	lamp.turn_on_at(main.get_node("DayCemetery/BabyTomb/HumanSymbol").get_global_rect().get_center(), true)
	await wait(0.8)
	check("wrong year cannot bypass searchlight tutorial", not state.evidence_ids.has("infant_graffiti") and not radio._can_open())
	# Use the actual tool wheel input to move 40 -> 50, while the beam remains pinned.
	var tool_lamp = main.get_node("FlashlightTool")
	tool_lamp._set_state(tool_lamp.State.ON)
	tool_lamp._scale.value = 40.0
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel.pressed = true
	wheel.shift_pressed = true
	wheel.position = Vector2(100, 100)
	tool_lamp._on_catcher_input(wheel)
	await wait(1.3)
	await drain(tutorial._dialogue)
	await drain(tutorial._dialogue)
	check("50-year scan precedes radio", state.evidence_ids.has("infant_graffiti") and state.tutorial_searchlight_found_heard and state.tutorial_radio_intro_heard)
	check("collected sketch visible in Clues", state.notebook_entries(2).any(func(e: Dictionary) -> bool: return e["id"] == "infant_graffiti"))
	check("collected sketch remains beside its gravestone", state.get_gravestone_info("baby_tomb")["clues"].any(func(e: Dictionary) -> bool: return e["id"] == "infant_graffiti"))
	state.debug_overlay = false
	radio.open()
	await wait(0.2)
	check("radio frames the gravestone without the debug overlay", tutorial._highlight_target == radio.tutorial_controls.get("stone") and radio._tutorial_hint.visible)
	radio._start_call("baby_tomb")
	await wait(0.2)
	check("radio frames the first question", tutorial._highlight_target == radio.tutorial_controls.get("test_answer_baby_8") and tutorial._highlight.visible)
	check("no more empty recorded-gravestone radio state", radio._tomb == "baby_tomb")
	check("first question is the only tutorial question initially", radio._lesson_question() == "test_answer_baby_8")
	var human_question: Dictionary = {}
	for q in radio.model.data["questions"]:
		if q["target"] == "test_answer_baby_17": human_question = q
	radio._select_question(human_question)
	check("second question cannot be selected early", radio._question.is_empty())
	await send("test_answer_baby_8", "infant_graffiti")
	check("sketch cannot trigger follow-up before first answer", not state.radio_progress.get("read_answers", []).has("baby_8_additional_10"))
	await send("test_answer_baby_8", "infant_moon_rubbing")
	radio._collect_term("natural")
	check("first question stays active for the evidence follow-up", radio._lesson_question() == "test_answer_baby_8")
	await send("test_answer_baby_8", "infant_graffiti")
	radio._collect_term("unexplained death")
	check("second question unlocks after the follow-up", radio._lesson_question() == "test_answer_baby_17")
	await send("test_answer_baby_17", "designer_manuscript")
	check("manuscript cannot skip the comparison", not state.radio_progress.get("read_answers", []).has("baby_17_supported_19"))
	await send("test_answer_baby_17", "dayfolk_appearance")
	check("comparison keeps second question open for manuscript follow-up", radio._lesson_question() == "test_answer_baby_17" and not state.tutorial_hidden_heard)
	radio._select_question(human_question)
	radio._set_slot(radio.model.data["evidence_groups"]["designer_manuscript"])
	radio._send()
	await wait(0.1)
	check("hidden instruction waits while the second reply plays", radio._reply_playing and not tutorial._speaking and not state.tutorial_hidden_heard)
	await drain(radio._reply_box)
	await drain(tutorial._dialogue)
	check("hidden-question teaching follows the finished second reply", state.tutorial_hidden_heard and radio._lesson_question() == "test_answer_baby_21")
	radio.open()
	radio._start_call("baby_tomb")
	radio._set_slot(radio.model.data["evidence_groups"]["infant_graffiti"])
	check("evidence reveals hidden question", radio.model.questions_for("baby_tomb", radio._slot).any(func(q: Dictionary) -> bool: return q["target"] == "test_answer_baby_21"))
	await send("test_answer_baby_21", "infant_graffiti")
	await drain(tutorial._dialogue)
	check("Aurora hands off to the report after the hidden reply", state.tutorial_report_intro_heard and not radio.is_open())
	check("report guide highlights the notebook", tutorial._highlight_target == notebook.get_node("NotebookButton") and tutorial._panel.is_visible_in_tree())
	notebook.show_gravestone_next("baby_tomb")
	await notebook.open()
	await wait(0.2)
	var report_page: Control = notebook.book.left_page.get_node("Gravestone")
	check("report guide highlights the identity dropdown first", tutorial._highlight_target == report_page.identity_input)
	state.set_report_choice("baby_tomb", "identity", "infant")
	await wait(0.2)
	check("report guide moves to the death dropdown", tutorial._highlight_target == report_page.death_input)
	state.set_report_choice("baby_tomb", "death", "unexplained")
	tutorial.refresh()
	await drain(tutorial._dialogue)
	var camera = main.get_node("CameraTool")
	await drain_camera(camera._dialogue)
	await wait(1.3)
	await drain_camera(camera._dialogue)
	check("camera starts after infant report", camera._overlay.visible and state.camera_tutorial_pending)
	for id in ["base_scholar", "base_infant", "base_sun"]: camera._select_spot(id)
	await wait(0.4)
	await drain_camera(camera._dialogue)
	check("camera finishes formal investigation handoff", state.camera_tutorial_completed and state.formal_investigation_started and state.evidence_ids.has("shared_family_base"))
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

func drain_camera(box) -> void:
	await wait(0.4)
	for i in 45:
		if not box.is_playing(): break
		if box._accept_input: box._finish_line(); box._advance()
		await wait(0.04)
	await wait(0.4)
