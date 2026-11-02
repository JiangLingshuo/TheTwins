extends Control
## A short message that fades in at the top of the screen, stays for
## `show_time` seconds and fades out. It never takes mouse or keyboard input.
##
## From other scripts: show_message("..."). A new message replaces the one shown.

## Seconds the message stays fully visible.
@export var show_time: float = 2.0
## Seconds to fade in and to fade out.
@export var fade_time: float = 0.35

@onready var _label: Label = $Panel/Label

var _tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	modulate.a = 0.0
	visible = false


func show_message(text: String) -> void:
	_label.text = text
	visible = true
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, fade_time * (1.0 - modulate.a))
	_tween.tween_interval(show_time)
	_tween.tween_property(self, "modulate:a", 0.0, fade_time)
	_tween.tween_callback(hide)
