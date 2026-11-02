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
	var sun = main.get_node("DayCemetery/Sun/SunSymbol")
	var moon = main.get_node("DayCemetery/BabyTomb/MoonSymbol")
	check("initial hint asks for rubbing tool", tutorial.step == tutorial.Step.TOOL)
	await shot("01_pick_tool")
	check("moon waits until sun is collected", not moon.collection_enabled)
	tool.set_active(true)
	check("tool pickup points to sun", tutorial.step == tutorial.Step.SUN)
	brush(tool, moon)
	check("moon cannot bypass initial sun step", not state.rubbings.has("infant_moon_rubbing"))
	brush(tool, sun)
	check("brushing sun records it", state.rubbings.has("sky_sun_rubbing"))
	check("next hint points to moon", tutorial.step == tutorial.Step.MOON and moon.collection_enabled)
	await shot("02_rub_moon")
	brush(tool, moon)
	await wait(0.5)
	check("moon completion starts Aurora line", tutorial.step == tutorial.Step.AURORA and tutorial._dialogue.is_playing())
	tutorial._dialogue._finish_line()
	await shot("03_aurora")
	check("tutorial line appears in radio history", state.radio_logs.any(func(log: Dictionary) -> bool: return log["id"] == "tutorial_sun_moon"))
	for line_index in 3:
		tutorial._dialogue._finish_line()
		tutorial._dialogue._advance()
		await wait(0.05)
	await wait(0.5)
	check("after dialogue asks for notebook", tutorial.step == tutorial.Step.BOOK and state.cycle_hint_heard)
	await notebook.open()
	await wait(0.2)
	check("opening notebook asks for dedicated tab", tutorial.step == tutorial.Step.TAB)
	notebook.book.jump_to_section(5)
	await wait(0.9)
	check("dedicated spread prompts moon drag", tutorial.step == tutorial.Step.DRAG)
	await shot("04_rise_set")
	check("icons do not duplicate in Rubbings", state.regular_rubbings().is_empty())
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
	check("navigation does not decode natural death", not state.is_rubbing_deciphered("infant_moon_rubbing"))
	await wait(0.9)
	await shot("05_night_city")
	drag.begin_cycle("sky_sun_rubbing", Vector2(700, 300))
	drag._left_book = true
	drag._drop(main.get_node("NightCemetery/Moon").get_global_rect().get_center())
	check("sun dropped on moon returns to day", main.is_day)
	check("tutorial enables other tomb symbols", main.get_node("DayCemetery/BabyTomb/HumanSymbol").collection_enabled)
	state.cycle_tutorial_completed = false
	state.cycle_hint_heard = false
	tutorial.skip()
	check("developer skip unlocks navigation and reaches night", state.cycle_tutorial_completed and state.cycle_hint_heard and not main.is_day)
	main.queue_free()
	await process_frame
	print("SUN MOON TUTORIAL: " + ("ALL PASSED" if failures == 0 else "%d FAILED" % failures))
	quit(0 if failures == 0 else 1)
