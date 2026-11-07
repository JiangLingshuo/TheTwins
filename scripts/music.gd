extends Node
## Background music player (autoload "Music").
## Lives outside any scene, so the music keeps playing across scene changes.

const BGM_MAIN: AudioStream = preload("res://assets/audio/初期调查bgm loop加长版.wav")

## Target loudness of the background music, in decibels (0 = original level).
@export_range(-40.0, 6.0, 0.5) var music_volume_db: float = -8.0
## Seconds to fade in when the music starts.
@export var fade_in_time: float = 2.0

var _player: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_player = AudioStreamPlayer.new()
	_player.name = "BGMPlayer"
	add_child(_player)


func play_bgm(stream: AudioStream = BGM_MAIN) -> void:
	if _player.playing and _player.stream == stream:
		return
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	elif stream is AudioStreamWAV:
		var wave := stream as AudioStreamWAV
		wave.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wave.loop_begin = 0
		wave.loop_end = roundi(wave.get_length() * wave.mix_rate)
	_player.stream = stream
	_player.volume_db = -60.0
	_player.play()
	create_tween().tween_property(_player, "volume_db", music_volume_db, fade_in_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func stop_bgm(fade_out_time: float = 1.0) -> void:
	if not _player.playing:
		return
	var tween := create_tween()
	tween.tween_property(_player, "volume_db", -60.0, fade_out_time)
	tween.finished.connect(_player.stop)
