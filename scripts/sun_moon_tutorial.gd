extends Node
## A small ordered tutorial; all progression survives scene recreation in GameState.
## BOOK / TAB / DRAG are used by both Step 2 (moon onto sun, by day) and Step 3
## (sun onto moon, at night). AWAIT_STEP_4: Step 3 is done; Step 4 comes next.
enum Step { TOOL, MOON, AURORA, BOOK, TAB, DRAG, AWAIT_STEP_4, DONE }
## Steps where only the highlighted control may be used; anything else shakes the hint.
const GATED := [Step.TOOL, Step.BOOK, Step.TAB, Step.DRAG]
## Shown once Aurora's Step 1 line ends and the moon and sun are in the notebook.
@export var step1_notebook_message := "Notebook updated: the moon is recorded in Rise & Set."
const SKY_SUN_TEXTURE := GameState.SUN_RUBBING_TEXTURE
## Least time the rubbed crescent blinks on the marker before the notebook opens.
@export var moon_blink_time: float = 2.5
## Seconds for the crescent to drop from the marker onto the notebook, then to grow.
@export var moon_drop_time: float = 0.9
@export var moon_grow_time: float = 0.45
var step := Step.TOOL
var _speaking := false
## True while the crescent is moving into the notebook; all input waits.
var _delivering := false
var _icon_blink: Tween
var _skipping := false
var _highlight_target: Control
var _panel: PanelContainer
var _text: Label
var _highlight: HighlightFrame
var _dialogue: Control
var _main: Control
var _notebook: Control
var _rubbing: Control
var _moon: RubbingSymbol
var _human: RubbingSymbol
var _box: Control
var _skip_button: Button
var _shake_tween: Tween
var _drag_hint: DragHint

func _ready() -> void:
	await get_tree().process_frame
	_main = get_parent()
	_notebook = _main.get_node("NotebookTool")
	_rubbing = _main.get_node("RubbingTool")
	_moon = _main.get_node("DayCemetery/BabyTomb/MoonSymbol")
	_human = _main.get_node("DayCemetery/BabyTomb/HumanSymbol")
	_build_guide()
	_box = _main.get_node_or_null("Toolbox")
	if _box: _box.tray_toggled.connect(func(_expanded: bool) -> void: refresh())
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
			_main.get_node("Toast").show_message("Drop the notebook's moon onto the sun in the sky.", true)
		elif id == "sky_sun_rubbing" and not _main.is_day and not GameState.investigation_tutorial_completed:
			_main.get_node("Toast").show_message("Drop the notebook's sun onto the moon in the sky.", true)
	)
	refresh()

func _process(_delta: float) -> void:
	if _notebook == null: # _ready() is still waiting a frame
		return
	if _dialogue_is_playing():
		_hide_guide_during_dialogue()
		return
	# Page-opening animations finish after notebook_opened; keep the hint in sync.
	if not _speaking and not _skipping and step >= Step.BOOK:
		refresh()

func _dialogue_is_playing() -> bool:
	var radio := _main.get_node_or_null("RadioTool")
	return _speaking or (is_instance_valid(_dialogue) and _dialogue.is_playing()) or (radio and radio._reply_playing)


func _hide_guide_during_dialogue() -> void:
	_panel.hide()
	_highlight.dismiss(false)
	_highlight_target = null
	_drag_hint.target = null
	var radio := _main.get_node_or_null("RadioTool")
	if radio and is_instance_valid(radio._tutorial_hint):
		radio._tutorial_hint.hide()


func refresh() -> void:
	if _dialogue_is_playing():
		_hide_guide_during_dialogue()
		return
	if _skipping:
		return
	# Mid-drag the notebook has folded away; keep the drag hint until the drop.
	if _notebook.rubbing_drag.is_dragging():
		return
	var has_moon := GameState.rubbings.has("infant_moon_rubbing")
	_moon.collection_enabled = true
	# The sun is recorded when the moon first replaces it; this covers games saved before that.
	if has_moon and GameState.cycle_tutorial_completed and not GameState.rubbings.has("sky_sun_rubbing"):
		_record_cycle_symbols()
	_human.collection_enabled = GameState.cycle_tutorial_completed
	if GameState.cycle_tutorial_completed:
		_guide_investigation()
	elif not has_moon:
		if _rubbing.active:
			_set_step(Step.MOON, "1 / 4  There seems to be a crescent shape on the base. Make a rubbing of it.", _moon)
		elif _box and _box.tray and not _box.tray.visible:
			# Onboarding, part one: the toolbox starts folded; only it can be clicked.
			_set_step(Step.TOOL, "1 / 4  Open the toolbox.", _box.button)
		else:
			_set_step(Step.TOOL, "1 / 4  Pick up the rubbing tool to record the crescent on the small marker.", _rubbing.get_node("RubbingButton"))
	elif not GameState.cycle_hint_heard:
		_speak.call_deferred()
	else:
		# Step 2: moon onto sun (the moon is on the right, dark page).
		_guide_cycle("2 / 4  Open your notebook (Tab or N). A sun icon is provided in Rise & Set.",
			"3 / 4  Choose the Rise & Set tab.",
			"4 / 4  Drag the moon from the black page onto the sun in the scene. The notebook folds away as you drag out.",
			false)

## Steps 2 and 3: open the notebook, (be on Rise & Set), drag one icon out.
func _guide_cycle(book_text: String, tab_text: String, drag_text: String, icon_on_left: bool) -> void:
	if not _notebook.is_open():
		_set_step(Step.BOOK, book_text, _notebook.get_node("NotebookButton"))
	elif _notebook.book.get_section() != 5:
		_set_step(Step.TAB, tab_text, _notebook.book.tabs._tabs[5])
	else:
		var page: Control = _notebook.book.left_page if icon_on_left else _notebook.book.right_page
		_set_step(Step.DRAG, drag_text, page.get_node_or_null("CycleIcon"))

func _input(event: InputEvent) -> void:
	# _ready() waits a frame before wiring nodes up; ignore input until then.
	if _skipping or _notebook == null:
		return
	if GameState.is_dev_menu_click(event):
		return
	if event is InputEventKey and (event.keycode in [KEY_F2, KEY_F3] or (event.keycode == KEY_T and event.ctrl_pressed)):
		return  # the development overlay toggle (GameState) always works
	if _delivering:
		if not (event is InputEventMouseMotion):
			get_viewport().set_input_as_handled()
		return
	# Until the crescent is rubbed, and while a tutorial dialogue plays, the notebook stays shut.
	if step in [Step.MOON, Step.AURORA] or _speaking:
		_block_notebook(event)
		return
	# Gated steps: only a left click on the highlighted control gets through
	# (plus Tab / N to open the notebook, and the required drag itself).
	# Anything else is blocked and the hint shakes.
	if step not in GATED:
		return
	var dragging: bool = _notebook.rubbing_drag.is_dragging()
	# Never lock input when the highlighted control can't be used.
	if not dragging and (not is_instance_valid(_highlight_target) or not _highlight_target.is_visible_in_tree()):
		return
	if event is InputEventMouseMotion or not event.is_pressed() or event.is_echo():
		return
	if dragging:
		# The drag owns the mouse until the drop; Esc may cancel it.
		if event is InputEventMouseButton or (event is InputEventKey and event.keycode == KEY_ESCAPE):
			return
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var point: Vector2 = event.position
		if _highlight_target.get_global_rect().has_point(point):
			return
		if _skip_button.is_visible_in_tree() and _skip_button.get_global_rect().has_point(point):
			return
	elif step == Step.BOOK and event is InputEventKey and event.keycode in [_notebook.toggle_key, _notebook.alt_toggle_key]:
		return
	get_viewport().set_input_as_handled()
	if event is InputEventKey and event.keycode in [KEY_SHIFT, KEY_CTRL, KEY_ALT, KEY_META]:
		return
	if event is InputEventMouseButton and event.button_index not in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
		return # wheel: blocked quietly
	_shake_hint()

func _block_notebook(event: InputEvent) -> void:
	var opens := false
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		opens = _notebook.get_node("NotebookButton").get_global_rect().has_point(event.position)
	elif event is InputEventKey and event.pressed and not event.echo:
		opens = event.keycode in [_notebook.toggle_key, _notebook.alt_toggle_key]
	if opens:
		get_viewport().set_input_as_handled()
		_shake_hint()

func _shake_hint() -> void:
	if _shake_tween and _shake_tween.is_running():
		return
	var home := _panel.position.x
	_shake_tween = create_tween()
	for offset in [10.0, -8.0, 6.0, -4.0, 0.0]:
		_shake_tween.tween_property(_panel, "position:x", home + offset, 0.05)

func _set_step(value: Step, text: String, target: Control, persistent := false) -> void:
	var box := _main.get_node_or_null("Toolbox")
	if box and target:
		target = box.proxy_for(target)
		# The toolbox stays folded: point at its button until the player opens it.
		if box.tray and box.tray.is_ancestor_of(target) and not box.tray.visible:
			target = box.button
	step = value
	if value != Step.DRAG:
		_stop_icon_blink()
	# Gated steps pulse until done; other hints blink a few times.
	_highlight.loop = value in GATED or persistent
	_highlight.z_index = 95 if persistent else 59
	_highlight.padding = 5 if persistent else 14
	_panel.z_index = 95 if persistent else 60
	_panel.get_parent().visible = GameState.debug_overlay or persistent
	_drag_hint.target = target if value == Step.DRAG else null
	_text.text = GameState.zh_text(text)
	var radio := _main.get_node_or_null("RadioTool")
	if radio and radio.is_open() and not radio._reply_playing:
		_panel.visible = false
		if is_instance_valid(radio._tutorial_hint):
			radio._tutorial_hint.text = GameState.zh_text(text)
			radio._tutorial_hint.visible = GameState.debug_overlay or persistent
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
	# Step 1 feedback, in order: the crescent was rubbed (rubbing_collected) ->
	# it blinks on the marker during Aurora's line -> the notebook opens on
	# Rise & Set and the crescent drops onto it -> drag step. The sun follows
	# once the moon has replaced it in the sky (_on_sky_replaced).
	_record_cycle_symbols(false)
	_set_step(Step.AURORA, "Aurora is on the line…", null)
	# Put the brush down while she talks (it hides the cursor).
	_rubbing.turn_off()
	_main.get_node("FlashlightTool").turn_off()
	_moon.start_blinking()
	var started := Time.get_ticks_msec()
	_dialogue.play_file("res://assets/dialogue/tutorial_sun_moon.xml")
	await _dialogue.finished
	var left := moon_blink_time - (Time.get_ticks_msec() - started) / 1000.0
	if left > 0.0:
		await get_tree().create_timer(left).timeout
	_moon.stop_blinking()
	var invert := ShaderMaterial.new()
	invert.shader = preload("res://shaders/portrait_invert.gdshader")
	invert.set_shader_parameter("invert", 1.0)
	var flyer := await _drop_into_notebook(_moon.texture, _moon.get_global_rect(), false, invert, Color.WHITE, Color.WHITE)
	GameState.cycle_hint_heard = true
	GameState.notebook_changed.emit()
	await get_tree().process_frame  # the page redraws with the moon
	flyer.queue_free()
	var icon: Control = _notebook.book.right_page.get_node_or_null("CycleIcon")
	if icon:
		_icon_blink = icon.create_tween().set_loops()
		_icon_blink.tween_property(icon, "modulate:a", 0.3, 0.4).set_trans(Tween.TRANS_SINE)
		_icon_blink.tween_property(icon, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE)
	_delivering = false
	_main.get_node("Toast").show_message(step1_notebook_message)
	_speaking = false
	refresh()

## A copy of `texture` lifts off `from` (screen rect) and hovers while the
## notebook opens quickly on Rise & Set; once the book is fully open it drops
## onto the left or right page's icon spot and grows into place. Returns the
## copy, still showing, so the caller can swap in the real icon; input waits
## (_delivering) until the caller clears it.
func _drop_into_notebook(texture: Texture2D, from: Rect2, on_left: bool, look: Material, tint: Color, landed_tint: Color) -> TextureRect:
	_delivering = true
	_panel.hide()
	_highlight.dismiss(false)
	_highlight_target = null
	var flyer := TextureRect.new()
	flyer.texture = texture
	flyer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	flyer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	flyer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flyer.z_index = 58
	flyer.material = look
	flyer.modulate = tint
	_main.add_child(flyer)
	flyer.global_position = from.position
	flyer.size = from.size
	# It rises while the notebook comes out beneath it, quicker than usual.
	var hover_size := from.size * clampf(120.0 / maxf(from.size.y, 1.0), 1.0, 2.0)
	var hover := Rect2(from.get_center() - hover_size / 2.0 - Vector2(0, 120), hover_size)
	if from.get_center().y < 260.0:
		hover.position.y = from.get_center().y - hover_size.y / 2.0  # already high in the sky
	var t := create_tween().set_parallel(true)
	t.tween_property(flyer, "global_position", hover.position, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(flyer, "size", hover.size, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await _open_notebook_quickly()
	if t.is_running():
		await t.finished
	var page: Control = _notebook.book.left_page if on_left else _notebook.book.right_page
	var icon: Control = page.get_node_or_null("CycleIcon")
	var landing: Rect2 = icon.get_global_rect() if icon else page.get_global_rect()
	# Drop onto the page at a little under its size...
	var small := Rect2(landing.get_center() - landing.size * 0.3, landing.size * 0.6)
	t = create_tween().set_parallel(true)
	t.tween_property(flyer, "global_position", small.position, moon_drop_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_property(flyer, "size", small.size, moon_drop_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_property(flyer, "modulate", landed_tint, moon_drop_time)
	await t.finished
	# ...then grow into the icon's place.
	t = create_tween().set_parallel(true)
	t.tween_property(flyer, "global_position", landing.position, moon_grow_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(flyer, "size", landing.size, moon_grow_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await t.finished
	return flyer

## Bring the notebook out on Rise & Set at twice the usual pace and wait until
## it is fully open there (if it was still folding away, let that finish first).
func _open_notebook_quickly() -> void:
	var book: Control = _notebook.book
	while book._busy and _notebook.is_open():
		await get_tree().process_frame
	if _notebook.is_open():
		if book.get_section() != book.RISE_AND_SET:
			book.jump_to_section(book.RISE_AND_SET)
	else:
		var saved: Array = [book.wake_time, book.stow_time, book.flip_time]
		book.wake_time *= 0.5
		book.stow_time *= 0.5
		book.flip_time *= 0.6
		await _notebook.open()  # it opens on Rise & Set
		book.wake_time = saved[0]
		book.stow_time = saved[1]
		book.flip_time = saved[2]
	while not _notebook.is_open() or book._busy:
		await get_tree().process_frame

func _stop_icon_blink() -> void:
	if _icon_blink and _icon_blink.is_valid():
		_icon_blink.kill()
		var icon: Control = _notebook.book.right_page.get_node_or_null("CycleIcon")
		if icon:
			icon.modulate.a = 1.0
	_icon_blink = null

## Record the crescent's and (`with_sun`) the sky sun's icons (both appear in
## Rise & Set and Rubbings), deciphered with their icon file names as temporary
## meanings. Safe to call again: recording and deciphering only change things once.
func _record_cycle_symbols(with_sun: bool = true) -> void:
	if with_sun:
		GameState.record_rubbing("sky_sun_rubbing", "", SKY_SUN_TEXTURE)
	for id in ["infant_moon_rubbing", "sky_sun_rubbing"]:
		if GameState.rubbings.has(id) and not GameState.is_rubbing_deciphered(id):
			GameState.confirm_rubbing_meaning(id, GameState.get_rubbing_texture(id).get_file().get_basename())

## The moon has taken the sun's place for the first time: the sky sun drops into
## the notebook's Day page the way the crescent did, then the notebook closes.
func _deliver_sun(sky_sun: Control) -> void:
	_speaking = true
	var from := sky_sun.get_global_rect()
	sky_sun.modulate.a = 0.0  # the copy takes its place on the way down
	var flyer := await _drop_into_notebook(load(SKY_SUN_TEXTURE), from, true, null, Color(1.0, 0.95, 0.78), _notebook.book.day_ink)
	_record_cycle_symbols()
	GameState.notebook_changed.emit()
	await get_tree().process_frame  # the page redraws with the sun
	flyer.queue_free()
	sky_sun.modulate.a = 1.0
	await get_tree().create_timer(0.8).timeout
	_notebook.close()
	while _notebook.is_open():
		await get_tree().process_frame
	_delivering = false
	_speaking = false

func _on_sky_replaced(id: String, target: Control) -> void:
	if id == "infant_moon_rubbing":
		GameState.cycle_tutorial_completed = true
		GameState.confirm_rubbing_meaning("infant_moon_rubbing", "Moon")
		_main.set_night()
		if not GameState.rubbings.has("sky_sun_rubbing"):
			await _deliver_sun(target)
		_main.get_node("Toast").show_message("Night City — the moon has taken the sun's place.")
		# Started now (not deferred) so Step 3 only begins once Aurora's line ends.
		if not GameState.tutorial_night_heard: _night_arrival()
	else:
		_main.set_day()
		_main.get_node("Toast").show_message("Day City — the sun has taken the moon's place.")
	refresh()

func skip() -> void:
	if _speaking:
		return
	_skipping = true
	GameState.record_rubbing("infant_moon_rubbing", "baby_tomb", "res://assets/Art/symbol/moon.png", "moon")
	_record_cycle_symbols()
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
	_skip_button = Button.new()
	_skip_button.text = "DEV — skip tutorial"
	_skip_button.visible = OS.is_debug_build()
	_skip_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	_skip_button.pressed.connect(skip)
	stack.add_child(_skip_button)
	# The hint box is part of the development overlay (F2); the steps still run.
	var overlay := Control.new()
	overlay.name = "TutorialOverlay"
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.visible = GameState.debug_overlay
	overlay.add_child(_panel)
	_main.add_child(overlay)
	GameState.debug_overlay_changed.connect(func(shown: bool) -> void:
		overlay.visible = shown
		var radio := _main.get_node_or_null("RadioTool")
		if radio and is_instance_valid(radio._tutorial_hint): radio._tutorial_hint.visible = shown)
	_highlight = HighlightFrame.new()
	_highlight.z_index = 59
	_highlight.blinks = 8
	_highlight.padding = 14
	_main.add_child(_highlight)
	_drag_hint = DragHint.new()
	_drag_hint.color = _highlight.color
	_main.add_child(_drag_hint)
	_dialogue = preload("res://scenes/dialogue_box.tscn").instantiate()
	_dialogue.z_index = 100
	_main.add_child(_dialogue)


func _night_arrival() -> void:
	if _speaking or GameState.tutorial_night_heard: return
	_speaking = true
	_set_step(Step.AURORA, "Aurora is on the line…", null)
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
	if not _main.is_day and not GameState.tutorial_night_heard:
		_night_arrival.call_deferred() # e.g. the scene reloaded before Aurora's night line
	elif not _main.is_day and not GameState.tutorial_day_return_heard:
		# Step 3: sun onto moon (the sun is on the left, light page).
		_guide_cycle("Bring back daylight: open your notebook (Tab or N).",
			"Choose the Rise & Set tab.",
			"Drag the sun from the light page onto the moon in the sky. The notebook folds away as you drag out.",
			true)
	elif not _main.is_day:
		_set_step(Step.DONE, "Bring back daylight: open Rise & Set and drag the sun onto the moon. Day City questions are available in daylight.", _notebook.get_node("NotebookButton") if not _notebook.is_open() else null)
	elif not GameState.tutorial_day_return_heard:
		_play_milestone.call_deferred("tutorial_day_return", "tutorial_day_return_heard")
	elif not GameState.rubbings.has("infant_figure_rubbing"):
		# Step 3 is done. Step 4 is not gated yet: just the existing hint, no input lock.
		_set_step(Step.AWAIT_STEP_4, "Make a rubbing of the small marker's person-shaped figure. Completing it will record the whole marker.", _human if _rubbing.active else _rubbing.get_node("RubbingButton"))
	elif not GameState.gravestones.has("baby_tomb"):
		_record_first_marker.call_deferred()
	elif not GameState.evidence_ids.has("dayfolk_appearance"):
		_guide_human_comparison()
	elif not GameState.tutorial_record_intro_heard:
		GameState.record_evidence("designer_manuscript")
		GameState.record_evidence("designer_journal")
		_play_milestone.call_deferred("tutorial_recorded", "tutorial_record_intro_heard")
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
		_guide_radio(radio, "Contact Aurora and select the first question. Choose the best evidence that helps answer the question.")
	elif "natural" not in progress.get("causes", []):
		_guide_radio(radio, "Click the underlined natural death in Aurora's reply. You can also use Read last reply to collect a missed term.", true)
	elif not read.has("baby_8_additional_10"):
		_guide_radio(radio, "You can follow up on some questions with a different piece of evidence. Select the first question again and submit A Sketch of the Infant.")
	elif "unexplained" not in progress.get("causes", []):
		_guide_radio(radio, "Collect the underlined unexplained circumstances from Aurora's reply.", true)
	elif not read.has("baby_17_comparison"):
		_guide_radio(radio, "Now ask why the marker is shaped like a person. Submit the comparison you made with the Day City figure.")
	elif not read.has("baby_17_supported_19"):
		_guide_radio(radio, "Select the second question again and follow up with the designer's manuscript.")
	elif not GameState.tutorial_hidden_heard:
		_play_milestone.call_deferred("tutorial_hidden_question", "tutorial_hidden_heard")
	elif not read.has("baby_21_hidden_23"):
		_guide_radio(radio, "Contact Aurora. Place A Sketch of the Infant in the slot before choosing a question: a hidden question about its artist will appear.")
	elif not GameState.tutorial_report_intro_heard:
		_play_milestone.call_deferred("tutorial_report_intro", "tutorial_report_intro_heard")
	else:
		var report: Dictionary = GameState.gravestone_reports.get("baby_tomb", {})
		if report.get("identity", "") == "infant" and report.get("death", "") in ["natural", "unexplained", "euthanasia"]:
			_finish_investigation.call_deferred()
		else:
			_guide_report(report)

func _guide_radio(radio: Control, instruction: String, collect_term := false) -> void:
	var controls: Dictionary = radio.tutorial_controls
	var target: Control
	if not radio.is_open():
		target = radio._button
		if collect_term: instruction = "Call Aurora again to revisit the reply and collect the underlined term."
	elif radio._reply_playing:
		if not collect_term:
			_panel.hide()
			_highlight.dismiss(false)
			_highlight_target = null
			return
		target = radio._reply_box.content_label
	elif radio._tomb.is_empty():
		instruction = "Choose the small human-shaped marker."
		target = controls.get("stone")
	elif collect_term:
		target = controls.get("replay", controls.get(radio_lesson_question()))
	elif not radio._question.is_empty():
		if radio._slot.is_empty():
			target = controls.get("evidence")
		else:
			instruction = "Send the selected evidence to Aurora."
			target = controls.get("send")
	elif radio_lesson_question() == "test_answer_baby_21":
		if radio.model.group_member(radio._slot) != "infant_graffiti":
			instruction = "Place A Sketch of the Infant in the evidence slot to reveal a new question."
			target = controls.get("sketch", controls.get("evidence"))
		else:
			instruction = "Choose the hidden question that appeared after you selected the sketch."
			target = controls.get("test_answer_baby_21")
	else:
		target = controls.get(radio_lesson_question())
	_set_step(Step.DONE, instruction, target, true)

func _guide_report(report: Dictionary) -> void:
	if not _notebook.is_open():
		_set_step(Step.DONE, "Open your notebook.", _notebook.get_node("NotebookButton"), true)
	elif _notebook.book.get_section() != 0 or _notebook.book.get_section_spread() != 0:
		_set_step(Step.DONE, "Turn to the small marker in Gravestones.", _notebook.book.tabs._tabs[0], true)
	else:
		var page: Control = _notebook.book.left_page.get_node("Gravestone")
		if report.get("identity", "") != "infant":
			_set_step(Step.DONE, "Open Identity and choose Infant.", page.identity_input, true)
		else:
			_set_step(Step.DONE, "Open Death / Departure and choose your provisional cause of death.", page.death_input, true)

func radio_lesson_question() -> String:
	if not GameState.tutorial_radio_intro_heard or GameState.investigation_tutorial_completed or GameState.notebook_preview:
		return ""
	var progress := GameState.radio_progress
	var read: Array = progress.get("read_answers", [])
	var causes: Array = progress.get("causes", [])
	if not read.has("baby_8_normal_9") or not causes.has("natural") or not read.has("baby_8_additional_10") or not causes.has("unexplained"):
		return "test_answer_baby_8"
	if not read.has("baby_17_supported_19"):
		return "test_answer_baby_17"
	if not GameState.tutorial_hidden_heard:
		return "tutorial_hidden_question"
	if not read.has("baby_21_hidden_23"):
		return "test_answer_baby_21"
	return ""


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
	if _speaking or GameState.gravestones.has("baby_tomb"): return
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
	_speaking = false
	refresh()

func _guide_human_comparison() -> void:
	if not _notebook.is_open():
		_set_step(Step.BOOK, "Open your notebook to find the person-shaped rubbing you just made.", _notebook.get_node("NotebookButton"))
	elif _notebook.book.get_section() == 1:
		var page: Control = _notebook.book.left_page
		_set_step(Step.DRAG, "Drag the person-shaped rubbing onto the figure in the Day City background.", page.get_node("Rubbings"))
	elif _notebook.book.get_section() == 0 and _notebook.book.get_section_spread() == 0:
		var page: Control = _notebook.book.left_page
		var row: HBoxContainer = page.get_node("Gravestone").rubbings_row
		var index := GameState.get_gravestone_rubbings("baby_tomb").find("infant_figure_rubbing")
		var slot := row.get_child(index) as Control if index >= 0 and index < row.get_child_count() else null
		_set_step(Step.TAB, "Click the small marker's person-shaped rubbing in its Rubbings row.", slot)
	else:
		_set_step(Step.TAB, "Return to Gravestones and find the small marker's person-shaped rubbing.", _notebook.book.tabs._tabs[0])

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
		_set_step(Step.DONE, "Scroll the mouse wheel to the 50-years-ago setting (2000). Each scroll moves one setting.", tool.get_node("FocusScale"))
	else:
		_set_step(Step.DONE, "Keep the light on the small marker for a moment. If nothing appears, click its figure or base to re-aim.", _human)


## A subtle "drag upward" gesture above an icon: a dot rises from the icon with a
## short trail and a chevron, fades out, and repeats. Draws nothing without a target.
class DragHint extends Control:
	var target: Control
	var color := Color(0.86, 0.72, 0.45)
	## Seconds for one rise, and how far it rises (pixels).
	var period := 1.6
	var rise := 70.0
	var _time := 0.0

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		z_index = 61

	func _process(delta: float) -> void:
		visible = is_instance_valid(target) and target.is_visible_in_tree()
		if not visible:
			_time = 0.0
			return
		_time = fmod(_time + delta, period)
		var rect := target.get_global_rect()
		global_position = Vector2(rect.get_center().x, rect.position.y)
		queue_redraw()

	func _draw() -> void:
		var t := clampf(_time / (period * 0.8), 0.0, 1.0)
		var y := -6.0 - rise * (1.0 - pow(1.0 - t, 2.0))
		var faded := Color(color, 0.8 * sin(t * PI))
		draw_line(Vector2(0, y + 6), Vector2(0, y + 26), Color(faded, faded.a * 0.45), 2.0, true)
		draw_circle(Vector2(0, y), 5.0, faded)
		draw_polyline(PackedVector2Array([Vector2(-7, y - 9), Vector2(0, y - 16), Vector2(7, y - 9)]), faded, 2.0, true)
