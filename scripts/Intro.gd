extends Control

@onready var body: RichTextLabel = %Body
@onready var cont_btn: Button = %ContinueBtn
@onready var skip_btn: Button = %SkipBtn

var _pages: PackedStringArray = PackedStringArray([
	"你欠下 [color=#ff8888]一億[/color]。\n口袋只得 [color=#ffdd88]$100,000[/color]。\n有人話：賭場可以翻本。",
	"燈火通明，音樂輕快——\n但走廊永遠陰冷。\n莊家唔使趕客；[color=#ff6666]概率[/color]會代勞。",
	"目標：淨資產達 [color=#88ff88]二十億[/color]，再按「真勝利停手」——\n成就：[color=#ffd700]登峰造極[/color]。\n若曾翻到一億卻再跌穿……[color=#ff8888]翻本又輸返[/color]。",
	"而家，直接入場。\n唔使閑逛——桌檯已經等你。"
])
var _idx: int = 0

func _ready() -> void:
	cont_btn.pressed.connect(_on_cont)
	skip_btn.pressed.connect(_go_hub)
	_show()

func _show() -> void:
	body.text = _pages[_idx]
	cont_btn.text = "繼續" if _idx < _pages.size() - 1 else "進入賭場"

func _on_cont() -> void:
	if _idx < _pages.size() - 1:
		_idx += 1
		_show()
	else:
		_go_hub()

func _go_hub() -> void:
	get_tree().change_scene_to_file("res://scenes/CasinoHub.tscn")
