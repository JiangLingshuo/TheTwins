extends SceneTree
var state
var main
var drag
var failures := 0
var mismatches := 0
var acknowledgements: Array = []
func _initialize() -> void: _run.call_deferred()
func check(text: String, ok: bool) -> void:
	print(("PASS " if ok else "FAIL ") + text)
	if not ok: failures += 1
func drop(id: String, point: Vector2) -> void:
	check("drag begins: " + id, drag.begin(id, Vector2(400, 320)))
	drag._left_book = true
	drag._drop(point)
func _run() -> void:
	await process_frame
	state = root.get_node("GameState")
	state.cycle_hint_heard = true
	state.cycle_tutorial_completed = true
	state.investigation_tutorial_completed = true
	state.camera_tutorial_completed = true
	state.record_rubbing("sky_sun_rubbing", "", state.SUN_RUBBING_TEXTURE)
	state.record_rubbing("infant_moon_rubbing", "baby_tomb", "res://assets/Art/symbol/moon.png", "moon")
	state.record_rubbing("sun_shaped_marker_rubbing", "sun_tomb", "res://assets/Art/symbol/coin&sun.png", "day_city_coin")
	# Simulate an old save with no matching_target_id on the path rubbing.
	state.record_rubbing("night_father_path_rubbing", "father_tomb", "res://assets/Art/symbol/ladder.png", "")
	change_scene_to_file("res://scenes/main.tscn")
	await create_timer(0.3).timeout
	main = current_scene
	drag = main.get_node("NotebookTool").rubbing_drag
	drag.mismatched.connect(func(_id, _target): mismatches += 1)
	drag.acknowledged.connect(func(_id, _target, message): acknowledgements.append(message))
	var sun = main.get_node("DayCemetery/Sun")
	drop("sky_sun_rubbing", sun.get_global_rect().get_center())
	check("sun onto itself acknowledges without mismatch", acknowledgements.has("You know that’s a sun.") and mismatches == 0)
	drop("sun_shaped_marker_rubbing", sun.get_global_rect().get_center())
	check("monument matches the sun without leaking coin", state.get_rubbing_meaning("sun_shaped_marker_rubbing") == "Sun" and state.get_rubbing_meaning("sky_sun_rubbing") == "Sun")
	var coin = get_nodes_in_group("flashlight_targets").filter(func(n): return n.evidence_id == "day_city_coin")[0]
	coin.discovered = true
	coin.visible = true
	state.record_evidence("day_city_coin")
	drop("sun_shaped_marker_rubbing", coin.get_global_rect().get_center())
	check("coin match upgrades prior Sun interpretation", state.get_rubbing_meaning("sun_shaped_marker_rubbing") == "Coin and Sun")
	drop("sun_shaped_marker_rubbing", sun.get_global_rect().get_center())
	check("later sun match never downgrades coin meaning", state.get_rubbing_meaning("sun_shaped_marker_rubbing") == "Coin and Sun")
	main.set_night()
	await process_frame
	var moon = main.get_node("NightCemetery/Moon")
	drop("infant_moon_rubbing", moon.get_global_rect().get_center())
	check("moon onto itself acknowledges without mismatch", acknowledgements.has("You know that’s a moon.") and mismatches == 0)
	var ladder = main.get_node("NightCemetery/Ladder")
	check("ladder registered as a scene target", ladder in get_nodes_in_group("decipher_targets"))
	var found := Vector2.ZERO
	for local in [Vector2(450, 680), Vector2(650, 500), Vector2(820, 310), Vector2(970, 180)]:
		var point: Vector2 = ladder.get_global_transform() * local
		if ladder.contains_point(point) and drag._target_at(point) == ladder:
			found = point
			break
	check("visible ladder has reachable drop region", found != Vector2.ZERO)
	drop("night_father_path_rubbing", found)
	check("old path rubbing now deciphers and grants route clue", state.is_rubbing_deciphered("night_father_path_rubbing") and state.evidence_ids.has("skyway_reference"))
	check("successful correspondence causes no mismatches", mismatches == 0)
	state.record_gravestone("altar_tomb")
	state.record_rubbing("infant_figure_rubbing", "baby_tomb", "res://assets/Art/symbol/man.png", "dayfolk_appearance")
	var radio = main.get_node("RadioTool")
	var locked: Array = radio.model.questions_for("altar_tomb").filter(func(q): return q["target"] == "test_answer_altar_12")
	check("altar child question needs the comparison", locked.size() == 1 and not locked[0]["available"])
	var infant = main.get_node("NightCemetery/AltarTomb/InfantComparisonTarget")
	drop("infant_figure_rubbing", infant.get_global_rect().get_center())
	check("Dayfolk rubbing matches the actual altar infant", state.evidence_ids.has("infant_memorial_correspondence"))
	var unlocked: Array = radio.model.questions_for("altar_tomb").filter(func(q): return q["target"] == "test_answer_altar_12")
	check("infant comparison unlocks the radio question", unlocked.size() == 1 and unlocked[0]["available"])
	main.queue_free()
	await process_frame
	print("SCENE CORRESPONDENCE: %d failures" % failures)
	quit(0 if failures == 0 else 1)
