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
func question_for(model, tomb: String, target: String, slot: String = "") -> Dictionary:
	for q in model.questions_for(tomb, slot):
		if q["target"] == target: return q
	return {}

func run() -> void:
	await process_frame
	var state = root.get_node("GameState")
	var model = load("res://scripts/radio_model.gd").new()
	state.current_city_day = true
	state.record_gravestone("girl_tomb")
	state.record_evidence("girl_cover_correspondence")
	var cover: String = model.data["evidence_groups"]["girl_cover_correspondence"]
	var final_question := question_for(model, "girl_tomb", "test_answer_girl_24", cover)
	check("cover proof opens the existing girl radio entry", not final_question.is_empty())
	var result: Dictionary = model.send(final_question, cover)
	check("player confirms the final conversation", result.get("choices", []).size() == 2)
	result = model.choose(result["choices"][0])
	check("new wind and Goethe opening precedes reflection", joined(result).contains("The wind echoes") and joined(result).contains("bright tumult") and result["choices"].size() == 3)
	result = model.choose(result["choices"][0])
	check("first question asks about civilization", joined(result).contains("civilization's fall"))
	result = model.choose(result["choices"][0])
	check("second question asks about the mothers", joined(result).contains("What did the mothers do"))
	result = model.choose(result["choices"][2])
	check("wrong cause has the authored reply and skips the removed third question", joined(result).contains("Both of us know") and not joined(result).contains("How do the girls feel"))
	check("absent bear and photo skip the toy exchange", not joined(result).contains("She left your toy at the marker"))
	state.record_evidence("girl_teddy_bear")
	state.record_evidence("family_photo")
	state.record_evidence("girl_painted_flower")
	state.current_city_day = false
	state.record_gravestone("mother_tomb")
	state.record_evidence("night_mother_flower")
	var flower_question := question_for(model, "mother_tomb", "test_answer_mother_flower")
	model.send(flower_question, model.data["evidence_groups"]["night_mother_flower"])
	check("Night radio records the flower meaning", state.evidence_ids.has("mother_daughter_flower_meaning"))
	state.current_city_day = true
	for id in ["bear", "flower"]:
		var tease := question_for(model, "girl_tomb", "test_answer_girl_" + id + "_preview")
		var evidence := "girl_teddy_bear" if id == "bear" else "girl_painted_flower"
		result = model.send(tease, model.data["evidence_groups"][evidence])
		check("teaser closes with fixed reply: " + id, joined(result).contains("Anything else?"))
	result = model.send(final_question, cover)
	result = model.choose(result["choices"][0])
	result = model.choose(result["choices"][0])
	result = model.choose(result["choices"][2])
	result = model.choose(result["choices"][2])
	check("best cause and photo-supported callback play", joined(result).contains("That's what I thought as well") and joined(result).contains("She left your toy at the marker"))
	var transcript := joined(result)
	var changed_to_night := false
	for i in 32:
		var choices: Array = result.get("choices", [])
		if choices.is_empty(): break
		result = model.choose(choices[0])
		changed_to_night = changed_to_night or result.get("city", "") == "night"
		transcript += joined(result)
		if result.get("hang_up", false): break
	check("daydream and Night reunion play in sequence", changed_to_night and transcript.contains("what it means to have a dream") and transcript.contains("I read her note"))
	check("paired flowers unlock the Night callback", transcript.contains("I left it there") and transcript.contains("I thought escaping without her"))
	# The final scene now ends on the open-ending event (no hang-up tag): the exchange simply runs out of choices.
	check("open ending records the departure and closes the call", transcript.contains("Tomorrow the sun will rise") and model.progress.get("final_confronted", false) and result.get("choices", []).is_empty())
	print("FINAL CONFRONTATION: " + ("ALL PASSED" if failures == 0 else str(failures) + " FAILED"))
	quit(0 if failures == 0 else 1)
