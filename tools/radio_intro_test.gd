extends SceneTree
## Intro calls: when a first-step question becomes available the radio pops up with the
## question and evidence filled in; once answered it leaves the list but stays in the logs.
##   godot --path . --audio-driver Dummy --resolution 1280x720 -s tools/radio_intro_test.gd
var failures := 0
var state
var radio
func _initialize() -> void: _run.call_deferred()
func check(label: String, ok: bool) -> void:
	print(("PASS " if ok else "FAIL ") + label)
	if not ok: failures += 1
func wait(seconds: float) -> void: await create_timer(seconds).timeout
func drain(dialogue) -> void:
	await wait(0.4)
	for i in 40:
		if not dialogue.is_playing(): break
		if dialogue._accept_input:
			dialogue._finish_line()
			dialogue._advance()
		await wait(0.05)
	await wait(0.5)
func _run() -> void:
	await process_frame
	state = root.get_node("GameState")
	state._autosave_path = "user://test_radio_intro.autosave"  # never touch the real save
	state.investigation_tutorial_completed = true
	state.cycle_tutorial_completed = true
	state.camera_tutorial_completed = true
	state.tutorial_radio_intro_heard = true
	state.current_city_day = true
	state.resume_saved_city = false
	change_scene_to_file("res://scenes/main.tscn")
	await wait(0.8)
	var main = current_scene
	radio = main.get_node("RadioTool")
	state.record_gravestone("scholar_tomb")
	state.record_evidence("profession_record")
	state.record_rubbing("crystal_marker_rubbing", "scholar_tomb", "res://assets/Art/symbol/spar.png", "crystal_lamp")
	state.confirm_rubbing_meaning("crystal_marker_rubbing", "Crystal")
	state.investigation_tutorial_completed = false
	check("no intro call while the tutorial is running", radio._next_intro(true).is_empty())
	state.investigation_tutorial_completed = true
	await wait(2.0)
	check("radio pops up by itself once the comparison exists", radio.is_open())
	check("the question is selected", radio._question.get("id", "") == "scholar:test_answer_scholar_8")
	check("its evidence is already in the slot", radio._slot == "profession_record")
	check("the stone is the Scholar's", radio._tomb == "scholar_tomb")
	radio._send()
	await drain(radio._reply_box)
	var answered: Array = radio.model.progress.get("intro_done", [])
	check("the question is marked answered", "scholar:test_answer_scholar_8" in answered)
	var ids: Array = radio._visible_questions().map(func(q: Dictionary) -> String: return q["id"])
	check("it no longer shows in the radio list", "scholar:test_answer_scholar_8" not in ids)
	check("the exchange is kept in the radio logs", not state.radio_history_records("scholar_tomb", "scholar:test_answer_scholar_8").is_empty())
	# A second intro becomes ready while the radio is still open: no chaining on the same line.
	state.record_evidence("twin_beast_account")
	state.record_rubbing("scholar_beast_rubbing", "scholar_tomb", "res://assets/Art/symbol/spar.png", "beast")
	state.confirm_rubbing_meaning("scholar_beast_rubbing", "Beast")
	await wait(1.5)
	radio._queue_render()
	await wait(0.6)
	check("a second intro does not chain onto the open call", radio._question.is_empty())
	# Once the call is over it rings on its own.
	radio.close(false)
	await wait(2.4)
	check("the second intro pops up by itself after the call", radio.is_open() and radio._question.get("id", "") == "scholar:test_answer_scholar_12")
	# Hanging up on it: it does not pop up again by itself, but is ready when the radio is reopened.
	radio.close(false)
	await wait(0.4)
	radio._intro_dirty = true
	await wait(2.0)
	check("a call that was hung up on does not pop up again", not radio.is_open())
	radio.open()
	await wait(0.5)
	check("reopening the radio brings it back filled in", radio._question.get("id", "") == "scholar:test_answer_scholar_12" and radio._slot == "twin_beast_account")
	# A wrong record only gets a nudge, so the question stays.
	var wrong: String = radio.model.data["evidence_groups"].get("profession_record", "")
	radio._slot = wrong
	radio._send()
	await drain(radio._reply_box)
	check("a nudge reply does not use the question up", "scholar:test_answer_scholar_12" not in radio.model.progress.get("intro_done", []))
	radio.close(false)
	await wait(0.3)
	# Several questions ready at once: only one rings, the rest wait for the player.
	radio.model.progress["intro_done"] = []
	radio.model.progress["intro_skipped"] = []
	radio._intro_dismissed = []
	radio.model.progress["intro_started"] = true
	state.radio_question_history.clear()  # nothing has been heard yet
	state.record_gravestone("sun_tomb")
	state.record_evidence("shared_family_base")
	radio._intro_dirty = true
	await wait(2.4)
	check("with several ready, one rings", radio.is_open())
	var rang: String = radio._question.get("id", "")
	radio.close(false)
	await wait(2.4)
	check("the others do not ring by themselves", not radio.is_open())
	check("the one that rang is not asked for again", rang != "" and rang in radio._intro_dismissed)
	# A save from before intro calls: everything already ready is left alone.
	radio.model.progress.erase("intro_started")
	radio.model.progress["intro_done"] = []
	radio.model.progress["intro_skipped"] = []
	radio._intro_dismissed = []
	radio._start_intro_calls()
	check("an old save marks what is ready as skipped", radio.model.progress.get("intro_skipped", []).size() >= 2)
	check("and nothing pops up for it", radio._next_intro(false).is_empty())
	radio._intro_dirty = true
	await wait(2.0)
	check("no pop-up for an old save", not radio.is_open())
	print("radio intro failures: ", failures)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_radio_intro.autosave"))
	quit(1 if failures else 0)
