extends SceneTree
## Smoke test: loads every scene and dialogue, then plays through the notebook flow.
## Runs without a window, so it works with nobody at the computer.
## Prints PASS / FAIL per check and exits with 1 if anything failed.
## Run it with: powershell -File tools/run.ps1 smoke

const TIMEOUT_SECONDS := 90.0

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
	await _wait(1.5)
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
	start._start_game()
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
	_expect("notebook keeps the pages from the start screen", notebook.pages.size() > 3 and notebook.pages[3] == "carried over")
	_expect("opening the notebook turns the flashlight off", flashlight_tool.state == flashlight_tool.State.OFF)
	notebook_tool.close()
	await _wait(2.5)
	_expect("notebook closes back into its button", not notebook.visible and not notebook_tool.is_open())
	notebook_tool.open()
	await _wait(3.0)
	_expect("notebook reopens on the same page", notebook.is_open() and notebook.get_spread() == _autoload("GameState").notebook_spread)
	notebook_tool.close()
	await _wait(2.5)
	await _check_notebook_sections(notebook_tool)
	await _check_rubbing(main)


func _check_notebook_sections(notebook_tool: Node) -> void:
	var notebook = notebook_tool.book
	notebook_tool.open()
	await _wait(3.0)
	_expect("notebook has 7 spreads in 5 sections", notebook._spread_count() == 7 and notebook.tabs.get_child_count() == 5)
	notebook.jump_to_section(0)
	notebook.jump_to_section(3)  # ignored: a page is already turning
	await _wait(1.0)
	_expect("tab jumps to the first spread of its section", notebook.get_spread() == 0 and notebook.get_section() == 0)
	_expect("all six gravestone slots start uncollected", notebook.gravestone_collected == [false, false, false, false, false, false])
	_expect("gravestone pages show the placeholder", notebook.left_page.get_node("Art")._kind == preload("res://scripts/notebook_page_art.gd").Kind.GRAVESTONE)
	_expect("only the current section's tab is on the left", notebook.tabs._tabs.map(func(t): return t.on_left) == [true, false, false, false, false])
	for i in 2:
		notebook.flip_forward()
		await _wait(0.8)
	_expect("Gravestones has three spreads", notebook.get_section() == 0 and notebook.get_section_spread() == 2)
	notebook.flip_forward()
	await _wait(0.8)
	_expect("next from Gravestones 3/3 opens Rubbings", notebook.get_spread() == 3 and notebook.get_section() == 1)
	_expect("visited tabs move to the left", notebook.tabs._tabs.map(func(t): return t.on_left) == [true, true, false, false, false])
	notebook.flip_backward()
	await _wait(0.8)
	_expect("back from Rubbings returns to Gravestones 3/3", notebook.get_spread() == 2)
	notebook.jump_to_section(4)
	await _wait(0.8)
	_expect("Radio Logs tab jumps in one turn", notebook.get_spread() == 6 and notebook.get_section() == 4)
	notebook.flip_forward()
	await _wait(2.5)
	_expect("next from Radio Logs closes the notebook", not notebook_tool.is_open() and not notebook.visible)
	notebook_tool.open()
	await _wait(3.0)
	_expect("reopens on Radio Logs", notebook.get_spread() == 6 and notebook.tabs.visible)
	notebook.jump_to_section(0)
	await _wait(0.8)
	_expect("left corner shows on the first spread", notebook.left_corner.visible)
	notebook.flip_backward()
	await _wait(2.5)
	_expect("previous from Gravestones 1/3 closes the notebook", not notebook_tool.is_open())


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


## Brush back and forth across `rect` a few times through the rubbing tool.
func _scribble(symbol: RubbingSymbol, rect: Rect2) -> void:
	var tool = symbol.get_tree().current_scene.get_node("RubbingTool")
	for row in 6:
		var y := rect.position.y + rect.size.y * (row + 0.5) / 6.0
		for _pass in 2:
			if tool.active:
				tool._brush(Vector2(rect.position.x - 10, y), Vector2(rect.end.x + 10, y))
