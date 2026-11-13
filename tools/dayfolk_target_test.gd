extends SceneTree
## The person-shaped rubbing belongs on the faint figure behind the small marker, not on the
## whole wash of colour around it; the figure is framed when the player is stuck; dragging a
## rubbing pulls the view back out to the whole scene.
##   godot --path . --audio-driver Dummy --resolution 1280x720 -s tools/dayfolk_target_test.gd
var failures := 0
func _initialize() -> void: _run.call_deferred()
func check(label: String, ok: bool) -> void:
	print(("PASS " if ok else "FAIL ") + label)
	if not ok: failures += 1
func wait(seconds: float) -> void: await create_timer(seconds).timeout
func _run() -> void:
	await process_frame
	var state := root.get_node("GameState")
	state._autosave_path = "user://test_dayfolk_target.autosave"  # never touch the real save
	state.cycle_tutorial_completed = true
	state.cycle_hint_heard = true
	state.tutorial_night_heard = true
	state.tutorial_day_return_heard = true
	state.camera_tutorial_completed = true
	state.current_city_day = true
	state.resume_saved_city = false
	change_scene_to_file("res://scenes/main.tscn")
	await wait(0.8)
	var main = current_scene
	state.record_gravestone("baby_tomb")
	state.record_rubbing("infant_figure_rubbing", "baby_tomb", "res://assets/Art/symbol/day.png")
	await wait(0.5)
	var target = main.get_node("DayCemetery/AppearanceOfTheDayfolk")
	var blob: Image = target.texture.get_image()
	if blob.is_compressed(): blob.decompress()
	var mask: Image = target.hit_mask.get_image()
	if mask.is_compressed(): mask.decompress()
	var inside := Vector2i(-1, -1)
	var outside := Vector2i(-1, -1)
	for y in range(0, mask.get_height(), 8):
		for x in range(0, mask.get_width(), 8):
			var in_blob := blob.get_pixel(x, y).a >= 0.5
			var in_mask := mask.get_pixel(x, y).a >= 0.5
			if in_mask and inside.x < 0 and Vector2i(x, y).distance_to(Vector2i(1030, 430)) < 40: inside = Vector2i(x, y)
			if in_blob and not in_mask and outside.x < 0 and x > 830 and y > 540: outside = Vector2i(x, y)
	var to_screen := func(px: Vector2i) -> Vector2:
		return target.get_global_transform() * (Vector2(px) * target.size / Vector2(mask.get_size()))
	check("found a pixel on the figure and one on the wash around it", inside.x >= 0 and outside.x >= 0)
	check("a drop on the figure matches", target.contains_point(to_screen.call(inside)))
	check("a drop on the wash of colour around it does not", not target.contains_point(to_screen.call(outside)))
	var rect: Rect2 = target.get_hit_global_rect()
	check("the frame rect is the figure, smaller than the whole painting", rect.has_area() and rect.size.x < target.get_global_rect().size.x * 0.4)
	# The frame.
	var tutorial = main.get_node("SunMoonTutorial")
	check("the comparison step is waiting", tutorial._comparison_pending())
	await wait(0.3)
	tutorial._comparison_since = Time.get_ticks_msec()
	tutorial._comparison_missed = false
	tutorial._update_target_frame()
	check("no frame for a player who just got here", not tutorial._target_frame.active)
	while Time.get_ticks_msec() < 11000: await wait(0.5)  # the idle clock counts engine milliseconds
	tutorial._comparison_since = Time.get_ticks_msec() - 10000
	tutorial._update_target_frame()
	check("the figure is framed once the player has been idle", tutorial._target_frame.active)
	tutorial._comparison_since = Time.get_ticks_msec()
	tutorial._comparison_missed = true
	tutorial._update_target_frame()
	check("and right after a drop in the wrong place", tutorial._target_frame.active)
	# Dragging pulls the view back out.
	tutorial._comparison_missed = false
	var zoom = main.get_node("SceneZoom")
	zoom.zoom_to(main.get_node("DayCemetery/BabyTomb"))
	await wait(1.1)
	check("zoomed in on the marker", zoom.get_zoomed() != null)
	var drag = main.get_node("NotebookTool").rubbing_drag
	drag.begin("infant_figure_rubbing", Vector2(300, 300))
	check("starting the drag shows the whole scene", zoom.get_zoomed() == null)
	tutorial._update_target_frame()
	check("the figure is framed while the rubbing is dragged", tutorial._target_frame.active)
	drag.cancel()
	await wait(1.1)
	print("dayfolk target failures: ", failures)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_dayfolk_target.autosave"))
	quit(1 if failures else 0)
