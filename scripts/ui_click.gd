extends Node
## Mouse-click sound for every button in the game (autoload "UiClick").
## Buttons are hooked as they enter the tree, so scene changes and buttons
## built in code need no wiring.

const CLICK: AudioStream = preload("res://assets/audio/鼠标单击声.mp3")

## Loudness of the click in decibels.
@export_range(-40.0, 6.0, 0.5) var volume_db: float = -6.0

var _player: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_player = AudioStreamPlayer.new()
	_player.stream = CLICK
	_player.volume_db = volume_db
	add_child(_player)
	get_tree().node_added.connect(_hook)
	_hook_tree(get_tree().root)


func _hook_tree(node: Node) -> void:
	_hook(node)
	for child in node.get_children():
		_hook_tree(child)


func _hook(node: Node) -> void:
	if node is BaseButton and not node.pressed.is_connected(_play):
		node.pressed.connect(_play)


func _play() -> void:
	_player.play()
