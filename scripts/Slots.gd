extends Control

@onready var reel0: Label = %Reel0
@onready var reel1: Label = %Reel1
@onready var reel2: Label = %Reel2
@onready var msg_label: Label = %MsgLabel
@onready var pay_label: Label = %PayLabel
@onready var chip_row: HBoxContainer = %ChipRow
@onready var spin_btn: Button = %SpinBtn
@onready var back_btn: Button = %BackBtn
@onready var rtp_label: Label = %RtpLabel

var _chip_sel: ChipSelector
var _busy: bool = false

func _ready() -> void:
	GameState.ending_ready.connect(func(_id): get_tree().change_scene_to_file("res://scenes/Ending.tscn"))
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/CasinoHub.tscn"))
	_chip_sel = ChipSelector.new()
	chip_row.add_child(_chip_sel)
	spin_btn.pressed.connect(_spin)
	pay_label.text = "賠率：櫻桃×3=5x　檸檬×3=6x　鈴×3=14x　BAR×3=35x　７×3=110x　｜　左兩連櫻桃/檸檬=2x　鈴=3x"
	rtp_label.text = "理論 RTP ≈ %.1f%%（固定權重表）" % (SlotsLogic.theoretical_rtp() * 100.0)
	reel0.text = "？"
	reel1.text = "？"
	reel2.text = "？"

func _spin() -> void:
	if _busy or GameState.ending_locked:
		return
	_chip_sel.refresh_affordability()
	var wager: int = _chip_sel.selected
	if wager <= 0 or wager > GameState.cash:
		msg_label.text = "籌碼不足。"
		return
	_busy = true
	spin_btn.disabled = true
	msg_label.text = "旋轉中…"
	for _t in range(8):
		reel0.text = SlotsLogic.SYMBOLS[randi() % SlotsLogic.SYMBOLS.size()]
		reel1.text = SlotsLogic.SYMBOLS[randi() % SlotsLogic.SYMBOLS.size()]
		reel2.text = SlotsLogic.SYMBOLS[randi() % SlotsLogic.SYMBOLS.size()]
		await get_tree().create_timer(0.06).timeout
	var reels: Array = SlotsLogic.spin()
	reel0.text = SlotsLogic.SYMBOLS[reels[0]]
	reel1.text = SlotsLogic.SYMBOLS[reels[1]]
	reel2.text = SlotsLogic.SYMBOLS[reels[2]]
	var payout: int = SlotsLogic.resolve(wager, reels)
	GameState.apply_bet_result(wager, payout, "slots")
	_chip_sel.refresh_affordability()
	var mult: int = SlotsLogic.payout_multiplier(reels)
	if payout > 0:
		msg_label.text = "中獎！%dx　派彩 %s" % [mult, GameState.format_money(payout)]
	else:
		msg_label.text = "冇中。長期期望值約 −4%（RTP 96%）。"
	spin_btn.disabled = false
	_busy = false
	if GameState.ending_locked:
		await get_tree().create_timer(0.8).timeout
		get_tree().change_scene_to_file("res://scenes/Ending.tscn")
