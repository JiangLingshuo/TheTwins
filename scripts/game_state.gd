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
	return rubbing_records.get(rubbing_id, {}).get("meaning", "")


## target_id of the scene object that deciphers a rubbing ("" if none).
func get_rubbing_target(rubbing_id: String) -> String:
	return rubbing_records.get(rubbing_id, {}).get("target", "")


## Texture path of a rubbing's symbol ("" if unknown).
func get_rubbing_texture(rubbing_id: String) -> String:
	return rubbing_records.get(rubbing_id, {}).get("texture", "")


## Rubbings taken from one gravestone, in collection order.
func get_gravestone_rubbings(gravestone_id: String) -> Array[String]:
	return rubbings.filter(func(id: String) -> bool:
		return rubbing_records.get(id, {}).get("gravestone", "") == gravestone_id)


## Returns `text` with every name placeholder replaced by the player's name.
func fill_placeholders(text: String) -> String:
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
	return _content


func get_evidence(id: String) -> Dictionary:
	return content_catalog().get("evidence", {}).get(id, {})


func record_evidence(id: String) -> bool:
	if evidence_ids.has(id) or get_evidence(id).is_empty():
		return false
	evidence_ids.append(id)
	notebook_changed.emit()
	return true


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
	for evidence_id in deliveries.get(id, []):
		record_evidence(evidence_id)
	notebook_changed.emit()
	return true


func get_gravestone_info(id: String) -> Dictionary:
	var info: Dictionary = content_catalog().get("gravestones", {}).get(id, {}).duplicate(true)
	info["clues"] = []
	for evidence_id in evidence_ids:
		var entry := get_evidence(evidence_id)
		if id in entry.get("gravestones", [entry.get("gravestone", "")]) and entry.get("category", "") not in ["rubbing", "manuscript"]:
			info["clues"].append({"id": evidence_id, "title": entry.get("title", evidence_id), "body": entry.get("body", "")})
	return info


func notebook_entries(section: int) -> Array[Dictionary]:
	if section == 4:
		return radio_logs.duplicate(true)
	var entries: Array[Dictionary] = []
	for id in evidence_ids:
		var entry := get_evidence(id)
		var category: String = entry.get("category", "")
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
	notebook_changed.emit()


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
			"blessing": {"ids": ["altar_blessing_glyph"], "meaning": "A blessing for the departed"},
			"unending_path": {"ids": ["altar_path_rubbing", "girl_path_rubbing"], "meaning": "An unending journey / disappearance"},
			"dry_river": {"ids": ["night_mother_river_rubbing"], "meaning": "A river that has run dry"},
			"ascending_path": {"ids": ["night_father_path_rubbing"], "meaning": "A path toward the surface"},
			"crystal_god": {"ids": ["crystal_god_rubbing", "night_father_god_rubbing"], "meaning": "Faith in the Crystal God"},
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
const CAUSE_LABELS := {"natural": "Natural death", "unexplained": "Unexplained circumstances", "hunger_and_thirst": "Hunger and thirst", "disappearance": "Disappearance", "missed_sleeping_deadline": "Exceeded the day/night limit", "escape": "Departure"}

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
	return ("☾" if id == "infant_moon_rubbing" else get_evidence(id).get("title", id)) + (" → " + meaning if not meaning.is_empty() else " · undeciphered")


# Negative scans retain checked endpoints when the scene is recreated.
var searchlight_scan_progress: Dictionary = {}


var tutorial_day_return_heard := false
var tutorial_record_intro_heard := false
var tutorial_keyword_ack_heard := false
var tutorial_radio_intro_heard := false
var tutorial_end_heard := false
signal term_collected(term_id: String)

func collect_term(id: String) -> void:
	var identities := {"infant": "infant", "scholar": "scholar", "tycoon": "tycoon", "divine_messenger": "divine_messenger", "night_mother": "night_mother", "night_father": "night_father", "aurora": "aurora", "funerary_artist": "funerary_artist"}
	var causes := {"natural": "natural", "unexplained death": "unexplained", "thirst": "hunger_and_thirst", "disappearance": "disappearance", "missed_sleeping_deadline": "missed_sleeping_deadline", "escape": "escape"}
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
		var entry := get_evidence(id)
		if entry.get("category", "") != "manuscript": continue
		var places: Array = entry.get("metadata", {}).get("related_location", [])
		if "night_cemetery" in places: continue
		if "day_cemetery" in places or entry.get("gravestone", "") in ["baby_tomb", "scholar_tomb", "sun_tomb", "girl_tomb"]: record_evidence(id)


func finish_current_manuscript() -> void:
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
