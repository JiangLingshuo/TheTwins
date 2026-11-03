extends SceneTree
var failures := 0
var state
var radio
func _initialize() -> void: _run.call_deferred()
func check(message: String, ok: bool) -> void:
	print(("PASS " if ok else "FAIL ") + message)
	if not ok: failures += 1
func wait(seconds: float) -> void: await create_timer(seconds).timeout
func finish_reply() -> void:
	await wait(0.4)
	for i in 30:
		if not radio._reply_box.is_playing(): break
		if radio._reply_box._accept_input:
			radio._reply_box._finish_line()
			radio._reply_box._advance()
		await wait(0.04)
	await wait(0.4)
func shot(name: String) -> void:
	if not OS.get_cmdline_user_args().has("--shots"): return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://test_output/radio_dialogue"))
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://test_output/radio_dialogue/" + name + ".png"))
func _run() -> void:
	await process_frame
	state = root.get_node("GameState")
	state.cycle_tutorial_completed = true
	state.investigation_tutorial_completed = true
	state.cycle_hint_heard = true
	state.tutorial_night_heard = true
	state.record_gravestone("baby_tomb")
	state.record_evidence("infant_graffiti")
	state.record_rubbing("infant_moon_rubbing", "baby_tomb", "res://assets/Art/symbols/moon.png", "moon")
	state.confirm_rubbing_meaning("infant_moon_rubbing", "Moon")
	change_scene_to_file("res://scenes/main.tscn")
	await wait(1.0)
	radio = current_scene.get_node("RadioTool")
	radio.open()
	radio._start_call("baby_tomb")
	await wait(0.1)
	var question: Dictionary = {}
	for q in radio.model.data["questions"]:
		if q["target"] == "test_answer_baby_8": question = q
	radio._select_question(question)
	radio._set_slot(radio.model.data["evidence_groups"]["infant_moon_rubbing"])
	await wait(0.1)
	await shot("00_question_and_evidence")
	radio._send()
	check("selection controls also use opening dialogue scene", radio._overlay.scene_file_path == "res://scenes/dialogue_box.tscn" and radio._layout.get_parent() == radio._overlay.get_node("Panel/Margin/VBox"))
	check("shared opening dialogue scene instanced", radio._reply_box.scene_file_path == "res://scenes/dialogue_box.tscn")
	check("reply hides selector but retains radio modal lock", radio._reply_playing and not radio._overlay.visible and radio.is_open() and state.radio_modal_open)
	await wait(0.4)
	var box = radio._reply_box
	box._finish_line()
	check("Ink link rendered as underlined clickable text", box.content_label is RichTextLabel and box.content_label.text.contains("[url=natural]") and not box.content_label.get_parsed_text().contains("<link="))
	var index: int = box._index
	box.content_label.meta_hover_started.emit("natural")
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	box._on_content_input(click)
	box.content_label.meta_clicked.emit("natural")
	check("term click collects without advancing dialogue", box._index == index and "natural" in radio.model.progress.get("causes", []))
	box.content_label.meta_hover_ended.emit("natural")
	await shot("01_shared_reply")
	radio.close()
	check("cannot end or change evidence mid reply", radio.is_open() and radio._reply_playing)
	await finish_reply()
	check("finished reply returns to question selector", not radio._reply_playing and radio._overlay.visible and radio._question.is_empty())
	await wait(0.1)
	await shot("02_return_to_questions")
	var log: Dictionary = state.radio_logs.filter(func(item: Dictionary) -> bool: return item["id"] == radio._session)[0]
	check("logged answer contains plain readable text", log["body"].contains("natural death") and not log["body"].contains("<link="))
	var log_size: int = log["lines"].size()
	radio._replay_reply()
	await finish_reply()
	check("replay neither reruns Ink nor duplicates logs", log["lines"].size() == log_size)
	radio._select_question(question)
	radio._set_slot(radio.model.data["evidence_groups"]["infant_graffiti"])
	radio._send()
	await wait(0.4)
	box._finish_line()
	check("hidden reply uses gold shared frame", box.panel.get_theme_stylebox("panel").border_width_left == 2 and box._feedback_kind == "hidden")
	check("future lines are not logged upfront", log["lines"].size() == log_size + 3)
	box._advance()
	await wait(0.1)
	box._finish_line()
	await shot("03_hidden_gold_reply")
	await finish_reply()
	check("hidden feedback persists on return", radio._feedback == "hidden" and radio._status.contains("hidden connection"))
	radio.close()
	check("call closes and releases modal lock", not state.radio_modal_open and not radio.is_open())
	# XML opening remains supported by the same rich-text dialogue scene.
	box.play_file("res://assets/dialogue/tutorial_sun_moon.xml")
	await wait(0.4)
	check("XML playback remains plain and resets gold frame", box.content_label.get_parsed_text().contains("crescent") and box._feedback_kind == "")
	await finish_reply()
	print("RADIO DIALOGUE UI: " + ("ALL PASSED" if failures == 0 else str(failures) + " FAILED"))
	quit(0 if failures == 0 else 1)
