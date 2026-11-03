extends Control
## Notebook button for the game scenes.
## Click it (or press Tab / N) to bring the notebook out, open on the page
## it was left on; click it again, click the dark area around the book, or turn
## past the last page to put it away. It shrinks back into the button.

## Emitted when the notebook comes out / is put away.
signal notebook_opened
signal notebook_closed

## Keys that open and close the notebook. Set to KEY_NONE to disable.
@export var toggle_key: Key = KEY_TAB
@export var alt_toggle_key: Key = KEY_N
## How dark the screen gets behind the open notebook.
@export_range(0.0, 1.0, 0.05) var dim_alpha: float = 0.55

@onready var book: Control = $Book
## Drags rubbings from the notebook onto scene objects (see rubbing_drag.gd).
@onready var rubbing_drag: Control = $RubbingDrag
@onready var _dim: ColorRect = $Dim
@onready var _button: TextureButton = $NotebookButton

var _taken_out := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dim.visible = false
	_button.pressed.connect(toggle)
	_dim.gui_input.connect(_on_dim_input)
	book.closed.connect(_on_book_closed)
	# The book shrinks into the button when it is put away.
	await get_tree().process_frame
	var screen := get_viewport_rect().size
	book.icon_margin = screen - _button.get_global_rect().get_center()


func _input(event: InputEvent) -> void:
	if GameState.radio_modal_open or GameState.camera_modal_open:
		return
	# Handled before the GUI so Tab isn't taken for focus navigation; ignored
	# while typing in a text field.
	if not (event is InputEventKey) or not event.is_pressed() or event.is_echo():
		return
	var key := (event as InputEventKey).keycode
	if key == KEY_NONE or (key != toggle_key and key != alt_toggle_key):
		return
	var focused := get_viewport().gui_get_focus_owner()
	if focused is LineEdit or focused is TextEdit:
		return
	toggle()
	get_viewport().set_input_as_handled()


func is_open() -> bool:
	return _dim.visible


func toggle() -> void:
	if is_open():
		close()
	else:
		open()


func open() -> void:
	if is_open():
		return
	_set_dim(true)
	notebook_opened.emit()
	if not _taken_out:
		_taken_out = true
		# The start screen's book has no sections, so its spread is not reused here.
		await book.open_saved(GameState.notebook_pages, GameState.notebook_section_spread)
	else:
		book.visible = true
		await book.open_from_icon()


## Open on gravestone `id`'s page next time (call it when one is recorded).
func show_gravestone_next(id: String) -> void:
	var spread: int = book.get_gravestone_spread(id)
	if spread < 0 or is_open():
		return
	GameState.notebook_section_spread = spread
	book.set_closed_spread(spread)


func close() -> void:
	if is_open():
		book.close()


func _on_book_closed() -> void:
	book.visible = false
	GameState.notebook_pages = book.pages
	GameState.notebook_spread = book.get_spread()
	GameState.notebook_section_spread = book.get_spread()
	_set_dim(false)
	notebook_closed.emit()


func _on_dim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_dim.accept_event()
		close()


func _set_dim(on: bool) -> void:
	_dim.visible = on
	var t := create_tween()
	_dim.color.a = 0.0 if on else _dim.color.a
	t.tween_property(_dim, "color:a", dim_alpha if on else 0.0, 0.3)
