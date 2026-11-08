extends SceneTree
var failures := 0
func check(label: String, ok: bool) -> void:
	print(("PASS " if ok else "FAIL ") + label)
	if not ok: failures += 1
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	await process_frame
	var state = root.get_node("GameState")
	check("story mode defaults off and is not saved", not state.story_mode_enabled() and "story_mode" not in state.AUTOSAVE_FIELDS)
	state.set_story_mode(true)
	check("debug story mode can be enabled", state.story_mode_enabled())
	state.record_gravestone("baby_tomb")
	state.record_evidence("infant_graffiti")
	state.record_evidence("designer_journal")
	state.cycle_tutorial_completed = true
	var model = load("res://scripts/radio_model.gd").new()
	var q: Dictionary
	for candidate in model.data["questions"]:
		if candidate["target"] == "test_answer_baby_8": q = candidate
	check("moon question exists", not q.is_empty())
	if q.is_empty(): quit(1); return
	var sketch: String = model.data["evidence_groups"]["infant_graffiti"]
	var journal: String = model.data["evidence_groups"]["designer_journal"]
	var before := JSON.stringify(state._checkpoint_state())
	var good: Dictionary = model.story_evidence_hint("baby_tomb", sketch, q)
	check("sketch reveals hidden question", good["hidden"])
	check("sketch supports moon follow-up", good["correct"])
	check("journal is not falsely marked as revealing hidden question", not model.story_evidence_hint("baby_tomb", journal)["hidden"])
	check("uncollected evidence is not suggested", not model.story_evidence_hint("baby_tomb", model.data["evidence_groups"]["designer_manuscript"], q)["correct"])
	check("hint calculation changes no progress or evidence", before == JSON.stringify(state._checkpoint_state()))
	state.investigation_tutorial_completed = true
	state.camera_tutorial_completed = true
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	await create_timer(1.0).timeout
	state._set_debug_overlay(true)
	check("F2 menu includes story switch", state._dev_menu.get_child(0).get_children().any(func(n: Node) -> bool: return n is CheckButton and n.text.contains("Story mode")))
	state._set_debug_overlay(false)
	var radio = main.get_node("RadioTool")
	radio.open()
	radio._start_call("baby_tomb")
	await process_frame
	radio._select_question(q)
	await process_frame
	check("radio renders with story hints", radio.is_open() and radio._layout != null)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("user://story-mode-radio.png")
	state.set_story_mode(false)
	await process_frame
	check("story mode can turn off without closing radio", not state.story_mode_enabled() and radio.is_open())
	radio.close()
	state.set_story_mode(true)
	state.record_rubbing("infant_figure_rubbing", "baby_tomb", "", "dayfolk_appearance")
	var drag = main.get_node("NotebookTool").rubbing_drag
	check("rubbing drag starts in story mode", drag.begin("infant_figure_rubbing", Vector2(400, 350)))
	await create_timer(0.3).timeout
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("user://story-mode-drag.png")
	drag.cancel()
	main.queue_free()
	await process_frame
	print("STORY MODE: %d failures" % failures)
	quit(0 if failures == 0 else 1)
