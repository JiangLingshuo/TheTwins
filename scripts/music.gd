extends Node
## Background music player (autoload "Music").
## Lives outside any scene, so the music keeps playing across scene changes.

const BGM_MAIN: AudioStream = preload("res://assets/audio/初期调查bgm loop加长版.wav")
## Second-stage investigation music: from the camera tutorial's photograph onward.
const BGM_STAGE_TWO: AudioStream = preload("res://assets/audio/第二阶段bgm.wav")
## Final-stage music: from the solitary marker's investigation to the end of the true route.
const FINAL_STAGE_PATH := "res://assets/audio/最终bgm.wav"

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


## The music for the current stage of the investigation.
func stage_stream() -> AudioStream:
	if GameState.final_marker_phase or GameState.ending_true:
		var final := final_stream()
		if final != null:
			return final
	return BGM_STAGE_TWO if GameState.camera_tutorial_completed else BGM_MAIN


## The final-stage track, or null while it has not been added to the project.
func final_stream() -> AudioStream:
	return load(FINAL_STAGE_PATH) as AudioStream if ResourceLoader.exists(FINAL_STAGE_PATH) else null


## Play `stream`, or the current stage's music when none is given.
func play_bgm(stream: AudioStream = null) -> void:
	if stream == null:
		stream = stage_stream()
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


## Fade whatever is playing out and bring `stream` in.
func crossfade_to(stream: AudioStream, fade_out_time: float = 1.5) -> void:
	if stream == null or (_player.playing and _player.stream == stream):
		return
	if not _player.playing:
		play_bgm(stream)
		return
	var tween := create_tween()
	tween.tween_property(_player, "volume_db", -60.0, fade_out_time)
	tween.tween_callback(play_bgm.bind(stream))


## Fade the opening music out and bring in the second stage.
func enter_stage_two(fade_out_time: float = 1.5) -> void:
	crossfade_to(BGM_STAGE_TWO, fade_out_time)


## The solitary marker's investigation and everything after it. Until the final-stage
## track is in the project, the second-stage music simply carries on.
func enter_final_stage(fade_out_time: float = 1.5) -> void:
	var final := final_stream()
	if final != null:
		crossfade_to(final, fade_out_time)


func stop_bgm(fade_out_time: float = 1.0) -> void:
	if not _player.playing:
		return
	var tween := create_tween()
	tween.tween_property(_player, "volume_db", -60.0, fade_out_time)
	tween.finished.connect(_player.stop)
