extends SceneTree
## Saves real rendered screenshots to test_output/ (needs a desktop session, so
## it opens a game window for a few seconds).
## Run it with: powershell -File tools/run.ps1 shots
## With a scene path it just photographs that scene after `SCENE_DELAY` seconds:
##   powershell -File tools/run.ps1 shots res://scenes/flashlight_demo.tscn

const OUTPUT_FOLDER := "res://test_output"
const SCENE_DELAY := 2.0

var _output_path := ProjectSettings.globalize_path(OUTPUT_FOLDER)


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(_output_path)
	# Keep Godot from importing the screenshots as project assets.
	FileAccess.open(_output_path.path_join(".gdignore"), FileAccess.WRITE)
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		_shoot_notebook()
	else:
		_shoot_scene(args[0])


func _wait(seconds: float) -> void:
	await create_timer(seconds).timeout


func _shot(shot_name: String) -> void:
	await RenderingServer.frame_post_draw
	var path := _output_path.path_join(shot_name + ".png")
	root.get_texture().get_image().save_png(path)
	print("saved ", path)


func _shoot_scene(path: String) -> void:
	await process_frame
	change_scene_to_file(path)
	await _wait(SCENE_DELAY)
	await _shot(path.get_file().get_basename())
	quit()


func _shoot_notebook() -> void:
	await process_frame
	change_scene_to_file("res://scenes/start.tscn")
	await _wait(0.3)
	var start := current_scene
	var book = start.get_node("Book")
	start.dialogue_page = -1
	book.pages[0] = "Left page text"
	book.pages[1] = "Right page, #PLAYER#."
	book.pages[2] = "Back of the leaf"

	start._start_game()
	await _wait(1.4)
	book.name_input.text = "Ann"
	await _shot("notebook_1_cover")
	book._on_name_submitted("Ann")
	await _wait(1.6)
	await _shot("notebook_2_spread")
	book.right_corner._animate_to(1.0)
	book.left_corner._animate_to(1.0)
	await _wait(0.3)
	await _shot("notebook_3_corner_hover")
	book.flip_forward()
	await _wait(0.4)
	await _shot("notebook_4_turning")
	await _wait(1.0)
	book.close_to_icon()
	await _wait(2.2)
	await _shot("notebook_5_icon")
	quit()
