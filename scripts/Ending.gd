extends Control

@onready var title: Label = %Title
@onready var body: RichTextLabel = %Body
@onready var stats: Label = %Stats
@onready var again_btn: Button = %AgainBtn
@onready var menu_btn: Button = %MenuBtn

func _ready() -> void:
	title.text = GameState.ending_title()
	body.text = GameState.ending_body()
	stats.text = "最終現金：%s　｜　峰值：%s　｜　注數：%d　｜　總下注：%s　｜　總派彩：%s" % [
		GameState.format_money(GameState.cash),
		GameState.format_money(GameState.peak_cash),
		GameState.bets_placed,
		GameState.format_money(GameState.total_wagered),
		GameState.format_money(GameState.total_returned),
	]
	match GameState.ending_id:
		"peak":
			title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.2))
		"relapse":
			title.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))
		"broke":
			title.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
		"quit":
			title.add_theme_color_override("font_color", Color(0.6, 0.8, 0.9))
	again_btn.pressed.connect(_again)
	menu_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/MainMenu.tscn"))

func _again() -> void:
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/Intro.tscn")
