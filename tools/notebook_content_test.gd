extends SceneTree

var failures := 0

func _initialize() -> void:
	_run.call_deferred()

func check(label: String, passed: bool) -> void:
	print(("PASS " if passed else "FAIL ") + label)
	if not passed:
		failures += 1

func _run() -> void:
	await process_frame
	var state := root.get_node("GameState")
	check("catalog has seven descriptions", state.content_catalog()["gravestones"].size() == 7)
	check("catalog has 65 evidence records", state.content_catalog()["evidence"].size() == 65)
	check("no spoilers on startup", state.evidence_ids.is_empty() and state.radio_logs.is_empty())
	state.record_gravestone("baby_tomb")
	check("baby description populated", not state.get_gravestone_info("baby_tomb")["description"].is_empty())
	check("baby manuscripts delivered only", state.notebook_entries(3).size() == 2 and not state.evidence_ids.has("girl_diary"))
	check("duplicate grant ignored", not state.record_evidence("designer_manuscript"))
	state.record_evidence("infant_graffiti")
	check("grave clue routed to its stone", state.get_gravestone_info("baby_tomb")["clues"].size() == 1)
	check("grave clue absent from environment page", state.notebook_entries(2).is_empty())
	state.record_evidence("giant_footprint")
	check("environment clue on its own page", state.notebook_entries(2).size() == 1)
	state.record_rubbing("infant_moon_rubbing", "baby_tomb")
	check("rubbing still undeciphered", not state.is_rubbing_deciphered("infant_moon_rubbing"))
	state.confirm_rubbing_meaning("infant_moon_rubbing", "Natural death")
	check("existing rubbing state preserved", state.is_rubbing_deciphered("infant_moon_rubbing"))
	state.append_radio_line("test", {"speaker": "Aurora", "content": "A played answer."})
	check("only played radio lines logged", state.radio_logs.size() == 1 and state.radio_logs[0]["body"] == "Aurora: A played answer.")
	var book = load("res://scenes/book.tscn").instantiate()
	book.use_sections = true
	root.add_child(book)
	await process_frame
	book._opened = true
	book._busy = false
	book.visible = true
	book._fill(book.left_text, book.left_number, 0)
	check("notebook description uses catalog", book.left_page.get_node("Gravestone").description.text == state.get_gravestone_info("baby_tomb")["description"])
	for section in [2, 4]:
		var page_index: int = book._section_start(section) * 2
		book._fill(book.left_text, book.left_number, page_index)
		var reader = book.left_page.get_node("Records")
		check("section %d shows full text reader" % section, reader.visible and not reader.get_node("Body").text.is_empty())
	book._fill(book.left_text, book.left_number, book._section_start(3) * 2)
	var items = book.left_page.get_node("ManuscriptItems")
	check("manuscript list shows received document cards", items.visible and items._entries.size() == 2 and items._selected.is_empty())
	items._stack.get_node("designer_manuscript").pressed.emit()
	check("click opens selected full manuscript", items._selected == "designer_manuscript" and items._stack.get_node("BackToManuscripts") != null)
	items._stack.get_node("BackToManuscripts").pressed.emit()
	check("back restores manuscript list", items._selected.is_empty() and items._stack.has_node("designer_journal"))
	check("final grave not exposed", book.section_spreads[0] == 3)
	state.preview_notebook_content()
	await process_frame
	check("preview exposes all seven stones", state.gravestones.size() == 7 and book.section_spreads[0] == 4)
	check("preview includes all manuscripts", state.notebook_entries(3).size() == 11)
	check("manuscript cards paginate eight per spread", book.section_spreads[3] == 2)
	check("preview includes authored radio drafts", state.radio_logs.size() > 70)
	book.queue_free()
	await process_frame
	print("NOTEBOOK CONTENT TEST: " + ("ALL PASSED" if failures == 0 else "%d FAILED" % failures))
	quit(0 if failures == 0 else 1)
