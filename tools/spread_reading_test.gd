extends SceneTree
var failures := 0
func _initialize() -> void: _run.call_deferred()
func check(message: String, ok: bool) -> void:
	print(("PASS " if ok else "FAIL ") + message)
	if not ok: failures += 1
func wait(seconds: float) -> void: await create_timer(seconds).timeout
func shot(name: String) -> void:
	if not OS.get_cmdline_user_args().has("--shots"): return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://test_output/spread_reading"))
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://test_output/spread_reading/" + name + ".png"))
func _run() -> void:
	await process_frame
	var state := root.get_node("GameState")
	state.investigation_tutorial_completed = true
	state.cycle_tutorial_completed = true
	state.record_gravestone("baby_tomb")
	change_scene_to_file("res://scenes/main.tscn")
	await wait(1.0)
	var notebook = current_scene.get_node("NotebookTool")
	await notebook.open()
	notebook.book.jump_to_section(3)
	await wait(0.8)
	var book = notebook.book
	var items = book.left_page.get_node("ManuscriptItems")
	check("list cards fill page width without scroll container", items is Control and not items is ScrollContainer and items._stack.size.x >= 319)
	await shot("00_list")
	items.show_document("designer_manuscript")
	await wait(0.1)
	var teaching = book.left_page.get_node("SpreadReader")
	check("tutorial ripple restored", teaching.has_node("KeywordRipple") and teaching.body.text.contains("[wave"))
	check("manuscript keywords use dark red", teaching.body.text.contains("[color=#843c42]"))
	await shot("keyword_ripple")
	teaching.body.meta_clicked.emit("infant")
	await wait(0.1)
	check("ripple stops after keyword collected", not book.left_page.get_node("SpreadReader").has_node("KeywordRipple"))
	book._close_reading_document()
	items.show_document("designer_journal")
	await wait(0.1)
	var left = book.left_page.get_node("SpreadReader")
	var right = book.right_page.get_node("SpreadReader")
	check("journal occupies both pages", left.visible and right.visible and not left.body.text.is_empty() and not right.body.text.is_empty())
	check("neither page scrolls vertically", not left is ScrollContainer and not right is ScrollContainer and not left.body.scroll_active and not right.body.scroll_active)
	check("journal text fits both fixed pages", left.body.get_content_height() <= 300 and right.body.get_content_height() <= 300)
	check("legacy Ink clue string is present before student click", state.radio_progress.get("clue_words") is String)
	left.body.meta_clicked.emit("student")
	await wait(0.1)
	check("student safely collects in separate clue list", "student" in state.radio_progress.get("clue_terms", []) and state.radio_progress["clue_words"] is String)
	left.body.meta_clicked.emit("student")
	await wait(0.1)
	check("repeated click is idempotent", state.radio_progress["clue_terms"].count("student") == 1)
	await shot("01_journal_spread")
	var font: Font = book.left_text.label_settings.font
	var reader_script = load("res://scripts/spread_reader.gd")
	for entry in state.content_catalog()["evidence"].values():
		var raw: String = entry.get("interactive_body", entry["body"])
		var pages: Array = reader_script.paginate(raw, font, 320, 300)
		check("pagination preserves all text: " + entry["id"], "".join(pages) == raw)
		for page in pages:
			check("page fits: " + entry["id"], font.get_multiline_string_size(reader_script.plain(page), HORIZONTAL_ALIGNMENT_LEFT, 320, 22).y <= 300)
	# Long log spans several spreads; book corner advances local text rather than leaving it.
	book._close_reading_document()
	state.append_radio_line("long-test", {"speaker": "Aurora", "content": "A remembered detail in this civilization. ".repeat(120)})
	book.jump_to_section(4)
	await wait(0.8)
	check("long radio log paginates", book._reading_count > 2)
	var before: int = book._spread
	book.flip_forward()
	await wait(0.1)
	check("corner advances text while keeping log selected", book._spread == before and book._reading_offsets[book._reading_key] == 2)
	await shot("02_radio_log_spread")
	book.flip_backward()
	check("back returns to earlier text", book._reading_offsets[book._reading_key] == 0)
	print("SPREAD READING: " + ("ALL PASSED" if failures == 0 else str(failures) + " FAILED"))
	quit(0 if failures == 0 else 1)
