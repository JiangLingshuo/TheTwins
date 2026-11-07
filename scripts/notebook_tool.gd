extends Control
## Notebook button for the game scenes.
## Click it (or press Tab / N) to bring the notebook out at the last spread.
## It starts on Rise & Set unless the tutorial requests a page. Click again, click the
## dark area around the book, or turn past the last page to put it away. It
## shrinks back into the button.

## Emitted when the notebook comes out / is put away.
signal notebook_opened
signal notebook_closed
signal cover_comparison_ready
var _cover_holding := false
var _cover_ready := false
var _cover_releasing := false

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
## The button's picture: a copy of the stowed notebook (see Book.make_icon).
var _icon: Control


## Centre of NotebookButton on a `screen`-sized viewport (its anchors and offsets
## in notebook_tool.tscn). The start screen stows its book here to match.
static func button_center(screen: Vector2) -> Vector2:
	return Vector2(screen.x - 92.0, screen.y * 0.5)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dim.visible = false
	SoftIcon.apply(_button)
	_button.pressed.connect(toggle)
	_dim.gui_input.connect(_on_dim_input)
	book.closed.connect(_on_book_closed)
	var cover_target := Control.new()
	cover_target.set_script(preload("res://scripts/notebook_cover_target.gd"))
	cover_target.name = "NotebookCoverTarget"
	add_child(cover_target)
	# The button shows the put-away notebook itself, so stowing ends right on it.
	# Built straight away: the start screen's book is still showing in this spot.
	_icon = book.make_icon()
	_button.add_child(_icon)
	# Same soft, grainy finish as the other tool buttons.
	SoftIcon.apply_tree(_icon.get_child(0))
	var offset := _icon.position  # make_icon() centres the copy on (0, 0)
	_button.resized.connect(func() -> void: _icon.position = offset + _button.size / 2.0)
	_icon.position = offset + _button.size / 2.0
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
	if _cover_holding or _cover_releasing: return
	if is_open():
		close()
	else:
		open()


func open() -> void:
	if _cover_holding or _cover_releasing: return
	if is_open():
		return
	_set_dim(true)
	if _icon:
		_icon.visible = false  # the notebook itself comes out of the button
	notebook_opened.emit()
	# The live book tracks its spread even if earlier sections gain pages.
	var spread: int = book.get_spread() if _taken_out else GameState.notebook_section_spread
	if spread < 0:
		spread = book.get_opening_spread()
	if not _taken_out:
		_taken_out = true
		# The start screen's book has no sections, so its spread is not reused here.
		await book.open_saved(GameState.notebook_pages, spread)
	else:
		book.set_closed_spread(spread)
		book.visible = true
		await book.open_from_icon()


## Let the tutorial open directly to a particular gravestone.
func show_gravestone_next(id: String) -> void:
	var spread: int = book.get_gravestone_spread(id)
	if spread < 0 or is_open():
		return
	GameState.notebook_section_spread = spread
	book.set_closed_spread(spread)


func close() -> void:
	if _cover_holding or _cover_releasing: return
	if is_open():
		book.close()


func _on_book_closed() -> void:
	book.visible = false
	if _icon:
		_icon.visible = true
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


## Use the actual book and its existing closing animation, stopping before stow.
func hold_cover_for_comparison() -> void:
	if _cover_holding or _cover_releasing or book._busy or not is_open(): return
	_cover_holding = true
	_cover_ready = false
	await book.close_to_icon(true)
	_cover_ready = true
	cover_comparison_ready.emit()
	if not rubbing_drag.is_dragging(): release_cover_comparison()

func release_cover_comparison() -> void:
	if not _cover_holding or _cover_releasing: return
	_cover_releasing = true
	if not _cover_ready: await cover_comparison_ready
	# Give the player a moment to see the completed match before the book leaves.
	if GameState.evidence_ids.has("girl_cover_correspondence"):
		await get_tree().create_timer(0.7).timeout
	_cover_ready = false
	await book.stow_closed_cover()
	_cover_holding = false
	_cover_releasing = false
