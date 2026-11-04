extends SceneTree
## Radio dialogue history (data for the Notebook's Radio Logs).
## Run: godot --headless --path . -s tools/radio_history_test.gd
## Question replies come from the real radio model (radio_content.json) and are
## delivered line by line the way the dialogue box does (append_radio_line).
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

## Ask like RadioTool._send does, then deliver every reply line like DialogueBox.
## Returns the reply lines as delivered.
func ask(q: Dictionary, slot: String, session: String) -> Array:
	var result: Dictionary = model.send(q, slot)
	if result.has("error"):
		print("  send error: " + str(result["error"]))
		return []
	var context := {"gravestone_id": q["tomb"], "question_id": q["id"], "question_text": q["label"],
		"evidence_id": model.submitted_id, "evidence_group": slot,
		"evidence_name": model.group_title(slot) if not slot.is_empty() else "", "follow_up": ""}
	state.begin_radio_exchange(session, context)
	var delivered: Array = []
	for line in result["lines"]:
		var content := RegEx.create_from_string('<link="[^"]+">([^<]+)</link>').sub(str(line["content"]), "$1", true)
		state.append_radio_line(session, {"speaker": line["speaker"], "content": content})
		delivered.append({"speaker": line["speaker"], "content": content})
	state.end_radio_exchange(session)
	return delivered

## Click through the RadioTool's reply box until the reply has finished.
func finish_reply(tool: Control) -> void:
	for i in 100:
		await create_timer(0.1).timeout
		if not tool._reply_playing: return
		tool._reply_box._advance()

func records(q: Dictionary, evidence_id: String = "*") -> Array:
	return state.radio_history_records(q["tomb"], q["id"]).filter(func(r: Dictionary) -> bool:
		return evidence_id == "*" or r["evidence_id"] == evidence_id)

func joined(lines: Array) -> String:
	var text := ""
	for line in lines: text += str(line["content"]) + "\n"
	return text

func _run() -> void:
	await process_frame
	state = root.get_node("GameState")
	model = load("res://scripts/radio_model.gd").new()
	state.player_name = "Mira"
	state.record_gravestone("baby_tomb")
	state.cycle_tutorial_completed = true  # the moon question is available
	state.record_rubbing("infant_moon_rubbing", "baby_tomb")
	state.record_rubbing("infant_figure_rubbing", "baby_tomb")
	state.record_evidence("infant_graffiti")
	state.record_evidence("designer_manuscript")
	var session := "radio:baby_tomb:1"
	var moon_q := question("test_answer_baby_8", "baby_tomb")
	var human_q := question("test_answer_baby_17", "baby_tomb")

	# 1. A question without evidence creates a record (this reply has no AnswerId).
	state.play_time = 10.0
	var hint := ask(moon_q, "", session)
	var plain := records(moon_q, "")
	check("question without evidence is recorded", plain.size() == 1 and plain[0]["evidence_id"] == "" and plain[0]["evidence_group"] == "")
	check("reply without AnswerId is recorded", not hint.is_empty() and plain[0]["lines"] == hint)
	check("question text and ids are stored", state.radio_history_questions("baby_tomb")[0]["question_text"] == moon_q["label"] \
		and state.radio_history_gravestones().size() == 1 and state.radio_history_gravestones()[0] == "baby_tomb")

	# 2. Same question, evidence and dialogue: one record, last_heard_at moves.
	state.play_time = 20.0
	ask(moon_q, "", session)
	plain = records(moon_q, "")
	check("repeat does not duplicate", plain.size() == 1)
	check("repeat keeps first_heard_at and updates last_heard_at", plain[0]["first_heard_at"] == 10.0 and plain[0]["last_heard_at"] == 20.0)

	# 3. Different evidence gives distinguishable records (same reply text here).
	ask(human_q, group("infant_figure_rubbing"), session)
	ask(human_q, group("infant_graffiti"), session)
	var by_figure := records(human_q, "infant_figure_rubbing")
	var by_graffiti := records(human_q, "infant_graffiti")
	check("different evidence -> separate records", by_figure.size() == 1 and by_graffiti.size() == 1)
	check("identical reply text stays separate per evidence", by_figure[0]["lines"] == by_graffiti[0]["lines"])
	check("evidence display name is stored", not str(by_figure[0]["evidence_name"]).is_empty())

	# 4/5. Same question + same evidence, different dialogue (depends on read_answers).
	var before := ask(moon_q, group("infant_graffiti"), session)  # hint + appended hidden text
	ask(moon_q, group("infant_moon_rubbing"), session)  # moon answer (baby_8_normal_9)
	var after := ask(moon_q, group("infant_graffiti"), session)  # moon answer + appended hidden text
	var graffiti := records(moon_q, "infant_graffiti")
	check("same question/evidence, different dialogue -> two records", graffiti.size() == 2 and graffiti[0]["lines"] != graffiti[1]["lines"])
	check("appended (additional) dialogue is kept", joined(before).contains("peaceful ending") and joined(after).contains("peaceful ending") \
		and joined(graffiti[0]["lines"]).contains("peaceful ending") and joined(graffiti[1]["lines"]).contains("peaceful ending"))
	check("earlier variant is not overwritten", graffiti[0]["lines"] == before and graffiti[1]["lines"] == after)

	# 7. Speakers and order are preserved.
	var speakers_ok := true
	for i in after.size():
		speakers_ok = speakers_ok and graffiti[1]["lines"][i]["speaker"] == after[i]["speaker"]
	check("speakers and line order are preserved", speakers_ok and graffiti[1]["lines"].size() == after.size())

	# 8. Two questions in one call (same session id) stay separate.
	check("questions in one call are separate", state.radio_history_questions("baby_tomb").size() == 2 \
		and records(moon_q).size() == 4 and records(human_q).size() == 2)
	check("call session id is not part of any record", not JSON.stringify(state.radio_question_history).contains("radio:baby_tomb"))

	# An exchange that delivered nothing records nothing.
	state.begin_radio_exchange(session, {"gravestone_id": "baby_tomb", "question_id": "x", "question_text": "x"})
	state.end_radio_exchange(session)
	check("empty exchange records nothing", state.radio_history_questions("baby_tomb").size() == 2)

	# 9. A non-question transmission played by a real dialogue box.
	var box: Control = load("res://scenes/dialogue_box.tscn").instantiate()
	root.add_child(box)
	await process_frame
	var tutorial_lines: Array[Dictionary] = [{"speaker": "Aurora", "content": "First line."}, {"speaker": "#PLAYER#", "content": "Second line."}]
	box.play(tutorial_lines, "tutorial_test")
	for i in 40:
		await create_timer(0.1).timeout
		if not box.is_playing(): break
		box._advance()
	var others: Array = state.radio_other_transmissions()
	check("transmission is recorded outside gravestones", others.size() == 1 and others[0]["source_id"] == "tutorial_test" \
		and others[0]["title"] == "Tutorial Test" and state.radio_history_gravestones().size() == 1 and state.radio_history_gravestones()[0] == "baby_tomb")
	check("transmission lines and speakers are kept", others.size() == 1 and others[0]["lines"] == [{"speaker": "Aurora", "content": "First line."}, {"speaker": "Mira", "content": "Second line."}])
	box.queue_free()

	# 10. Play time: HH:MM:SS, advances, stops while the tree is paused.
	check("time format", state.format_play_time(3725.9) == "01:02:05" and state.format_play_time(0.0) == "00:00:00")
	var start: float = state.play_time
	await create_timer(0.3).timeout
	check("play time advances", state.play_time > start)
	paused = true
	var held: float = state.play_time
	await create_timer(0.3, true).timeout
	check("play time stops while paused", state.play_time == held)
	paused = false

	# Real RadioTool path: the submitted group, a follow-up under its question,
	# placeholders, and the raw radio logs.
	state.current_city_day = true
	state.record_gravestone("scholar_tomb")
	state.record_evidence("night_father_death")
	state.radio_progress["hypothesis_open"] = true
	state.radio_progress["hypothesis_skin"] = true  # this answer now completes the hypothesis
	var tool: Control = load("res://scripts/radio_tool.gd").new()
	root.add_child(tool)
	await process_frame
	var hypothesis := question("test_disappearance_hypothesis", "scholar_tomb")
	tool._start_call("scholar_tomb")
	tool._question = hypothesis
	tool._slot = group("night_father_death")
	tool._send()
	await finish_reply(tool)
	check("the reply offers follow-ups", tool._followups.size() >= 2)
	var follow: Dictionary = tool._followups[0]
	tool._follow(follow)
	await finish_reply(tool)
	var variants: Array = state.radio_history_records("scholar_tomb", hypothesis["id"])
	check("question and follow-up are separate records under one question", variants.size() == 2 \
		and variants[0]["follow_up"] == "" and variants[1]["follow_up"] == follow["label"])
	check("the follow-up keeps its question's evidence", variants.size() == 2 \
		and variants[1]["evidence_id"] == "night_father_death" and variants[1]["evidence_group"] == group("night_father_death"))
	check("evidence_group is the record the player submitted", variants.size() == 2 and variants[0]["evidence_group"] == group("night_father_death"))
	check("follow-up reply lines are recorded", variants.size() == 2 and not variants[1]["lines"].is_empty())
	var raw_speakers: Array = state.radio_question_history["scholar_tomb"][hypothesis["id"]]["records"][0]["lines"].map(func(l: Dictionary) -> String: return l["speaker"])
	var shown_speakers: Array = variants[0]["lines"].map(func(l: Dictionary) -> String: return l["speaker"])
	check("#PLAYER# is resolved for the notebook, raw in storage", raw_speakers.has("#PLAYER#") and shown_speakers.has("Mira") and not shown_speakers.has("#PLAYER#"))
	var raw_log: Dictionary = {}
	for log in state.radio_logs:
		if log["id"] == tool._session: raw_log = log
	check("existing raw radio log still records the call", not raw_log.is_empty() and raw_log["body"].contains(hypothesis["label"]) \
		and raw_log["body"].contains(follow["label"]))
	# A combined record group: the player picks the group, the model evaluates its owned member.
	state.current_city_day = false
	state.record_gravestone("altar_tomb")
	state.record_evidence("night_father_moon_stone")
	var moon_stone_q := question("test_answer_altar_16", "altar_tomb")
	var moon_group := group("night_father_moon_stone")
	tool._start_call("altar_tomb")
	tool._question = moon_stone_q
	tool._slot = moon_group
	tool._send()
	await finish_reply(tool)
	var stone_records: Array = state.radio_history_records("altar_tomb", moon_stone_q["id"])
	check("combined group: submitted group and evaluated record are both kept", stone_records.size() == 1 \
		and stone_records[0]["evidence_group"] == moon_group and stone_records[0]["evidence_id"] == "night_father_moon_stone" \
		and moon_group != "night_father_moon_stone")
	tool.queue_free()
	state.current_city_day = true

	# 11. Records live in GameState, not in Notebook or scene nodes.
	state.current_city_day = false
	check("records survive a Day/Night switch", records(moon_q).size() == 4)

	print("RADIO HISTORY TEST: " + ("ALL PASSED" if failures == 0 else "%d FAILED" % failures))
	quit(0 if failures == 0 else 1)
