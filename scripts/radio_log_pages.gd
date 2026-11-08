extends RefCounted
## What the Notebook's Radio Logs section shows, built from the radio history
## in GameState (radio_history_* read API). Nothing is stored here.
##
## Radio Logs -> gravestone -> question -> dialogue records, plus
## "Aurora — Other Transmissions" for dialogue that answered no question.
## Lists are shown as cards (ManuscriptItems); dialogue records as text in the
## two-page reader (SpreadReader, log_style), newest last.

## Id of the Other Transmissions entry in the gravestone list.
const OTHER := "__other"
const OTHER_TITLE := "Aurora — Other Transmissions"
const PROGRESS_NOTE := "Progress counts the dialogue passages unlocked in this log. You do not need every response to solve the investigation. Additional replies may deepen your understanding of the world, but they are optional."
static var _reply_catalog: Dictionary = {}

## Count authored reply passages, not evidence submissions or repeat listening.
## Follow answer/query diversions only: returning to a menu is not another reply.
static func _reply_blocks(ops: Array, programs: Dictionary, visited: Array, blocks: Dictionary) -> void:
	var passage: Array[String] = []
	for op: Dictionary in ops:
		if op.get("op") == "line":
			passage.append(str(op.get("text", "")))
		elif op.get("op") in ["if", "goto", "choice"]:
			if not passage.is_empty():
				blocks[JSON.stringify(passage)] = passage.duplicate()
				passage.clear()
			if op.get("op") == "if":
				_reply_blocks(op.get("then", []), programs, visited, blocks)
				_reply_blocks(op.get("else", []), programs, visited, blocks)
			else:
				var target := str(op.get("target", ""))
				if (target.begins_with("test_answer_") or target.begins_with("query_night_")) and target not in visited:
					_reply_blocks(programs.get(target, []), programs, visited + [target], blocks)
	if not passage.is_empty():
		blocks[JSON.stringify(passage)] = passage.duplicate()

static func _plain_reply(text: String) -> String:
	return GameState.fill_placeholders(RegEx.create_from_string('<link="[^"]+">([^<]+)</link>').sub(text, "$1", true))

static func dialogue_progress(stone: String) -> Vector2i:
	if _reply_catalog.is_empty():
		var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/dialogue/radio_content.json"))
		for question: Dictionary in data.get("questions", []):
			var tomb := str(question.get("tomb", ""))
			if not _reply_catalog.has(tomb): _reply_catalog[tomb] = {}
			var target := str(question.get("target", ""))
			_reply_blocks(data.get("programs", {}).get(target, []), data.get("programs", {}), [target], _reply_catalog[tomb])
	var heard: Dictionary = {}
	for question in GameState.radio_history_questions(stone):
		for record: Dictionary in question.get("records", []):
			for line: Dictionary in record.get("lines", []):
				heard[_plain_reply(str(line.get("content", "")))] = true
	var unlocked := 0
	var blocks: Dictionary = _reply_catalog.get(stone, {})
	for passage: Array in blocks.values():
		var complete := true
		for line: String in passage:
			if not heard.has(_plain_reply(line)):
				complete = false
		if complete: unlocked += 1
	return Vector2i(unlocked, blocks.size())
## Invisible marks in reader text; SpreadReader (log_style) styles and removes them.
## HEADING starts a record's heading line, SPEAKER ends a speaker's name.
const HEADING := "⁠"
const SPEAKER := "⁣"


## Cards for the first level: gravestones with radio history, then Other Transmissions.
static func gravestone_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for stone in GameState.radio_history_gravestones():
		var progress := dialogue_progress(stone)
		entries.append({"id": stone, "gravestone": stone, "title": str(GameState.get_gravestone_info(stone).get("title", stone)), "progress": "%d/%d" % [progress.x, progress.y]})
	if not GameState.radio_other_transmissions().is_empty():
		entries.append({"id": OTHER, "gravestone": OTHER, "title": OTHER_TITLE})
	return entries


## Cards for a gravestone's recorded questions, in the order they were first asked.
static func question_entries(stone: String) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for question in GameState.radio_history_questions(stone):
		entries.append({"id": question["question_id"], "title": question["question_text"]})
	return entries


## Title shown above a gravestone's question cards.
static func gravestone_title(stone: String) -> String:
	return OTHER_TITLE if stone == OTHER else str(GameState.get_gravestone_info(stone).get("title", stone))


## The reader's entry for a question (or Other Transmissions when stone is OTHER):
## {"id", "title", "body"}. Every dialogue variant, oldest last_heard_at first.
static func reader_entry(stone: String, question_id: String) -> Dictionary:
	if stone == OTHER:
		var blocks: PackedStringArray = []
		for record in _by_last_heard(GameState.radio_other_transmissions()):
			blocks.append(_block(GameState.format_play_time(record["last_heard_at"]) + " · " + str(record["title"]), "", record["lines"]))
		return {"id": OTHER, "title": OTHER_TITLE, "body": "\n\n".join(blocks)}
	var title := question_id
	for question in GameState.radio_history_questions(stone):
		if question["question_id"] == question_id:
			title = question["question_text"]
	var blocks: PackedStringArray = []
	for record in _by_last_heard(GameState.radio_history_records(stone, question_id)):
		var heading := GameState.format_play_time(record["last_heard_at"])
		if not str(record["evidence_id"]).is_empty():
			var evidence := str(record["evidence_name"])
			if evidence.is_empty():
				evidence = str(GameState.get_evidence(record["evidence_id"]).get("title", record["evidence_id"]))
			heading += " · " + GameState.zh_text("Submitted: ") + GameState.zh_text(evidence)
		var follow_up := GameState.zh_text("Follow-up: ") + GameState.zh_text(str(record["follow_up"])) if not str(record["follow_up"]).is_empty() else ""
		blocks.append(_block(heading, follow_up, record["lines"]))
	return {"id": "q:" + stone + ":" + question_id, "title": title, "body": "\n\n".join(blocks)}


static func _by_last_heard(records: Array[Dictionary]) -> Array[Dictionary]:
	var sorted := records.duplicate()
	sorted.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["last_heard_at"] < b["last_heard_at"])
	return sorted


## One record: its heading line(s), then "Speaker: line" (narration has no speaker).
static func _block(heading: String, subheading: String, lines: Array) -> String:
	var rows: PackedStringArray = [HEADING + heading]
	if not subheading.is_empty():
		rows.append(HEADING + subheading)
	for line in lines:
		var speaker := str(line["speaker"])
		# The log keeps the English; the Chinese playtest shows its translation.
		rows.append((GameState.zh_text(speaker) + SPEAKER + ": " if not speaker.is_empty() else "") + GameState.zh_text(str(line["content"])))
	return "\n".join(rows)
