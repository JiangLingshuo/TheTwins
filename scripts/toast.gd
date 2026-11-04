extends Control
## A short message that fades in at the top of the screen, stays for
## `show_time` seconds and fades out. It never takes mouse or keyboard input.
##
## From other scripts: show_message("..."). Messages that arrive while one is
## showing wait their turn and play one by one, so none are cut off (e.g. a
## gravestone and a rubbing recorded together, or several clues at once).
## A message already showing or waiting is not queued twice. Pass
## interrupt = true to replace the message on screen right away (the queue is kept).

## Seconds the message stays fully visible.
@export var show_time: float = 2.0
## Seconds to fade in and to fade out.
@export var fade_time: float = 0.35

@onready var _label: Label = $Panel/Label

var _tween: Tween
var _queue: PackedStringArray = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	modulate.a = 0.0
	visible = false


func show_message(text: String, interrupt: bool = false) -> void:
	var busy := _tween != null and _tween.is_valid() and _tween.is_running()
	if busy and not interrupt:
		if text != _label.text and not _queue.has(text):
			_queue.append(text)
		return
	_play(text)


## Messages still waiting to be shown.
func pending() -> PackedStringArray:
	return _queue


func _play(text: String) -> void:
	_label.text = text
	visible = true
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, fade_time * (1.0 - modulate.a))
	_tween.tween_interval(show_time)
	_tween.tween_property(self, "modulate:a", 0.0, fade_time)
	_tween.tween_callback(_next)


func _next() -> void:
	if _queue.is_empty():
		hide()
		return
	var text := _queue[0]
	_queue.remove_at(0)
	_play(text)
