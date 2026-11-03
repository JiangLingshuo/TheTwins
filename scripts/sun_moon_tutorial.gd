extends Node
## A small ordered tutorial; all progression survives scene recreation in GameState.
enum Step { TOOL, SUN, MOON, AURORA, BOOK, TAB, DRAG, DONE }
var step := Step.TOOL
var _speaking := false
var _skipping := false
var _highlight_target: Control
var _panel: PanelContainer
var _text: Label
var _highlight: HighlightFrame
var _dialogue: Control
var _main: Control
var _notebook: Control
var _rubbing: Control
var _sun: Control
var _moon: RubbingSymbol
var _human: RubbingSymbol

func _ready() -> void:
	await get_tree().process_frame
	_main = get_parent()
	_notebook = _main.get_node("NotebookTool")
	_rubbing = _main.get_node("RubbingTool")
	_sun = _main.get_node("DayCemetery/Sun")
	_moon = _main.get_node("DayCemetery/BabyTomb/MoonSymbol")
	_human = _main.get_node("DayCemetery/BabyTomb/HumanSymbol")
	_build_guide()
	_rubbing.state_changed.connect(func(_on: bool) -> void: refresh())
	_rubbing.rubbing_collected.connect(func(_id: String) -> void: refresh())
	_notebook.notebook_opened.connect(func() -> void: refresh())
	_notebook.notebook_closed.connect(func() -> void:
		GameState.finish_current_manuscript()
		refresh())
	_notebook.book.page_changed.connect(func(_page: int) -> void: refresh())
	_notebook.rubbing_drag.sky_replaced.connect(_on_sky_replaced)
	_notebook.rubbing_drag.mismatched.connect(func(id: String, _target: Control) -> void:
		if id in ["sky_sun_rubbing", "infant_moon_rubbing"] and not GameState.cycle_tutorial_completed:
			_main.get_node("Toast").show_message("Drop the notebook's moon onto the sun in the sky.")
	)
	refresh()

func _process(_delta: float) -> void:
	# Page-opening animations finish after notebook_opened; keep the hint in sync.
	if not _speaking and not _skipping and step >= Step.BOOK:
		refresh()

func refresh() -> void:
	if _skipping or _speaking:
		return
	var has_sun := GameState.rubbings.has("sky_sun_rubbing")
	var has_moon := GameState.rubbings.has("infant_moon_rubbing")
	_moon.collection_enabled = has_sun or GameState.cycle_tutorial_completed
	_human.collection_enabled = GameState.cycle_tutorial_completed
	if GameState.cycle_tutorial_completed:
		_guide_investigation()
	elif not has_sun:
		if _rubbing.active:
			_set_step(Step.SUN, "1 / 5  Hold and brush over the sun in the sky to make a rubbing.", _sun)
		else:
			_set_step(Step.TOOL, "1 / 5  Pick up the rubbing tool. We will start with the sun.", _rubbing.get_node("RubbingButton"))
	elif not has_moon:
		_set_step(Step.MOON, "2 / 5  There seems to be a crescent shape on the base. Make a rubbing of it.", _moon if _rubbing.active else _rubbing.get_node("RubbingButton"))
	elif not GameState.cycle_hint_heard:
		_speak.call_deferred()
	elif not _notebook.is_open():
		_set_step(Step.BOOK, "3 / 5  Open your notebook (Tab or N). Your two icons have their own spread.", _notebook.get_node("NotebookButton"))
	elif _notebook.book.get_section() != 5:
		_set_step(Step.TAB, "4 / 5  Choose the Rise & Set tab.", _notebook.book.tabs._tabs[5])
	else:
		_set_step(Step.DRAG, "5 / 5  Drag the moon from the black page onto the sun in the scene. The notebook folds away as you drag out.", _notebook.book.right_page.get_node_or_null("CycleIcon"))

func _set_step(value: Step, text: String, target: Control) -> void:
	var box := _main.get_node_or_null("Toolbox")
	if box and target:
		target = box.proxy_for(target)
		box.reveal_for(target)
	step = value
	_text.text = text
	var radio := _main.get_node_or_null("RadioTool")
	if radio and radio.is_open():
		_panel.visible = false
		if is_instance_valid(radio._tutorial_hint): radio._tutorial_hint.text = text
	else:
		_panel.visible = true
	if _highlight_target != target:
		_highlight_target = target
		_highlight.dismiss(false)
		if target:
			_highlight.blink_around(target)

func _speak() -> void:
	if _speaking or _skipping or GameState.cycle_hint_heard:
		return
	_speaking = true
	_set_step(Step.AURORA, "Aurora is on the line…", null)
	_rubbing.turn_off()
	_main.get_node("FlashlightTool").turn_off()
	_dialogue.play_file("res://assets/dialogue/tutorial_sun_moon.xml")
	await _dialogue.finished
	GameState.cycle_hint_heard = true
	_speaking = false
	refresh()

func _on_sky_replaced(id: String, _target: Control) -> void:
	if id == "infant_moon_rubbing":
		GameState.cycle_tutorial_completed = true
		GameState.confirm_rubbing_meaning("infant_moon_rubbing", "Moon")
		_main.set_night()
		if not GameState.tutorial_night_heard: _night_arrival.call_deferred()
		_main.get_node("Toast").show_message("Night City — the moon has taken the sun's place.")
	else:
		_main.set_day()
		_main.get_node("Toast").show_message("Day City — the sun has taken the moon's place.")
	refresh()

func skip() -> void:
	if _speaking:
		return
	_skipping = true
	GameState.record_rubbing("sky_sun_rubbing", "", "res://assets/Art/symbols/sky_sun.svg")
	GameState.record_rubbing("infant_moon_rubbing", "baby_tomb", "res://assets/Art/symbol/moon.png", "moon")
	GameState.cycle_hint_heard = true
	GameState.cycle_tutorial_completed = true
	GameState.investigation_tutorial_completed = true
	GameState.tutorial_night_heard = true
	GameState.confirm_rubbing_meaning("infant_moon_rubbing", "Moon")
	_rubbing.turn_off()
	_main.set_night()
	_skipping = false
	refresh()

func _build_guide() -> void:
	_panel = PanelContainer.new()
	_panel.position = Vector2(24, 20)
	_panel.custom_minimum_size = Vector2(570, 0)
	_panel.z_index = 60
	var paper := StyleBoxFlat.new()
	paper.bg_color = Color(0.1, 0.13, 0.17, 0.92)
	paper.set_content_margin_all(12)
	paper.set_corner_radius_all(5)
	_panel.add_theme_stylebox_override("panel", paper)
	var stack := VBoxContainer.new()
	_panel.add_child(stack)
	_text = Label.new()
	_text.custom_minimum_size.x = 540
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.add_theme_font_size_override("font_size", 18)
	stack.add_child(_text)
	var skip_button := Button.new()
	skip_button.text = "DEV — skip tutorial"
	skip_button.visible = OS.is_debug_build()
	skip_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	skip_button.pressed.connect(skip)
	stack.add_child(skip_button)
	_main.add_child(_panel)
	_highlight = HighlightFrame.new()
	_highlight.z_index = 59
	_highlight.blinks = 8
	_highlight.padding = 14
	_main.add_child(_highlight)
	_dialogue = preload("res://scenes/dialogue_box.tscn").instantiate()
	_dialogue.z_index = 100
	_main.add_child(_dialogue)


func _night_arrival() -> void:
	if _speaking or GameState.tutorial_night_heard: return
	_speaking = true
	_notebook.close()
	_rubbing.turn_off()
	_dialogue.play_file("res://assets/dialogue/tutorial_night_arrival.xml")
	await _dialogue.finished
	GameState.tutorial_night_heard = true
	_speaking = false
	refresh()

func _guide_investigation() -> void:
	step = Step.DONE
	if GameState.investigation_tutorial_completed:
		_panel.visible = false
		_highlight.dismiss(false)
		return
	var radio: Control = _main.get_node("RadioTool")
	_panel.position = Vector2(24, 4) if not radio.is_open() else Vector2(24, 4)
	_panel.z_index = 60
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var progress := GameState.radio_progress
	var read: Array = progress.get("read_answers", [])
	if not _main.is_day:
		_set_step(Step.DONE, "Bring back daylight: open Rise & Set and drag the sun onto the moon. Day City questions are available in daylight.", _notebook.get_node("NotebookButton") if not _notebook.is_open() else null)
	elif not GameState.tutorial_day_return_heard:
		_play_milestone.call_deferred("tutorial_day_return", "tutorial_day_return_heard")
	elif not GameState.rubbings.has("infant_figure_rubbing"):
		_set_step(Step.DONE, "Make a rubbing of the small marker's person-shaped figure. Completing it will record the whole marker.", _human if _rubbing.active else _rubbing.get_node("RubbingButton"))
	elif not GameState.tutorial_record_intro_heard:
		_record_first_marker.call_deferred()
	elif "designer_manuscript" not in progress.get("read_manuscripts", []):
		_set_step(Step.DONE, "Open Manuscripts and read A Marker for Someone Without an Occupation.", _notebook.book.tabs._tabs[3] if _notebook.is_open() else _notebook.get_node("NotebookButton"))
	elif "infant" not in progress.get("manuscript_keywords", []):
		_set_step(Step.DONE, "Click the underlined infant in the designer's manuscript to take down a keyword. It will become a report option.", null)
	elif not GameState.tutorial_keyword_ack_heard:
		_play_milestone.call_deferred("tutorial_keyword_noted", "tutorial_keyword_ack_heard")
	elif "designer_journal" not in progress.get("read_manuscripts", []):
		_set_step(Step.DONE, "Return to the manuscript list and read A Page of the Designer's Journal as well. Its account may give you another question.", null)
	elif not GameState.tutorial_radio_intro_heard and ("designer_manuscript" not in progress.get("finished_manuscripts", []) or "designer_journal" not in progress.get("finished_manuscripts", [])):
		_set_step(Step.DONE, "Take your time reading. When finished, return to the manuscript list or close the notebook.", null)
	elif not GameState.tutorial_searchlight_intro_heard:
		_play_milestone.call_deferred("tutorial_searchlight_intro", "tutorial_searchlight_intro_heard")
	elif not GameState.evidence_ids.has("infant_graffiti"):
		_guide_searchlight()
	elif not GameState.tutorial_searchlight_found_heard:
		_play_milestone.call_deferred("tutorial_searchlight_found", "tutorial_searchlight_found_heard")
	elif not GameState.tutorial_radio_intro_heard:
		_play_milestone.call_deferred("tutorial_radio_ready", "tutorial_radio_intro_heard")
	elif not read.has("baby_8_normal_9"):
		_set_step(Step.DONE, "Close the notebook and contact Aurora → small marker → interpret the icon. Submit ☾ → Moon for an informed reply.", radio._button if not radio.is_open() else null)
	elif "natural" not in progress.get("causes", []):
		_set_step(Step.DONE, "Click the underlined natural death in Aurora's reply. You can also use Read last reply to collect a missed term.", null)
	elif not read.has("baby_17_supported_19"):
		_set_step(Step.DONE, "Ask why the marker is shaped like a person. Submit the designer's manuscript; continue through Aurora's follow-up.", radio._button if not radio.is_open() else null)
	elif not GameState.tutorial_hidden_heard:
		_hidden_hint.call_deferred()
	elif not read.has("baby_21_hidden_23"):
		_set_step(Step.DONE, "Contact Aurora. Place A Sketch of the Infant in the slot before choosing a question: a hidden question about its artist will appear.", radio._button if not radio.is_open() else null)
	elif not read.has("baby_8_additional_10"):
		_set_step(Step.DONE, "Ask about the icon again with A Sketch of the Infant, revealed by the searchlight. Compare the child's actual appearance with the family's chosen image to question the recorded death.", null)
	elif "unexplained" not in progress.get("causes", []):
		_set_step(Step.DONE, "Collect the underlined unexplained circumstances from Aurora's reply.", null)
	else:
		var report: Dictionary = GameState.gravestone_reports.get("baby_tomb", {})
		if report.get("identity", "") == "infant" and report.get("death", "") in ["natural", "unexplained"]:
			_finish_investigation.call_deferred()
		else:
			_set_step(Step.DONE, "End the call. Open Gravestones and choose the small marker's identity and death from your collected keywords.", _notebook.get_node("NotebookButton") if not _notebook.is_open() else null)

func _hidden_hint() -> void:
	if _speaking or GameState.tutorial_hidden_heard: return
	_speaking = true
	_main.get_node("FlashlightTool").turn_off()
	_dialogue.play_file("res://assets/dialogue/tutorial_hidden_question.xml")
	await _dialogue.finished
	GameState.tutorial_hidden_heard = true
	_speaking = false
	refresh()


func _play_milestone(file: String, flag: String) -> void:
	if _speaking or GameState.get(flag): return
	var radio := _main.get_node("RadioTool")
	if radio._reply_playing: return
	_speaking = true
	if radio.is_open(): radio.close()
	_rubbing.turn_off()
	_main.get_node("FlashlightTool").turn_off()
	_panel.hide()
	_highlight.dismiss(false)
	_highlight_target = null
	_dialogue.play_file("res://assets/dialogue/" + file + ".xml")
	await _dialogue.finished
	GameState.set(flag, true)
	GameState.notebook_changed.emit()
	_speaking = false
	refresh()

func _record_first_marker() -> void:
	if _speaking or GameState.tutorial_record_intro_heard: return
	_speaking = true
	_rubbing.turn_off()
	_main.get_node("FlashlightTool").turn_off()
	_panel.hide()
	_highlight.dismiss(false)
	_highlight_target = null
	# First show the unknown gravestone page, then grant the real marker record.
	if not _notebook.is_open():
		_notebook.show_gravestone_next("baby_tomb")
		await _notebook.open()
	else:
		while _notebook.book._busy: await get_tree().process_frame
		_notebook.book.jump_to_section(0)
		while _notebook.book._busy: await get_tree().process_frame
	await get_tree().create_timer(0.35).timeout
	_main.get_node("DayCemetery/BabyTomb").record()
	await get_tree().create_timer(0.4).timeout
	_dialogue.play_file("res://assets/dialogue/tutorial_recorded.xml")
	await _dialogue.finished
	GameState.tutorial_record_intro_heard = true
	_speaking = false
	refresh()

func _finish_investigation() -> void:
	if _speaking or GameState.investigation_tutorial_completed: return
	var radio := _main.get_node("RadioTool")
	if radio._reply_playing: return
	_speaking = true
	if radio.is_open(): radio.close()
	_panel.hide()
	_highlight.dismiss(false)
	_highlight_target = null
	_dialogue.play_file("res://assets/dialogue/tutorial_investigation_complete.xml")
	await _dialogue.finished
	GameState.tutorial_end_heard = true
	GameState.deliver_day_manuscripts()
	GameState.investigation_tutorial_completed = true
	GameState.camera_tutorial_pending = true
	await _main.get_node("CameraTool").play_tutorial()
	_speaking = false
	_main.get_node("Toast").show_message("New Day City manuscripts received. Your investigation continues.")
	refresh()


func _guide_searchlight() -> void:
	var tool := _main.get_node("FlashlightTool")
	if _notebook.is_open():
		_set_step(Step.DONE, "Close the notebook (Tab / N). Next, use the searchlight to investigate the small marker's past.", _notebook.get_node("NotebookButton"))
	elif tool.state == 0:
		_set_step(Step.DONE, "Pick up the searchlight. It can reveal traces that are no longer visible in the present.", tool.get_node("FlashlightButton"))
	elif tool.state == 1:
		_set_step(Step.DONE, "Click the figure or base of the small marker to lock the light there. The beam stays fixed while you adjust the year.", _human)
	elif absf(tool.flashlight.focus - 50.0) > tool.flashlight.perfect_tolerance:
		_set_step(Step.DONE, "Scroll the mouse wheel to 50 years ago (2000). Shift + scroll moves 10 years at a time.", tool.get_node("FocusScale"))
	else:
		_set_step(Step.DONE, "Keep the light on the small marker for a moment. If nothing appears, click its figure or base to re-aim.", _human)
