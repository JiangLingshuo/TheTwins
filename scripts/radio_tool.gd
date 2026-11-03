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
var _reply_box: Control
var _reply_playing := false
var _previous_layout: VBoxContainer

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
	_button.offset_left = -148
	_button.offset_right = -36
	_button.offset_top = 224
	_button.offset_bottom = 336
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
		_button.position = Vector2(size.x - 148, size.y / 2 + 224)

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
	if _tomb.is_empty():
		_layout.add_child(_label("Which gravestone would you like to ask about?", 23))
		var list := _scroll_stack(_layout, 140)
		for id in GameState.gravestones:
			if not model.city_allows(id): continue
			var info := GameState.get_gravestone_info(id)
			list.add_child(_action(info.get("title", id), _start_call.bind(id)))
		if list.get_child_count() == 0: list.add_child(_label("No recorded gravestones in this city yet. Return to Day City to continue the small marker investigation." if not GameState.current_city_day else "Record a Day City gravestone in your notebook first."))
		_commit_layout()
		return
	var status := _label(_status if not _status.is_empty() else "Choose a question, or place evidence to reveal a hidden question.", 18)
	if _feedback == "hidden": status.add_theme_color_override("font_color", Color(1, 0.8, 0.35))
	_layout.add_child(status)
	_tutorial_hint = _label("", 18)
	_tutorial_hint.add_theme_color_override("font_color", Color(0.94, 0.8, 0.5))
	_layout.add_child(_tutorial_hint)
	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 22)
	_layout.add_child(columns)
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 1.8
	columns.add_child(left)
	if not _last_lines.is_empty():
		left.add_child(_action("Read last reply", _replay_reply))
	left.add_child(_label("Follow-up" if not _followups.is_empty() else "Questions", 20))
	var questions := _scroll_stack(left, 110)
	if not _followups.is_empty():
		for choice in _followups: questions.add_child(_action(choice["label"], _follow.bind(choice)))
	else:
		for question in model.questions_for(_tomb, _slot):
			var text: String = question["label"]
			if question["hidden"]: text = "◇ " + text
			if _question.get("id", "") == question["id"]: text = "→ " + text
			if not question["available"]:
				text += "  (record the human-shaped symbol first)" if question["target"] == "test_answer_baby_17" else "  (symbol link needed)"
			questions.add_child(_action(text, _select_question.bind(question), not question["available"]))
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
	var ids: Array = model.data["groups"].keys() if _question.is_empty() else model.candidates(_question, _slot)
	var visible_ids: Array = model.groups_for_filter(ids, _filter, _question.is_empty())
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
	if visible_ids.is_empty(): records.add_child(_label("No unlocked records of this type.", 18))
	if not _question.is_empty():
		var actions := HBoxContainer.new()
		right.add_child(actions)
		actions.add_child(_action("Send evidence" if not _slot.is_empty() else "Ask", _send, not _followups.is_empty()))
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
	_queue_render()

func _change_tomb() -> void:
	if _reply_playing: return
	_tomb = ""
	_question = {}
	_followups = []
	_queue_render()

func _select_question(question: Dictionary) -> void:
	if _reply_playing: return
	_question = question
	if not model.candidates(question, _slot).has(_slot): _slot = ""
	_filter = 0
	_status = "Choose a record, or ask without evidence for Aurora's initial reply."
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
	if _reply_playing: return
	if _question.is_empty(): return
	var result: Dictionary = model.send(_question, _slot)
	if result.has("error"):
		_status = result["error"]
		_queue_render()
		return
	GameState.append_radio_line(_session, {"speaker": "#PLAYER#", "content": _question["label"]})
	if not _slot.is_empty(): GameState.append_radio_line(_session, {"speaker": "", "content": "Submitted record: " + str(model.data["groups"][_slot]["title"])})
	_last_lines = []
	_show_result(result)
	_question = {}

func _follow(choice: Dictionary) -> void:
	if _reply_playing: return
	var result: Dictionary = model.choose(choice)
	if not result.has("error"): GameState.append_radio_line(_session, {"speaker": "#PLAYER#", "content": choice["label"]})
	_show_result(result)

func _show_result(result: Dictionary) -> void:
	if result.has("error"):
		_status = result["error"]
	else:
		_followups = result.get("choices", [])
		_feedback = result.get("feedback", "")
		_status = "A hidden connection surfaced." if _feedback == "hidden" else ("Evidence connected." if _feedback == "linked" else ("That record does not establish a connection. Try another." if _feedback == "unmatched" else "Reply received."))
		var lines: Array[Dictionary] = []
		for line in result.get("lines", []):
			_last_lines.append(line)
			lines.append(line.duplicate())
		if not lines.is_empty(): await _play_reply(lines, _session)
	_queue_render()

func _play_reply(lines: Array[Dictionary], log_session: String) -> void:
	_reply_playing = true
	_overlay.visible = false
	_reply_box.set_feedback(_feedback)
	_reply_box.play(lines, log_session)
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
