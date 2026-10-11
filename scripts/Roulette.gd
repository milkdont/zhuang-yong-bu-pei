extends Control

@onready var result_label: Label = %ResultLabel
@onready var msg_label: Label = %MsgLabel
@onready var chip_row: HBoxContainer = %ChipRow
@onready var board: GridContainer = %Board
@onready var outside: HBoxContainer = %OutsideBets
@onready var back_btn: Button = %BackBtn
@onready var spinning_label: Label = %SpinningLabel

var _chip_sel: ChipSelector
var _busy: bool = false
var _straight_btns: Dictionary = {}

func _ready() -> void:
	GameState.ending_ready.connect(func(_id): get_tree().change_scene_to_file("res://scenes/Ending.tscn"))
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/CasinoHub.tscn"))
	_chip_sel = ChipSelector.new()
	chip_row.add_child(_chip_sel)
	_build_board()
	_build_outside()
	result_label.text = "點選號碼或外注（紅／黑／單／雙／高低／打）"
	spinning_label.text = ""

func _build_board() -> void:
	board.columns = 13
	## 0 單獨
	var zero := Button.new()
	zero.text = "0"
	zero.custom_minimum_size = Vector2(48, 40)
	zero.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))
	zero.pressed.connect(_bet_straight.bind(0))
	board.add_child(zero)
	_straight_btns[0] = zero
	for n in range(1, 37):
		var b := Button.new()
		b.text = str(n)
		b.custom_minimum_size = Vector2(48, 40)
		if RouletteLogic.is_red(n):
			b.add_theme_color_override("font_color", Color(1, 0.35, 0.35))
		else:
			b.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
		b.pressed.connect(_bet_straight.bind(n))
		board.add_child(b)
		_straight_btns[n] = b

func _build_outside() -> void:
	var specs: Array = [
		["紅", RouletteLogic.BetKind.RED],
		["黑", RouletteLogic.BetKind.BLACK],
		["單", RouletteLogic.BetKind.ODD],
		["雙", RouletteLogic.BetKind.EVEN],
		["1–18", RouletteLogic.BetKind.LOW],
		["19–36", RouletteLogic.BetKind.HIGH],
		["第1打", RouletteLogic.BetKind.DOZEN1],
		["第2打", RouletteLogic.BetKind.DOZEN2],
		["第3打", RouletteLogic.BetKind.DOZEN3],
	]
	for s in specs:
		var b := Button.new()
		b.text = s[0]
		b.custom_minimum_size = Vector2(88, 40)
		b.pressed.connect(_bet_outside.bind(s[1], s[0]))
		outside.add_child(b)

func _bet_straight(n: int) -> void:
	_place(RouletteLogic.BetKind.STRAIGHT, "直注 %d" % n, n)

func _bet_outside(kind: int, label: String) -> void:
	_place(kind, label, -1)

func _place(kind: int, label: String, straight_n: int) -> void:
	if _busy or GameState.ending_locked:
		return
	_chip_sel.refresh_affordability()
	var wager: int = _chip_sel.selected
	if wager <= 0 or wager > GameState.cash:
		msg_label.text = "籌碼不足。"
		return
	_busy = true
	spinning_label.text = "轉盤中…"
	msg_label.text = "下注：%s　%s" % [label, GameState.format_money(wager)]
	await get_tree().create_timer(0.55).timeout
	var result: int = RouletteLogic.spin()
	var payout: int = RouletteLogic.resolve(kind, wager, result, straight_n)
	var color := "綠" if result == 0 else ("紅" if RouletteLogic.is_red(result) else "黑")
	result_label.text = "結果：%d（%s）" % [result, color]
	GameState.apply_bet_result(wager, payout, "roulette")
	_chip_sel.refresh_affordability()
	if payout > 0:
		msg_label.text = "贏！派彩 %s（淨 +%s）" % [GameState.format_money(payout), GameState.format_money(payout - wager)]
	else:
		msg_label.text = "輸咗。莊家優勢永遠喺度。"
	spinning_label.text = ""
	_busy = false
	if GameState.ending_locked:
		await get_tree().create_timer(0.8).timeout
		get_tree().change_scene_to_file("res://scenes/Ending.tscn")
