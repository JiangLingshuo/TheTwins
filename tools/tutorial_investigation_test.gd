extends SceneTree
var failures := 0
var main
var state
var radio
func _initialize() -> void: _run.call_deferred()
func check(label: String, ok: bool) -> void:
	print(("PASS " if ok else "FAIL ") + label)
	if not ok: failures += 1
func wait(seconds: float) -> void: await create_timer(seconds).timeout
func drain(dialogue) -> void:
	await wait(0.4)
	for i in 30:
		if not dialogue.is_playing(): break
		if dialogue._accept_input:
			dialogue._finish_line()
			dialogue._advance()
		await wait(0.05)
	await wait(0.4)
func q(target: String) -> Dictionary:
	for item in radio.model.data["questions"]:
		if item["target"] == target: return item
	return {}
func send(target: String, evidence: String) -> void:
	radio._select_question(q(target))
	radio._slot = radio.model.data["evidence_groups"].get(evidence, "")
	radio._send()
	await drain(radio._reply_box)
func shot(name: String) -> void:
	if not OS.get_cmdline_user_args().has("--shots"): return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://test_output/investigation"))
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://test_output/investigation/" + name + ".png"))
func _run() -> void:
	await process_frame
	state = root.get_node("GameState")
	# This regression targets radio/searchlight/report mechanics; handoff is tested separately.
	state.tutorial_day_return_heard = true
	state.tutorial_record_intro_heard = true
	state.tutorial_keyword_ack_heard = true
	state.tutorial_radio_intro_heard = true
	change_scene_to_file("res://scenes/main.tscn")
	await wait(0.3)
	main = current_scene
	radio = main.get_node("RadioTool")
	var tutorial = main.get_node("SunMoonTutorial")
	state.record_rubbing("sky_sun_rubbing", "", "res://assets/Art/symbols/sky_sun.svg")
	state.record_rubbing("infant_moon_rubbing", "baby_tomb", "res://assets/Art/symbol/moon.png", "moon")
	await drain(tutorial._dialogue)
	state.cycle_hint_heard = true
	tutorial._on_sky_replaced("infant_moon_rubbing", main.get_node("DayCemetery/Sun"))
	await drain(tutorial._dialogue)
	check("first night dialogue completed", state.tutorial_night_heard and not main.is_day)
	check("moon correspondence is a submittable updated rubbing", state.get_rubbing_meaning("infant_moon_rubbing") == "Moon" and radio.model.group_title(radio.model.data["evidence_groups"]["infant_moon_rubbing"]) == "☾ → Moon")
	state.record_gravestone("baby_tomb")
	check("Day question unavailable at night", radio.model.questions_for("baby_tomb").is_empty() and radio.model.send(q("test_answer_baby_8"), "").has("error"))
	tutorial._on_sky_replaced("sky_sun_rubbing", main.get_node("NightCemetery/Moon"))
	radio.open()
	radio._start_call("baby_tomb")
	await send("test_answer_baby_8", "infant_moon_rubbing")
	check("moon comparison unlocks natural death explanation", str(radio._last_lines).contains("natural death") and radio._feedback == "linked")
	radio._collect_term("natural")
	check("natural death unlocks global dropdown", state.report_options("causes", "baby_tomb").has("natural"))
	radio.close()
	state.record_rubbing("infant_figure_rubbing", "baby_tomb", "res://assets/Art/symbols/human.png")
	state.radio_progress["read_manuscripts"] = ["designer_manuscript", "designer_journal"]
	state.radio_progress["manuscript_keywords"] = ["infant"]
	radio.open()
	radio._start_call("baby_tomb")
	await send("test_answer_baby_17", "designer_manuscript")
	check("infant is explicitly clickable in supported reply", radio._last_lines.any(func(line: Dictionary) -> bool: return line.get("content", "").contains('<link="infant">')))
	radio._collect_term("infant")
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
	check("searchlight discovers sketch at 2000", state.evidence_ids.has("infant_graffiti"))
	await drain(tutorial._dialogue)
	check("hidden question explanation plays once", state.tutorial_hidden_heard)
	radio.open()
	radio._start_call("baby_tomb")
	check("hidden question not shown for ownership alone", not radio.model.questions_for("baby_tomb").any(func(item: Dictionary) -> bool: return item["target"] == "test_answer_baby_21"))
	radio._set_slot(radio.model.data["evidence_groups"]["infant_graffiti"])
	check("slot reveals hidden question", radio.model.questions_for("baby_tomb", radio._slot).any(func(item: Dictionary) -> bool: return item["target"] == "test_answer_baby_21"))
	await send("test_answer_baby_21", "infant_graffiti")
	await send("test_answer_baby_8", "infant_graffiti")
	check("searchlight sketch supplies gold hidden answer", radio._feedback == "hidden" and state.evidence_ids.has("infant_death_doubt"))
	radio._collect_term("unexplained death")
	await shot("radio_guidance")
	radio.close()
	check("report rejects uncollected identity", not state.set_report_choice("baby_tomb", "identity", "tycoon"))
	check("report accepts collected infant", state.set_report_choice("baby_tomb", "identity", "infant"))
	state.record_gravestone("scholar_tomb")
	check("identity unavailable on other stones", not state.report_options("identities", "scholar_tomb").has("infant") and not state.set_report_choice("scholar_tomb", "identity", "infant"))
	check("current stone retains selected identity", state.report_options("identities", "baby_tomb").has("infant"))
	check("death cause is reusable", state.set_report_choice("scholar_tomb", "death", "natural"))
	state.set_report_choice("baby_tomb", "death", "unexplained")
	tutorial.refresh()
	await drain(tutorial._dialogue)
	check("tutorial reaches completed report", state.investigation_tutorial_completed)
	var notebook = main.get_node("NotebookTool")
	await notebook.open()
	notebook.book.jump_to_section(0)
	await wait(1.0)
	await shot("dropdown_report")
	check("report uses native dropdown widgets", notebook.book.left_page.get_node("Gravestone/Form/IdentityInput") is OptionButton)
	notebook.close()
	await wait(0.8)
	var coin = main.get_node("DayCemetery/WishPoolCoin")
	lamp.turn_on_at(coin.get_global_rect().get_center(), true)
	lamp.focus = 50.0
	lamp._target_focus = 50.0
	await wait(0.8)
	check("coin not revealed at incorrect year", not coin.discovered)
	lamp.focus = 60.0
	lamp._target_focus = 60.0
	await wait(1.0)
	check("coin revealed at 1990", coin.discovered and state.evidence_ids.has("day_city_coin"))
	main.get_node("FlashlightTool").turn_off()
	lamp.active = false
	await process_frame
	check("discovered coin stays a comparison target without lamp", coin.contains_point(coin.get_global_rect().get_center()))
	state.record_rubbing("sun_shaped_marker_rubbing", "sun_tomb", "res://assets/Art/symbols/sky_sun.svg", "day_city_coin")
	var drag = notebook.rubbing_drag
	check("coin rubbing starts drag", drag.begin("sun_shaped_marker_rubbing", Vector2(700, 300)))
	drag._left_book = true
	drag._drop(coin.get_global_rect().get_center())
	check("historical coin matches rubbing", state.get_rubbing_meaning("sun_shaped_marker_rubbing") == "Wishing-pool coin")
	await shot("historical_coin")
	state.set_report_choice("baby_tomb", "identity", "")
	check("clearing identity releases it globally", state.report_options("identities", "scholar_tomb").has("infant"))
	print("TUTORIAL INVESTIGATION: " + ("ALL PASSED" if failures == 0 else str(failures) + " FAILED"))
	quit(0 if failures == 0 else 1)
