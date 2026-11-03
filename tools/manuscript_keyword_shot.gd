extends SceneTree
func _initialize() -> void: _run.call_deferred()
func _run() -> void:
	await process_frame
	var state := root.get_node("GameState")
	state.investigation_tutorial_completed = true
	state.cycle_tutorial_completed = true
	state.record_gravestone("baby_tomb")
	change_scene_to_file("res://scenes/main.tscn")
	await create_timer(1.0).timeout
	var notebook = current_scene.get_node("NotebookTool")
	await notebook.open()
	notebook.book.jump_to_section(3)
	await create_timer(1.0).timeout
	var items = notebook.book.left_page.get_node("ManuscriptItems")
	items.show_document("designer_manuscript")
	await create_timer(0.3).timeout
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://test_output/manuscript_flow"))
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://test_output/manuscript_flow/keyword_preview.png"))
	print("KEYWORD PREVIEW SAVED")
	quit()
