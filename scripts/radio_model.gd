extends RefCounted
## Temporary radio controller: executes the explicitly exported Ink subset.
## It does not run arbitrary GDScript or flatten conditional answers.

var data: Dictionary
var progress: Dictionary
var tomb := ""
var submitted_id := ""
var _context: Dictionary = {}
var _depth := 0
## Side-effect-free evaluation for hiding exhausted evidence in the picker.
var preview_only := false
var _ending_preview_evidence: Array[String] = []

func begin_report_walk() -> Dictionary:
	# A dev preview must not grant evidence or modify the live investigation.
	progress = progress.duplicate(true)
	preview_only = true
	_context = {}
	_depth = 0
	var result := {"lines": [], "choices": []}
	_program("test_walk", result)
	return result

func begin_ending(true_ending: bool, preview: bool) -> Dictionary:
	if preview:
		progress = progress.duplicate(true)
		_ending_preview_evidence.assign(["girl_teddy_bear", "family_photo", "girl_painted_flower", "mother_daughter_flower_meaning"])
	_context = {}
	_depth = 0
	var result := {"lines": [], "choices": []}
	_program("test_confrontation" if true_ending else "ending_false", result)
	return result

func _init(shared_data: Dictionary = {}) -> void:
	data = shared_data if not shared_data.is_empty() else JSON.parse_string(FileAccess.get_file_as_string("res://assets/dialogue/radio_content.json"))
	if GameState.radio_progress.is_empty():
		GameState.radio_progress = data.get("defaults", {}).duplicate(true)
	progress = GameState.radio_progress

func owns(id: String) -> bool:
	return GameState.evidence_ids.has(id) or GameState.rubbings.has(id) or id in _ending_preview_evidence

func record_type(id: String) -> int:
	var entry := GameState.get_evidence(id)
	if entry.get("category", "") == "manuscript" or id == "history_coffin_illustration":
		return 2
	return 1 if entry.get("category", "") == "rubbing" else 3

func group_member(group_id: String) -> String:
	for id in data.get("groups", {}).get(group_id, {}).get("members", []):
		if owns(id):
			return id
	return ""

func group_unlocked(group_id: String) -> bool:
	return not group_member(group_id).is_empty()

func groups_for_filter(ids: Array, filter_type: int, unlocked_only: bool) -> Array:
	var result: Array = []
	for id in ids:
		var group: Dictionary = data["groups"].get(id, {})
		if group.is_empty() or (unlocked_only and not group_unlocked(id)):
			continue
		var matches := filter_type == 0
		for member in group["members"]:
			if record_type(member) == filter_type and (not unlocked_only or owns(member)):
				matches = true
		if matches:
			result.append(id)
	return result

func _tags(id: String) -> Array:
	return GameState.get_evidence(id).get("metadata", {}).get("evidence_tag", [])

func _knows(tag: String) -> bool:
	if tag in progress.get("known_tags", []):
		return true
	for id in GameState.evidence_ids + _ending_preview_evidence:
		if tag in _tags(id):
			return true
	return false

func _membership(pool: String, value: String) -> bool:
	if pool == "owned_evidence":
		return owns(value)
	if pool == "links":
		if value == "sun" and GameState.evidence_ids.has("sun_coin_correspondence"):
			return true
		if value == "moon" and GameState.cycle_tutorial_completed:
			return true # tutorial established which shape is the moon, not its death meaning
		var rubbing_relations := {"human": "infant_figure_rubbing", "crystal": "crystal_marker_rubbing", "sun": "sun_shaped_marker_rubbing", "beast": "scholar_beast_rubbing", "river": "night_mother_river_rubbing", "father_path": "night_father_path_rubbing"}
		if rubbing_relations.has(value) and GameState.is_rubbing_deciphered(rubbing_relations[value]):
			return true
	return value in progress.get(pool, [])

func _boolean(value: bool) -> String:
	return "true" if value else "false"

func condition(code: String) -> bool:
	var text := code
	var regex := RegEx.create_from_string('(has_tag|know)\\(EvidenceTag\\.(\\w+)\\)')
	for match in regex.search_all(text):
		var value := match.get_string(2) in _tags(submitted_id) if match.get_string(1) == "has_tag" else _knows(match.get_string(2))
		text = text.replace(match.get_string(), _boolean(value))
	regex = RegEx.create_from_string('LIST_COUNT\\((\\w+)\\)')
	for match in regex.search_all(text):
		text = text.replace(match.get_string(), str(progress.get(match.get_string(1), []).size()))
	regex = RegEx.create_from_string('(\\w+)\\s*\\?\\s*\\w+\\.(\\w+)')
	for match in regex.search_all(text):
		text = text.replace(match.get_string(), _boolean(_membership(match.get_string(1), match.get_string(2))))
	regex = RegEx.create_from_string('(\\w+)\\s*==\\s*"([^"]*)"')
	for match in regex.search_all(text):
		var actual = submitted_id if match.get_string(1) == "submitted_id" else _context.get(match.get_string(1), progress.get(match.get_string(1), ""))
		text = text.replace(match.get_string(), _boolean(str(actual) == match.get_string(2)))
	text = text.replace("&&", " and ").replace("||", " or ")
	regex = RegEx.create_from_string('\\b[A-Za-z_][A-Za-z_0-9]*\\b')
	var matches := regex.search_all(text)
	matches.reverse()
	for match in matches:
		var word := match.get_string()
		if word in ["true", "false", "and", "or", "not"]:
			continue
		if not _context.has(word) and not progress.has(word):
			push_warning("Radio condition has unmapped state: " + word)
			return false
		var value = _context.get(word, progress.get(word, false))
		var literal := str(value) if value is int or value is float else _boolean(bool(value))
		text = text.substr(0, match.get_start()) + literal + text.substr(match.get_end())
	# Expression receives only booleans, numeric comparisons and logical operators.
	if RegEx.create_from_string('[^a-z0-9\\s().<>=!+-]').search(text):
		return false
	var expression := Expression.new()
	if expression.parse(text) != OK:
		push_warning("Radio condition cannot be parsed: " + code)
		return false
	var value = expression.execute([], null, false)
	return not expression.has_execute_failed() and bool(value)

func questions_for(tomb_id: String, slot_group: String = "") -> Array[Dictionary]:
	tomb = tomb_id
	submitted_id = group_member(slot_group)
	_context = {"active_tomb": tomb_id.trim_suffix("_tomb"), "supported": false}
	var result: Array[Dictionary] = []
	for question in data["questions"]:
		if not city_allows(tomb_id) or question["tomb"] != tomb_id:
			continue
		var available := condition(question["condition"])
		if question["hidden"] and not available:
			continue
		var item: Dictionary = question.duplicate(true)
		item["available"] = available
		result.append(item)
	return result

func candidates(question: Dictionary, slot_group: String = "") -> Array:
	var choices: Array = question["candidates"].duplicate()
	if question["target"] == "test_disappearance_hypothesis" and progress.get("hypothesis_open", false):
		var stage := "skin" if not progress.get("hypothesis_skin", false) else "death"
		choices = []
		for id in data["stage_candidates"][stage]:
			choices.append(data["evidence_groups"][id])
	if question["hidden"] and not slot_group.is_empty() and not choices.has(slot_group):
		choices[0] = slot_group # preserve an accepted alternative that revealed this question
	return choices

func send(question: Dictionary, slot_group: String) -> Dictionary:
	if not city_allows(question["tomb"]): return {"error": "Contact Aurora about this stone in its own city."}
	submitted_id = group_member(slot_group)
	if not slot_group.is_empty() and submitted_id.is_empty():
		return {"error": "That record has not been unlocked."}
	if not slot_group.is_empty() and not candidates(question, slot_group).has(slot_group):
		return {"error": "Choose one of this question's three records."}
	if not GameState.gravestones.has(question["tomb"]):
		return {"error": "Record this gravestone before contacting Aurora about it."}
	tomb = question["tomb"]
	_context = {"active_tomb": tomb.trim_suffix("_tomb"), "supported": false, "feedback_kind": ""}
	if not condition(question["condition"]):
		return {"error": "The question is not available with this record yet."}
	var result := {"lines": [], "choices": [], "feedback": ""}
	_depth = 0
	_program(question["target"], result)
	result["feedback"] = _context.get("feedback_kind", progress.get("feedback_kind", ""))
	return result

func choose(choice: Dictionary) -> Dictionary:
	if not condition(choice.get("condition", "true")):
		return {"error": "This follow-up is not available yet."}
	if choice.get("once", false):
		var seen: Array = progress.get("radio_choices_seen", [])
		if seen.has(choice["key"]):
			return {"error": "This follow-up has already been asked."}
		seen.append(choice["key"])
		progress["radio_choices_seen"] = seen
	var result := {"lines": [], "choices": [], "feedback": ""}
	_depth = 0
	_nodes(choice["body"], result, choice.get("source", ""))
	result["feedback"] = _context.get("feedback_kind", "")
	return result

func _assignment(code: String) -> void:
	var match := RegEx.create_from_string('^(?:temp )?(\\w+)\\s*(\\+=|=)\\s*(.*)$').search(code)
	if match == null:
		push_warning("Unsupported radio assignment: " + code)
		return
	var key := match.get_string(1)
	var operator := match.get_string(2)
	var raw := match.get_string(3)
	var ids: Array = []
	for token in RegEx.create_from_string('\\w+\\.(\\w+)').search_all(raw):
		ids.append(token.get_string(1))
	var value = raw.trim_prefix('"').trim_suffix('"')
	if raw == "true" or raw == "false": value = raw == "true"
	elif raw.is_valid_int(): value = int(raw)
	elif raw == "()": value = []
	elif not ids.is_empty(): value = ids
	if operator == "+=" and value is Array:
		var current: Array = progress.get(key, [])
		for id in value:
			if not current.has(id): current.append(id)
			if key == "owned_evidence" and not preview_only: GameState.record_evidence(id)
		progress[key] = current
	elif operator == "+=":
		progress[key] = int(progress.get(key, 0)) + int(value)
	else:
		if key == "supported" or key == "feedback_kind": _context[key] = value
		else: progress[key] = value

func _program(name: String, result: Dictionary) -> void:
	if _depth > 12:
		push_warning("Radio program exceeded its transition limit.")
		return
	_depth += 1
	_nodes(data["programs"].get(name, []), result, name)
	_depth -= 1

func _nodes(nodes: Array, result: Dictionary, source: String) -> bool:
	for instruction in nodes:
		match instruction["op"]:
			"line":
				result["lines"].append({"speaker": instruction["speaker"], "content": instruction["text"]})
			"set": _assignment(instruction["code"])
			"tag":
				var tag: String = instruction["value"]
				if tag == "feedback:gold": _context["feedback_kind"] = "hidden"
				if tag.begins_with("event:") and not preview_only: GameState.apply_notebook_event(tag)
				if tag == "city:night": result["city"] = "night"
				if tag == "radio:hang_up": result["hang_up"] = true
			"if":
				var branch: Array = instruction["then"] if condition(instruction["condition"]) else instruction["else"]
				if _nodes(branch, result, source): return true
			"goto":
				var target: String = instruction["target"]
				if data["programs"].has(target): _program(target, result)
				return true
			"choices":
				for index in instruction["items"].size():
					var choice: Dictionary = instruction["items"][index].duplicate(true)
					choice["source"] = source
					choice["key"] = source + ":" + str(index)
					if condition(choice["condition"]) and not (choice["once"] and choice["key"] in progress.get("radio_choices_seen", [])):
						result["choices"].append(choice)
				return true
	return false

func city_allows(id: String) -> bool:
	return (id in ["baby_tomb", "scholar_tomb", "sun_tomb", "girl_tomb"]) == GameState.current_city_day

func group_title(id: String) -> String:
	for candidate in data.get("groups", {}).get(id, {}).get("members", []):
		if candidate in GameState.rubbings and GameState.is_rubbing_deciphered(candidate): return GameState.rubbing_display(candidate)
	var member := group_member(id)
	if member in GameState.rubbings: return GameState.rubbing_display(member)
	return data.get("groups", {}).get(id, {}).get("title", "No record selected")


## Include three-choice records and any alternative matching a submitted tag/id,
## even if collected at a different marker. Do not follow menu-return loops.
func _related_code(target: String, visited: Array) -> String:
	if target in visited or target.begins_with("test_radio_"): return ""
	visited.append(target)
	var ops: Array = data.get("programs", {}).get(target, [])
	var code := JSON.stringify(ops)
	for match in RegEx.create_from_string('"target"\\s*:\\s*"([^" ]+)"').search_all(code):
		code += _related_code(match.get_string(1), visited)
	return code.replace("\\\"", "\"")

func related_groups(tomb_id: String) -> Array:
	var result: Array = []
	for question: Dictionary in data.get("questions", []):
		if question.get("tomb", "") != tomb_id: continue
		for group in question.get("candidates", []):
			if group not in result: result.append(group)
		var code: String = question.get("condition", "") + " " + _related_code(question.get("target", ""), [])
		var tags: Array = []
		for match in RegEx.create_from_string('has_tag\\(EvidenceTag\\.(\\w+)\\)').search_all(code): tags.append(match.get_string(1))
		for group: String in data.get("groups", {}):
			for member: String in data["groups"][group].get("members", []):
				var relevant := code.contains('submitted_id == \"' + member + '\"') or code.contains('submitted_id == "' + member + '"')
				for tag in _tags(member):
					if tag in tags: relevant = true
				if relevant and group not in result: result.append(group)
	return result

func directly_from_marker(group_id: String, tomb_id: String) -> bool:
	var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/dialogue/searchlight_placeholders.json"))
	for member: String in data.get("groups", {}).get(group_id, {}).get("members", []):
		if not owns(member): continue
		var entry := GameState.get_evidence(member)
		# Aurora-delivered documents and interpreted notebook findings are related
		# records, but were not obtained directly from the marker itself.
		if entry.get("category", "") in ["manuscript", "finding"]: continue
		var source := str(entry.get("gravestone", ""))
		for record: Dictionary in layout.get("records", []):
			if record.get("evidence_id", "") == member:
				source = str(record.get("required_grave", source))
		if source == tomb_id or member in GameState.get_gravestone_rubbings(tomb_id): return true
	return false

## Compare a read-only simulation with actually delivered log text. New state
## or new follow-ups can put a previously exhausted record back in the picker.
func has_unheard_reply(tomb_id: String, group_id: String) -> bool:
	var submitted := group_member(group_id)
	if submitted.is_empty(): return false
	var plain := RegEx.create_from_string('<link="[^"]+">([^<]+)</link>')
	for question: Dictionary in data.get("questions", []):
		if question.get("tomb", "") != tomb_id: continue
		var probe = get_script().new(data)
		probe.preview_only = true
		probe.progress = progress.duplicate(true)
		probe.submitted_id = submitted
		probe._context = {"active_tomb": tomb_id.trim_suffix("_tomb"), "supported": false}
		if not probe.condition(question.get("condition", "false")): continue
		if group_id not in probe.candidates(question, group_id if question.get("hidden", false) else ""): continue
		var heard: Dictionary = {}
		for record in GameState.radio_history_records(tomb_id, question["id"]):
			for line: Dictionary in record.get("lines", []): heard[GameState.fill_placeholders(str(line.get("content", "")))] = true
		var reply: Dictionary = probe.send(question, group_id)
		if _reply_has_new_text(probe, reply, heard, plain, []): return true
	return false


func _reply_has_new_text(probe: RefCounted, reply: Dictionary, heard: Dictionary, plain: RegEx, visited: Array) -> bool:
	for line: Dictionary in reply.get("lines", []):
		var text := GameState.fill_placeholders(plain.sub(str(line.get("content", "")), "$1", true))
		if not heard.has(text): return true
	for choice: Dictionary in reply.get("choices", []):
		var key := str(choice.get("key", ""))
		if key in visited or visited.size() > 12: continue
		var branch = get_script().new(data)
		branch.preview_only = true
		branch.progress = probe.progress.duplicate(true)
		branch._context = probe._context.duplicate(true)
		branch.submitted_id = probe.submitted_id
		branch.tomb = probe.tomb
		if _reply_has_new_text(branch, branch.choose(choice), heard, plain, visited + [key]): return true
	return false
