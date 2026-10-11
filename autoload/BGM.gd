extends Node
## 輕快對比 BGM：預設播 assets/audio/cheerful_loop.wav
## 換曲：將 mp3/ogg/wav 放到同目錄並改 PATH（或喺編輯器換 stream）

const PATH := "res://assets/audio/cheerful_loop.wav"

var player: AudioStreamPlayer

func _ready() -> void:
	player = AudioStreamPlayer.new()
	player.name = "BGMPlayer"
	player.volume_db = -12.0
	add_child(player)
	if ResourceLoader.exists(PATH):
		var stream = load(PATH)
		if stream is AudioStreamWAV:
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			player.stream = stream
			player.play()
		elif stream is AudioStream:
			player.stream = stream
			player.play()

func set_enabled(on: bool) -> void:
	if player == null:
		return
	if on:
		if not player.playing and player.stream:
			player.play()
	else:
		player.stop()
