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
	check("journal keeps student as plain text", left.body.text.contains("student") and not left.body.text.contains("[url") and not right.body.text.contains("[url"))
	await shot("01_journal_spread")
	book._close_reading_document()
	state.deliver_day_manuscripts()
	check("medical record excluded from early Day delivery", not state.evidence_ids.has("infant_medical_record"))
	state.record_gravestone("father_tomb")
	check("one parent alone does not unlock medical record", not state.evidence_ids.has("infant_medical_record"))
	state.record_gravestone("mother_tomb")
	check("medical record delivered after both parents", state.evidence_ids.has("infant_medical_record"))
	state.collect_term("unexplained death")
	state.set_report_choice("baby_tomb", "death", "unexplained")
	check("medical record alone does not unlock cause", "euthanasia" not in state.report_options("causes", "baby_tomb"))
	var manuscript_ids: Array = state.notebook_entries(3).map(func(entry: Dictionary) -> String: return entry["id"])
	var medical_index := manuscript_ids.find("infant_medical_record")
	book._turn_forward(book._section_start(3) + medical_index / 8)
	await wait(0.8)
	var manuscript_page: Control = book.left_page if medical_index % 8 < 4 else book.right_page
	manuscript_page.get_node("ManuscriptItems").show_document("infant_medical_record")
	await wait(0.1)
	var body = left.body if left.body.text.contains("[url=euthanasia]") else right.body
	check("euthanasia is clickable in the medical record", body.text.contains("[url=euthanasia]"))
	body.meta_clicked.emit("euthanasia")
	await wait(0.1)
	check("new cause unlocks without overwriting the existing report", "euthanasia" in state.report_options("causes", "baby_tomb") and state.gravestone_reports["baby_tomb"]["death"] == "unexplained")
	check("infant report can be revised", state.set_report_choice("baby_tomb", "death", "euthanasia"))
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
	state.begin_radio_exchange("radio:long-test", {"gravestone_id": "baby_tomb", "question_id": "baby:long", "question_text": "A long question?", "evidence_id": "", "follow_up": ""})
	state.append_radio_line("radio:long-test", {"speaker": "Aurora", "content": "A remembered detail in this civilization. ".repeat(120)})
	state.end_radio_exchange("radio:long-test")
	book.jump_to_section(4)
	await wait(0.8)
	book._open_radio_entry("baby_tomb")
	book._open_radio_entry("baby:long")
	await wait(0.2)
	check("long radio log paginates", book._reading_count > 2)
	var before: int = book._spread
	book.flip_forward()
	await wait(0.8)  # the text turns with a page-turn animation
	check("corner advances text while keeping log selected", book._spread == before and book._reading_offsets[book._reading_key] == 2)
	await shot("02_radio_log_spread")
	book.flip_backward()
	await wait(0.8)
	check("back returns to earlier text", book._reading_offsets[book._reading_key] == 0)
	print("SPREAD READING: " + ("ALL PASSED" if failures == 0 else str(failures) + " FAILED"))
	quit(0 if failures == 0 else 1)
