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
	while book._can_flip_forward():
		book.flip_forward()
		await _wait(0.8)
	book.flip_forward()  # past the last page: close the book
	await _wait(4.0)
	_expect("closing the book loads the main scene", current_scene != null and current_scene.name == "Main")
	_expect("main scene starts in daytime", current_scene != null and current_scene.get("is_day") == true)
