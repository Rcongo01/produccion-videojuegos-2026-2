# res://src/core/audio_manager.gd
# Lab 8 (Reto 2): retroalimentación sonora. Autoload "AudioManager".
# Escucha al EventBus y reproduce efectos; ninguna pantalla lo llama directamente,
# así que se puede quitar o reemplazar sin tocar la interfaz.
extends Node

const SOUNDS := {
	"correct": preload("res://src/assets/audio/correct.wav"),
	"wrong": preload("res://src/assets/audio/wrong.wav"),
	"pick": preload("res://src/assets/audio/pick.wav"),
	"drop": preload("res://src/assets/audio/drop.wav"),
	"click": preload("res://src/assets/audio/click.wav"),
	"star": preload("res://src/assets/audio/star.wav"),
	"win": preload("res://src/assets/audio/win.wav"),
	"lose": preload("res://src/assets/audio/lose.wav"),
	"streak": preload("res://src/assets/audio/streak.wav"),
}
const POOL_SIZE := 6

var players: Array[AudioStreamPlayer] = []
var next_player: int = 0
var last_played: String = ""


func _ready() -> void:
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.volume_db = -4.0
		add_child(p)
		players.append(p)
	EventBus.sound_requested.connect(play)
	EventBus.placement_evaluated.connect(func(_f: String, _g: String, correct: bool) -> void:
		play("correct" if correct else "wrong")
	)
	EventBus.bonus_obtained.connect(func(_b: Dictionary) -> void: play("star"))


func play(sound_name: String) -> void:
	last_played = sound_name
	if not GlobalManager.settings.get("sound_enabled", true):
		return
	if not SOUNDS.has(sound_name):
		push_warning("Sonido desconocido: " + sound_name)
		return
	var p: AudioStreamPlayer = players[next_player]
	next_player = (next_player + 1) % players.size()
	p.stream = SOUNDS[sound_name]
	p.pitch_scale = randf_range(0.97, 1.03)
	p.play()
