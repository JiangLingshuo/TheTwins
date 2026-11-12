extends SceneTree
var failures := 0
var state: Node
var model
func _initialize() -> void:
	_run.call_deferred()
func check(label: String, value: bool) -> void:
	print(("PASS " if value else "FAIL ") + label)
	if not value: failures += 1
func question(target: String, tomb_id: String) -> Dictionary:
	for q in model.data["questions"]:
		if q["target"] == target and q["tomb"] == tomb_id: return q
	return {}
func group(id: String) -> String:
	return model.data["evidence_groups"][id]
func joined(result: Dictionary) -> String:
	var text := ""
	for line in result.get("lines", []): text += line["content"] + "\n"
	return text
func _run() -> void:
	await process_frame
	state = root.get_node("GameState")
	model = load("res://scripts/radio_model.gd").new()
	check("all questions exported", model.data["questions"].size() == 58)
	for q in model.data["questions"]:
		check("three unique candidates: " + q["id"], q["candidates"].size() == 3 and q["candidates"][0] != q["candidates"][1] and q["candidates"][1] != q["candidates"][2] and q["candidates"][0] != q["candidates"][2])
	var repetition_target := "test_answer_repeated_beast"
	state.record_evidence("repeated_beast_motifs")
	state.record_evidence("twin_beast_account")
	for tomb_id in ["scholar_tomb", "sun_tomb", "girl_tomb"]:
		state.record_gravestone(tomb_id)
		var perspective := question(repetition_target, tomb_id)
		check("repetition question hidden without evidence: " + tomb_id, not model.questions_for(tomb_id).any(func(q: Dictionary) -> bool: return q["target"] == repetition_target))
		check("historical account cannot reveal repetition question: " + tomb_id, not model.questions_for(tomb_id, group("twin_beast_account")).any(func(q: Dictionary) -> bool: return q["target"] == repetition_target))
		check("camera evidence reveals repetition question: " + tomb_id, model.questions_for(tomb_id, group("repeated_beast_motifs")).any(func(q: Dictionary) -> bool: return q["target"] == repetition_target))
		var perspective_reply: Dictionary = model.send(perspective, group("repeated_beast_motifs"))
		check("perspective answer points to Night City: " + tomb_id, joined(perspective_reply).contains("Night City") and perspective_reply.get("feedback") == "hidden")
	var crystal_q: Dictionary = {}
	for candidate in model.questions_for("scholar_tomb"):
		if candidate["target"] == "test_answer_scholar_8": crystal_q = candidate
	check("crystal question locked before the camera comparison", not crystal_q.is_empty() and not crystal_q["available"])
	state.record_evidence("crystal_marker_correspondence")
	crystal_q = {}
	for candidate in model.questions_for("scholar_tomb"):
		if candidate["target"] == "test_answer_scholar_8": crystal_q = candidate
	check("camera crystal comparison unlocks the crystal question", not crystal_q.is_empty() and crystal_q["available"])
	var was_day: bool = state.current_city_day
	state.current_city_day = false  # the parents' stones are in Night City
	for pair in [["mother_tomb", "test_answer_mother_8"], ["father_tomb", "test_answer_father_8"]]:
		state.record_gravestone(pair[0])
		var parent_q: Dictionary = {}
		for candidate in model.questions_for(pair[0]):
			if candidate["target"] == pair[1]: parent_q = candidate
		check("parent question locked before the child repetition: " + pair[0], not parent_q.is_empty() and not parent_q["available"])
	state.record_evidence("repeated_child_figures")
	for pair in [["mother_tomb", "test_answer_mother_8"], ["father_tomb", "test_answer_father_8"]]:
		var parent_q: Dictionary = {}
		for candidate in model.questions_for(pair[0]):
			if candidate["target"] == pair[1]: parent_q = candidate
		check("child repetition unlocks the parent question: " + pair[0], not parent_q.is_empty() and parent_q["available"])
		var parent_reply: Dictionary = model.send(parent_q, group("repeated_child_figures"))
		check("child repetition answers who the parent is: " + pair[0], joined(parent_reply).contains("Night City") and parent_reply.get("feedback") == "linked")
	state.current_city_day = was_day
	check("repetition question excluded from infant marker", question(repetition_target, "baby_tomb").is_empty())
	check("perspective answer does not award disappearance", not state.radio_progress.get("causes", []).has("disappearance"))
	state.record_gravestone("baby_tomb")
	state.cycle_tutorial_completed = true
	state.record_rubbing("infant_moon_rubbing", "baby_tomb")
	var moon_q := question("test_answer_baby_8", "baby_tomb")
	var result: Dictionary = model.send(moon_q, "")
	check("ordinary reply without evidence", not joined(result).contains("natural death") and not state.evidence_ids.has("infant_death_doubt"))
	check("ordinary moon reply does not claim evidence connection", result.get("feedback") == "unmatched")
	result = model.send(moon_q, group("designer_manuscript"))
	check("unrelated manuscript does not claim moon evidence connection", result.has("error") or result.get("feedback") == "unmatched")
	var human_q := question("test_answer_baby_17", "baby_tomb")
	check("human question initially needs rubbing", not model.questions_for("baby_tomb").filter(func(q: Dictionary) -> bool: return q["target"] == "test_answer_baby_17")[0]["available"])
	state.record_rubbing("infant_figure_rubbing", "baby_tomb")
	check("human rubbing unlocks question without prior deciphering", model.questions_for("baby_tomb").filter(func(q: Dictionary) -> bool: return q["target"] == "test_answer_baby_17")[0]["available"])
	state.record_evidence("designer_manuscript")
	result = model.send(human_q, "")
	check("owning manuscript does not trigger evidence answer", joined(result).contains("Compare the rubbing") and not joined(result).contains("Before we ask why") and result.get("choices", []).is_empty())
	result = model.send(human_q, group("designer_manuscript"))
	check("manuscript needs prior comparison", joined(result).contains("Compare the rubbing") and not joined(result).contains("Before we ask why"))
	state.record_evidence("dayfolk_appearance")
	result = model.send(human_q, group("dayfolk_appearance"))
	check("scene comparison identifies the Dayfolk", joined(result).contains("icon for the Dayfolk") and result.get("feedback") == "linked")
	result = model.send(human_q, group("designer_manuscript"))
	check("designer manuscript supports human explanation", not result.has("error") and joined(result).contains("without an identifiable occupation") and result.get("feedback") == "linked")
	check("updated human answer has no deleted followups", result.get("choices", []).is_empty())
	result = model.send(human_q, "")
	check("previous supported reply cannot leak into ordinary reply", joined(result).contains("Compare the rubbing") and not joined(result).contains("Before we ask why") and result.get("choices", []).is_empty())
	check("locked record cannot be submitted", model.send(moon_q, group("infant_graffiti")).has("error"))
	state.record_evidence("infant_graffiti")
	var hidden_before: Array = model.questions_for("baby_tomb", "")
	check("owned evidence alone does not reveal hidden question", not hidden_before.any(func(q: Dictionary) -> bool: return q["target"] == "test_answer_baby_21"))
	check("journal testimony does not unlock real-appearance question", not model.questions_for("baby_tomb", group("designer_journal")).any(func(q: Dictionary) -> bool: return q["target"] == "test_answer_baby_21"))
	var hidden_after: Array = model.questions_for("baby_tomb", group("infant_graffiti"))
	check("slot evidence reveals hidden question", hidden_after.any(func(q: Dictionary) -> bool: return q["target"] == "test_answer_baby_21"))
	var primary: String = group("infant_graffiti")
	for id in model.data["groups"][primary]["members"]: state.record_evidence(id)
	result = model.send(moon_q, primary)
	check("supported reply appends hidden answer and grants finding", joined(result).contains("unexplained circumstances") and state.evidence_ids.has("infant_death_doubt"))
	check("hidden reply has gold feedback", result.get("feedback") == "hidden")
	check("equivalent beast rubbings collapse to one group", group("scholar_beast_rubbing") == group("sun_shaped_beast_rubbing"))
	check("beast historical account stays distinct", group("twin_beast_account") != group("scholar_beast_rubbing"))
	var filtered: Array = model.groups_for_filter(model.data["groups"].keys(), 2, true)
	check("manuscript filter excludes symbols", filtered.all(func(id: String) -> bool: return model.data["groups"][id]["members"].any(func(member: String) -> bool: return model.record_type(member) == 2 and model.owns(member))))
	state.record_gravestone("scholar_tomb")
	var gate_target := "test_answer_scholar_passage_gate"
	var gate := question(gate_target, "scholar_tomb")
	state.record_evidence("one_way_passage_order")
	check("gate question hidden when order is merely owned", not model.questions_for("scholar_tomb").any(func(q: Dictionary) -> bool: return q["target"] == gate_target))
	check("order in slot reveals gate question", model.questions_for("scholar_tomb", group("one_way_passage_order")).any(func(q: Dictionary) -> bool: return q["target"] == gate_target))
	var gate_reply: Dictionary = model.send(gate, group("one_way_passage_order"))
	check("gate reply explains crystal supply failure", joined(gate_reply).contains("crystal power supply") and joined(gate_reply).contains("with the gate open") and gate_reply.get("feedback") == "hidden")
	state.record_evidence("skin_picture")
	state.record_evidence("night_father_death")
	model.progress["read_answers"].append("scholar_12_supported_15")
	var hypothesis := question("test_disappearance_hypothesis", "scholar_tomb")
	result = model.send(hypothesis, group("disappearance_inquiry"))
	check("inquiry opens staged exchange", model.progress.get("hypothesis_open", false) and not model.progress.get("hypothesis_skin", false))
	check("owned skin is not treated as submitted", not model.progress.get("hypothesis_skin", false))
	check("skin stage uses authored triple", model.candidates(hypothesis) == [group("skin_picture"), group("designer_journal"), group("night_mother_child_rubbing")])
	result = model.send(hypothesis, group("skin_picture"))
	check("skin evidence advances only its stage", model.progress.get("hypothesis_skin", false) and not model.progress.get("hypothesis_death", false))
	check("death stage uses authored triple", model.candidates(hypothesis) == [group("night_father_death"), group("twin_beast_account"), group("skyway_reference")])
	result = model.send(hypothesis, group("night_father_death"))
	check("second submitted evidence opens deeper followups", model.progress.get("hypothesis_death", false) and result.get("choices", []).size() == 3)
	result = model.choose(result["choices"][0])
	check("followup explains shared body", joined(result).contains("share one living body"))
	state.current_city_day = false
	state.record_gravestone("altar_tomb")
	state.record_gravestone("mother_tomb")
	state.record_gravestone("father_tomb")
	state.record_evidence("altar_blessing_glyph")
	for id in ["altar_path_rubbing", "night_mother_river_rubbing", "night_father_path_rubbing", "crystal_god_rubbing"]: state.record_rubbing(id)
	state.record_evidence("altar_blessing_translation")
	check("path rubbing in the slot reveals the path question", model.questions_for("altar_tomb", group("altar_path_rubbing")).any(func(q: Dictionary) -> bool: return q["target"] == "query_night_unending_path_hint"))
	check("blessing translation alone does not explain the path", not model.questions_for("altar_tomb", group("altar_blessing_translation")).any(func(q: Dictionary) -> bool: return q["target"] == "query_night_unending_path"))
	model.send(question("query_night_unending_path_hint", "altar_tomb"), group("altar_path_rubbing"))
	check("after the hint the blessing translation explains the path", model.questions_for("altar_tomb", group("altar_blessing_translation")).any(func(q: Dictionary) -> bool: return q["target"] == "query_night_unending_path"))
	check("translation knowledge alone does not reveal translation question", not model.questions_for("altar_tomb").any(func(q: Dictionary) -> bool: return q["target"] == "test_answer_altar_24"))
	for pair in [["test_answer_altar_8", "altar_tomb"], ["query_night_unending_path", "altar_tomb"], ["query_night_dry_river", "mother_tomb"], ["query_night_ascending_path", "father_tomb"]]:
		result = model.send(question(pair[0], pair[1]), group("altar_blessing_glyph") if pair[0] == "test_answer_altar_8" else (group("altar_blessing_translation") if pair[0] == "query_night_unending_path" else ""))
	check("four translations do not unlock fifth requirement", model.progress.get("queried_night_glyphs", []).size() == 4 and not model.questions_for("altar_tomb").any(func(q: Dictionary) -> bool: return q["target"] == "test_answer_altar_24"))
	model.send(question("query_night_crystal_god", "altar_tomb"), "")
	check("crystal god question hidden until the correspondence is shown", not model.questions_for("altar_tomb").any(func(q: Dictionary) -> bool: return q["target"] == "test_answer_altar_crystal_shape"))
	state.record_evidence("crystal_god_crystal_correspondence")
	for tomb_id in ["altar_tomb", "mother_tomb", "father_tomb"]:
		check("showing the crystal correspondence reveals the crystal god question: " + tomb_id, model.questions_for(tomb_id, group("crystal_god_crystal_correspondence")).any(func(q: Dictionary) -> bool: return q["target"] == "test_answer_altar_crystal_shape"))
	check("all five unlock translation question without evidence", model.questions_for("altar_tomb").any(func(q: Dictionary) -> bool: return q["target"] == "test_answer_altar_24"))
	var river_q := question("test_answer_mother_12", "mother_tomb")
	model.send(river_q, "")
	check("symbol alone does not grant death conclusion", not state.evidence_ids.has("night_mother_death_finding"))
	check("river primary candidate is not its own reward", river_q["candidates"][0] == group("dry_underground_river"))
	state.record_evidence("dry_underground_river")
	model.send(river_q, group("dry_underground_river"))
	check("field evidence awards correct death conclusion", state.evidence_ids.has("night_mother_death_finding"))
	state.investigation_tutorial_completed = true
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	var radio = main.get_node("RadioTool")
	radio._intro_calls = []  # intro calls are covered by radio_intro_test.gd; this checks the plain stone list
	radio.open()
	check("fourth radio icon stays inside viewport", radio.get_viewport_rect().has_point(radio._button.get_global_rect().get_center()))
	check("radio opens with stone selection", radio.is_open() and radio._tomb.is_empty() and state.radio_modal_open)
	radio._start_call("baby_tomb")
	await process_frame
	radio._select_question(moon_q)
	await process_frame
	radio._send()
	await process_frame
	check("actual radio reply enters notebook history", state.radio_logs.any(func(log: Dictionary) -> bool: return str(log["id"]).begins_with("radio:baby_tomb:")))
	radio._collect_term("natural")
	check("clickable cause recorded in global pool", "natural" in radio.model.progress.get("causes", []))
	await create_timer(0.4).timeout
	for i in 20:
		if not radio._reply_box.is_playing(): break
		if radio._reply_box._accept_input:
			radio._reply_box._finish_line()
			radio._reply_box._advance()
		await create_timer(0.05).timeout
	await create_timer(0.4).timeout
	radio.close()
	check("closing radio releases notebook input", not state.radio_modal_open)
	main.queue_free()
	await process_frame
	print("RADIO FRAMEWORK: " + ("ALL PASSED" if failures == 0 else "%d FAILED" % failures))
	quit(0 if failures == 0 else 1)
