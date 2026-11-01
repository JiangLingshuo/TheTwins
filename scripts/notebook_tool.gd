extends Control
## Notebook button for the game scenes.
## Click it (or press `toggle_key`) to bring the notebook out, open on the page
## it was left on; click it again, click the dark area around the book, or turn
## past the last page to put it away. It shrinks back into the button.

## Emitted when the notebook comes out / is put away.
signal notebook_opened
signal notebook_closed

## Key that opens and closes the notebook. Set to KEY_NONE to disable.
@export var toggle_key: Key = KEY_N
## How dark the screen gets behind the open notebook.
@export_range(0.0, 1.0, 0.05) var dim_alpha: float = 0.55

@onready var book: Control = $Book
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


func _unhandled_key_input(event: InputEvent) -> void:
	if toggle_key != KEY_NONE and event.is_pressed() and not event.is_echo() \
			and (event as InputEventKey).keycode == toggle_key:
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
		await book.open_saved(GameState.notebook_pages, GameState.notebook_spread)
	else:
		book.visible = true
		await book.open_from_icon()


func close() -> void:
	if is_open():
		book.close()


func _on_book_closed() -> void:
	book.visible = false
	GameState.notebook_pages = book.pages
	GameState.notebook_spread = book.get_spread()
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
