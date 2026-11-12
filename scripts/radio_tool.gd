extends Control
## Temporary radio UI for the tutorial branch. Styling can be replaced independently.
const FONT := preload("res://assets/fonts/IMFellEnglish-Regular.ttf")
var model = preload("res://scripts/radio_model.gd").new()
const HANGUP_SOUND := preload("res://assets/audio/无线电挂断.wav")
## Aurora's goodbyes when the player ends a call. Daylight Aurora is warm and
## polite; Night Aurora is brief, and only rarely shows any concern.
const FAREWELLS_DAY: Array[String] = [
	"Have a nice day ahead. I hope your investigation goes well.",
	"The Twins can be windy at this time of year. Please take good care of yourself.",
	"Thank you for the update. Be careful out there, and call whenever you like.",
	"Don't forget to rest and drink some water. Talk to you soon.",
	"I hope the light stays kind to you today. Until next time.",
	"Please look after yourself, #PLAYER#. I'll be here whenever you need me.",
]
const FAREWELLS_NIGHT: Array[String] = [
	"Bye. Talk to you later.",
	"I still have work. I have to drop.",
	"That's all for now. Later.",
	"Got it. Call me when you have more.",
	"Mm. Bye.",
]
const FAREWELLS_NIGHT_CARE: Array[String] = [
	"Watch your step down there.",
	"Mind yourself. Don't wander off the path.",
]
## Share of Night farewells that show concern.
const NIGHT_CARE_CHANCE := 0.15
var _hangup: AudioStreamPlayer
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
var _direct_only := false
var _question_states: Dictionary = {}
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
var _tutorial_paused := false
var _heard_reply := false
var _previous_layout: VBoxContainer
## Radio history context of the last question sent; follow-ups chosen from its
## reply are recorded under the same question and evidence.
var _exchange_context: Dictionary = {}

## First-step questions Aurora asks for the player (assets/dialogue/radio_intro_calls.json).
## When one becomes available and its evidence is owned, the radio opens with the
## question and evidence already filled in; once answered it leaves the question list.
const INTRO_PATH := "res://assets/dialogue/radio_intro_calls.json"
## Seconds an intro must stay ready before the radio pops up (lets the "Recorded" toast show).
const INTRO_DELAY := 0.9
var _intro_calls: Array = []
var _intro_current: Dictionary = {}
var _intro_dismissed: Array = []
var _intro_ready_for := -1.0
var _intro_poll := 0.0
var _intro_dirty := true

func _ready() -> void:
	z_index = 80
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_button = TextureButton.new()
	_button.name = "RadioButton"
	_button.texture_normal = preload("res://assets/Art/ui/radio.png")
	_button.ignore_texture_size = true
	_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	SoftIcon.apply(_button)
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
	_fit_selection_panel()
	_menu_host = _overlay.get_node("Panel/Margin/VBox")
	GameState.notebook_changed.connect(_queue_render)
	GameState.story_mode_changed.connect(func(_enabled: bool) -> void: _queue_render())
	resized.connect(_reposition_button)
	_reply_box = preload("res://scenes/dialogue_box.tscn").instantiate()
	_reply_box.name = "RadioDialogueBox"
	_reply_box.z_index = 10
	add_child(_reply_box)
	_reply_box.term_selected.connect(_collect_term)
	_hangup = AudioStreamPlayer.new()
	_hangup.stream = HANGUP_SOUND
	_hangup.volume_db = 6.0
	add_child(_hangup)
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(INTRO_PATH))
	if parsed is Dictionary:
		_intro_calls = parsed.get("calls", [])
	_start_intro_calls()
	GameState.notebook_changed.connect(func() -> void: _intro_dirty = true)
	GameState.rubbings_changed.connect(func() -> void: _intro_dirty = true)
	# An intro for a stone in the other city waits until the player is there.
	if get_parent().has_signal("time_changed"):
		get_parent().time_changed.connect(func(_day: bool) -> void: _intro_dirty = true)

func _exit_tree() -> void:
	GameState.radio_modal_open = false

func _reposition_button() -> void:
	if _button:
		_button.position = Vector2(size.x - 140, size.y / 2 + 72)

func _process(delta: float) -> void:
	_button.disabled = not _can_open()
	_button.tooltip_text = "Contact Aurora" if _can_open() else "Read the manuscripts, then use the searchlight to inspect the marker 50 years ago."
	_poll_intros(delta)

func _unhandled_key_input(event: InputEvent) -> void:
	if is_open() and not _reply_playing and not _tutorial_paused and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

func is_open() -> bool:
	return _overlay != null and (_overlay.visible or _reply_playing or _tutorial_paused)

func open() -> void:
	if is_open() or not _can_open():
		return
	_heard_reply = false
	GameState.radio_modal_open = true
	get_parent().get_node("FlashlightTool").turn_off()
	get_parent().get_node("RubbingTool").turn_off()
	get_parent().get_node("NotebookTool").rubbing_drag.cancel()
	get_parent().get_node("NotebookTool").close()
	_overlay.show_menu()
	_tomb = ""
	_status = ""
	# A first-step question that has not been answered yet: Aurora is already calling about it.
	var pending := _next_intro(false)
	if not pending.is_empty():
		_start_call(pending["tomb"])
		_apply_intro(pending)
	_render()

## The player ends the call: Aurora says a short goodbye, then the line drops.
func _end_call() -> void:
	if _reply_playing: return
	_feedback = ""
	await _play_reply([{"speaker": "Aurora", "content": GameState.zh_text(_farewell())}], "")
	close()

## A random goodbye, in the voice of whichever Aurora the player is talking to.
func _farewell() -> String:
	if GameState.current_city_day:
		return FAREWELLS_DAY.pick_random()
	if randf() < NIGHT_CARE_CHANCE:
		return FAREWELLS_NIGHT_CARE.pick_random()
	return FAREWELLS_NIGHT.pick_random()

func close(play_hangup: bool = true) -> void:
	if _reply_playing: return
	_tutorial_paused = false
	if GameState.radio_modal_open and play_hangup:
		_hangup.play()
	# Every call is a checkpoint, even one that taught nothing new.
	if GameState.radio_modal_open:
		GameState.write_autosave()
	_heard_reply = false
	_overlay.visible = false
	GameState.radio_modal_open = false
	# Hanging up on an intro call leaves it for the next time the radio is opened,
	# without popping up again by itself.
	if not _intro_current.is_empty() and not _intro_current["question"]["id"] in _intro_dismissed:
		_intro_dismissed.append(_intro_current["question"]["id"])
	_intro_current = {}
	_question = {}
	_followups = []
	_slot = ""

## A tutorial aside is part of this call, not a hang-up or a new session.
func pause_for_tutorial() -> void:
	if _reply_playing: return
	_tutorial_paused = true
	_overlay.hide()

func resume_after_tutorial() -> void:
	_tutorial_paused = false
	_question = {}
	_slot = ""
	_followups = []
	_filter = 0
	_direct_only = false
	_status = ""
	_feedback = ""
	GameState.radio_modal_open = true
	_overlay.show_menu()
	if _tomb.is_empty(): _start_call("baby_tomb")
	_render()

func _queue_render() -> void:
	if not is_open() or _reply_playing or _tutorial_paused or _render_pending:
		return
	_render_pending = true
	_render.call_deferred()

func _label(text: String, font_size: int = 22) -> Label:
	var label := Label.new()
	label.text = GameState.zh_text(text)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size.x = 800
	label.add_theme_font_override("font", GameState.playtest_font(FONT))
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(0.94, 0.92, 0.8))
	return label

func _action(text: String, callback: Callable, disabled: bool = false) -> Button:
	text = GameState.zh_text(text)
	var button := Button.new()
	var font := GameState.playtest_font(FONT)
	button.custom_minimum_size.x = maxf(110.0, font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x + 28.0) if text.length() <= 16 else 110.0
	var wrapped := ""
	var row := ""
	for word in text.split(" "):
		if not row.is_empty() and (row + " " + word).length() > 44:
			wrapped += row + "\n"
			row = word
		else: row += (" " if not row.is_empty() else "") + word
	wrapped += row
	# A label only draws the lines that fit its height, so size the button from the font's
	# real line height (a Chinese system font is taller than the Latin one).
	var line_height := ceilf(font.get_height(20))
	button.custom_minimum_size.y = maxf(34.0, wrapped.split("\n").size() * line_height + 12.0)
	if GameState.chinese_playtest:
		var rows := ceilf(font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x / 280.0)
		button.custom_minimum_size.y = maxf(34.0, rows * line_height + 12.0)
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
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if GameState.chinese_playtest else TextServer.AUTOWRAP_OFF
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
	# A line wider than the button shrinks the text to fit instead of being cut off.
	if title.autowrap_mode == TextServer.AUTOWRAP_OFF:
		var fit := func() -> void:
			var available := button.size.x - 20.0
			var widest := 0.0
			for line in wrapped.split("
"):
				widest = maxf(widest, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x)
			var font_size := 20
			if widest > available and available > 0.0:
				font_size = clampi(floori(20.0 * available / widest), 12, 20)
			title.add_theme_font_size_override("font_size", font_size)
		button.resized.connect(fit)
		fit.call_deferred()
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
	if not is_open() or _reply_playing or _tutorial_paused: return
	_update_question_activity()
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
	header.add_child(_action("End call", _end_call))
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
			if _marker_has_reopened_questions(id):
				var dot := _label("●", 16)
				dot.name = "NewRepliesDot"
				dot.add_theme_color_override("font_color", Color("cf6068"))
				dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
				stone.add_child(dot)
				dot.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
				dot.offset_left = -25
				dot.offset_right = -7
				dot.offset_top = 5
				dot.offset_bottom = 27
				stone.get_child(0).offset_right = -30
			if id == "baby_tomb": tutorial_controls["stone"] = stone
		if list.get_child_count() == 0: list.add_child(_label("No recorded gravestones in this city yet. Return to Day City to continue the small marker investigation." if not GameState.current_city_day else "Record a Day City gravestone in your notebook first."))
		_commit_layout()
		return
	var status := _label(_status if not _status.is_empty() else "Choose a question, or place evidence to reveal a hidden question.", 18)
	if _feedback == "hidden": status.add_theme_color_override("font_color", Color(1, 0.8, 0.35))
	_layout.add_child(status)
	if GameState.story_mode_enabled():
		var legend := _label("剧情模式：青绿 = 正确证据；紫色 ◇ = 可显示隐藏问题" if GameState.chinese_playtest else "STORY MODE: teal = correct evidence; violet ◇ = reveals a hidden question", 17)
		_layout.add_child(legend)
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
		for question in _visible_questions():
			if not _lesson_allows(question): continue
			var text := GameState.zh_text(question["label"])
			if question["hidden"]: text = "◇ " + text
			if _question.get("id", "") == question["id"]: text = "→ " + text
			if not question["available"]:
				text += "  (" + GameState.zh_text("record the human-shaped symbol first" if question["target"] == "test_answer_baby_17" else "symbol link needed") + ")"
			var question_button := _action(text, _select_question.bind(question), not question["available"])
			questions.add_child(question_button)
			tutorial_controls[question["target"]] = question_button
	if questions.get_child_count() == 0:
		questions.add_child(_label("当前可问的内容已全部听过。发现新线索后可能有新的回复。" if GameState.chinese_playtest else "You have heard all currently available replies. New findings may open further questions.", 18))
	var right := VBoxContainer.new()
	right.custom_minimum_size.x = 360
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(right)
	right.add_child(_label("Evidence · one record", 20))
	var slot_title := GameState.zh_text(model.group_title(_slot))
	right.add_child(_action(slot_title + ("  ×" if not _slot.is_empty() else ""), _clear_slot, not _followups.is_empty()))
	var filter := OptionButton.new()
	if GameState.chinese_playtest:
		var font := GameState.playtest_font(FONT)
		filter.add_theme_font_override("font", font)
		filter.get_popup().add_theme_font_override("font", font)
	for label in ["All types", "Symbol records", "Manuscripts", "Other clues"]: filter.add_item(GameState.zh_text(label))
	filter.selected = _filter
	filter.disabled = not _followups.is_empty()
	filter.item_selected.connect(_set_filter)
	right.add_child(filter)
	var direct := CheckButton.new()
	direct.text = "仅显示本碑直接线索" if GameState.chinese_playtest else "Directly related to current marker"
	direct.tooltip_text = "仅显示从本碑获得的拓印、痕迹和观察记录，不包括 Aurora 发来的文献。" if GameState.chinese_playtest else "Only rubbings, traces and observations obtained from this marker; excludes documents sent by Aurora."
	direct.button_pressed = _direct_only
	direct.disabled = not _followups.is_empty()
	direct.add_theme_font_override("font", GameState.playtest_font(FONT))
	direct.add_theme_font_size_override("font_size", 18)
	direct.toggled.connect(func(on: bool) -> void:
		_direct_only = on
		_queue_render())
	right.add_child(direct)
	var ids: Array = model.related_groups(_tomb) if _question.is_empty() else _ordered_candidates()
	var visible_ids: Array = model.groups_for_filter(ids, _filter, _question.is_empty())
	if _direct_only:
		visible_ids = visible_ids.filter(func(id: String) -> bool: return model.directly_from_marker(id, _tomb))
	if _question.is_empty():
		visible_ids = visible_ids.filter(func(id: String) -> bool: return id == _slot or model.has_unheard_reply(_tomb, id))
	var sketch_group: String = model.data["evidence_groups"].get("infant_graffiti", "")
	if _question.is_empty() and _lesson_question() == "test_answer_baby_21" and visible_ids.has(sketch_group):
		visible_ids.erase(sketch_group)
		visible_ids.push_front(sketch_group)
	right.add_child(_label("Collected records" if _question.is_empty() else GameState.zh_text("Three choices · %d shown") % visible_ids.size(), 17))
	var records := _scroll_stack(right, 170 if not _question.is_empty() else 115)
	for id in visible_ids:
		var unlocked: bool = model.group_unlocked(id)
		var group: Dictionary = model.data["groups"][id]
		var label := GameState.zh_text(model.group_title(id) if unlocked else "Uncollected record")
		if unlocked and group["members"].size() > 1: label += "  (" + GameState.zh_text("combined") + ")"
		if id == _slot: label = "✓ " + label
		var record_button := _action(label, _set_slot.bind(id), not unlocked or not _followups.is_empty())
		if unlocked: record_button.tooltip_text = GameState.get_evidence(model.group_member(id)).get("body", "")
		if GameState.story_mode_enabled() and unlocked:
			var hint: Dictionary = model.story_evidence_hint(_tomb, id, _question)
			if hint["correct"] or hint["hidden"]:
				_story_highlight(record_button, Color(0.35, 0.94, 0.78) if hint["correct"] else Color(0.8, 0.58, 1.0))
				if hint["hidden"]:
					var caption := record_button.get_child(0) as Label
					caption.text = "◇ " + caption.text
					record_button.tooltip_text += "\n" + ("这份证据可显示隐藏问题。" if GameState.chinese_playtest else "This record reveals a hidden question.")
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

func _story_highlight(button: Button, color: Color) -> void:
	for state in ["normal", "hover", "focus", "pressed"]:
		var frame := button.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
		frame.bg_color = Color(color.r * 0.16, color.g * 0.16, color.b * 0.16, 0.96)
		frame.border_color = color
		frame.set_border_width_all(2)
		button.add_theme_stylebox_override(state, frame)
	var caption := button.get_child(0) as Label
	caption.add_theme_color_override("font_color", color)

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
	_fit_selection_panel()

## Only formal investigation uses exhaustion; tutorial questions stay available
## for the scripted sequence and collecting missed underlined terms.
func _update_question_activity() -> void:
	_question_states.clear()
	if not GameState.investigation_tutorial_completed: return
	var exhausted: Array = model.progress.get("exhausted_questions", [])
	var pending: Array = model.progress.get("reopened_questions", [])
	for question in model.data.get("questions", []):
		if question["tomb"] not in GameState.gravestones or not model.city_allows(question["tomb"]): continue
		var state: Dictionary = model.question_reply_state(question)
		_question_states[question["id"]] = state
		if not state["available"]: continue
		if not state["unheard"]:
			if question["id"] not in exhausted: exhausted.append(question["id"])
			pending.erase(question["id"])
		elif question["id"] in exhausted:
			exhausted.erase(question["id"])
			if question["id"] not in pending: pending.append(question["id"])
	model.progress["exhausted_questions"] = exhausted
	model.progress["reopened_questions"] = pending

func _marker_has_reopened_questions(stone: String) -> bool:
	for question in model.data.get("questions", []):
		if question["tomb"] == stone and question["id"] in model.progress.get("reopened_questions", []): return true
	return false

func _visible_questions() -> Array:
	var hidden: Array = []
	var ordinary: Array = []
	var answered: Array = model.progress.get("intro_done", [])
	for question in model.questions_for(_tomb, _slot):
		# First-step questions Aurora already answered stay in Radio Logs, not in this list.
		if question["id"] in answered and question["id"] != _question.get("id", ""): continue
		var state: Dictionary = _question_states.get(question["id"], {})
		if question["available"] and state.get("available", false) and not state.get("unheard", true): continue
		if question.get("hidden", false): hidden.append(question)
		else: ordinary.append(question)
	return hidden + ordinary

func _start_call(id: String) -> void:
	if _reply_playing: return
	_tomb = id
	var pending: Array = model.progress.get("reopened_questions", [])
	for item in model.data.get("questions", []):
		if item["tomb"] == id: pending.erase(item["id"])
	model.progress["reopened_questions"] = pending
	_direct_only = false
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
	if not sent_slot.is_empty(): GameState.append_radio_line(_session, {"speaker": "", "content": GameState.zh_text("Submitted record: %s") % GameState.zh_text(model.data["groups"][sent_slot]["title"])})
	# The reply that plays now is one exchange of the radio history. model.submitted_id
	# is the record send() actually evaluated ("" without evidence).
	_exchange_context = {"gravestone_id": sent_question["tomb"], "question_id": sent_question["id"],
		"question_text": sent_question["label"], "evidence_id": model.submitted_id, "evidence_group": sent_slot,
		"evidence_name": model.group_title(sent_slot) if not sent_slot.is_empty() else "", "follow_up": ""}
	GameState.begin_radio_exchange(_session, _exchange_context)
	# A first-step question that got its real reply (not a "try another record" nudge)
	# is done: it leaves the question list for good.
	if _is_intro_question(sent_question["id"]) and result.get("feedback", "") != "unmatched":
		_mark_intro_done(sent_question["id"])
	if not _intro_current.is_empty() and _intro_current["question"]["id"] == sent_question["id"]:
		_intro_current = {}
	_question = {}
	_slot = ""
	_last_lines = []
	_show_result(result.duplicate(true))

func _follow(choice: Dictionary) -> void:
	if _reply_playing: return
	# The final confrontation belongs to the ending scene, not the radio menu.
	for instruction in choice.get("body", []):
		if instruction.get("op", "") == "goto" and instruction.get("target", "") == "test_confrontation":
			close(false)
			GameState.open_ending(true, GameState.ending_preview, true)
			return
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
	_heard_reply = true
	if not log_session.is_empty():
		GameState.write_autosave()
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


## --- First-step ("intro") calls -------------------------------------------------

## A save that predates intro calls (or was played before the feature) may already have a
## pile of questions that are ready. Calling about all of them at once would flood the
## player, so they are left as ordinary questions in the list and never pop up. Questions
## already answered with their evidence are marked done. A fresh game starts clean.
func _start_intro_calls() -> void:
	if model.progress.get("intro_started", false): return
	model.progress["intro_started"] = true
	if GameState.gravestones.is_empty() or not GameState.investigation_tutorial_completed: return
	var skipped: Array = model.progress.get("intro_skipped", [])
	for ready_intro: Dictionary in _ready_intros(false):
		var id: String = ready_intro["question"]["id"]
		if id not in skipped: skipped.append(id)
	model.progress["intro_skipped"] = skipped


func _question_by_id(id: String) -> Dictionary:
	for question: Dictionary in model.data.get("questions", []):
		if question["id"] == id: return question
	return {}


func _is_intro_question(id: String) -> bool:
	for call: Dictionary in _intro_calls:
		if call["question"] == id: return true
	return false


func _mark_intro_done(id: String) -> void:
	var done: Array = model.progress.get("intro_done", [])
	if id not in done: done.append(id)
	model.progress["intro_done"] = done


## Was this question already answered with its evidence (by hand, or in a save from
## before intro calls existed)?
func _intro_heard(tomb: String, id: String, group: String) -> bool:
	var members: Array = model.data.get("groups", {}).get(group, {}).get("members", []) if not group.is_empty() else []
	for record in GameState.radio_history_records(tomb, id):
		if group.is_empty() or str(record.get("evidence_id", "")) in members: return true
	return false


## The first intro call that is waiting: its question is available, its evidence is
## owned, and its stone is recorded in the city the player is in. `skip_dismissed`
## leaves out the calls the player already hung up on.
func _next_intro(skip_dismissed: bool) -> Dictionary:
	var ready_list := _ready_intros(skip_dismissed, true)
	return ready_list[0] if not ready_list.is_empty() else {}


## Every intro call that is waiting (see _next_intro); `first_only` stops at the first.
func _ready_intros(skip_dismissed: bool, first_only: bool = false) -> Array:
	var found: Array = []
	if not GameState.investigation_tutorial_completed: return found
	var answered: Array = model.progress.get("intro_done", [])
	for call: Dictionary in _intro_calls:
		var id: String = call["question"]
		if id in answered or id in model.progress.get("intro_skipped", []) or (skip_dismissed and id in _intro_dismissed): continue
		var question := _question_by_id(id)
		if question.is_empty(): continue
		var tomb: String = question["tomb"]
		if tomb not in GameState.gravestones or not model.city_allows(tomb): continue
		var evidence: String = call.get("evidence", "")
		var group: String = model.data.get("evidence_groups", {}).get(evidence, "") if not evidence.is_empty() else ""
		if not evidence.is_empty() and (group.is_empty() or not model.owns(evidence)): continue
		if _intro_heard(tomb, id, group):
			_mark_intro_done(id)
			continue
		for item in model.questions_for(tomb, group):
			if item["id"] == id and item["available"]:
				found.append({"question": item, "tomb": tomb, "group": group})
				if first_only: return found
	return found


## Fill the radio in for an intro call: the question selected, its evidence in the slot.
func _apply_intro(intro: Dictionary) -> void:
	_intro_current = intro
	_slot = intro["group"]
	_select_question(intro["question"])
	_slot = intro["group"]
	_status = "Aurora is calling about what you just found. Send the evidence to hear her."
	_queue_render()


func _intro_idle() -> bool:
	if GameState.radio_modal_open or GameState.camera_modal_open: return false
	var parent := get_parent()
	var notebook := parent.get_node_or_null("NotebookTool")
	if notebook and notebook.rubbing_drag.is_dragging(): return false
	var guide := parent.get_node_or_null("SunMoonTutorial")
	if guide and guide.has_method("_dialogue_is_playing") and guide._dialogue_is_playing(): return false
	return true


## Pop the radio up when an intro call has been ready for a moment and nothing else is going on.
func _poll_intros(delta: float) -> void:
	_intro_poll += delta
	if _intro_poll < 0.25: return
	_intro_poll = 0.0
	if is_open() or not _can_open() or not _intro_idle():
		_intro_ready_for = -1.0
		return
	if not _intro_dirty and _intro_ready_for < 0.0: return
	if _next_intro(true).is_empty():
		_intro_dirty = false
		_intro_ready_for = -1.0
		return
	_intro_ready_for = maxf(_intro_ready_for, 0.0) + 0.25
	if _intro_ready_for >= INTRO_DELAY:
		_intro_ready_for = -1.0
		_intro_dirty = false
		# One call at a time: any others that are ready wait, filled in, until the player
		# opens the radio again (they never pop up by themselves).
		for waiting: Dictionary in _ready_intros(true):
			var waiting_id: String = waiting["question"]["id"]
			if waiting_id not in _intro_dismissed: _intro_dismissed.append(waiting_id)
		var first := _next_intro(false)
		if not first.is_empty():
			open()


func _can_open() -> bool:
	if GameState.camera_modal_open: return false
	var guide := get_parent().get_node_or_null("SunMoonTutorial")
	if guide and guide.get("_speaking"): return false
	return GameState.cycle_tutorial_completed and ((GameState.tutorial_radio_intro_heard and GameState.evidence_ids.has("infant_graffiti")) or GameState.investigation_tutorial_completed or GameState.notebook_preview)


func _fit_selection_panel() -> void:
	_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_panel.offset_left = 80
	_panel.offset_right = -80
	_panel.offset_top = -450
	_panel.offset_bottom = -48
	var grain: ColorRect = _overlay.get_node("Panel/RadioStatic")
	grain.material.set_shader_parameter("top_fade_height", 220.0)
	grain.material.set_shader_parameter("top_fade_inset", 30.0)
