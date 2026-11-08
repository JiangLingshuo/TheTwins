extends SceneTree
var failures := 0
var state
func _initialize() -> void: _run.call_deferred()
func check(message: String, ok: bool) -> void:
	print(("PASS " if ok else "FAIL ") + message)
	if not ok: failures += 1
func remember(question: Dictionary, reply: Dictionary) -> void:
	state.begin_radio_exchange("availability_test", {"gravestone_id": question["tomb"], "question_id": question["id"], "question_text": question["label"]})
	for line in reply.get("lines", []): state.append_radio_line("availability_test", line)
	state.end_radio_exchange("availability_test")
func aim(target, lamp, point: Vector2, year: float) -> void:
	lamp.turn_on_at(point, true)
	lamp.focus = year
	lamp._target_focus = year
	target.apply_flashlight(lamp)
	target.exposure = 0.8
	target.apply_flashlight(lamp)
func _run() -> void:
	await process_frame
	state = root.get_node("GameState")
	state.cycle_tutorial_completed = true
	state.cycle_hint_heard = true
	state.investigation_tutorial_completed = true
	state.camera_tutorial_completed = true
	state.record_gravestone("baby_tomb")
	state.record_rubbing("infant_moon_rubbing", "baby_tomb", "res://assets/Art/symbol/moon.png", "moon")
	state.confirm_rubbing_meaning("infant_moon_rubbing", "Moon")
	change_scene_to_file("res://scenes/main.tscn")
	await create_timer(0.3).timeout
	var main = current_scene
	var radio = main.get_node("RadioTool")
	var model = radio.model
	var q: Dictionary
	for item in model.data["questions"]:
		if item["target"] == "test_answer_baby_8": q = item
	var moon: String = model.data["evidence_groups"]["infant_moon_rubbing"]
	check("first substantive reply available", model.question_reply_state(q)["unheard"])
	remember(q, model.send(q, moon))
	check("heard substantive reply exhausted without forcing wrong answers", not model.question_reply_state(q)["unheard"])
	radio._update_question_activity()
	radio._tomb = "baby_tomb"
	check("exhausted question absent from menu", not radio._visible_questions().any(func(item: Dictionary) -> bool: return item["id"] == q["id"]))
	state.record_evidence("infant_graffiti")
	var snapshot: Dictionary = state._checkpoint_state()
	check("new evidence reopens a reply", model.question_reply_state(q)["unheard"])
	check("preview did not grant doubt finding", snapshot == state._checkpoint_state())
	radio._update_question_activity()
	check("reopened reply marks stone with red dot", radio._marker_has_reopened_questions("baby_tomb"))
	radio.open()
	await process_frame
	check("red dot renders on stone selection", radio._layout.find_children("NewRepliesDot", "Label", true, false).size() == 1)
	radio._start_call("baby_tomb")
	await process_frame
	check("opening stone acknowledges red dot", not radio._marker_has_reopened_questions("baby_tomb"))
	radio._set_slot(model.data["evidence_groups"]["infant_graffiti"])
	check("revealed hidden question is first", radio._visible_questions()[0]["hidden"])
	radio.close(false)
	var target = main.get_node("DayCemetery/ScholarNoTraces")
	var lamp = main.get_node("FlashlightTool/Flashlight")
	var point: Vector2 = main.get_node("DayCemetery").get_global_transform() * main.get_node("DayCemetery/ScholarTomb").zoom_rect.get_center()
	check("scholar requires all four settings", target.scan_years == [0.0, 45.0, 50.0, 60.0])
	for year in [0.0, 45.0, 50.0]: aim(target, lamp, point, year)
	check("three settings insufficient", not state.evidence_ids.has("scholar_no_traces"))
	aim(target, lamp, point, 250)
	check("250 does not count", not state.evidence_ids.has("scholar_no_traces") and state.searchlight_scan_progress.get("scholar_no_traces", []).size() == 3)
	aim(target, lamp, point, 60)
	check("fourth setting grants clue at actual scholar monument", state.evidence_ids.has("scholar_no_traces"))
	await process_frame
	var box = main.get_node_or_null("AbsenceReflection")
	check("first discovery plays inner monologue", box != null)
	if box:
		await create_timer(0.35).timeout
		check("reflection uses authored grammar-corrected text", box._lines[0]["content"].contains("absence, too, tells a history"))
		for i in 5:
			if is_instance_valid(box) and box.is_playing() and box._accept_input:
				box._finish_line()
				box._advance()
			await create_timer(0.1).timeout
	await create_timer(0.4).timeout
	aim(target, lamp, point, 60)
	await process_frame
	check("repeat scan does not replay reflection", main.get_node_or_null("AbsenceReflection") == null)
	main.queue_free()
	await process_frame
	print("RADIO AVAILABILITY / SCHOLAR ABSENCE: %d failures" % failures)
	quit(0 if failures == 0 else 1)
