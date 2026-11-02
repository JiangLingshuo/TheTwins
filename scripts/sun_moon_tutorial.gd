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
	_notebook.notebook_closed.connect(func() -> void: refresh())
	_notebook.book.page_changed.connect(func(_page: int) -> void: refresh())
	_notebook.rubbing_drag.sky_replaced.connect(_on_sky_replaced)
	_notebook.rubbing_drag.mismatched.connect(func(id: String, _target: Control) -> void:
		if id in ["sky_sun_rubbing", "infant_moon_rubbing"] and not GameState.cycle_tutorial_completed:
			_main.get_node("Toast").show_message("Drop the notebook's moon onto the sun in the sky.")
	)
	refresh()

func _process(_delta: float) -> void:
	# Page-opening animations finish after notebook_opened; keep the hint in sync.
	if not _speaking and not _skipping and not GameState.cycle_tutorial_completed and step >= Step.BOOK:
		refresh()

func refresh() -> void:
	if _skipping or _speaking:
		return
	var has_sun := GameState.rubbings.has("sky_sun_rubbing")
	var has_moon := GameState.rubbings.has("infant_moon_rubbing")
	_moon.collection_enabled = has_sun or GameState.cycle_tutorial_completed
	_human.collection_enabled = GameState.cycle_tutorial_completed
	if GameState.cycle_tutorial_completed:
		_set_step(Step.DONE, "Tutorial complete. Drag the sun onto the moon to return to Day City.", null)
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
	step = value
	_text.text = text
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
		_main.set_night()
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
	GameState.record_rubbing("infant_moon_rubbing", "baby_tomb", "res://assets/Art/symbols/moon.png", "moon")
	GameState.cycle_hint_heard = true
	GameState.cycle_tutorial_completed = true
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
	_dialogue.z_index = 70
	_main.add_child(_dialogue)
