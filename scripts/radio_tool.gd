extends Control
## Temporary radio UI for the tutorial branch. Styling can be replaced independently.
const FONT := preload("res://assets/fonts/CormorantGaramond-Regular.ttf")
var model = preload("res://scripts/radio_model.gd").new()
var _button: TextureButton
var _overlay: Control
var _menu_host: VBoxContainer
var _panel: PanelContainer
var _layout: VBoxContainer
var _tomb := ""
var _question: Dictionary = {}
var _candidate_order: Array[int] = [0, 1, 2]
var _slot := ""
var _filter := 0
var _last_lines: Array = []
var _followups: Array = []
var _status := ""
var _feedback := ""
var _session := ""
var _session_number := 0
var _render_pending := false
var _tutorial_hint: Label
var tutorial_controls: Dictionary = {}
var _reply_box: Control
var _reply_playing := false
var _previous_layout: VBoxContainer
## Radio history context of the last question sent; follow-ups chosen from its
## reply are recorded under the same question and evidence.
var _exchange_context: Dictionary = {}

func _ready() -> void:
	z_index = 80
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_button = TextureButton.new()
	_button.name = "RadioButton"
	_button.texture_normal = preload("res://assets/Art/symbols/radio_tool.svg")
	_button.ignore_texture_size = true
	_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	add_child(_button)
	_button.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	_button.offset_left = -140
	_button.offset_right = -44
	_button.offset_top = 72
	_button.offset_bottom = 168
	_button.pressed.connect(open)
	_overlay = preload("res://scenes/dialogue_box.tscn").instantiate()
	_overlay.name = "RadioSelectionBox"
	add_child(_overlay)
	_panel = _overlay.panel
	_panel.offset_top = -450
	_menu_host = _overlay.get_node("Panel/Margin/VBox")
	GameState.notebook_changed.connect(_queue_render)
	resized.connect(_reposition_button)
	_reply_box = preload("res://scenes/dialogue_box.tscn").instantiate()
	_reply_box.name = "RadioDialogueBox"
	_reply_box.z_index = 10
	add_child(_reply_box)
	_reply_box.term_selected.connect(_collect_term)

func _exit_tree() -> void:
	GameState.radio_modal_open = false

func _reposition_button() -> void:
	if _button:
		_button.position = Vector2(size.x - 140, size.y / 2 + 72)

func _process(_delta: float) -> void:
	_button.disabled = not _can_open()
	_button.tooltip_text = "Contact Aurora" if _can_open() else "Read the manuscripts, then use the searchlight to inspect the marker 50 years ago."

func _unhandled_key_input(event: InputEvent) -> void:
	if is_open() and not _reply_playing and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

func is_open() -> bool:
	return _overlay != null and (_overlay.visible or _reply_playing)

func open() -> void:
	if is_open() or not _can_open():
		return
	GameState.radio_modal_open = true
	get_parent().get_node("FlashlightTool").turn_off()
	get_parent().get_node("RubbingTool").turn_off()
	get_parent().get_node("NotebookTool").rubbing_drag.cancel()
	get_parent().get_node("NotebookTool").close()
	_overlay.show_menu()
	_tomb = ""
	_status = ""
	_render()

func close() -> void:
	if _reply_playing: return
	_overlay.visible = false
	GameState.radio_modal_open = false
	_question = {}
	_followups = []
	_slot = ""

func _queue_render() -> void:
	if not is_open() or _reply_playing or _render_pending:
		return
	_render_pending = true
	_render.call_deferred()

func _label(text: String, font_size: int = 22) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size.x = 800
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(0.94, 0.92, 0.8))
	return label

func _action(text: String, callback: Callable, disabled: bool = false) -> Button:
	var button := Button.new()
	button.custom_minimum_size.x = maxf(110.0, FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x + 28.0) if text.length() <= 16 else 110.0
	var wrapped := ""
	var row := ""
	for word in text.split(" "):
		if not row.is_empty() and (row + " " + word).length() > 44:
			wrapped += row + "\n"
			row = word
		else: row += (" " if not row.is_empty() else "") + word
	wrapped += row
	button.custom_minimum_size.y = maxf(34, wrapped.split("\n").size() * 22 + 10)
	button.size = Vector2(360, button.custom_minimum_size.y)
	button.disabled = disabled
	var frame := StyleBoxFlat.new()
	frame.bg_color = Color(0.085, 0.085, 0.095)
	frame.border_color = Color(0.92, 0.89, 0.82, 0.45)
	frame.set_border_width_all(1)
	frame.set_content_margin_all(8)
	button.add_theme_stylebox_override("normal", frame)
	var hover := frame.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.16, 0.16, 0.18)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", hover)
	var title := _label(wrapped, 20)
	title.autowrap_mode = TextServer.AUTOWRAP_OFF
	title.clip_text = true
	button.tooltip_text = text
	button.add_child(title)
	title.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title.offset_left = 10
	title.offset_right = -10
	title.offset_top = 5
	title.offset_bottom = -5
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if disabled: title.modulate.a = 0.45
	button.pressed.connect(callback)
	return button

func _scroll_stack(parent: Control, minimum_height: float) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size.y = minimum_height
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(scroll)
	var stack := VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_theme_constant_override("separation", 7)
	scroll.add_child(stack)
	return stack

func _render() -> void:
	_render_pending = false
	if not is_open() or _reply_playing: return
	# Build the replacement off-tree, then swap once complete. Never show an empty dimmer.
	_previous_layout = _layout
	tutorial_controls.clear()
	_layout = VBoxContainer.new()
	_layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_layout.size = Vector2(_menu_host.size.x, 400)
	_layout.add_theme_constant_override("separation", 6)
	var header := HBoxContainer.new()
	_layout.add_child(header)
	var title := _label("FIELD RADIO / AURORA" if _tomb.is_empty() else GameState.get_gravestone_info(_tomb).get("title", "FIELD RADIO"), 24)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	if not _tomb.is_empty(): header.add_child(_action("Change stone", _change_tomb))
	header.add_child(_action("End call", close))
	_tutorial_hint = _label("", 18)
	_tutorial_hint.add_theme_color_override("font_color", Color(0.94, 0.8, 0.5))
	_tutorial_hint.visible = GameState.debug_overlay  # tutorial hints are on the F2 overlay
	_layout.add_child(_tutorial_hint)
	if _tomb.is_empty():
		_layout.add_child(_label("Which gravestone would you like to ask about?", 23))
		var list := _scroll_stack(_layout, 140)
		for id in GameState.gravestones:
			if not model.city_allows(id): continue
			var info := GameState.get_gravestone_info(id)
			var stone := _action(info.get("title", id), _start_call.bind(id))
			list.add_child(stone)
			if id == "baby_tomb": tutorial_controls["stone"] = stone
		if list.get_child_count() == 0: list.add_child(_label("No recorded gravestones in this city yet. Return to Day City to continue the small marker investigation." if not GameState.current_city_day else "Record a Day City gravestone in your notebook first."))
		_commit_layout()
		return
	var status := _label(_status if not _status.is_empty() else "Choose a question, or place evidence to reveal a hidden question.", 18)
	if _feedback == "hidden": status.add_theme_color_override("font_color", Color(1, 0.8, 0.35))
	_layout.add_child(status)
	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 22)
	_layout.add_child(columns)
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 1.8
	columns.add_child(left)
	if not _last_lines.is_empty():
		var replay := _action("Read last reply", _replay_reply)
		left.add_child(replay)
		tutorial_controls["replay"] = replay
	left.add_child(_label("Follow-up" if not _followups.is_empty() else "Questions", 20))
	var questions := _scroll_stack(left, 110)
	if not _followups.is_empty():
		for choice in _followups: questions.add_child(_action(choice["label"], _follow.bind(choice)))
	else:
		for question in model.questions_for(_tomb, _slot):
			if not _lesson_allows(question): continue
			var text: String = question["label"]
			if question["hidden"]: text = "◇ " + text
			if _question.get("id", "") == question["id"]: text = "→ " + text
			if not question["available"]:
				text += "  (record the human-shaped symbol first)" if question["target"] == "test_answer_baby_17" else "  (symbol link needed)"
			var question_button := _action(text, _select_question.bind(question), not question["available"])
			questions.add_child(question_button)
			tutorial_controls[question["target"]] = question_button
	var right := VBoxContainer.new()
	right.custom_minimum_size.x = 330
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(right)
	right.add_child(_label("Evidence · one record", 20))
	var slot_title: String = model.group_title(_slot)
	right.add_child(_action(slot_title + ("  ×" if not _slot.is_empty() else ""), _clear_slot, not _followups.is_empty()))
	var filter := OptionButton.new()
	for label in ["All types", "Symbol records", "Manuscripts", "Other clues"]: filter.add_item(label)
	filter.selected = _filter
	filter.disabled = not _followups.is_empty()
	filter.item_selected.connect(_set_filter)
	right.add_child(filter)
	var ids: Array = model.data["groups"].keys() if _question.is_empty() else _ordered_candidates()
	var visible_ids: Array = model.groups_for_filter(ids, _filter, _question.is_empty())
	var sketch_group: String = model.data["evidence_groups"].get("infant_graffiti", "")
	if _question.is_empty() and _lesson_question() == "test_answer_baby_21" and visible_ids.has(sketch_group):
		visible_ids.erase(sketch_group)
		visible_ids.push_front(sketch_group)
	right.add_child(_label("Collected records" if _question.is_empty() else "Three choices · %d shown" % visible_ids.size(), 17))
	var records := _scroll_stack(right, 170 if not _question.is_empty() else 115)
	for id in visible_ids:
		var unlocked: bool = model.group_unlocked(id)
		var group: Dictionary = model.data["groups"][id]
		var label: String = model.group_title(id) if unlocked else "Uncollected record"
		if unlocked and group["members"].size() > 1: label += "  (combined)"
		if id == _slot: label = "✓ " + label
		var record_button := _action(label, _set_slot.bind(id), not unlocked or not _followups.is_empty())
		if unlocked: record_button.tooltip_text = GameState.get_evidence(model.group_member(id)).get("body", "")
		records.add_child(record_button)
		if id == sketch_group: tutorial_controls["sketch"] = record_button
	tutorial_controls["evidence"] = records.get_parent()
	if visible_ids.is_empty(): records.add_child(_label("No unlocked records of this type.", 18))
	if not _question.is_empty():
		var actions := HBoxContainer.new()
		right.add_child(actions)
		var send_button := _action("Send evidence" if not _slot.is_empty() else "Ask", _send, not _followups.is_empty())
		actions.add_child(send_button)
		tutorial_controls["send"] = send_button
		actions.add_child(_action("Back", _clear_question))

	_commit_layout()

func _commit_layout() -> void:
	_menu_host.add_child(_layout)
	if is_instance_valid(_previous_layout):
		var focused := get_viewport().gui_get_focus_owner()
		if focused and _previous_layout.is_ancestor_of(focused): focused.release_focus()
		_menu_host.remove_child(_previous_layout)
		_previous_layout.queue_free()
	_previous_layout = null
	_overlay.show_menu()
	_overlay.set_feedback(_feedback)
	_panel.offset_top = -450

func _start_call(id: String) -> void:
	if _reply_playing: return
	_tomb = id
	_question = {}
	_slot = ""
	_filter = 0
	_last_lines = []
	_followups = []
	_feedback = ""
	_status = ""
	_session_number = int(model.progress.get("call_count", 0)) + 1
	model.progress["call_count"] = _session_number
	_session = "radio:" + id + ":" + str(_session_number)
	_exchange_context = {}
	_queue_render()

func _change_tomb() -> void:
	if _reply_playing: return
	_tomb = ""
	_question = {}
	_followups = []
	_queue_render()

func _lesson_question() -> String:
	var guide := get_parent().get_node_or_null("SunMoonTutorial")
	return guide.radio_lesson_question() if guide else ""


func _lesson_allows(question: Dictionary) -> bool:
	var target := _lesson_question()
	return target.is_empty() or question.get("target", "") == target


func _ordered_candidates() -> Array:
	var candidates := model.candidates(_question, _slot)
	var ordered: Array = []
	for index in _candidate_order:
		ordered.append(candidates[index])
	return ordered


func _select_question(question: Dictionary) -> void:
	if _reply_playing or not _lesson_allows(question): return
	_question = question
	_candidate_order.shuffle()
	if not model.candidates(question, _slot).has(_slot): _slot = ""
	_filter = 0
	_status = "Choose the best evidence that helps answer the question." if not _lesson_question().is_empty() else "Choose a record, or ask without evidence for Aurora's initial reply."
	_queue_render()

func _clear_question() -> void:
	if _reply_playing: return
	_question = {}
	_queue_render()

func _set_slot(id: String) -> void:
	if _reply_playing: return
	if not model.group_unlocked(id): return
	_slot = id
	_queue_render()

func _clear_slot() -> void:
	if _reply_playing: return
	_slot = ""
	if _question.get("hidden", false): _question = {}
	_status = "Evidence removed. Choose another record."
	_queue_render()

func _set_filter(index: int) -> void:
	if _reply_playing: return
	_filter = index
	_queue_render()

func _send() -> void:
	if _reply_playing or _question.is_empty() or not _lesson_allows(_question): return
	if not _lesson_question().is_empty():
		if _slot.is_empty():
			_status = "Choose the best evidence that helps answer the question."
			_queue_render()
			return
		if _lesson_question() == "test_answer_baby_8" and not model.progress.get("read_answers", []).has("baby_8_normal_9") and model.group_member(_slot) == "infant_graffiti":
			_status = "Choose evidence that identifies the icon. You can use the sketch to follow up later."
			_queue_render()
			return
	# A submission owns one immutable question/evidence pair. Neither menu
	# refreshes nor later selections may turn an ordinary reply into another one.
	var sent_question: Dictionary = _question.duplicate(true)
	var sent_slot := _slot
	var result: Dictionary = model.send(sent_question, sent_slot)
	if result.has("error"):
		_status = result["error"]
		_queue_render()
		return
	GameState.append_radio_line(_session, {"speaker": "#PLAYER#", "content": sent_question["label"]})
	if not sent_slot.is_empty(): GameState.append_radio_line(_session, {"speaker": "", "content": "Submitted record: " + str(model.data["groups"][sent_slot]["title"])})
	# The reply that plays now is one exchange of the radio history. model.submitted_id
	# is the record send() actually evaluated ("" without evidence).
	_exchange_context = {"gravestone_id": sent_question["tomb"], "question_id": sent_question["id"],
		"question_text": sent_question["label"], "evidence_id": model.submitted_id, "evidence_group": sent_slot,
		"evidence_name": model.group_title(sent_slot) if not sent_slot.is_empty() else "", "follow_up": ""}
	GameState.begin_radio_exchange(_session, _exchange_context)
	_question = {}
	_slot = ""
	_last_lines = []
	_show_result(result.duplicate(true))

func _follow(choice: Dictionary) -> void:
	if _reply_playing: return
	var result: Dictionary = model.choose(choice)
	if not result.has("error"):
		GameState.append_radio_line(_session, {"speaker": "#PLAYER#", "content": choice["label"]})
		# Follow-ups only come from the reply to the last question sent in this call.
		if _exchange_context.is_empty():
			push_warning("Radio follow-up without a question to record it under: " + str(choice["label"]))
		else:
			var context := _exchange_context.duplicate()
			context["follow_up"] = choice["label"]
			GameState.begin_radio_exchange(_session, context)
	_show_result(result)

func _show_result(result: Dictionary) -> void:
	if _reply_playing: return # Never splice another result into an active reply.
	if result.has("error"):
		_status = result["error"]
	else:
		if result.get("city", "") == "night": get_parent().set_night()
		_followups = result.get("choices", [])
		_feedback = result.get("feedback", "")
		_status = "A hidden connection surfaced." if _feedback == "hidden" else ("Evidence connected." if _feedback == "linked" else ("That record does not establish a connection. Try another." if _feedback == "unmatched" else "Reply received."))
		var lines: Array[Dictionary] = []
		for line in result.get("lines", []):
			_last_lines.append(line)
			lines.append(line.duplicate())
		if not lines.is_empty(): await _play_reply(lines, _session)
		else: GameState.end_radio_exchange(_session)  # nothing was said: nothing to record
		if result.get("hang_up", false):
			close()
			return
	_queue_render()

func _play_reply(lines: Array[Dictionary], log_session: String) -> void:
	_reply_playing = true
	_overlay.visible = false
	_reply_box.set_feedback(_feedback)
	var playback: Array[Dictionary] = []
	for line in lines: playback.append(line.duplicate(true))
	_reply_box.play(playback, log_session)
	await _reply_box.finished
	_reply_playing = false
	_overlay.visible = true
	_queue_render()

func _replay_reply() -> void:
	if _reply_playing or _last_lines.is_empty(): return
	var lines: Array[Dictionary] = []
	for line in _last_lines: lines.append(line.duplicate())
	# Re-reading does not duplicate logs or re-execute Ink grants.
	_play_reply(lines, "")


func _collect_term(meta: Variant) -> void:
	var id := str(meta)
	GameState.collect_term(id)
	_status = "Recorded: " + id
	_queue_render()


func _can_open() -> bool:
	if GameState.camera_modal_open: return false
	var guide := get_parent().get_node_or_null("SunMoonTutorial")
	if guide and guide.get("_speaking"): return false
	return GameState.cycle_tutorial_completed and ((GameState.tutorial_radio_intro_heard and GameState.evidence_ids.has("infant_graffiti")) or GameState.investigation_tutorial_completed or GameState.notebook_preview)
