extends SceneTree

const OUT := "res://test_output/notebook_content"

func _initialize() -> void:
	_run.call_deferred()

func wait(seconds: float) -> void:
	await create_timer(seconds).timeout

func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT.path_join(name + ".png")))
	print("saved " + name)

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	FileAccess.open("res://test_output/.gdignore", FileAccess.WRITE)
	await process_frame
	var state := root.get_node("GameState")
	state.player_name = "Ann"
	state.preview_notebook_content()
	change_scene_to_file("res://scenes/main.tscn")
	await wait(1.2)
	var tool = current_scene.get_node("NotebookTool")
	await tool.open()
	await wait(0.5)
	await shot("gravestones")
	for section in [2, 3, 4]:
		tool.book.jump_to_section(section)
		await wait(0.9)
		await shot(["gravestones", "rubbings", "clues", "manuscripts", "radio_logs"][section])
		if section == 3:
			var items = tool.book.left_page.get_node("ManuscriptItems")
			items.show_document("designer_manuscript")
			await wait(0.2)
			await shot("manuscript_open")
			items.show_list()
	quit()
