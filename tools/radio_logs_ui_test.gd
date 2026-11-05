extends SceneTree
## Notebook Radio Logs (R2): gravestones -> questions -> dialogue records, and
## Other Transmissions, read from the radio history in GameState.
## Run: godot --headless --path . -s tools/radio_logs_ui_test.gd
## Screenshots: godot --path . --audio-driver Dummy --resolution 1280x720 -s tools/radio_logs_ui_test.gd -- --shots
var failures := 0
var state: Node
var book: Control
var notebook: Control

func _initialize() -> void: _run.call_deferred()

func check(message: String, ok: bool) -> void:
	print(("PASS " if ok else "FAIL ") + message)
	if not ok: failures += 1

func wait(seconds: float) -> void: await create_timer(seconds).timeout

func shot(name: String) -> void:
	if not OS.get_cmdline_user_args().has("--shots"): return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://test_output/radio_logs"))
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://test_output/radio_logs/" + name + ".png"))

## Record one exchange through the R1 API, as the radio / dialogue box do.
func hear(question: Dictionary, lines: Array, at: float) -> void:
	var session := "radio:test" if not question.is_empty() else "tutorial_test"
	state.play_time = at
	state.begin_radio_exchange(session, question, "" if not question.is_empty() else "Tutorial Test")
	for line in lines: state.append_radio_line(session, line)
	state.end_radio_exchange(session)

func q(stone: String, id: String, text: String, evidence: String = "", evidence_name: String = "") -> Dictionary:
	return {"gravestone_id": stone, "question_id": id, "question_text": text, "evidence_id": evidence,
		"evidence_group": evidence, "evidence_name": evidence_name, "follow_up": ""}

func items(left: bool = true) -> Control:
	return (book.left_page if left else book.right_page).get_node("ManuscriptItems")

func reader(left: bool = true) -> Control:
	return (book.left_page if left else book.right_page).get_node("SpreadReader")

func card_ids(list: Control) -> Array:
	return list._entries.map(func(e: Dictionary) -> String: return e["id"])

func stack_text(list: Control) -> String:
	var text := ""
	for child in list._stack.get_children():
		if child is Label or child is Button: text += str(child.text) + "\n"
	return text

func reader_labels() -> String:
	var text := ""
	for child in reader().get_children():
		if child is Label or child is Button: text += str(child.text) + "\n"
	return text

func click_card(list: Control, id: String) -> void:
	list.show_document(id)
	await wait(0.15)

func press_back_in_reader() -> void:
	for child in reader().get_children():
		if child is Button and str(child.text).begins_with("←"):
			child.pressed.emit()
	await wait(0.15)

func fits(list: Control) -> bool:
	return list._stack.get_combined_minimum_size().y <= list.size.y

func reader_text() -> String:
	return reader().body.get_parsed_text() + "\n" + reader(false).body.get_parsed_text()

func _run() -> void:
	await process_frame
	state = root.get_node("GameState")
	state.player_name = "Mira"
	state.investigation_tutorial_completed = true
	state.cycle_tutorial_completed = true
	state.record_gravestone("baby_tomb")
	state.record_gravestone("scholar_tomb")
	change_scene_to_file("res://scenes/main.tscn")
	await wait(1.0)
	notebook = current_scene.get_node("NotebookTool")
	book = notebook.book
	await notebook.open()
	await wait(0.5)
	book.jump_to_section(4)
	await wait(0.9)

	# Empty history.
	check("Radio Logs is one spread", book.section_spreads[4] == 1 and book.get_section() == 4)
	check("empty history shows a note, no reader", items().visible and not reader().visible \
		and stack_text(items()).contains("No radio transmissions recorded yet.") and items()._entries.is_empty())
	await shot("00_empty")

	# History arrives while the notebook shows Radio Logs (live refresh).
	var moon := q("baby_tomb", "baby:test_answer_baby_8", "How do we interpret the icon on the tombstone?")
	var moon_ev := q("baby_tomb", "baby:test_answer_baby_8", moon["question_text"], "infant_moon_rubbing", "Crescent rubbing")
	var hint_lines := [{"speaker": "Aurora", "content": "The outline is a starting point."}]
	hear(moon, hint_lines, 100.0)
	hear(moon_ev, [{"speaker": "Aurora", "content": "Yes, it does look like a moon."}, {"speaker": "", "content": "(She pauses.)"}, {"speaker": "#PLAYER#", "content": "I see."}], 200.0)
	for i in 10:
		hear(q("scholar_tomb", "scholar:test_q_%d" % i, "Scholar question number %d, which is long enough to wrap onto a second line of the card?" % i),
			[{"speaker": "Aurora", "content": "Answer %d." % i}], 300.0 + i)
	hear({}, [{"speaker": "Aurora", "content": "Glad you're safe!"}, {"speaker": "#PLAYER#", "content": "Me too."}], 50.0)
	await wait(0.2)
	check("gravestones with history, then Other Transmissions", card_ids(items()) == ["baby_tomb", "scholar_tomb", "__other"])
	check("gravestone cards use the gravestone titles", items()._entries[0]["title"] == state.get_gravestone_info("baby_tomb")["title"])
	await shot("01_gravestones")

	# Gravestone -> questions.
	await click_card(items(), "baby_tomb")
	check("a gravestone shows its questions", items().visible and card_ids(items()) == ["baby:test_answer_baby_8"])
	check("question list has the gravestone name and a back button", items()._stack.has_node("BackButton") \
		and stack_text(items()).contains(state.get_gravestone_info("baby_tomb")["title"]))
	await shot("02_questions")

	# Question -> dialogue records.
	await click_card(items(), "baby:test_answer_baby_8")
	var text := reader_text()
	check("a question opens its dialogue records", reader().visible and not items().visible)
	check("title and back button on the left page", reader_labels().contains(moon["question_text"]) and reader_labels().contains("← Questions"))
	check("record without evidence shows only its time", text.contains("00:01:40\n") and not text.contains("00:01:40 ·"))
	check("record with evidence shows it beside the time", text.contains("00:03:20 · Submitted: Crescent rubbing"))
	check("speakers and lines in order, player name resolved", text.contains("Aurora: Yes, it does look like a moon.\n(She pauses.)\nMira: I see."))
	check("speaker names are styled, marks removed", reader().body.text.contains("[color=#843c42]Aurora:[/color]") \
		and not reader().body.text.contains("⁠") and not reader().body.text.contains("⁣"))
	await shot("03_dialogue")

	# Hearing the same dialogue again: timestamp moves, no duplicate, order by last heard.
	hear(moon, hint_lines, 400.0)
	await wait(0.2)
	text = reader_text()
	check("repeat updates the shown time without duplicating", text.contains("00:06:40") and not text.contains("00:01:40") \
		and text.count("The outline is a starting point.") == 1)
	check("records ordered by last heard", text.find("00:03:20") < text.find("00:06:40"))
	check("reader stays on the question after a refresh", reader().visible and book._radio_question == "baby:test_answer_baby_8")

	# Back: dialogue -> questions -> gravestones.
	await press_back_in_reader()
	check("back returns to the question list", items().visible and card_ids(items()) == ["baby:test_answer_baby_8"])
	items()._stack.get_node("BackButton").pressed.emit()
	await wait(0.15)
	check("back returns to the gravestone list", items().visible and card_ids(items()).has("scholar_tomb"))

	# A long question list continues on the next spread, turned with the corner.
	await click_card(items(), "scholar_tomb")
	check("left page: heading + 3 cards, right page: 4 cards", items().visible and items()._entries.size() == 3 and items(false)._entries.size() == 4)
	check("cards stay inside the page", fits(items()) and fits(items(false)))
	await shot("04_long_question_list")
	var spread: int = book.get_spread()
	book.flip_forward()
	await wait(0.1)
	var sheet_list: Control = book.flip_sheet.get_node_or_null("ManuscriptItems")
	check("the turning sheet carries the list inside the sheet", book.flip_sheet.visible and sheet_list != null and sheet_list.visible \
		and sheet_list.position.x >= 0 and sheet_list.position.x + sheet_list.size.x <= book.PAGE_SIZE.x)
	await wait(0.8)
	check("corner turns the list, not the section", book.get_spread() == spread and card_ids(items()) == ["scholar:test_q_7", "scholar:test_q_8", "scholar:test_q_9"])
	book.flip_backward()
	await wait(0.9)
	check("corner turns back to the first list page", card_ids(items()).size() == 3 and card_ids(items())[0] == "scholar:test_q_0")

	# Long dialogue paginates within the page and turns with the corner.
	var long_lines: Array = []
	for i in 30: long_lines.append({"speaker": "Aurora" if i % 2 == 0 else "#PLAYER#", "content": "A remembered detail number %d in this civilization, told slowly." % i})
	hear(q("scholar_tomb", "scholar:test_q_0", "Scholar question number 0, which is long enough to wrap onto a second line of the card?", "profession_record", "Occupation record"), long_lines, 900.0)
	await wait(0.2)
	await click_card(items(), "scholar:test_q_0")
	check("long dialogue spans several pages", book._reading_count > 2)
	check("dialogue text stays inside the page", reader().body.get_content_height() <= reader().body.size.y \
		and reader(false).body.get_content_height() <= reader(false).body.size.y)
	await shot("05_long_dialogue")
	book.flip_forward()
	await wait(0.9)
	check("corner turns the dialogue", book._reading_offsets[book._reading_key] == 2 and reader().visible)
	await press_back_in_reader()
	items()._stack.get_node("BackButton").pressed.emit()
	await wait(0.15)

	# Other Transmissions: its dialogue directly, not grouped by gravestone.
	await click_card(items(), "__other")
	text = reader_text()
	check("Other Transmissions shows its records", reader().visible and text.contains("00:00:50 · Tutorial Test") \
		and text.contains("Aurora: Glad you're safe!\nMira: Me too."))
	check("Other Transmissions holds no question dialogue", not text.contains("Answer 1."))
	await shot("06_other_transmissions")

	# Switching tabs, closing the notebook and Day/Night keep the place.
	book.jump_to_section(3)
	await wait(0.9)
	check("other sections are unaffected", book.get_section() == 3 and not reader().visible and items().visible \
		and items()._back_text.is_empty() and items()._heading.is_empty())
	book.jump_to_section(4)
	await wait(0.9)
	check("returning to Radio Logs restores the reading", reader().visible and reader_text().contains("Tutorial Test"))
	notebook.close()
	await wait(2.5)
	current_scene.set_night()
	await wait(1.0)
	await notebook.open()
	await wait(0.8)
	if book.get_section() != 4:
		book.jump_to_section(4)
		await wait(0.9)
	check("after closing and Day/Night the history and place remain", reader().visible and reader_text().contains("Glad you're safe!"))
	await press_back_in_reader()
	check("history still lists every gravestone", card_ids(items()) == ["baby_tomb", "scholar_tomb", "__other"])

	print("RADIO LOGS UI: " + ("ALL PASSED" if failures == 0 else "%d FAILED" % failures))
	quit(0 if failures == 0 else 1)
