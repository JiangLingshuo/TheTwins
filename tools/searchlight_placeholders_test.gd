extends SceneTree
var failures := 0
var state
var main
var lamp
func _initialize() -> void: _run.call_deferred()
func check(message: String, ok: bool) -> void:
	print(("PASS " if ok else "FAIL ") + message)
	if not ok: failures += 1
func aim(target, year: float) -> void:
	lamp.turn_on_at(target.get_global_rect().get_center(), true)
	lamp.focus = year
	lamp._target_focus = year
	target.apply_flashlight(lamp)
	target.exposure = 0.8
	target.apply_flashlight(lamp)
func _run() -> void:
	await process_frame
	state = root.get_node("GameState")
	state.cycle_tutorial_completed = true
	state.investigation_tutorial_completed = true
	state.cycle_hint_heard = true
	state.tutorial_night_heard = true
	change_scene_to_file("res://scenes/main.tscn")
	await create_timer(0.2).timeout
	main = current_scene
	lamp = main.get_node("FlashlightTool/Flashlight")
	var catalog: Dictionary = state.content_catalog()["evidence"]
	var targets := get_nodes_in_group("flashlight_targets")
	check("thirteen searchlight targets placed", targets.size() == 13)
	check("dial reaches ancient beast year", lamp.focus_max == 250 and main.get_node("FlashlightTool/FocusScale").max_value == 250)
	for target in targets:
		check("no debug placeholder card: " + target.evidence_id, target.get_parent().get_node_or_null(str(target.name) + "Placeholder") == null)
		var meta: Dictionary = catalog[target.evidence_id]["metadata"]
		check("only authored searchlight evidence", "searchlight" in meta.get("tool", []))
		if not target.scan_years.is_empty(): continue
		var night: bool = target.get_parent().name == "NightCemetery"
		if night: main.set_night()
		else: main.set_day()
		if not target.required_grave.is_empty() and target.required_grave not in state.gravestones:
			aim(target, target.years_ago)
			check("trace waits for its required marker", not target.discovered)
			state.record_gravestone(target.required_grave)
		aim(target, 0.0)
		check("wrong year does not collect: " + target.evidence_id, not target.discovered)
		aim(target, target.years_ago)
		check("correct year records: " + target.evidence_id, target.discovered and state.evidence_ids.has(target.evidence_id))
		lamp.active = false
		check("positive trace persists for comparison", target.contains_point(target.get_global_rect().get_center()))
	for target in targets:
		if target.scan_years.is_empty(): continue
		if target.get_parent().name == "NightCemetery": main.set_night()
		else: main.set_day()
		aim(target, 45)
		check("one empty endpoint is not enough: " + target.evidence_id, not target.discovered and not state.evidence_ids.has(target.evidence_id))
		aim(target, 45)
		check("same endpoint does not count twice", state.searchlight_scan_progress[target.evidence_id].size() == 1)
		aim(target, 0)
		if target.evidence_id in ["scholar_no_traces", "night_mother_no_traces"]:
			check("%s needs more than two endpoints" % target.evidence_id, not target.discovered)
			aim(target, 50)
			check("%s still needs the fourth setting" % target.evidence_id, not target.discovered)
			aim(target, 60)
		check("all required settings record range observation", target.discovered and state.evidence_ids.has(target.evidence_id))
		check("negative scan is not a symbol match target", not target.contains_point(target.get_global_rect().get_center()))
	main.set_day()
	if OS.get_cmdline_user_args().has("--shots"):
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://test_output/searchlight_placeholders"))
		lamp.active = false
		await create_timer(1.0).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://test_output/searchlight_placeholders/day.png"))
		main.set_night()
		await create_timer(1.0).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://test_output/searchlight_placeholders/night.png"))
	print("SEARCHLIGHT PLACEHOLDERS: " + ("ALL PASSED" if failures == 0 else str(failures) + " FAILED"))
	quit(0 if failures == 0 else 1)
