extends Control
## Temporary radio UI for the tutorial branch. Styling can be replaced independently.
const FONT := preload("res://assets/fonts/CormorantGaramond-Regular.ttf")
var model = preload("res://scripts/radio_model.gd").new()
var _button: TextureButton
var _overlay: ColorRect
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
	_overlay = ColorRect.new()
	_overlay.name = "RadioOverlay"
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color(0.02, 0.04, 0.05, 0.8)
	_overlay.visible = false
	add_child(_overlay)
	_panel = PanelContainer.new()
	_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_panel.offset_left = 58
	_panel.offset_right = -58
	_panel.offset_top = 35
	_panel.offset_bottom = -35
	var paper := StyleBoxFlat.new()
	paper.bg_color = Color(0.075, 0.13, 0.11)
	paper.border_color = Color(0.65, 0.64, 0.46)
	paper.set_border_width_all(1)
	paper.set_content_margin_all(20)
	_panel.add_theme_stylebox_override("panel", paper)
	_overlay.add_child(_panel)
	GameState.notebook_changed.connect(_queue_render)
	resized.connect(_reposition_button)

func _exit_tree() -> void:
	GameState.radio_modal_open = false

func _reposition_button() -> void:
	if _button:
		_button.position = Vector2(size.x - 148, size.y / 2 + 224)

func _process(_delta: float) -> void:
	_button.disabled = not GameState.cycle_tutorial_completed
	_button.tooltip_text = "Contact Aurora" if GameState.cycle_tutorial_completed else "Finish the sun-and-moon tutorial first."

func _unhandled_key_input(event: InputEvent) -> void:
	if is_open() and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

func is_open() -> bool:
	return _overlay != null and _overlay.visible

func open() -> void:
	if is_open() or not GameState.cycle_tutorial_completed:
		return
	GameState.radio_modal_open = true
	get_parent().get_node("FlashlightTool").turn_off()
	get_parent().get_node("RubbingTool").turn_off()
	get_parent().get_node("NotebookTool").rubbing_drag.cancel()
	get_parent().get_node("NotebookTool").close()
	_overlay.visible = true
	_tomb = ""
	_status = ""
	_render()

func close() -> void:
	_overlay.visible = false
	GameState.radio_modal_open = false
	_question = {}
	_followups = []
	_slot = ""

func _queue_render() -> void:
	if not is_open() or _render_pending:
		return
	_render_pending = true
	_render.call_deferred()

func _label(text: String, font_size: int = 22) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(0.94, 0.92, 0.8))
	return label

func _action(text: String, callback: Callable, disabled: bool = false) -> Button:
	var button := Button.new()
	button.custom_minimum_size.x = 190
	button.custom_minimum_size.y = maxf(42, ceili(text.length() / 38.0) * 23 + 14)
	button.disabled = disabled
	var frame := StyleBoxFlat.new()
	frame.bg_color = Color(0.13, 0.21, 0.17)
	frame.border_color = Color(0.48, 0.56, 0.45)
	frame.set_border_width_all(1)
	frame.set_content_margin_all(8)
	button.add_theme_stylebox_override("normal", frame)
	var hover := frame.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.21, 0.3, 0.22)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", hover)
	var title := _label(text, 20)
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
	if not is_open(): return
	if _layout:
		_panel.remove_child(_layout)
		_layout.queue_free()
	_layout = VBoxContainer.new()
	_layout.add_theme_constant_override("separation", 10)
	_panel.add_child(_layout)
	var header := HBoxContainer.new()
	_layout.add_child(header)
	var title := _label("FIELD RADIO / AURORA", 28)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	header.add_child(_action("End call", close))
	if _tomb.is_empty():
		_layout.add_child(_label("Which gravestone would you like to ask about?", 26))
		var list := _scroll_stack(_layout, 250)
		for id in GameState.gravestones:
			var info := GameState.get_gravestone_info(id)
			list.add_child(_action(info.get("title", id), _start_call.bind(id)))
		if GameState.gravestones.is_empty(): list.add_child(_label("Record a gravestone in your notebook first."))
		return
	var subheader := HBoxContainer.new()
	_layout.add_child(subheader)
	var stone := _label(GameState.get_gravestone_info(_tomb).get("title", ""), 24)
	stone.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	subheader.add_child(stone)
	subheader.add_child(_action("Change gravestone", _change_tomb))
	var status := _label(_status if not _status.is_empty() else "Place a collected record in the slot to reveal evidence-dependent questions.", 18)
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
		var reply_stack := _scroll_stack(left, 145)
		var reply := RichTextLabel.new()
		reply.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		reply.fit_content = true
		reply.scroll_active = false
		reply.bbcode_enabled = true
		reply.add_theme_font_override("normal_font", FONT)
		reply.add_theme_font_size_override("normal_font_size", 22)
		reply.add_theme_color_override("default_color", Color(0.96, 0.93, 0.82))
		var content := ""
		for line in _last_lines:
			var speaker: String = GameState.fill_placeholders(line.get("speaker", ""))
			var text: String = GameState.fill_placeholders(line.get("content", ""))
			text = RegEx.create_from_string('<link="([^"]+)">([^<]+)</link>').sub(text, '[url=$1][u]$2[/u][/url]', true)
			content += (speaker + ": " if not speaker.is_empty() else "") + text + "\n\n"
		reply.text = content
		reply.meta_clicked.connect(_collect_term)
		reply_stack.add_child(reply)
	left.add_child(_label("Follow-up" if not _followups.is_empty() else "Questions", 23))
	var questions := _scroll_stack(left, 170)
	if not _followups.is_empty():
		for choice in _followups: questions.add_child(_action(choice["label"], _follow.bind(choice)))
	else:
		for question in model.questions_for(_tomb, _slot):
			var text: String = question["label"]
			if question["hidden"]: text = "◇ " + text
			if _question.get("id", "") == question["id"]: text = "→ " + text
			if not question["available"]: text += "  (symbol link needed)"
			questions.add_child(_action(text, _select_question.bind(question), not question["available"]))
	var right := VBoxContainer.new()
	right.custom_minimum_size.x = 350
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(right)
	right.add_child(_label("Evidence slot — one record", 23))
	var slot_title: String = model.data["groups"].get(_slot, {}).get("title", "No record selected")
	right.add_child(_action(slot_title + ("  ×" if not _slot.is_empty() else ""), _clear_slot, not _followups.is_empty()))
	var filter := OptionButton.new()
	for label in ["All types", "Symbol records", "Manuscripts", "Other clues"]: filter.add_item(label)
	filter.selected = _filter
	filter.disabled = not _followups.is_empty()
	filter.item_selected.connect(_set_filter)
	right.add_child(filter)
	var ids: Array = model.data["groups"].keys() if _question.is_empty() else model.candidates(_question, _slot)
	var visible_ids: Array = model.groups_for_filter(ids, _filter, _question.is_empty())
	right.add_child(_label("Collected records" if _question.is_empty() else "Three reference choices · %d shown" % visible_ids.size(), 17))
	var records := _scroll_stack(right, 140)
	for id in visible_ids:
		var unlocked: bool = model.group_unlocked(id)
		var group: Dictionary = model.data["groups"][id]
		var label: String = group["title"] if unlocked else "Uncollected record"
		if unlocked and group["members"].size() > 1: label += "  (combined)"
		if id == _slot: label = "✓ " + label
		var record_button := _action(label, _set_slot.bind(id), not unlocked or not _followups.is_empty())
		if unlocked: record_button.tooltip_text = GameState.get_evidence(model.group_member(id)).get("body", "")
		records.add_child(record_button)
	if visible_ids.is_empty(): records.add_child(_label("No unlocked records of this type.", 18))
	if not _question.is_empty():
		var caption := "Send with selected record" if not _slot.is_empty() else "Ask without evidence"
		right.add_child(_action(caption, _send, not _followups.is_empty()))
		right.add_child(_action("Back to all records", _clear_question))

func _start_call(id: String) -> void:
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
	_tomb = ""
	_question = {}
	_followups = []
	_queue_render()

func _select_question(question: Dictionary) -> void:
	_question = question
	if not model.candidates(question, _slot).has(_slot): _slot = ""
	_filter = 0
	_status = "Choose a record, or ask without evidence for Aurora's initial reply."
	_queue_render()

func _clear_question() -> void:
	_question = {}
	_queue_render()

func _set_slot(id: String) -> void:
	if not model.group_unlocked(id): return
	_slot = id
	_queue_render()

func _clear_slot() -> void:
	_slot = ""
	_queue_render()

func _set_filter(index: int) -> void:
	_filter = index
	_queue_render()

func _send() -> void:
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
	var result: Dictionary = model.choose(choice)
	if not result.has("error"): GameState.append_radio_line(_session, {"speaker": "#PLAYER#", "content": choice["label"]})
	_show_result(result)

func _show_result(result: Dictionary) -> void:
	if result.has("error"):
		_status = result["error"]
	else:
		_followups = result.get("choices", [])
		_feedback = result.get("feedback", "")
		_status = "A hidden connection surfaced." if _feedback == "hidden" else ("Connection made." if _feedback == "linked" else "Try another record when you are ready.")
		for line in result.get("lines", []):
			_last_lines.append(line)
			var log_line: Dictionary = line.duplicate()
			log_line["content"] = RegEx.create_from_string('<link="[^"]+">([^<]+)</link>').sub(log_line["content"], '$1', true)
			GameState.append_radio_line(_session, log_line)
	_queue_render()

func _collect_term(meta: Variant) -> void:
	var id := str(meta)
	var identities := {"scholar": "scholar", "tycoon": "tycoon", "infant": "infant", "night_mother": "night_mother", "night_father": "night_father", "aurora": "aurora", "funerary_artist": "funerary_artist"}
	var causes := {"natural": "natural", "unexplained death": "unexplained", "thirst": "hunger_and_thirst", "disappearance": "disappearance", "missed_sleeping_deadline": "missed_sleeping_deadline", "escape": "escape"}
	var pool := "identities" if identities.has(id) else ("causes" if causes.has(id) else "clue_words")
	var value: String = identities.get(id, causes.get(id, id))
	var values: Array = model.progress.get(pool, [])
	if not values.has(value): values.append(value)
	model.progress[pool] = values
	_status = "Recorded: " + id
	_queue_render()
