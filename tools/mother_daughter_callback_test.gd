extends SceneTree
var failures := 0
func _initialize() -> void: run.call_deferred()
func check(label: String, ok: bool) -> void:
	print(("PASS " if ok else "FAIL ") + label)
	if not ok: failures += 1
func joined(result: Dictionary) -> String:
	var text := ""
	for line in result.get("lines", []): text += line["content"] + "\n"
	return text
func run() -> void:
	await process_frame
	var state = root.get_node("GameState")
	var model = load("res://scripts/radio_model.gd").new()
	var result := {"lines": [], "choices": [], "feedback": ""}
	model._program("test_answer_girl_24", result)
	check("ending starts with an explicit decision", result["choices"].size() == 2)
	result = model.choose(result["choices"][0])
	check("both identity clues are available", result["choices"].size() == 2)
	result = model.choose(result["choices"][1])
	check("one clue cannot unlock the identity conclusion", result["choices"].size() == 1)
	result = model.choose(result["choices"][0])
	check("both clues unlock two interpretations", result["choices"].size() == 2)
	result = model.choose(result["choices"][1])
	check("incorrect interpretation allows another attempt", result["choices"].size() == 1 and not model.progress.get("final_confronted", false))
	result = model.choose(result["choices"][0])
	check("correct deduction opens Day confrontation", joined(result).contains("One body, two lives") and result["choices"].size() == 1)
	state.record_evidence("girl_teddy_bear")
	result = {"lines": [], "choices": [], "feedback": ""}
	model._program("test_ending_day", result)
	check("bear needs photograph for identification", result["choices"].size() == 1)
	state.record_evidence("family_photo")
	result = {"lines": [], "choices": [], "feedback": ""}
	model._program("test_ending_day", result)
	check("bear and photo offer Day callback", result["choices"].size() == 2)
	result = model.choose(result["choices"][1])
	check("Day callback names the mother visit", joined(result).contains("She found the stone"))
	result = model.choose(result["choices"][0])
	result = model.choose(result["choices"][0])
	check("Day story leads to a separate Night call", result.get("city", "") == "night" and result["choices"].size() == 1)
	state.current_city_day = false
	state.record_gravestone("mother_tomb")
	check("flower question waits for trace", not model.questions_for("mother_tomb").any(func(q): return q["target"] == "test_answer_mother_flower" and q["available"]))
	state.record_evidence("night_mother_flower")
	var question: Dictionary = {}
	for q in model.questions_for("mother_tomb"):
		if q["target"] == "test_answer_mother_flower": question = q
	check("recovering paint unlocks flower question", not question.is_empty())
	result = model.send(question, "")
	check("owning trace alone does not interpret it", not state.evidence_ids.has("mother_daughter_flower_meaning"))
	result = model.send(question, model.data["evidence_groups"]["night_mother_flower"])
	check("submitted flower explains private meaning", joined(result).contains('I love you') and state.evidence_ids.has("mother_daughter_flower_meaning"))
	result = {"lines": [], "choices": [], "feedback": ""}
	model._program("test_ending_night", result)
	check("interpreted flower enables Night callback", result["choices"].size() == 2)
	result = model.choose(result["choices"][1])
	check("Night Aurora owns the childhood symbol", joined(result).contains("My mother and me"))
	result = model.choose(result["choices"][0])
	result = model.choose(result["choices"][0])
	check("both stories lead to the open ending", joined(result).contains("The radio stays open") and model.progress.get("final_confronted", false))
	result = model.choose(result["choices"][0])
	check("ending closes the call", result.get("hang_up", false))
	print("MOTHER DAUGHTER CALLBACKS: " + ("ALL PASSED" if failures == 0 else str(failures) + " FAILED"))
	quit(0 if failures == 0 else 1)
