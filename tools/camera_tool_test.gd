extends SceneTree
var failures := 0
func _initialize() -> void: _run.call_deferred()
func check(message: String, ok: bool) -> void:
	print(("PASS " if ok else "FAIL ") + message)
	if not ok: failures += 1
func wait(seconds: float) -> void: await create_timer(seconds).timeout
func drain(box) -> void:
	await wait(0.4)
	for i in 40:
		if not box.is_playing(): break
		if box._accept_input: box._finish_line(); box._advance()
		await wait(0.04)
	await wait(0.4)
func _run() -> void:
	await process_frame
	var state := root.get_node("GameState")
	state.investigation_tutorial_completed = true
	state.cycle_tutorial_completed = true
	change_scene_to_file("res://scenes/main.tscn")
	await wait(0.3)
	var main = current_scene
	var camera = main.get_node("CameraTool")
	var box = main.get_node("Toolbox")
	check("toolbox has three tools", box._proxies.size() == 3)
	box.reveal()
	check("hover opens tools on the left", box.tray.visible and box.tray.get_global_rect().end.x < box.button.get_global_rect().position.x)
	var rubbing = main.get_node("RubbingTool")
	box.proxy_for(rubbing._button).pressed.emit()
	check("proxy selects original rubbing tool", rubbing.active)
	rubbing.turn_off()
	var before: int = state.evidence_ids.size()
	camera.play_tutorial()
	await wait(1.0)
	await drain(camera._dialogue)
	await wait(1.3)
	await drain(camera._dialogue)
	check("camera exposes framed photo with noise shader", camera._overlay.visible and camera._photo.texture != null and camera._photo.material != null)
	check("photo itself grants no evidence", state.evidence_ids.size() == before)
	camera._select_spot("base_scholar")
	camera._select_spot("base_scholar")
	camera._select_spot("base_infant")
	check("unique marks required before conclusion", not state.evidence_ids.has("shared_family_base") and state.camera_observations["base"].size() == 2)
	if OS.get_cmdline_user_args().has("--shots"):
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://test_output/camera"))
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://test_output/camera/tutorial_photo.png"))
	camera._select_spot("base_sun")
	await wait(0.4)
	await drain(camera._dialogue)
	check("three bases grant one conclusion", state.evidence_ids.count("shared_family_base") == 1 and state.evidence_ids.size() == before + 1)
	check("camera tutorial opens formal investigation", state.camera_tutorial_completed and state.formal_investigation_started and not state.camera_modal_open)
	await camera.take_photo(false)
	check("ordinary photo has no automatic blue hints", not camera._tutorial)
	for id in ["beast_a", "beast_b", "beast_c"]: camera._select_spot(id)
	check("manual repeated motifs yield local observation", state.evidence_ids.has("repeated_beast_motifs"))
	camera._select_spot("day_crescent")
	camera.close_photo()
	main.set_night()
	await camera.take_photo(false)
	camera._select_spot("night_moon")
	check("observations persist between city photos", state.evidence_ids.has("moon_reference"))
	camera.close_photo()
	print("CAMERA TOOL: " + ("ALL PASSED" if failures == 0 else str(failures) + " FAILED"))
	quit(0 if failures == 0 else 1)
