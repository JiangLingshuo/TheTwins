extends SceneTree
var failures := 0
func _initialize() -> void:
	_run.call_deferred()
func check(label: String, value: bool) -> void:
	print(("PASS " if value else "FAIL ") + label)
	if not value: failures += 1
func wait(seconds: float) -> void:
	await create_timer(seconds).timeout
func brush(tool: Control, symbol: Control) -> void:
	var rect := symbol.get_global_rect()
	for pass_index in 8:
		for row in 10:
			var y := rect.position.y + rect.size.y * row / 9.0
			tool._brush(Vector2(rect.position.x, y), Vector2(rect.end.x, y))
func shot(name: String) -> void:
	if not OS.get_cmdline_user_args().has("--shots"):
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://test_output/sun_moon_tutorial"))
	FileAccess.open("res://test_output/.gdignore", FileAccess.WRITE)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://test_output/sun_moon_tutorial/" + name + ".png"))

func _run() -> void:
	await process_frame
	var state := root.get_node("GameState")
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	var tutorial = main.get_node("SunMoonTutorial")
	var tool = main.get_node("RubbingTool")
	var notebook = main.get_node("NotebookTool")
	check("sky sun has no rubbing component", not main.has_node("DayCemetery/Sun/SunSymbol"))
	var moon = main.get_node("DayCemetery/BabyTomb/MoonSymbol")
	var baby = main.get_node("DayCemetery/BabyTomb")
	check("tutorial opens by zooming in on the small marker", tutorial.step == tutorial.Step.ZOOM and baby.get_node("ZoomButton").visible)
	await shot("00_zoom")
	var scene_zoom = main.get_node("SceneZoom")
	baby.get_node("ZoomButton").pressed.emit()
	scene_zoom._tween.custom_step(10.0)
	await process_frame
	check("zooming in moves on to the rubbing tool", scene_zoom.get_zoomed() == baby and tutorial.step == tutorial.Step.TOOL)
	tool.set_active(true)
	scene_zoom.zoom_out()
	scene_zoom._tween.custom_step(10.0)
	await process_frame
	check("zooming out before the rubbing goes back to the zoom step", tutorial.step == tutorial.Step.ZOOM)
	brush(tool, moon)
	check("the crescent cannot be rubbed from afar", not moon.is_rubbed)
	tool.set_active(false)
	baby.get_node("ZoomButton").pressed.emit()
	scene_zoom._tween.custom_step(10.0)
	await process_frame
	check("initial hint asks for rubbing tool", tutorial.step == tutorial.Step.TOOL)
	await shot("01_pick_tool")
	check("crescent available from the start", moon.collection_enabled)
	check("sun not given before crescent", not state.rubbings.has("sky_sun_rubbing"))
	tool.set_active(true)
	check("tool pickup points directly to crescent", tutorial.step == tutorial.Step.MOON)
	await shot("02_rub_moon")
	brush(tool, moon)
	await wait(0.5)
	check("moon completion starts Aurora line", tutorial.step == tutorial.Step.AURORA and tutorial._dialogue.is_playing())
	tutorial._dialogue._finish_line()
	await shot("03_aurora")
	check("tutorial line appears in radio history", state.radio_logs.any(func(log: Dictionary) -> bool: return log["id"] == "tutorial_sun_moon"))
	check("rubbed crescent blinks on the marker", moon._blink_tween != null)
	for line_index in 3:
		tutorial._dialogue._finish_line()
		tutorial._dialogue._advance()
		await wait(0.05)
	await wait(0.5)
	check("sun not in the notebook before the moon replaces it", not state.rubbings.has("sky_sun_rubbing"))
	check("notebook icons wait for the crescent to land", not state.cycle_hint_heard)
	for i in 100:
		if not tutorial._speaking: break
		await wait(0.1)
	check("notebook opened by itself on Rise & Set", notebook.is_open() and notebook.book.get_section() == 5)
	check("crescent landed: icons shown, drag step", state.cycle_hint_heard and tutorial.step == tutorial.Step.DRAG)
	check("marker stops blinking, notebook moon keeps blinking", moon._blink_tween == null and tutorial._icon_blink != null and tutorial._icon_blink.is_running())
	notebook.book.jump_to_section(5)
	await wait(0.9)
	check("dedicated spread prompts moon drag", tutorial.step == tutorial.Step.DRAG)
	await shot("04_rise_set")
	check("sun on left and moon on right", notebook.book.left_page.get_node("CycleIcon").rubbing_id == "sky_sun_rubbing" and notebook.book.right_page.get_node("CycleIcon").rubbing_id == "infant_moon_rubbing")
	check("dedicated spread uses day-night papers", notebook.book.day_night_sections.has(5))
	var drag = notebook.rubbing_drag
	check("moon starts a reusable sky drag", drag.begin_cycle("infant_moon_rubbing", Vector2(700, 300)))
	drag._left_book = true
	drag._drop(Vector2(50, 600))
	check("wrong drop does not switch or consume icon", main.is_day and state.rubbings.has("infant_moon_rubbing"))
	var point: Vector2 = main.get_node("DayCemetery/Sun").get_global_rect().get_center()
	drag.begin_cycle("infant_moon_rubbing", Vector2(700, 300))
	var motion := InputEventMouseMotion.new()
	motion.global_position = Vector2(100, 10)
	drag._input(motion)
	await wait(2.0)
	drag._drop(point)
	check("moon dropped on sun switches to night", not main.is_day and state.cycle_tutorial_completed)
	check("navigation does not decode natural death", state.get_rubbing_meaning("infant_moon_rubbing") == "Moon")
	await wait(0.4)
	check("sky sun drops into the notebook", tutorial._delivering and not state.rubbings.has("sky_sun_rubbing"))
	for i in 100:
		if tutorial._dialogue.is_playing(): break
		await wait(0.1)
	check("sun recorded, notebook closed before Aurora's night line", state.rubbings.has("sky_sun_rubbing") and not notebook.is_open() and tutorial._dialogue.is_playing())
	check("both icons listed once in Rubbings, deciphered", state.rubbings.count("sky_sun_rubbing") == 1 and state.rubbings.count("infant_moon_rubbing") == 1 \
		and state.is_rubbing_deciphered("sky_sun_rubbing") and state.is_rubbing_deciphered("infant_moon_rubbing"))
	await wait(0.9)  # the box fades in before it takes input
	await shot("05_night_city")
	for line_index in 12:
		if not tutorial._dialogue.is_playing(): break
		tutorial._dialogue._finish_line()
		tutorial._dialogue._advance()
		await wait(0.05)
	await wait(0.5)
	drag.begin_cycle("sky_sun_rubbing", Vector2(700, 300))
	drag._left_book = true
	drag._drop(main.get_node("NightCemetery/Moon").get_global_rect().get_center())
	check("sun dropped on moon returns to day", main.is_day)
	check("tutorial enables other tomb symbols", main.get_node("DayCemetery/BabyTomb/HumanSymbol").collection_enabled)
	state.cycle_tutorial_completed = false
	state.cycle_hint_heard = false
	tutorial.skip()
	check("developer skip unlocks navigation and reaches night", state.cycle_tutorial_completed and state.cycle_hint_heard and not main.is_day)
	# Corner sun / moon on every other page, draggable onto the sky.
	await notebook.open()
	await wait(0.3)
	notebook.book.jump_to_section(2)
	await wait(1.2)
	var corner_sun: Control = notebook.book.left_page.get_node_or_null("CornerIcon")
	var corner_moon: Control = notebook.book.right_page.get_node_or_null("CornerIcon")
	check("corner sun top-left, moon top-right", corner_sun and corner_moon and corner_sun.visible and corner_moon.visible \
		and corner_sun.rubbing_id == "sky_sun_rubbing" and corner_moon.rubbing_id == "infant_moon_rubbing" \
		and corner_sun.position.x < 100 and corner_moon.position.x > 300)
	await shot("06_corner_icons")
	check("corner sun drags onto the moon", drag.begin_cycle(corner_sun.rubbing_id, Vector2(300, 300)))
	drag._left_book = true
	drag._drop(main.get_node("NightCemetery/Moon").get_global_rect().get_center())
	check("corner sun switches to day", main.is_day)
	main.queue_free()
	await process_frame
	print("SUN MOON TUTORIAL: " + ("ALL PASSED" if failures == 0 else "%d FAILED" % failures))
	quit(0 if failures == 0 else 1)
