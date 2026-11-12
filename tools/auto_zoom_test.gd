extends SceneTree
## Auto zoom: the searchlight and camera pull the view out; rubbing a marker zooms in on it.
##   godot --headless --path . -s tools/auto_zoom_test.gd
var failures := 0
func _initialize() -> void: _run.call_deferred()
func check(label: String, ok: bool) -> void:
	print(("PASS " if ok else "FAIL ") + label)
	if not ok: failures += 1
func wait(seconds: float) -> void: await create_timer(seconds).timeout
func stone(id: String) -> Control:
	for s in get_nodes_in_group("gravestones"):
		if s.gravestone_id == id: return s
	return null
func _run() -> void:
	await process_frame
	var state := root.get_node("GameState")
	state.investigation_tutorial_completed = true
	state.cycle_tutorial_completed = true
	state.camera_tutorial_completed = true
	state.current_city_day = true
	state.resume_saved_city = false
	change_scene_to_file("res://scenes/main.tscn")
	await wait(0.8)
	var main = current_scene
	var zoom = main.get_node("SceneZoom")
	var baby = stone("baby_tomb")
	# Searchlight: picking it up while zoomed in pulls the view out.
	zoom.zoom_to(baby)
	await wait(1.1)
	check("zoomed in on the small marker", zoom.get_zoomed() == baby)
	var lamp = main.get_node("FlashlightTool")
	lamp._on_button_pressed()
	check("searchlight pickup zooms out", zoom.get_zoomed() == null)
	await wait(1.1)
	# A zoom made while aiming: the next click zooms out instead of locking the beam.
	zoom.zoom_to(baby)
	await wait(1.1)
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = Vector2(300, 300)
	lamp._on_catcher_input(click)
	check("a click while zoomed zooms out and does not lock the beam", zoom.get_zoomed() == null and lamp.state == lamp.State.AIMING)
	await wait(1.1)
	lamp._on_catcher_input(click)
	check("the next click locks the beam", lamp.state == lamp.State.ON)
	lamp.turn_off()
	# Camera.
	zoom.zoom_to(baby)
	await wait(1.1)
	var camera = main.get_node("CameraTool")
	camera._prepare()
	check("camera zooms out", zoom.get_zoomed() == null)
	check("camera waits for the camera move", camera._settle > zoom.zoom_time)
	await wait(1.1)
	camera._prepare()
	check("no extra wait when already zoomed out", is_equal_approx(camera._settle, 0.9))
	# Rubbing.
	var rub = main.get_node("RubbingTool")
	rub.set_active(true)
	var point: Vector2 = baby.get_stone_global_rect().get_center()
	check("the small marker is under the test point", baby.is_point_on_stone(point))
	rub._drawing = true
	for i in 6:
		rub._last_move_msec = Time.get_ticks_msec()
		rub._track_linger(0.1, point)
	check("a short rub does not zoom", zoom.get_zoomed() == null)
	rub._last_move_msec = -100000
	for i in 20:
		rub._track_linger(0.1, point)
	check("holding still does not count", zoom.get_zoomed() == null)
	for i in 12:
		rub._last_move_msec = Time.get_ticks_msec()
		rub._track_linger(0.1, point)
	check("rubbing on the marker zooms in on it", zoom.get_zoomed() == baby)
	rub._drawing = true
	check("strokes are held back while the camera moves", zoom.is_moving())
	await wait(1.1)
	rub.set_active(false)
	# Other markers stay shut during the tutorial.
	zoom.zoom_out()
	await wait(1.1)
	state.investigation_tutorial_completed = false
	var other = stone("scholar_tomb")
	check("another marker is not auto-zoomed during the tutorial", rub._auto_zoom_stone_at(other.get_stone_global_rect().get_center()) != other)
	check("the small marker still is", rub._auto_zoom_stone_at(point) == baby)
	print("auto zoom failures: ", failures)
	quit(1 if failures else 0)
