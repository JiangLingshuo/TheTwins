extends SceneTree

var failures := 0

func _initialize() -> void:
	_run.call_deferred()

func check(label: String, value: bool) -> void:
	print(("PASS " if value else "FAIL ") + label)
	if not value:
		failures += 1

func mouse(button: MouseButton, at: Vector2) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.position = at
	event.pressed = true
	return event

func _run() -> void:
	await process_frame
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var tool = scene.get_node("FlashlightTool")
	tool._on_button_pressed()
	check("tool enters aiming", tool.state == tool.State.AIMING)
	tool._scale.value = 45
	tool._on_catcher_input(mouse(MOUSE_BUTTON_WHEEL_UP, Vector2(300, 300)))
	check("wheel before selecting does not alter year", tool._scale.value == 45)
	tool._on_catcher_input(mouse(MOUSE_BUTTON_LEFT, Vector2(300, 300)))
	var point: Vector2 = tool.flashlight.get_beam_global_position()
	check("scene click locks the beam", tool.state == tool.State.ON and tool.flashlight.beam_locked)
	var motion := InputEventMouseMotion.new()
	motion.position = Vector2(900, 200)
	Input.parse_input_event(motion)
	await process_frame
	tool.flashlight._process(0.2)
	check("moving mouse leaves beam fixed", tool.flashlight.get_beam_global_position().is_equal_approx(point))
	tool._on_catcher_input(mouse(MOUSE_BUTTON_WHEEL_UP, Vector2(300, 300)))
	check("wheel up increases years ago", tool._scale.value == 50)
	tool._on_catcher_input(mouse(MOUSE_BUTTON_WHEEL_DOWN, Vector2(300, 300)))
	check("wheel down decreases years ago", tool._scale.value == 45)
	tool._scale.adjust_with_wheel(mouse(MOUSE_BUTTON_WHEEL_UP, Vector2(50, 100)))
	check("scale still adjusts the same focus", tool._scale.value == 50)
	tool.flashlight._process(0.5)
	check("scale adjustment keeps beam fixed", tool.flashlight.get_beam_global_position().is_equal_approx(point))
	check("focus follows the selected year", absf(tool.flashlight.focus - 50) < 0.1)
	for index in tool.flashlight.YEAR_STOPS.size():
		var point_on_ring: Vector2 = tool._scale.size * 0.5 + Vector2.from_angle(tool._scale.START_ANGLE + tool._scale.SWEEP * index / 4.0) * tool._scale._radius()
		tool._scale._set_year_at(point_on_ring)
		check("ring selects fixed year " + str(tool.flashlight.YEAR_STOPS[index]), tool._scale.value == tool.flashlight.YEAR_STOPS[index])
	for candidate in [12.0, 46.0, 53.0, 100.0, 249.0]:
		tool.flashlight.set_target_focus(candidate)
		check("beam snaps external setting " + str(candidate), tool.flashlight.focus in tool.flashlight.YEAR_STOPS)
	tool._scale.value = tool._scale.max_value
	tool._on_catcher_input(mouse(MOUSE_BUTTON_WHEEL_UP, Vector2(300, 300)))
	check("upper year limit clamped", tool._scale.value == tool._scale.max_value)
	tool._scale.value = tool._scale.min_value
	tool._on_catcher_input(mouse(MOUSE_BUTTON_WHEEL_DOWN, Vector2(300, 300)))
	check("lower year limit clamped", tool._scale.value == tool._scale.min_value)
	tool._on_catcher_input(mouse(MOUSE_BUTTON_LEFT, Vector2(600, 400)))
	check("another click repositions beam", not tool.flashlight.get_beam_global_position().is_equal_approx(point))
	check("scene clicks do not record tombstones", root.get_node("GameState").gravestones.is_empty())
	var cancel := InputEventKey.new()
	cancel.keycode = KEY_ESCAPE
	cancel.pressed = true
	tool._unhandled_key_input(cancel)
	check("Escape turns tool off", tool.state == tool.State.OFF and not tool.flashlight.active and not tool._catcher.visible)
	check("cursor stays visible", Input.mouse_mode == Input.MOUSE_MODE_VISIBLE)
	scene.queue_free()
	await process_frame
	print("FLASHLIGHT INPUT TEST: " + ("ALL PASSED" if failures == 0 else "%d FAILED" % failures))
	quit(0 if failures == 0 else 1)
