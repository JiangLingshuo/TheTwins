extends SceneTree
## Smoke test: loads every scene and dialogue, then plays through the notebook flow.
## Runs without a window, so it works with nobody at the computer.
## Prints PASS / FAIL per check and exits with 1 if anything failed.
## Run it with: powershell -File tools/run.ps1 smoke

const TIMEOUT_SECONDS := 180.0

var _failures := 0


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS).timeout.connect(_on_timeout)
	_run()


func _run() -> void:
	await process_frame
	_check_files("res://scenes", ".tscn", _check_scene)
	_check_files("res://assets/dialogue", ".xml", _check_dialogue)
	await _check_notebook_flow()
	await _check_main_after_close()

	print("\n%s" % ("ALL PASSED" if _failures == 0 else "%d FAILED" % _failures))
	quit(1 if _failures > 0 else 0)


func _on_timeout() -> void:
	print("FAIL timed out after %d seconds" % TIMEOUT_SECONDS)
	quit(1)


func _expect(label: String, ok: bool) -> void:
	print("%s %s" % ["PASS" if ok else "FAIL", label])
	if not ok:
		_failures += 1


## Autoload singletons by name (their global names don't compile in a -s script).
func _autoload(node_name: String) -> Node:
	return root.get_node(node_name)


func _wait(seconds: float) -> void:
	await create_timer(seconds).timeout


func _check_files(folder: String, extension: String, check: Callable) -> void:
	for file_name in DirAccess.get_files_at(folder):
		if file_name.ends_with(extension):
			check.call(folder.path_join(file_name))
	for sub_folder in DirAccess.get_directories_at(folder):
		_check_files(folder.path_join(sub_folder), extension, check)


func _check_scene(path: String) -> void:
	var packed: PackedScene = load(path)
	var node := packed.instantiate() if packed else null
	_expect("scene loads: %s" % path, node != null)
	if node:
		node.free()


func _check_dialogue(path: String) -> void:
	_expect("dialogue has lines: %s" % path, not DialogueLoader.load_xml(path).is_empty())


func _check_notebook_flow() -> void:
	change_scene_to_file("res://scenes/start.tscn")
	await _wait(0.3)
	_autoload("Tutorial").reset()
	var start := current_scene
	var book = start.get_node("Book")
	var box = start.get_node("DialogueBox")
	start.dialogue_page = -1  # keep the dialogue out of the way until the book closes
	start.scene_after_close = ""  # stay here so reopening the book can be tested

	book.write(1, "Stored, #PLAYER#")
	start._start_game()
	await _wait(0.9)
	var music_player: AudioStreamPlayer = _autoload("Music").get_node("BGMPlayer")
	_expect("epigraph appears with no background music", start.epigraph.visible and not music_player.playing)
	await start.epigraph.visibility_changed
	await _wait(1.5)
	_expect("epigraph fades out automatically before music starts", not start.epigraph.visible and music_player.playing)
	_expect("prompt hides after a key press", not start.prompt.visible)

	book._on_name_submitted("Ann")
	await _wait(0.1)
	_expect("cover opening plays the flip sound", book._flip_player.playing)
	await _wait(1.5)
	_expect("text stored before opening shows the name", book.right_text.text == "Stored, Ann")
	var tutorial := _autoload("Tutorial")
	_expect("first opening points out the page corner", tutorial.current_hint() == tutorial.TURN_PAGE)

	book.write(4, "abc")
	await _wait(0.1)
	_expect("automatic turn plays the flip sound", book._flip_player.playing)
	await book.written
	_expect("write turns to the page", book._spread == 2 and book.left_text.text == "abc")
	_expect("writing sound stops afterwards", not book._write_player.playing)

	book.write(5, "first")
	book.write(5, "second")
	await _wait(0.1)
	_expect("writing sound plays", book._write_player.playing)
	await book.written
	await book.written
	_expect("queued writes append in order", book.right_text.text == "first\nsecond")
	book.write(5, "only", false)
	await book.written
	_expect("append = false replaces the page", book.right_text.text == "only")

	book.flip_backward()
	await _wait(0.1)
	_expect("manual turn plays the flip sound", book._flip_player.playing)
	await _wait(1.0)
	book.flip_forward()
	await _wait(1.0)
	_expect("manual turns land on the right spread", book._spread == 2)

	book.flip_forward()
	await _wait(2.5)
	_expect("last corner stows the book", book._stowed and book.right_page.visible == false)
	_expect("dialogue plays after stowing", box.is_playing())
	while box.is_playing():
		box._advance()
		await _wait(0.05)

	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	book._on_cover_gui_input(click)
	await _wait(2.5)
	_expect("clicking the icon reopens the book", not book._stowed and book.scale == Vector2.ONE)
	_expect("reopened at the same spread", book._spread == 2 and book.left_page.visible)
	_expect("page-corner hint is not shown again", tutorial.current_hint() == "" and tutorial.has_seen(tutorial.TURN_PAGE))
	book.write(9, "grown")
	await book.written
	_expect("writing past the end adds pages", book.pages.size() == 10 and book._spread == 4)


func _check_main_after_close() -> void:
	change_scene_to_file("res://scenes/start.tscn")
	await _wait(0.3)
	var start := current_scene
	var book = start.get_node("Book")
	start.dialogue_page = 99  # no dialogue in this check
	await start._start_game()
	await _wait(1.5)
	book._on_name_submitted("Ann")
	await _wait(1.5)
	book.write(3, "carried over")
	await book.written
	while book._can_flip_forward():
		book.flip_forward()
		await _wait(0.8)
	book.flip_forward()  # past the last page: close the book
	await _wait(4.0)
	_expect("closing the book loads the main scene", current_scene != null and current_scene.name == "Main")
	_expect("main scene starts in daytime", current_scene != null and current_scene.get("is_day") == true)

	var main := current_scene
	var flashlight_tool = main.get_node("FlashlightTool")
	var notebook_tool = main.get_node("NotebookTool")
	var notebook = notebook_tool.book
	flashlight_tool._set_state(flashlight_tool.State.ON)
	notebook_tool.open()
	await _wait(3.0)
	_expect("notebook button opens the notebook", notebook.is_open())
	_expect("first opening shows Rise & Set, not the start book's last page", notebook.get_spread() == 0 and notebook.get_section() == notebook.RISE_AND_SET)
	_expect("notebook keeps the pages from the start screen", notebook.pages.size() > 3 and notebook.pages[3] == "carried over")
	_expect("opening the notebook turns the flashlight off", flashlight_tool.state == flashlight_tool.State.OFF)
	notebook_tool.close()
	await _wait(2.5)
	_expect("notebook closes back into its button", not notebook.visible and not notebook_tool.is_open())
	notebook_tool.open()
	await _wait(3.0)
	_expect("notebook reopens on Rise & Set", notebook.is_open() and notebook.get_spread() == notebook.get_opening_spread())
	notebook_tool.close()
	await _wait(2.5)
	await _check_notebook_sections(notebook_tool)
	await _finish_tutorials(main)
	await _check_gravestone_record(main, notebook_tool)
	await _check_rubbing(main)
	await _check_rubbing_notebook(main)
	await _check_rubbing_drag(main)


func _check_notebook_sections(notebook_tool: Node) -> void:
	var notebook = notebook_tool.book
	notebook_tool.open()
	await _wait(3.0)
	_expect("notebook has 8 spreads in 6 sections", notebook._spread_count() == 8 and notebook.tabs.get_child_count() == 6)
	_expect("it opens on Rise & Set, the first spread", notebook.get_spread() == 0 and notebook.get_section() == notebook.RISE_AND_SET)
	notebook.jump_to_section(2)
	notebook.jump_to_section(3)  # ignored: a page is already turning
	await _wait(1.0)
	_expect("tab jump ignores a second click while turning", notebook.get_section() == 2)
	notebook.jump_to_section(0)
	await _wait(1.0)
	_expect("tab jumps to the first spread of its section", notebook.get_spread() == 1 and notebook.get_section() == 0)
	_expect("all six gravestone slots start uncollected", range(6).all(func(i): return not notebook.is_gravestone_collected(i)))
	_expect("gravestone pages show a blank page with a \"?\" sketch", notebook.left_page.get_node("Gravestone").visible \
		and notebook.left_page.get_node("Gravestone")._unknown and notebook.left_page.get_node("Art")._kind == 0)
	_expect("Gravestones: Day page on the left, Night page on the right", notebook.left_page.material == notebook._day_material and notebook.right_page.material == notebook._night_material)
	_expect("Night page has light ink", notebook.right_text.label_settings.font_color == notebook.night_ink and notebook.left_text.label_settings.font_color == notebook.day_ink)
	# Tabs are listed by section id (Gravestones, Rubbings, Clues, Manuscripts, Radio Logs, Rise & Set);
	# Rise & Set is the top tab, so it is on the left whenever a later section is open.
	_expect("only the current section's tab and the ones above it are on the left", notebook.tabs._tabs.map(func(t): return t.on_left) == [true, false, false, false, false, true])
	for i in 2:
		notebook.flip_forward()
		await _wait(0.8)
	_expect("Gravestones has three spreads", notebook.get_section() == 0 and notebook.get_section_spread() == 2)
	notebook.flip_forward()
	await _wait(0.8)
	_expect("next from Gravestones 3/3 opens Rubbings", notebook.get_spread() == 4 and notebook.get_section() == 1)
	_expect("Rubbings pages use the normal paper", notebook.left_page.material == null and notebook.right_page.material == null and notebook.right_text.label_settings.font_color == notebook._normal_ink)
	_expect("visited tabs move to the left", notebook.tabs._tabs.map(func(t): return t.on_left) == [true, true, false, false, false, true])
	notebook.flip_backward()
	await _wait(0.8)
	_expect("back from Rubbings returns to Gravestones 3/3", notebook.get_spread() == 3)
	_expect("back in Gravestones the Day/Night pages return", notebook.left_page.material == notebook._day_material and notebook.right_page.material == notebook._night_material)
	notebook.jump_to_section(4)
	await _wait(0.8)
	_expect("Radio Logs tab jumps in one turn", notebook.get_spread() == 7 and notebook.get_section() == 4)
	notebook.flip_forward()
	await _wait(2.5)
	_expect("next from Radio Logs closes the notebook", not notebook_tool.is_open() and not notebook.visible)
	notebook_tool.open()
	await _wait(3.0)
	_expect("reopens on Rise & Set, not where it was closed", notebook.get_spread() == 0 and notebook.get_section() == notebook.RISE_AND_SET and notebook.tabs.visible)
	notebook.jump_to_section(0)
	await _wait(0.8)
	_expect("left corner shows on the first spread", notebook.left_corner.visible)
	notebook.flip_backward()
	await _wait(0.8)
	_expect("previous from Gravestones 1/3 goes back to Rise & Set", notebook_tool.is_open() and notebook.get_spread() == 0 and notebook.get_section() == notebook.RISE_AND_SET)
	notebook.flip_backward()
	await _wait(2.5)
	_expect("previous from Rise & Set closes the notebook", not notebook_tool.is_open())


func _check_gravestone_record(main: Node, notebook_tool: Node) -> void:
	var game_state := _autoload("GameState")
	var tomb = main.get_node("DayCemetery/BabyTomb")
	var rubbing_tool = main.get_node("RubbingTool")
	var image: Image = tomb._image
	var used := image.get_used_rect()
	var stone_pixel := Vector2(_opaque_pixel_near(image, used.get_center()))
	var on_stone: Vector2 = tomb.get_global_transform() * (stone_pixel / Vector2(image.get_size()) * tomb.size)
	var off_stone: Vector2 = tomb.get_global_transform() * Vector2(5, 5)
	_expect("a pixel near the stone's centre is part of the stone", image.get_pixelv(Vector2i(stone_pixel)).a > 0.5)

	_move_mouse(on_stone)
	await _wait(0.4)
	_expect("hovering the baby tomb highlights it", tomb._material.get_shader_parameter("highlight") > 0.9)
	_move_mouse(off_stone)
	await _wait(0.4)
	_expect("moving away removes the highlight", tomb._material.get_shader_parameter("highlight") < 0.01)

	# Leave the notebook on another section: recording should bring it back.
	notebook_tool.open()
	await _wait(3.0)
	notebook_tool.book.jump_to_section(2)
	await _wait(1.0)
	notebook_tool.close()
	await _wait(2.5)
	_expect("the notebook was left on the Clues section", notebook_tool.book.get_section() == 2)

	rubbing_tool.set_active(true)
	_click(on_stone)
	await _wait(0.1)
	_expect("clicks while rubbing do not record the tomb", not game_state.gravestones.has("baby_tomb"))
	rubbing_tool.set_active(false)
	_click(off_stone)
	await _wait(0.1)
	_expect("clicking beside the stone does not record it", not game_state.gravestones.has("baby_tomb"))
	_click(on_stone)
	_click(on_stone)
	await _wait(0.1)
	_expect("clicking the baby tomb records it once", game_state.gravestones.count("baby_tomb") == 1)
	_expect("recording does not open the notebook", not notebook_tool.is_open())
	var toast = main.get_node("Toast")
	_expect("recording shows the toast", toast.visible and toast.get_node("Panel/Label").text == "New gravestone recorded in the Notebook.")
	_expect("the toast never takes mouse input", toast.mouse_filter == Control.MOUSE_FILTER_IGNORE \
		and toast.find_children("*", "Control", true, false).all(func(c): return c.mouse_filter == Control.MOUSE_FILTER_IGNORE))
	await _wait(1.5)
	_expect("the toast stays up for about 2 seconds", toast.visible and toast.modulate.a > 0.99)
	await _wait(1.5)
	_expect("the toast fades out", not toast.visible)
	_click(on_stone)
	await _wait(0.2)
	_expect("clicking a recorded tomb shows no toast and no duplicate", not toast.visible and game_state.gravestones.count("baby_tomb") == 1)

	var notebook = notebook_tool.book
	notebook_tool.open()
	await _wait(3.0)
	_expect("the notebook opens on the newly recorded gravestone's page", notebook.get_spread() == notebook.get_gravestone_spread("baby_tomb"))
	var left_entry = notebook.left_page.get_node("Gravestone")
	_expect("baby tomb page is on the left page of Gravestones 1/3", notebook.get_section() == 0 and notebook.get_section_spread() == 0 \
		and left_entry.visible and left_entry.gravestone_id == "baby_tomb")
	_expect("its unknown placeholder is gone", notebook.left_page.get_node("Art")._kind == 0)
	var right_entry = notebook.right_page.get_node("Gravestone")
	_expect("the right page shows a blank unknown gravestone page", right_entry.visible and right_entry._unknown \
		and right_entry.sketch.texture == null and right_entry.description.text.is_empty() \
		and right_entry.identity_input.disabled)
	_expect("the recorded page is no longer unknown", not left_entry._unknown and not left_entry.identity_input.disabled)
	_expect("only the baby tomb is recorded", range(6).filter(func(i): return notebook.is_gravestone_collected(i)) == [0])
	_expect("the baby tomb page uses the Day ink", left_entry.description.get_theme_color("font_color") == notebook.day_ink)
	var sketch = left_entry.sketch.texture
	_expect("the sketch is cropped to the stone", sketch is AtlasTexture \
		and sketch.region == Rect2(sketch.atlas.get_image().get_used_rect()))

	# The report form offers the identities and causes collected so far.
	game_state.collect_term("infant")
	game_state.collect_term("natural")
	await _wait(0.1)
	_select_option(left_entry.identity_input, "infant")
	_select_option(left_entry.death_input, "natural")
	notebook.flip_forward()
	await _wait(0.9)
	notebook.flip_backward()
	await _wait(0.9)
	_expect("answers survive a page turn", _selected(left_entry.identity_input) == "infant" and _selected(left_entry.death_input) == "natural")
	notebook_tool.close()
	await _wait(0.15)
	# Closing folds the left page (the baby tomb's) over on the turning sheet.
	var sheet_entry = notebook.flip_sheet.get_node("Gravestone")
	_expect("the turning sheet carries the filled-in page", sheet_entry.visible and _selected(sheet_entry.identity_input) == "infant")
	await _wait(2.4)
	notebook_tool.open()
	await _wait(3.0)
	notebook.jump_to_section(0)  # it reopens on Rise & Set
	await _wait(1.0)
	_expect("answers survive closing the notebook", left_entry.visible and _selected(left_entry.identity_input) == "infant" and _selected(left_entry.death_input) == "natural")
	_expect("answers are kept in GameState", game_state.gravestone_reports.get("baby_tomb", {}) == {"identity": "infant", "death": "natural"})
	notebook_tool.close()
	await _wait(2.5)


## The tutorials gate input and record symbols by themselves; their own tests
## cover them. Mark them done and take the guide out for the free-play checks.
func _finish_tutorials(main: Node) -> void:
	var game_state := _autoload("GameState")
	for flag in ["cycle_hint_heard", "cycle_tutorial_completed", "investigation_tutorial_completed",
			"tutorial_night_heard", "tutorial_record_intro_heard"]:
		game_state.set(flag, true)
	var guide := main.get_node_or_null("SunMoonTutorial")
	if guide:
		guide.queue_free()
	await _wait(0.1)
	for symbol in main.find_children("*", "RubbingSymbol", true, false):
		symbol.collection_enabled = true


## The opaque pixel closest to `centre` (the stone art may be hollow in the middle).
func _opaque_pixel_near(image: Image, centre: Vector2i) -> Vector2i:
	for radius in range(0, 200, 2):
		for y in range(centre.y - radius, centre.y + radius + 1, 2):
			for x in range(centre.x - radius, centre.x + radius + 1, 2):
				if Rect2i(Vector2i.ZERO, image.get_size()).has_point(Vector2i(x, y)) and image.get_pixel(x, y).a > 0.9:
					return Vector2i(x, y)
	return centre


func _select_option(input: OptionButton, value: String) -> void:
	for i in input.item_count:
		if str(input.get_item_metadata(i)) == value:
			input.select(i)
			input.item_selected.emit(i)
			return


func _selected(input: OptionButton) -> String:
	return str(input.get_item_metadata(input.selected)) if input.selected >= 0 else ""


func _move_mouse(position: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = position
	motion.global_position = position
	root.push_input(motion, true)


func _click(position: Vector2) -> void:
	for pressed in [true, false]:
		var button := InputEventMouseButton.new()
		button.button_index = MOUSE_BUTTON_LEFT
		button.pressed = pressed
		button.position = position
		button.global_position = position
		root.push_input(button, true)


func _check_rubbing(main: Node) -> void:
	var rubbing_tool = main.get_node("RubbingTool")
	var flashlight_tool = main.get_node("FlashlightTool")
	var symbol: RubbingSymbol = main.get_node("DayCemetery/BabyTomb/MoonSymbol")
	var rect := symbol.get_global_rect()
	_scribble(symbol, rect)
	_expect("brushing does nothing without the rubbing tool", symbol.get_touched() == 0.0)
	flashlight_tool._set_state(flashlight_tool.State.ON)
	rubbing_tool.set_active(true)
	_expect("picking up the rubbing tool turns the flashlight off", flashlight_tool.state == flashlight_tool.State.OFF)
	rubbing_tool._brush(rect.position + Vector2(2, rect.size.y / 2), rect.position + Vector2(8, rect.size.y / 2))
	_expect("one short stroke only reveals part of the symbol", symbol.get_touched() > 0.0 and not symbol.is_rubbed)
	_scribble(symbol, rect)
	_expect("brushing over the symbol rubs it", symbol.is_rubbed)
	_expect("the rubbing is recorded", _autoload("GameState").rubbings.has("infant_moon_rubbing"))
	rubbing_tool.set_active(false)


func _check_rubbing_notebook(main: Node) -> void:
	var game_state := _autoload("GameState")
	var rubbing_tool = main.get_node("RubbingTool")
	var notebook_tool = main.get_node("NotebookTool")
	var notebook = notebook_tool.book
	var toast = main.get_node("Toast")
	var label: Label = toast.get_node("Panel/Label")
	var moon: RubbingSymbol = main.get_node("DayCemetery/BabyTomb/MoonSymbol")
	var human: RubbingSymbol = main.get_node("DayCemetery/BabyTomb/HumanSymbol")
	_expect("the moon rubbing comes from the baby tomb, with its texture", game_state.rubbing_records.get("infant_moon_rubbing", {}).get("gravestone") == "baby_tomb" \
		and game_state.get_rubbing_texture("infant_moon_rubbing") == moon.texture.resource_path)
	# The crescent is announced by the tutorial, so it gets no general toast.
	_expect("the crescent gets no general rubbing toast", not (toast.visible and label.text == "New rubbing recorded in the Notebook."))
	_expect("collecting does not decipher", not game_state.is_rubbing_deciphered("infant_moon_rubbing") and game_state.get_rubbing_meaning("infant_moon_rubbing") == "")
	_expect("collecting does not open the notebook", not notebook_tool.is_open())
	await _wait(3.0)
	rubbing_tool._on_symbol_rubbed("infant_moon_rubbing")  # the same symbol revealed again
	await _wait(0.1)
	_expect("a repeated reveal adds nothing and shows no toast", not toast.visible and game_state.rubbings.count("infant_moon_rubbing") == 1)

	rubbing_tool.set_active(true)
	_scribble(human, human.get_global_rect())
	rubbing_tool.set_active(false)
	await _wait(0.1)
	_expect("other rubbings show the toast", toast.visible and label.text == "New rubbing recorded in the Notebook.")
	_expect("rubbings keep their collection order", game_state.rubbings == ["infant_moon_rubbing", "infant_figure_rubbing"])
	_expect("the gravestone lists its rubbings in collection order", game_state.get_gravestone_rubbings("baby_tomb") == ["infant_moon_rubbing", "infant_figure_rubbing"])

	notebook_tool.open()
	await _wait(3.0)
	notebook.jump_to_section(1)
	await _wait(1.0)
	var left_list = notebook.left_page.get_node("Rubbings")
	var right_list = notebook.right_page.get_node("Rubbings")
	_expect("the Rubbings tab lists the rubbings in collection order", left_list._ids == ["infant_moon_rubbing", "infant_figure_rubbing"] and right_list._ids.is_empty())
	_expect("the Rubbings title placeholder gives way to the entries", notebook.left_page.get_node("Art")._kind == 0)
	_expect("rubbing entries are not drawn on other sections' pages", notebook.right_page.get_node("Gravestone").visible == false)

	_expect("deciphering an uncollected rubbing fails", not game_state.confirm_rubbing_meaning("no_such_rubbing", "anything"))
	_expect("a blank meaning is refused", not game_state.confirm_rubbing_meaning("infant_figure_rubbing", "  "))
	_expect("deciphering a collected rubbing succeeds", game_state.confirm_rubbing_meaning("infant_figure_rubbing", "Test meaning"))
	_expect("calling it again is safe", game_state.confirm_rubbing_meaning("infant_figure_rubbing", "Test meaning") \
		and game_state.rubbings == ["infant_moon_rubbing", "infant_figure_rubbing"])
	_expect("only the deciphered rubbing has a meaning", game_state.is_rubbing_deciphered("infant_figure_rubbing") \
		and game_state.get_rubbing_meaning("infant_figure_rubbing") == "Test meaning" and not game_state.is_rubbing_deciphered("infant_moon_rubbing"))

	# Fill past one spread (4 per page) to get a second Rubbings spread.
	var spreads_before: int = notebook._spread_count()
	for i in 7:
		game_state.record_rubbing("test_rubbing_%d" % i, "", "")
	_expect("the Rubbings section grows to a second spread", notebook.section_spreads[1] == 2 and notebook._spread_count() == spreads_before + 1)
	_expect("the open page refreshes with the new entries", left_list._ids.size() == 4 and right_list._ids.size() == 4 and right_list._ids[0] == "test_rubbing_2")
	notebook.flip_forward()
	await _wait(0.8)
	_expect("the rest continue on the next spread", notebook.get_section() == 1 and left_list._ids == ["test_rubbing_6"] and right_list._ids.is_empty())
	notebook.flip_forward()
	await _wait(0.8)
	_expect("after the rubbings comes Clues", notebook.get_section() == 2)
	notebook.jump_to_section(0)
	await _wait(1.0)
	var entry = notebook.left_page.get_node("Gravestone")
	_expect("the baby tomb page still has its answers", _selected(entry.identity_input) == "infant")
	notebook_tool.close()
	await _wait(2.5)
	notebook_tool.open()
	await _wait(3.0)
	notebook.jump_to_section(1)
	await _wait(1.0)
	_expect("entries survive closing and reopening", left_list._ids.slice(0, 2) == ["infant_moon_rubbing", "infant_figure_rubbing"])
	notebook_tool.close()
	await _wait(2.5)


func _check_rubbing_drag(main: Node) -> void:
	var game_state := _autoload("GameState")
	var notebook_tool = main.get_node("NotebookTool")
	var notebook = notebook_tool.book
	var drag = notebook_tool.rubbing_drag
	var toast = main.get_node("Toast")
	var label: Label = toast.get_node("Panel/Label")
	var moon = main.get_node("NightCemetery/Moon")
	var moon_centre: Vector2 = moon.get_global_transform() * (moon.size / 2.0)
	var tomb_point: Vector2 = main.get_node("DayCemetery/BabyTomb/HumanSymbol").get_global_rect().get_center()
	var outside_book := Vector2(60, 680)
	_expect("the Moon is a drop target named after its texture", moon.is_in_group("decipher_targets") \
		and moon.target_id == "moon" and moon.get_meaning() == "moon")
	_expect("the Moon only shows at night", not moon.is_visible_in_tree())
	_expect("the moon rubbing knows its target", game_state.get_rubbing_target("infant_moon_rubbing") == "moon")

	notebook_tool.open()
	await _wait(3.0)
	notebook.jump_to_section(1)
	await _wait(1.0)
	var list = notebook.left_page.get_node("Rubbings")
	var row_height: float = list.size.y / list.rows
	var row := func(i: int) -> Vector2: return list.get_global_transform() * Vector2(48, row_height * (i + 0.5))
	_move_mouse(row.call(0))
	await _wait(0.1)
	_expect("hovering an undeciphered rubbing shows the drag hint", drag._hint.visible)
	_move_mouse(row.call(1))
	await _wait(0.1)
	_expect("a deciphered rubbing can still be dragged (it may reveal a clue)", drag._hint.visible)

	# Released inside the book: cancelled.
	_press(row.call(0), true)
	_drag_mouse(row.call(0) + Vector2(20, 10))
	_expect("pressing and moving starts a drag", drag.is_dragging() and drag.rubbing_id == "infant_moon_rubbing" and not drag._hint.visible)
	_press(row.call(0) + Vector2(20, 10), false)
	await _wait(0.1)
	_expect("releasing inside the book cancels quietly", not drag.is_dragging() and notebook_tool.is_open() \
		and not toast.visible and not game_state.is_rubbing_deciphered("infant_moon_rubbing"))
	# Escape: cancelled.
	_press(row.call(0), true)
	_drag_mouse(row.call(0) + Vector2(20, 10))
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	root.push_input(escape, true)
	_press(row.call(0) + Vector2(20, 10), false)
	await _wait(0.1)
	_expect("Escape cancels the drag", not drag.is_dragging() and notebook_tool.is_open() and not toast.visible)

	# Day: drag out and drop on the baby tomb (not its object).
	_press(row.call(0), true)
	_drag_mouse(row.call(0) + Vector2(20, 10))
	_drag_mouse(outside_book)
	await _wait(2.5)
	_expect("leaving the book closes the notebook, the drag goes on", not notebook_tool.is_open() and drag.is_dragging())
	_drag_mouse(tomb_point)
	_press(tomb_point, false)
	await _wait(0.1)
	_expect("dropping on the wrong object fails", not drag.is_dragging() and label.text == "This symbol doesn't seem connected to that." \
		and toast.visible and not game_state.is_rubbing_deciphered("infant_moon_rubbing"))
	await _wait(3.0)

	# Night: another rubbing dropped on the Moon does not match.
	main.set_night()
	await _wait(1.0)
	notebook_tool.open()
	await _wait(3.0)
	_expect("the notebook reopens on Rise & Set", notebook.get_section() == notebook.RISE_AND_SET)
	notebook.jump_to_section(1)
	await _wait(1.0)
	_press(row.call(2), true)
	_drag_mouse(row.call(2) + Vector2(20, 10))
	_drag_mouse(moon_centre)
	await _wait(2.5)
	_press(moon_centre, false)
	await _wait(0.1)
	_expect("another rubbing dropped on the Moon fails", label.text == "This symbol doesn't seem connected to that." \
		and not game_state.is_rubbing_deciphered(list._ids[2]) and not game_state.is_rubbing_deciphered("infant_moon_rubbing"))
	await _wait(3.0)

	# Night: the crescent in the notebook is the sky icon. Its meaning comes from
	# the tutorial / Aurora; dragged onto the Moon it switches nothing and
	# deciphers nothing (only moon-onto-sun replaces the sky).
	notebook_tool.open()
	await _wait(3.0)
	notebook.jump_to_section(1)
	await _wait(1.0)
	_press(row.call(0), true)
	_drag_mouse(row.call(0) + Vector2(20, 10))
	_expect("the crescent drags as the sky icon", drag.is_dragging() and drag._cycle_drag and drag.rubbing_id == "infant_moon_rubbing")
	_drag_mouse(moon_centre)
	await _wait(2.5)
	_press(moon_centre, false)
	await _wait(0.1)
	_expect("the crescent dropped on the Moon does not decipher it", game_state.get_rubbing_meaning("infant_moon_rubbing") == "" \
		and label.text == "This symbol doesn't seem connected to that." and toast.visible)
	_expect("the notebook stays closed after the drop", not notebook_tool.is_open() and not drag.is_dragging())
	_expect("the drop adds no entries", game_state.rubbings.count("infant_moon_rubbing") == 1 and game_state.rubbings[0] == "infant_moon_rubbing")
	await _wait(3.0)

	notebook_tool.open()
	await _wait(3.0)
	notebook.jump_to_section(1)
	await _wait(1.0)
	_expect("the Rubbings tab still lists the crescent first", list._ids[0] == "infant_moon_rubbing")

	# Gravestone page -> its rubbing's entry.
	notebook.jump_to_section(0)
	await _wait(1.0)
	var slot: Control = notebook.left_page.get_node("Gravestone").rubbings_row.get_child(1)
	var slot_point: Vector2 = slot.get_global_transform() * (slot.size / 2.0)
	_click(slot_point)
	await _wait(1.0)
	_expect("clicking a rubbing on the gravestone page opens its Rubbings spread", notebook.get_section() == 1 and notebook.get_section_spread() == 0)
	notebook.show_rubbing("test_rubbing_6")
	await _wait(1.0)
	_expect("a rubbing on the second Rubbings spread is found", notebook.get_section() == 1 and notebook.get_section_spread() == 1 \
		and list._ids.has("test_rubbing_6"))
	notebook_tool.close()
	await _wait(2.5)
	main.set_day()
	await _wait(1.0)


## Press or release the left mouse button at `position`.
func _press(position: Vector2, pressed: bool) -> void:
	var button := InputEventMouseButton.new()
	button.button_index = MOUSE_BUTTON_LEFT
	button.pressed = pressed
	button.position = position
	button.global_position = position
	if pressed:
		button.button_mask = MOUSE_BUTTON_MASK_LEFT
	root.push_input(button, true)


## Move the mouse with the left button held.
func _drag_mouse(position: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = position
	motion.global_position = position
	motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	root.push_input(motion, true)


## Brush back and forth across `rect` a few times through the rubbing tool.
func _scribble(symbol: RubbingSymbol, rect: Rect2) -> void:
	var tool = symbol.get_tree().current_scene.get_node("RubbingTool")
	for row in 6:
		var y := rect.position.y + rect.size.y * (row + 0.5) / 6.0
		for _pass in 2:
			if tool.active:
				tool._brush(Vector2(rect.position.x - 10, y), Vector2(rect.end.x + 10, y))
