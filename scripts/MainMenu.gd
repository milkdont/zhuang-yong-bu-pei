extends Control

@onready var title: Label = %Title
@onready var subtitle: Label = %Subtitle
@onready var start_btn: Button = %StartBtn
@onready var quit_app_btn: Button = %QuitAppBtn
@onready var demo_box: VBoxContainer = %DemoBox

func _ready() -> void:
	start_btn.pressed.connect(_on_start)
	quit_app_btn.pressed.connect(func(): get_tree().quit())
	var tw := create_tween().set_loops()
	tw.tween_property(title, "modulate", Color(1.0, 0.7, 0.7, 1), 1.2)
	tw.tween_property(title, "modulate", Color(0.85, 0.55, 0.55, 1), 1.2)
	## Demo 結局預覽（真實莊家優勢下廿億極難達成，方便驗收）
	_add_demo_btn("預覽：登峰造極", "peak", 2_000_000_000, true)
	_add_demo_btn("預覽：翻本又輸返", "relapse", 50_000_000, true)
	_add_demo_btn("預覽：賭到清零", "broke", 0, false)
	_add_demo_btn("預覽：放棄／逃出", "quit", 100_000, false)

func _add_demo_btn(label: String, ending: String, cash: int, reached: bool) -> void:
	var b := Button.new()
	b.text = label
	b.custom_minimum_size = Vector2(280, 28)
	b.pressed.connect(_preview.bind(ending, cash, reached))
	demo_box.add_child(b)

func _preview(ending: String, cash: int, reached: bool) -> void:
	GameState.reset()
	GameState.cash = cash
	GameState.peak_cash = maxi(cash, 100_000_000 if reached else cash)
	GameState.reached_100m = reached
	GameState.ending_id = ending
	GameState.ending_locked = true
	get_tree().change_scene_to_file("res://scenes/Ending.tscn")

func _on_start() -> void:
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/Intro.tscn")
