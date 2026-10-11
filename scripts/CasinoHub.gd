extends Control

@onready var stop_btn: Button = %StopBtn
@onready var quit_btn: Button = %QuitBtn
@onready var status: Label = %StatusLabel
@onready var roulette_btn: Button = %RouletteBtn
@onready var baccarat_btn: Button = %BaccaratBtn
@onready var slots_btn: Button = %SlotsBtn

func _ready() -> void:
	GameState.cash_changed.connect(func(_v): _refresh())
	GameState.stats_changed.connect(_refresh)
	GameState.ending_ready.connect(_on_ending)
	roulette_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Roulette.tscn"))
	baccarat_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Baccarat.tscn"))
	slots_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Slots.tscn"))
	stop_btn.pressed.connect(_on_stop)
	quit_btn.pressed.connect(_on_quit)
	_refresh()
	if GameState.ending_locked:
		_on_ending(GameState.ending_id)

func _refresh() -> void:
	var can := GameState.can_true_stop()
	stop_btn.disabled = not can
	if can:
		stop_btn.text = "真勝利停手（登峰造極）"
		status.text = "你已達二十億。可以真正停手——或者繼續賭到「翻本又輸返」。"
	else:
		stop_btn.text = "真勝利停手（需 ≥ $2,000,000,000）"
		if GameState.reached_100m:
			status.text = GameState.last_greed_message
		else:
			status.text = "欠債一億。選一張檯，用滑鼠點選下注。"

func _on_stop() -> void:
	if GameState.request_true_stop():
		get_tree().change_scene_to_file("res://scenes/Ending.tscn")

func _on_quit() -> void:
	GameState.request_quit()
	get_tree().change_scene_to_file("res://scenes/Ending.tscn")

func _on_ending(_id: String) -> void:
	get_tree().change_scene_to_file("res://scenes/Ending.tscn")
