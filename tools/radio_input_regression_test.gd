extends SceneTree
var failures := 0
func _initialize() -> void: _run.call_deferred()
func check(message: String, ok: bool) -> void:
	print(("PASS " if ok else "FAIL ") + message)
	if not ok: failures += 1
func wait(seconds: float) -> void: await create_timer(seconds).timeout
func click(point: Vector2) -> void:
	Input.warp_mouse(point)
	var move := InputEventMouseMotion.new()
	move.position = point
	move.global_position = point
	Input.parse_input_event(move)
	await process_frame
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = point
		event.global_position = point
		Input.parse_input_event(event)
		await process_frame
func slot_button(radio):
	for node in radio._layout.find_children("*", "Button", true, false):
		for label in node.get_children():
			if label is Label and label.text.ends_with("×"): return node
	return null
func _run() -> void:
	await process_frame
	var state := root.get_node("GameState")
	state.investigation_tutorial_completed = true
	state.cycle_tutorial_completed = true
	state.record_gravestone("baby_tomb")
	state.record_rubbing("infant_moon_rubbing", "baby_tomb")
	state.confirm_rubbing_meaning("infant_moon_rubbing", "Moon")
	state.record_evidence("infant_graffiti")
	change_scene_to_file("res://scenes/main.tscn")
	await wait(1.0)
	var radio = current_scene.get_node("RadioTool")
	radio.open()
	radio._start_call("baby_tomb")
	await wait(0.1)
	for i in 5:
		radio._set_slot(radio.model.data["evidence_groups"]["infant_moon_rubbing"])
		await wait(0.08)
		var button = slot_button(radio)
		check("clear slot button is visible", button != null and button.is_visible_in_tree())
		if button == null: break
		await click(button.get_global_rect().get_center())
		await wait(0.1)
		check("real clear click empties slot", radio._slot.is_empty())
		check("clear keeps complete visible menu", radio._layout.is_inside_tree() and radio._layout.get_child_count() > 3 and root.get_visible_rect().encloses(radio._panel.get_global_rect()))
	radio._set_slot(radio.model.data["evidence_groups"]["infant_graffiti"])
	await wait(0.1)
	for q in radio.model.questions_for("baby_tomb", radio._slot):
		if q["target"] == "test_answer_baby_21": radio._select_question(q)
	await wait(0.1)
	await click(slot_button(radio).get_global_rect().get_center())
	await wait(0.1)
	check("removing revealing evidence also clears hidden question", radio._question.is_empty() and radio._slot.is_empty())
	var moon: Dictionary = {}
	for q in radio.model.data["questions"]:
		if q["target"] == "test_answer_baby_8": moon = q
	radio._select_question(moon)
	radio._set_slot(radio.model.data["evidence_groups"]["infant_moon_rubbing"])
	radio._send()
	await wait(0.4)
	var box = radio._reply_box
	box._finish_line()
	await process_frame
	var rect: Rect2 = box.content_label.get_global_rect()
	var found := Vector2(-1, -1)
	# Locate the link using actual GUI hover events, not a hand-emitted meta_clicked signal.
	for y in range(int(rect.position.y + 10), int(rect.end.y), 12):
		if found.x >= 0: break
		for x in range(int(rect.position.x + 4), int(rect.end.x), 12):
			var event := InputEventMouseMotion.new()
			event.position = Vector2(x, y)
			event.global_position = event.position
			Input.warp_mouse(event.position)
			Input.parse_input_event(event)
			await process_frame
			if box._hovered_meta == "natural":
				found = event.position
				break
	check("natural death link reachable by real pointer", found.x >= 0)
	if found.x >= 0:
		var index: int = box._index
		await click(found)
		await wait(0.1)
		check("real click collects natural death without skipping", "natural" in state.radio_progress.get("causes", []) and box._index == index)
		check("immediate recorded feedback visible", box._term_notice.visible and box._term_notice.text.contains("natural death"))
	if OS.get_cmdline_user_args().has("--shots"):
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://test_output/radio_input"))
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://test_output/radio_input/feedback.png"))
	print("RADIO INPUT REGRESSION: " + ("ALL PASSED" if failures == 0 else str(failures) + " FAILED"))
	quit(0 if failures == 0 else 1)
