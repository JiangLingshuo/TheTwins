extends Node
## Global game data (autoload "GameState").

## Emitted when a rubbing is recorded or its meaning is confirmed.
signal rubbings_changed

## Name the player wrote on the book cover.
var player_name: String = ""
## Notebook contents carried from the start screen into the game.
var notebook_pages: PackedStringArray = []
## Spread the notebook was left open on.
var notebook_spread: int = 0
## A page the in-game notebook was asked to open on next (e.g. a newly recorded
## gravestone), or -1 for the default: the first spread of Rise & Set.
var notebook_section_spread: int = -1
## Ids of the symbols the player has rubbed, in the order they were collected.
var rubbings: Array[String] = []
## Rubbing id -> {"gravestone": source gravestone id, "texture": symbol texture
## path, "target": target_id of the scene object that deciphers it,
## "meaning": confirmed meaning ("" until deciphered)}.
var rubbing_records: Dictionary = {}
## Ids of the gravestones the player has recorded in the notebook (e.g. "baby_tomb").
var gravestones: Array[String] = []
## What the player wrote on each recorded gravestone's notebook page:
## gravestone id -> {"identity": String, "death": String}.
var gravestone_reports: Dictionary = {}

## Placeholders in dialogue / page text that become the player's name.
const NAME_PLACEHOLDERS := ["#PLAYER#", "{name}", "{player_name}"]

## Emitted when F2 shows or hides the development overlay.
signal debug_overlay_changed(shown: bool)
## Development overlay: the tutorial hint box (with its skip button) and the
## searchlight placeholder cards. Hidden by default; F2 toggles it.
var debug_overlay := false
var _dev_menu: PanelContainer
var _shortcut_menu: AcceptDialog
var chinese_playtest := false
var _chinese_text: Dictionary = {}
var _chinese_font: SystemFont
var _chinese_translation: Translation
var _previous_locale := ""
var ending_true := false
var ending_preview := false

const AUTOSAVE_VERSION := 1
const AUTOSAVE_FIELDS := [
	"player_name", "notebook_pages", "notebook_spread", "notebook_section_spread",
	"rubbings", "rubbing_records", "gravestones", "gravestone_reports", "evidence_ids",
	"clue_states", "radio_logs", "radio_progress", "radio_question_history", "radio_other_history",
	"play_time", "current_city_day", "searchlight_scan_progress", "camera_observations",
	"cycle_hint_heard", "cycle_tutorial_completed", "investigation_tutorial_completed",
	"tutorial_night_heard", "tutorial_hidden_heard", "tutorial_day_return_heard",
	"tutorial_record_intro_heard", "tutorial_keyword_ack_heard", "tutorial_radio_intro_heard",
	"tutorial_report_intro_heard", "tutorial_end_heard", "tutorial_searchlight_intro_heard",
	"tutorial_searchlight_found_heard", "camera_tutorial_pending", "camera_tutorial_completed",
	"formal_investigation_started",
]
var _autosave_path := "user://investigation.autosave"
var _new_run_defaults: Dictionary
var _autosave_enabled := false
var resume_saved_city := false

func _ready() -> void:
	_new_run_defaults = _checkpoint_state()

func _checkpoint_state() -> Dictionary:
	var state := {}
	for field in AUTOSAVE_FIELDS:
		state[field] = get(field)
	return state.duplicate(true)

func _apply_checkpoint_state(state: Dictionary) -> void:
	for field in AUTOSAVE_FIELDS:
		set(field, state.get(field, _new_run_defaults[field]))
	_radio_exchanges.clear()
	radio_progress.erase("active_manuscript")
	active_clue = ""
	radio_modal_open = false
	camera_modal_open = false
	notebook_preview = false
	ending_preview = false

func start_new_investigation() -> void:
	_apply_checkpoint_state(_new_run_defaults.duplicate(true))
	ending_true = false
	resume_saved_city = false
	_autosave_enabled = true

func write_autosave() -> bool:
	if not _autosave_enabled or notebook_preview or ending_preview:
		return false
	var scene := get_tree().current_scene
	var at_solitary_marker := scene != null and scene.scene_file_path == "res://scenes/ending.tscn" and ending_true
	var temp := _autosave_path + ".tmp"
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		push_warning("Could not open local autosave.")
		return false
	file.store_var({"version": AUTOSAVE_VERSION, "solitary_marker": at_solitary_marker, "state": _checkpoint_state()})
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK or DirAccess.rename_absolute(temp, _autosave_path) != OK:
		push_warning("Could not replace local autosave.")
		return false
	return true

func _read_autosave() -> Dictionary:
	if not FileAccess.file_exists(_autosave_path):
		return {}
	var file := FileAccess.open(_autosave_path, FileAccess.READ)
	if file == null:
		return {}
	var payload: Variant = file.get_var()
	if not payload is Dictionary or payload.get("version") != AUTOSAVE_VERSION:
		return {}
	var state: Variant = payload.get("state")
	if not state is Dictionary:
		return {}
	for field in AUTOSAVE_FIELDS:
		if not state.has(field) or typeof(state[field]) != typeof(_new_run_defaults[field]):
			return {}
	return payload

func has_autosave() -> bool:
	return not _read_autosave().is_empty()

func load_autosave() -> String:
	var saved := _read_autosave()
	if saved.is_empty():
		return ""
	_apply_checkpoint_state(saved["state"])
	_autosave_enabled = true
	ending_true = saved.get("solitary_marker", false)
	resume_saved_city = not ending_true
	return "res://scenes/ending.tscn" if ending_true else "res://scenes/main.tscn"

# The solitary marker is discovered after this report and is not part of its score.
const ENDING_REPORT_ANSWERS := {
	"baby_tomb": ["infant", "euthanasia"],
	"scholar_tomb": ["scholar", "disappearance"],
	"sun_tomb": ["tycoon", "disappearance"],
	"altar_tomb": ["divine_messenger", "disappearance"],
	"mother_tomb": ["night_mother", "hunger_and_thirst"],
	"father_tomb": ["night_father", "missed_sleeping_deadline"],
}

func ending_report_complete() -> bool:
	for id in ENDING_REPORT_ANSWERS:
		var report: Dictionary = gravestone_reports.get(id, {})
		if report.get("identity", "").is_empty() or report.get("death", "").is_empty():
			return false
	return true

func ending_report_passed() -> bool:
	var correct := 0
	for id in ENDING_REPORT_ANSWERS:
		var report: Dictionary = gravestone_reports.get(id, {})
		var answers: Array = ENDING_REPORT_ANSWERS[id]
		correct += int(report.get("identity", "") == answers[0])
		correct += int(report.get("death", "") == answers[1])
	return correct * 100 >= ENDING_REPORT_ANSWERS.size() * 2 * 80

func open_ending(is_true: bool, preview := false) -> void:
	ending_true = is_true
	ending_preview = preview
	radio_modal_open = false
	camera_modal_open = false
	_set_debug_overlay(false)
	get_tree().change_scene_to_file.call_deferred("res://scenes/ending.tscn")

func return_from_ending() -> void:
	_set_debug_overlay(false)
	get_tree().change_scene_to_file.call_deferred("res://scenes/main.tscn")

func _set_debug_overlay(shown: bool) -> void:
	debug_overlay = shown
	if OS.is_debug_build():
		if not is_instance_valid(_dev_menu):
			_build_dev_menu()
		_dev_menu.visible = shown
	debug_overlay_changed.emit(shown)

func _build_dev_menu() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 120
	add_child(layer)
	_dev_menu = PanelContainer.new()
	layer.add_child(_dev_menu)
	_dev_menu.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_dev_menu.offset_left = -290
	_dev_menu.offset_right = -24
	_dev_menu.offset_top = 24
	var stack := VBoxContainer.new()
	_dev_menu.add_child(stack)
	var title := Label.new()
	title.text = "DEV / Scene shortcuts"
	stack.add_child(title)
	for item in [["True ending", open_ending.bind(true, true)], ["False ending", open_ending.bind(false, true)], ["Close", _set_debug_overlay.bind(false)]]:
		var button := Button.new()
		button.text = item[0]
		button.custom_minimum_size.y = 36
		button.pressed.connect(item[1])
		stack.add_child(button)

func _toggle_playtest_language() -> void:
	if not OS.is_debug_build(): return
	if not chinese_playtest:
		if _chinese_text.is_empty():
			var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://assets/dialogue/chinese_playtest.json"))
			if not parsed is Dictionary or parsed.is_empty():
				push_error("Chinese playtest text is missing. Run tools/build_chinese_playtest.py.")
				return
			_chinese_text = parsed
			_chinese_translation = Translation.new()
			_chinese_translation.locale = "zh_CN"
			for message in _chinese_text:
				_chinese_translation.add_message(message, _chinese_text[message])
			_chinese_font = SystemFont.new()
			_chinese_font.font_names = ["Microsoft YaHei", "Noto Sans CJK SC", "PingFang SC", "WenQuanYi Zen Hei"]
			for font in [preload("res://assets/fonts/CormorantGaramond-Regular.ttf"), preload("res://assets/fonts/CormorantGaramond-SemiBold.ttf"), preload("res://assets/fonts/CormorantGaramond-Italic.ttf")]:
				var fonts: Array[Font] = font.fallbacks.duplicate()
				fonts.append(_chinese_font)
				font.fallbacks = fonts
		TranslationServer.add_translation(_chinese_translation)
		_previous_locale = TranslationServer.get_locale()
		chinese_playtest = true
		TranslationServer.set_locale("zh_CN")
	else:
		chinese_playtest = false
		TranslationServer.remove_translation(_chinese_translation)
		TranslationServer.set_locale(_previous_locale)
	_content.clear()
	radio_modal_open = false
	camera_modal_open = false
	_set_debug_overlay(false)
	get_tree().reload_current_scene.call_deferred()

func playtest_font(default_font: Font) -> Font:
	return _chinese_font if chinese_playtest and _chinese_font else default_font


func zh_text(text: String) -> String:
	return _chinese_text.get(text, text) if chinese_playtest else text

func is_dev_menu_click(event: InputEvent) -> bool:
	return is_instance_valid(_dev_menu) and _dev_menu.visible and event is InputEventMouseButton and _dev_menu.get_global_rect().has_point(event.position)


func _show_shortcuts() -> void:
	if is_instance_valid(_shortcut_menu):
		_shortcut_menu.free()
	_shortcut_menu = AcceptDialog.new()
	_shortcut_menu.title = "快捷键" if chinese_playtest else "Controls"
	_shortcut_menu.ok_button_text = "关闭" if chinese_playtest else "Close"
	var table := GridContainer.new()
	table.columns = 2
	table.add_theme_constant_override("h_separation", 26)
	table.add_theme_constant_override("v_separation", 7)
	var rows := [
		["Ctrl + T", "Show controls", "查看快捷键"],
		["Tab / N", "Open or close notebook", "打开或合上笔记本"],
		["Space / Enter", "Finish or advance dialogue", "显示整句或继续对白"],
		["Esc", "Put away searchlight or photo, end idle radio, or cancel drag", "收起探照灯或照片、退出无线电菜单，或取消拖拽"],
		["Mouse wheel", "Move the locked searchlight by one fixed year setting", "锁定探照灯后，每格切换一个年份档位"],
		["Drag year ring", "Set the searchlight year directly", "拖动圆环刻度直接调年份"],
		["F1", "Debug: switch between Day and Night", "调试：切换昼夜"],
		["F2", "Debug: toggle the developer overlay", "调试：开关开发面板"],
	]
	if OS.is_debug_build():
		rows.append(["F3", "Debug: switch Chinese / English", "调试：切换中英文"])
		rows.append(["F8", "Debug: unlock notebook preview", "调试：解锁笔记本预览"])
	for row in rows:
		for text in [row[0], row[2] if chinese_playtest else row[1]]:
			var label := Label.new()
			label.text = text
			table.add_child(label)
	_shortcut_menu.add_child(table)
	add_child(_shortcut_menu)
	_shortcut_menu.popup_centered()

func _input(event: InputEvent) -> void:
	# Read before the GUI, including during the tutorial.
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_T and event.ctrl_pressed:
			_show_shortcuts()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F2:
			_set_debug_overlay(not debug_overlay)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F3 and OS.is_debug_build():
			_toggle_playtest_language()
			get_viewport().set_input_as_handled()


## Record a rubbing the first time its symbol is revealed. Returns false if it
## was already recorded (nothing changes then).
func record_rubbing(rubbing_id: String, gravestone_id: String = "", texture_path: String = "",
		target_id: String = "") -> bool:
	if rubbing_id.is_empty() or rubbings.has(rubbing_id):
		return false
	rubbings.append(rubbing_id)
	rubbing_records[rubbing_id] = {"gravestone": gravestone_id, "texture": texture_path,
		"target": target_id, "meaning": ""}
	record_evidence(rubbing_id)
	rubbings_changed.emit()
	return true


## Decipher a collected rubbing: store its confirmed `meaning` so the notebook
## shows it (with a tick) in the Rubbings section and on its gravestone's page.
## For story progression, e.g.
##     GameState.confirm_rubbing_meaning("infant_moon_rubbing", "Night / the other city")
## Returns false if the rubbing has not been collected or `meaning` is blank.
## Calling it again replaces the meaning; collection order never changes.
func confirm_rubbing_meaning(rubbing_id: String, meaning: String) -> bool:
	meaning = meaning.strip_edges()
	if meaning.is_empty() or not rubbings.has(rubbing_id):
		return false
	var record: Dictionary = rubbing_records.get(rubbing_id, {})
	if record.get("meaning", "") != meaning:
		record["meaning"] = meaning
		rubbing_records[rubbing_id] = record
		rubbings_changed.emit()
	return true


## True once a rubbing's meaning has been confirmed.
func is_rubbing_deciphered(rubbing_id: String) -> bool:
	return not get_rubbing_meaning(rubbing_id).is_empty()


## Confirmed meaning of a rubbing, or "" while it is undeciphered.
func get_rubbing_meaning(rubbing_id: String) -> String:
	if rubbing_id == "infant_figure_rubbing" and rubbings.has(rubbing_id) and evidence_ids.has("dayfolk_appearance"):
		return "Dayfolk"
	return rubbing_records.get(rubbing_id, {}).get("meaning", "")


## target_id of the scene object that deciphers a rubbing ("" if none).
func get_rubbing_target(rubbing_id: String) -> String:
	return rubbing_records.get(rubbing_id, {}).get("target", "")


## Texture path of a rubbing's symbol ("" if unknown).
const SUN_RUBBING_TEXTURE := "res://assets/Art/symbol/coin&sun.png"

func get_rubbing_texture(rubbing_id: String) -> String:
	if rubbing_id == "sky_sun_rubbing" and rubbings.has(rubbing_id):
		return SUN_RUBBING_TEXTURE
	return rubbing_records.get(rubbing_id, {}).get("texture", "")


## Rubbings taken from one gravestone, in collection order.
func get_gravestone_rubbings(gravestone_id: String) -> Array[String]:
	return rubbings.filter(func(id: String) -> bool:
		return rubbing_records.get(id, {}).get("gravestone", "") == gravestone_id)


## Returns `text` with every name placeholder replaced by the player's name.
func fill_placeholders(text: String) -> String:
	text = zh_text(text)
	for placeholder in NAME_PLACEHOLDERS:
		text = text.replace(placeholder, player_name)
	return text


# --- Runtime notebook content: authored catalog vs. player-owned entries ---
signal notebook_changed

var evidence_ids: Array[String] = []
var radio_logs: Array[Dictionary] = []
var notebook_preview := false
var radio_progress: Dictionary = {}
var radio_modal_open := false
var cycle_hint_heard := false
var cycle_tutorial_completed := false
var _content: Dictionary = {}


func content_catalog() -> Dictionary:
	if _content.is_empty():
		var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://assets/dialogue/notebook_content.json"))
		if parsed is Dictionary:
			_content = parsed
			if chinese_playtest:
				for section in ["gravestones", "evidence"]:
					for entry in _content[section].values():
						for field in ["title", "description", "body", "interactive_body"]:
							if entry.has(field):
								entry[field] = zh_text(entry[field])
	return _content


## A clue revealed by a rubbing gets its title and text from the reveal, plus
## a "reveal" key ({rubbing, object_texture}) the notebook draws as a figure.
func get_evidence(id: String) -> Dictionary:
	var entry: Dictionary = content_catalog().get("evidence", {}).get(id, {})
	var reveal := get_clue_reveal(id)
	if reveal.is_empty():
		return entry
	entry = entry.duplicate(true)
	entry["id"] = id
	entry["category"] = entry.get("category", "observation")
	if reveal.has("title"):
		entry["title"] = zh_text(reveal["title"])
	var text: String = reveal.get("text", "")
	entry["body"] = text
	entry["interactive_body"] = text
	entry["reveal"] = reveal
	return entry


## Emitted once when a piece of evidence (clue, rubbing or manuscript) is recorded.
signal evidence_recorded(id: String)

func record_evidence(id: String) -> bool:
	if evidence_ids.has(id) or get_evidence(id).is_empty():
		return false
	evidence_ids.append(id)
	if is_clue(id):
		clue_states[id] = "unread"
	evidence_recorded.emit(id)
	notebook_changed.emit()
	return true


# --- Clues --------------------------------------------------------------------

## Clue id -> "unread" (just recorded, shows NEW in the notebook) or "finished"
## (opened and closed again).
var clue_states: Dictionary = {}
## Clue open in the notebook ("" = none); finished when the reader leaves it.
var active_clue := ""

## True for evidence shown in the Clues section (not rubbings or manuscripts).
func is_clue(id: String) -> bool:
	return get_evidence(id).get("category", "") not in ["manuscript", "rubbing", ""]

func is_clue_unread(id: String) -> bool:
	return clue_states.get(id, "") == "unread"

func open_clue(id: String) -> void:
	finish_current_manuscript()
	active_clue = id


# --- Rubbing reveals: a rubbing dropped on a matching scene object reveals a clue ---

var _reveals: Array = []
var _reveals_loaded := false

## All reveals from rubbing_reveals.json: {rubbing, target, clue, title?,
## object_texture, text?}.
func rubbing_reveals() -> Array:
	if not _reveals_loaded:
		_reveals_loaded = true
		var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://assets/dialogue/rubbing_reveals.json"))
		if parsed is Dictionary:
			_reveals = parsed.get("reveals", [])
	return _reveals

## The reveal for dropping `rubbing_id` on the object with `target_id`, or {}.
func find_rubbing_reveal(rubbing_id: String, target_id: String) -> Dictionary:
	for reveal in rubbing_reveals():
		if reveal.get("rubbing", "") == rubbing_id and reveal.get("target", "") == target_id:
			return reveal
	return {}

## The reveal that records clue `clue_id`, or {}.
func get_clue_reveal(clue_id: String) -> Dictionary:
	for reveal in rubbing_reveals():
		if reveal.get("clue", "") == clue_id:
			return reveal
	return {}


func record_gravestone(id: String) -> bool:
	if gravestones.has(id) or not content_catalog().get("gravestones", {}).has(id):
		return false
	gravestones.append(id)
	# Draft delivery schedule: only the local introduction documents, never all manuscripts.
	var deliveries := {
		"baby_tomb": ["designer_manuscript", "designer_journal"],
		"scholar_tomb": ["profession_record", "disappearance_inquiry"],
		"altar_tomb": ["crystal_god_prophecy"],
		"father_tomb": ["skyway_history", "natural_collapse_record"],
		"girl_tomb": ["girl_diary", "day_city_history"],
	}
	# During the tutorial, Aurora delivers these after the scene comparison.
	if id == "baby_tomb" and tutorial_day_return_heard and not investigation_tutorial_completed and not notebook_preview and not evidence_ids.has("dayfolk_appearance"):
		deliveries.erase(id)
	for evidence_id in deliveries.get(id, []):
		record_evidence(evidence_id)
	if id in ["mother_tomb", "father_tomb"] and "mother_tomb" in gravestones and "father_tomb" in gravestones:
		record_evidence("infant_medical_record")
	notebook_changed.emit()
	write_autosave()
	return true


func get_gravestone_info(id: String) -> Dictionary:
	var info: Dictionary = content_catalog().get("gravestones", {}).get(id, {}).duplicate(true)
	info["clues"] = []
	for evidence_id in evidence_ids:
		var entry := get_evidence(evidence_id)
		if id in entry.get("gravestones", [entry.get("gravestone", "")]) and entry.get("category", "") not in ["rubbing", "manuscript"]:
			info["clues"].append({"id": evidence_id, "title": entry.get("title", evidence_id), "body": entry.get("body", "")})
	return info


## Gravestone whose manuscripts the Manuscripts section is limited to ("" = all).
var manuscript_filter := ""
## Tool ("rubbing", "searchlight", "camera" or "finding") the Clues section is limited to ("" = all).
var clue_filter := ""

## How a clue was obtained: the tool named in its metadata, else "finding"
## (something worked out in the notebook or handed over).
func clue_tool(entry: Dictionary) -> String:
	var tool: String = str(entry.get("metadata", {}).get("tool", [""])[0])
	return tool if tool in ["rubbing", "searchlight", "camera"] else "finding"

func notebook_entries(section: int, apply_filter: bool = true) -> Array[Dictionary]:
	if section == 4:
		return radio_logs.duplicate(true)
	var entries: Array[Dictionary] = []
	for id in evidence_ids:
		var entry := get_evidence(id)
		var category: String = entry.get("category", "")
		if section == 3 and category == "manuscript" and apply_filter and not manuscript_filter.is_empty() and entry.get("gravestone", "") != manuscript_filter:
			continue
		if section == 2 and category not in ["manuscript", "rubbing"] and apply_filter and not clue_filter.is_empty() and clue_tool(entry) != clue_filter:
			continue
		if (section == 3 and category == "manuscript") or (section == 2 and category not in ["manuscript", "rubbing"]):
			entries.append(entry)
	return entries


# Log only lines actually displayed by the dialogue player. Do not log every branch on load.
func append_radio_line(session_id: String, line: Dictionary) -> void:
	if session_id.is_empty():
		return
	var log: Dictionary = {}
	for existing in radio_logs:
		if existing["id"] == session_id:
			log = existing
			break
	if log.is_empty():
		log = {"id": session_id, "title": "Opening transmission" if session_id == "opening" else "Radio transmission", "lines": [], "body": ""}
		if session_id.begins_with("radio:"):
			var stone_id := session_id.split(":")[1]
			log["title"] = "Aurora — " + str(get_gravestone_info(stone_id).get("title", "Radio transmission"))
		radio_logs.append(log)
	log["lines"].append(line.duplicate())
	var speaker: String = line.get("speaker", "")
	var text: String = line.get("content", "")
	log["body"] += ("\n\n" if not log["body"].is_empty() else "") + ((speaker + ": ") if not speaker.is_empty() else "") + text
	# The same delivered line also goes to the open exchange of the radio history.
	if _radio_exchanges.has(session_id):
		_radio_exchanges[session_id]["lines"].append({"speaker": speaker, "content": text})
	notebook_changed.emit()


# --- Radio dialogue history (data for the Notebook's Radio Logs) --------------
#
# What the player actually heard, grouped as
#   gravestone id -> question id -> dialogue variants   (radio questions)
#   other transmissions                                 (opening call, tutorial dialogue)
# The runtime call/session id ("radio:<tomb>:<n>") is only used to route the
# delivered lines of one exchange; it never decides grouping or identity.
#
# One exchange = one question asked (or one follow-up chosen) and the reply
# that played for it, or one non-question transmission. Lines are collected
# from append_radio_line(), which the dialogue box calls as each line is shown,
# so only delivered lines are kept. The exchange is committed when the
# dialogue box finishes (end_radio_exchange()).
#
# Question record (one dialogue variant):
#   {"evidence_id": String ("" = no evidence), "evidence_group": String,
#    "evidence_name": String, "follow_up": String ("" = the question itself,
#    else the follow-up choice's label), "lines": [{"speaker", "content"}],
#    "first_heard_at": float, "last_heard_at": float}   (seconds of play_time)
# Identity: gravestone + question + evidence_id + follow_up + lines (speaker,
# content, order). Hearing an identical variant again only updates last_heard_at.
#
# Other transmission record:
#   {"source_id": String, "title": String, "lines": [...],
#    "first_heard_at": float, "last_heard_at": float}
# Identity: source_id + lines.

## Emitted after a radio history record is added or heard again.
signal radio_history_changed

## Gameplay seconds since the game started. Counted in _process, so it stops
## while the scene tree is paused, and carries on across scene changes.
var play_time := 0.0
## gravestone id -> {question id -> {"gravestone_id", "question_id",
## "question_text", "records": Array of question records}}. Insertion order is
## first-heard order.
var radio_question_history: Dictionary = {}
## Other transmissions, in first-heard order.
var radio_other_history: Array[Dictionary] = []
## Log session id -> {"context": Dictionary, "lines": Array} while its dialogue plays.
var _radio_exchanges: Dictionary = {}


func _process(delta: float) -> void:
	play_time += delta


## "HH:MM:SS" for a play_time value.
static func format_play_time(seconds: float) -> String:
	var total := int(seconds)
	return "%02d:%02d:%02d" % [total / 3600, (total / 60) % 60, total % 60]


## Start collecting the lines delivered on `session_id`. `question` describes a
## radio question exchange ({"gravestone_id", "question_id", "question_text",
## "evidence_id", "evidence_group", "evidence_name", "follow_up"}); leave it
## empty for a non-question transmission (`title` names it).
func begin_radio_exchange(session_id: String, question: Dictionary = {}, title: String = "") -> void:
	if session_id.is_empty():
		return
	end_radio_exchange(session_id)  # an exchange left open on this session ends here
	_radio_exchanges[session_id] = {"context": question.duplicate(), "title": title, "lines": []}


func has_radio_exchange(session_id: String) -> bool:
	return _radio_exchanges.has(session_id)


## Commit the exchange on `session_id` (called when its dialogue has finished).
## An exchange in which no line was delivered records nothing.
func end_radio_exchange(session_id: String) -> void:
	if not _radio_exchanges.has(session_id):
		return
	var exchange: Dictionary = _radio_exchanges[session_id]
	_radio_exchanges.erase(session_id)
	var lines: Array = exchange["lines"]
	if lines.is_empty():
		return
	if exchange["context"].is_empty():
		_record_other_transmission(session_id, exchange["title"], lines)
	else:
		_record_question_dialogue(exchange["context"], lines)
	radio_history_changed.emit()


func _record_question_dialogue(context: Dictionary, lines: Array) -> void:
	var stone: String = context.get("gravestone_id", "")
	var question_id: String = context.get("question_id", "")
	if not radio_question_history.has(stone):
		radio_question_history[stone] = {}
	var questions: Dictionary = radio_question_history[stone]
	if not questions.has(question_id):
		questions[question_id] = {"gravestone_id": stone, "question_id": question_id,
			"question_text": context.get("question_text", ""), "records": []}
	var records: Array = questions[question_id]["records"]
	var evidence_id: String = context.get("evidence_id", "")
	var follow_up: String = context.get("follow_up", "")
	var key := JSON.stringify(lines)
	for record in records:
		if record["evidence_id"] == evidence_id and record["follow_up"] == follow_up \
				and JSON.stringify(record["lines"]) == key:
			record["last_heard_at"] = play_time
			return
	records.append({"evidence_id": evidence_id, "evidence_group": context.get("evidence_group", ""),
		"evidence_name": context.get("evidence_name", ""), "follow_up": follow_up,
		"lines": lines.duplicate(true), "first_heard_at": play_time, "last_heard_at": play_time})


func _record_other_transmission(source_id: String, title: String, lines: Array) -> void:
	var key := JSON.stringify(lines)
	for record in radio_other_history:
		if record["source_id"] == source_id and JSON.stringify(record["lines"]) == key:
			record["last_heard_at"] = play_time
			return
	radio_other_history.append({"source_id": source_id, "title": title, "lines": lines.duplicate(true),
		"first_heard_at": play_time, "last_heard_at": play_time})


## Read API for the Notebook's Radio Logs. All return copies, with name
## placeholders ("#PLAYER#", "{name}") resolved as the player saw them; the
## stored lines keep the raw text so record identity does not depend on the name.

## Gravestone ids that have recorded radio questions, in first-heard order.
func radio_history_gravestones() -> Array[String]:
	var ids: Array[String] = []
	for stone in radio_question_history:
		ids.append(stone)
	return ids


## Recorded questions of a gravestone, in first-heard order: each
## {"gravestone_id", "question_id", "question_text", "records"}.
func radio_history_questions(gravestone_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for question in radio_question_history.get(gravestone_id, {}).values():
		var copy: Dictionary = question.duplicate(true)
		copy["question_text"] = fill_placeholders(copy["question_text"])
		var records: Array = []
		for record in copy["records"]:
			records.append(_player_facing(record))
		copy["records"] = records
		result.append(copy)
	return result


## Dialogue variants heard for one question, in first-heard order (see the
## question record above).
func radio_history_records(gravestone_id: String, question_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for record in radio_question_history.get(gravestone_id, {}).get(question_id, {}).get("records", []):
		result.append(_player_facing(record))
	return result


## Non-question transmissions (opening call, tutorial dialogue), in first-heard order.
func radio_other_transmissions() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for record in radio_other_history:
		result.append(_player_facing(record))
	return result


## A copy of a history record with its speakers, lines and follow-up label as displayed.
func _player_facing(record: Dictionary) -> Dictionary:
	var copy: Dictionary = record.duplicate(true)
	for line in copy["lines"]:
		line["speaker"] = fill_placeholders(line["speaker"])
		line["content"] = fill_placeholders(line["content"])
	if copy.has("follow_up"):
		copy["follow_up"] = fill_placeholders(copy["follow_up"])
	return copy


# The radio controller must select the successful Ink branch before calling this.
func record_radio_answer(answer_id: String, session_id: String) -> bool:
	var answer: Dictionary = content_catalog().get("radio_answers", {}).get(answer_id, {})
	if answer.is_empty() or answer.get("preview_only", false):
		return false
	for line in answer.get("lines", []):
		append_radio_line(session_id, line)
	return true


# Supports the existing Ink grant/collect/translation event conventions.
func apply_notebook_event(tag: String) -> void:
	if tag == "event:decipher_human": confirm_rubbing_meaning("infant_figure_rubbing", "A person without an assigned occupation")
	if tag.begins_with("event:grant_evidence:"):
		record_evidence(tag.trim_prefix("event:grant_evidence:"))
	if tag.begins_with("event:night_symbol_queried:"):
		var glyph := tag.trim_prefix("event:night_symbol_queried:")
		var translations := {
			"blessing": {"ids": ["altar_blessing_glyph"], "meaning": "The Crystal God's sign, left as a blessing for the departed"},
			"unending_path": {"ids": ["altar_path_rubbing", "girl_path_rubbing"], "meaning": "An unending journey / disappearance"},
			"dry_river": {"ids": ["night_mother_river_rubbing"], "meaning": "A river that has run dry"},
			"ascending_path": {"ids": ["night_father_path_rubbing"], "meaning": "A path toward the surface"},
			"crystal_god": {"ids": ["crystal_god_rubbing", "night_father_god_rubbing"], "meaning": "Faith in the Crystal God, also left on graves as a blessing"},
		}
		var translation: Dictionary = translations.get(glyph, {})
		for rubbing_id in translation.get("ids", []):
			confirm_rubbing_meaning(rubbing_id, translation.get("meaning", ""))



# Development-only inspection. Never invoked by normal play; reset when process exits.
func preview_notebook_content() -> void:
	if not OS.is_debug_build():
		return
	notebook_preview = true
	for id in content_catalog().get("gravestones", {}):
		record_gravestone(id)
	for id in content_catalog().get("evidence", {}):
		var entry := get_evidence(id)
		if entry.get("category", "") == "rubbing":
			record_rubbing(id, entry.get("gravestone", ""))
		else:
			record_evidence(id)
	for id in content_catalog().get("radio_answers", {}):
		var answer: Dictionary = content_catalog()["radio_answers"][id]
		var log := {"id": "preview:" + id, "title": "DEV text preview — " + id, "body": ""}
		for line in answer["lines"]:
			log["body"] += str(line.get("speaker", "")) + ": " + str(line.get("content", "")) + "\n\n"
		if not radio_logs.any(func(existing: Dictionary) -> bool: return existing["id"] == log["id"]):
			radio_logs.append(log)
	notebook_changed.emit()


# The two sky icons have their own notebook spread, separate from ordinary rubbings.
func regular_rubbings() -> Array[String]:
	return rubbings.filter(func(id: String) -> bool: return id not in ["sky_sun_rubbing", "infant_moon_rubbing"])


var investigation_tutorial_completed := false
var tutorial_night_heard := false
var tutorial_hidden_heard := false
var current_city_day := true
const IDENTITY_LABELS := {"infant": "Infant", "scholar": "Scholar", "tycoon": "Tycoon", "divine_messenger": "Divine Messenger", "night_mother": "Holy Mother", "night_father": "Holy Father", "aurora": "Aurora", "funerary_artist": "Funerary Artist"}
const CAUSE_LABELS := {"natural": "Natural death", "unexplained": "Unexplained circumstances", "euthanasia": "Euthanasia", "hunger_and_thirst": "Hunger and thirst", "disappearance": "Disappearance", "missed_sleeping_deadline": "Exceeded the day/night limit", "escape": "Departure"}

func report_options(pool: String, tomb_id: String) -> Array[String]:
	var result: Array[String] = []
	for value in radio_progress.get(pool, []):
		if pool == "identities":
			var used := false
			for other in gravestone_reports:
				if other != tomb_id and gravestone_reports[other].get("identity", "") == value: used = true
			if used: continue
		result.append(value)
	return result

func set_report_choice(tomb_id: String, field: String, value: String) -> bool:
	if tomb_id not in gravestones or field not in ["identity", "death"]: return false
	if not value.is_empty() and value not in report_options("identities" if field == "identity" else "causes", tomb_id): return false
	var report: Dictionary = gravestone_reports.get(tomb_id, {}).duplicate()
	report[field] = value
	gravestone_reports[tomb_id] = report
	notebook_changed.emit()
	return true

func rubbing_display(id: String) -> String:
	var meaning := get_rubbing_meaning(id)
	return ("☾" if id == "infant_moon_rubbing" else get_evidence(id).get("title", id)) + (" → " + zh_text(meaning) if not meaning.is_empty() else " · " + zh_text("undeciphered"))


# Negative scans retain checked endpoints when the scene is recreated.
var searchlight_scan_progress: Dictionary = {}


var tutorial_day_return_heard := false
var tutorial_record_intro_heard := false
var tutorial_keyword_ack_heard := false
var tutorial_radio_intro_heard := false
var tutorial_report_intro_heard := false
var tutorial_end_heard := false
signal term_collected(term_id: String)

func collect_term(id: String) -> void:
	var identities := {"infant": "infant", "scholar": "scholar", "tycoon": "tycoon", "divine_messenger": "divine_messenger", "night_mother": "night_mother", "night_father": "night_father", "aurora": "aurora", "funerary_artist": "funerary_artist"}
	var causes := {"natural": "natural", "unexplained death": "unexplained", "euthanasia": "euthanasia", "thirst": "hunger_and_thirst", "disappearance": "disappearance", "missed_sleeping_deadline": "missed_sleeping_deadline", "escape": "escape"}
	var pool := "identities" if identities.has(id) else ("causes" if causes.has(id) else "clue_terms")
	var value: String = identities.get(id, causes.get(id, id))
	var stored: Variant = radio_progress.get(pool, [])
	var values: Array = stored if stored is Array else ([] if str(stored).is_empty() else [str(stored)])
	if not values.has(value): values.append(value)
	radio_progress[pool] = values
	# Signals let the tutorial respond without hard-coding the source UI.
	term_collected.emit(id)
	notebook_changed.emit()

func deliver_day_manuscripts() -> void:
	for id in content_catalog().get("evidence", {}):
		if id in ["infant_medical_record", "girl_diary"]: continue # Delivered at their own gravestone milestones.
		var entry := get_evidence(id)
		if entry.get("category", "") != "manuscript": continue
		var places: Array = entry.get("metadata", {}).get("related_location", [])
		if "night_cemetery" in places: continue
		if "day_cemetery" in places or entry.get("gravestone", "") in ["baby_tomb", "scholar_tomb", "sun_tomb", "girl_tomb"]: record_evidence(id)


## Called whenever the notebook reader leaves a document (back button, page
## turn, notebook closed). Also finishes an open clue, removing its NEW sign.
func finish_current_manuscript() -> void:
	if not active_clue.is_empty():
		clue_states[active_clue] = "finished"
		active_clue = ""
		notebook_changed.emit()
	var id: String = radio_progress.get("active_manuscript", "")
	if id.is_empty(): return
	var finished: Array = radio_progress.get("finished_manuscripts", [])
	if not finished.has(id): finished.append(id)
	radio_progress["finished_manuscripts"] = finished
	radio_progress["active_manuscript"] = ""


var tutorial_searchlight_intro_heard := false
var tutorial_searchlight_found_heard := false


var camera_modal_open := false
var camera_tutorial_pending := false
var camera_tutorial_completed := false
var formal_investigation_started := false
var camera_observations: Dictionary = {}
