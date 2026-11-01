extends CanvasLayer
## Tutorial hints (autoload "Tutorial").
##
## Each hint has an id and is shown only once per game. To add a new tutorial:
##   1. add an id constant below,
##   2. call Tutorial.show_once(Tutorial.MY_ID, the_control_to_point_at)
##      where it should happen.
## The hint blinks a frame around the control and goes away early as soon as
## the player hovers or clicks that control.

## Emitted when a hint starts (id) and when it ends.
signal hint_started(id: String)
signal hint_finished(id: String)

## Hint ids.
const TURN_PAGE := "turn_page"  ## Book: the page corner you click to turn the page.

var _seen: Dictionary = {}
var _current_id := ""
var _current_target: Control
var _frame: HighlightFrame


func _ready() -> void:
	layer = 50  # above the game and its UI
	_frame = HighlightFrame.new()
	_frame.name = "HighlightFrame"
	add_child(_frame)
	_frame.finished.connect(_on_frame_finished)


## Show the hint `id` around `target`, unless it has been shown before.
## Returns true if the hint was shown.
func show_once(id: String, target: Control) -> bool:
	if has_seen(id) or target == null or not target.is_visible_in_tree():
		return false
	_seen[id] = true
	_disconnect_target()
	_current_id = id
	_current_target = target
	target.mouse_entered.connect(dismiss)
	if target is BaseButton:
		target.pressed.connect(dismiss)
	elif target.has_signal("pressed"):
		target.connect("pressed", dismiss)
	_frame.blink_around(target)
	hint_started.emit(id)
	return true


## Hide the hint that is showing now, if any.
func dismiss() -> void:
	_frame.dismiss()


func has_seen(id: String) -> bool:
	return _seen.has(id)


## Which hint is showing now ("" if none).
func current_hint() -> String:
	return _current_id if _frame.visible else ""


## Forget all shown hints (new game / testing).
func reset() -> void:
	dismiss()
	_seen.clear()


func _on_frame_finished() -> void:
	var id := _current_id
	_disconnect_target()
	_current_id = ""
	hint_finished.emit(id)


func _disconnect_target() -> void:
	if is_instance_valid(_current_target):
		if _current_target.mouse_entered.is_connected(dismiss):
			_current_target.mouse_entered.disconnect(dismiss)
		if _current_target.has_signal("pressed") and _current_target.is_connected("pressed", dismiss):
			_current_target.disconnect("pressed", dismiss)
	_current_target = null
