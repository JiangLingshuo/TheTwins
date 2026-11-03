extends SceneTree
func _initialize() -> void:
	_run.call_deferred()
func wait(seconds: float) -> void:
	await create_timer(seconds).timeout
func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://test_output/radio_framework/" + name + ".png"))
	print("saved " + name)
func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://test_output/radio_framework"))
	FileAccess.open("res://test_output/.gdignore", FileAccess.WRITE)
	await process_frame
	var state := root.get_node("GameState")
	state.player_name = "Ann"
	state.preview_notebook_content()
	state.cycle_tutorial_completed = true
	state.cycle_hint_heard = true
	change_scene_to_file("res://scenes/main.tscn")
	await wait(1.2)
	var radio = current_scene.get_node("RadioTool")
	await shot("01_four_tools")
	radio.open()
	await wait(0.3)
	await shot("02_choose_grave")
	radio._start_call("baby_tomb")
	radio._set_slot(radio.model.data["evidence_groups"]["infant_graffiti"])
	await wait(0.3)
	await shot("03_hidden_questions")
	var question: Dictionary = {}
	for q in radio.model.data["questions"]:
		if q["target"] == "test_answer_baby_8": question = q
	radio._select_question(question)
	await wait(0.3)
	await shot("04_three_candidates")
	radio._set_slot(question["candidates"][0])
	radio._send()
	await wait(0.3)
	await shot("05_reply")
	radio._set_filter(2)
	await wait(0.3)
	await shot("06_manuscript_filter")
	quit()
