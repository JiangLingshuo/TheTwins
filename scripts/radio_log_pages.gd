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
## Invisible marks in reader text; SpreadReader (log_style) styles and removes them.
## HEADING starts a record's heading line, SPEAKER ends a speaker's name.
const HEADING := "⁠"
const SPEAKER := "⁣"


## Cards for the first level: gravestones with radio history, then Other Transmissions.
static func gravestone_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for stone in GameState.radio_history_gravestones():
		entries.append({"id": stone, "gravestone": stone, "title": str(GameState.get_gravestone_info(stone).get("title", stone))})
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
			heading += " · Submitted: " + evidence
		var follow_up := "Follow-up: " + str(record["follow_up"]) if not str(record["follow_up"]).is_empty() else ""
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
		rows.append((speaker + SPEAKER + ": " if not speaker.is_empty() else "") + str(line["content"]))
	return "\n".join(rows)
