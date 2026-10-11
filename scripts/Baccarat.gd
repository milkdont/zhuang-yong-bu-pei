extends Control

@onready var player_cards: Label = %PlayerCards
@onready var banker_cards: Label = %BankerCards
@onready var player_total: Label = %PlayerTotal
@onready var banker_total: Label = %BankerTotal
@onready var msg_label: Label = %MsgLabel
@onready var chip_row: HBoxContainer = %ChipRow
@onready var player_btn: Button = %PlayerBtn
@onready var banker_btn: Button = %BankerBtn
@onready var back_btn: Button = %BackBtn

var _chip_sel: ChipSelector
var _busy: bool = false

func _ready() -> void:
	GameState.ending_ready.connect(func(_id): get_tree().change_scene_to_file("res://scenes/Ending.tscn"))
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/CasinoHub.tscn"))
	_chip_sel = ChipSelector.new()
	chip_row.add_child(_chip_sel)
	player_btn.pressed.connect(func(): _bet(BaccaratLogic.Side.PLAYER))
	banker_btn.pressed.connect(func(): _bet(BaccaratLogic.Side.BANKER))
	player_cards.text = "—"
	banker_cards.text = "—"
	player_total.text = ""
	banker_total.text = ""
	msg_label.text = "只賭閒／莊。和局退本。莊贏扣 5% 佣金。"

func _fmt_hand(cards: Array) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for c in cards:
		parts.append(BaccaratLogic.card_label(int(c)))
	return "  ".join(parts)

func _bet(side: int) -> void:
	if _busy or GameState.ending_locked:
		return
	_chip_sel.refresh_affordability()
	var wager: int = _chip_sel.selected
	if wager <= 0 or wager > GameState.cash:
		msg_label.text = "籌碼不足。"
		return
	_busy = true
	player_btn.disabled = true
	banker_btn.disabled = true
	var side_name := "閒" if side == BaccaratLogic.Side.PLAYER else "莊"
	msg_label.text = "下注：%s　%s　…開牌中" % [side_name, GameState.format_money(wager)]
	await get_tree().create_timer(0.45).timeout
	var hand: Dictionary = BaccaratLogic.play_hand()
	player_cards.text = _fmt_hand(hand.player)
	banker_cards.text = _fmt_hand(hand.banker)
	player_total.text = "點數 %d" % int(hand.pt)
	banker_total.text = "點數 %d" % int(hand.bt)
	var payout: int = BaccaratLogic.resolve(side, wager, hand)
	GameState.apply_bet_result(wager, payout, "baccarat")
	_chip_sel.refresh_affordability()
	var w: String = hand.winner
	var outcome := "和局（退本）" if w == "tie" else ("閒贏" if w == "player" else "莊贏")
	if payout > wager:
		msg_label.text = "%s　你贏！派彩 %s" % [outcome, GameState.format_money(payout)]
	elif payout == wager:
		msg_label.text = "%s　退回 %s" % [outcome, GameState.format_money(payout)]
	else:
		msg_label.text = "%s　你輸。低優勢都係優勢。" % outcome
	player_btn.disabled = false
	banker_btn.disabled = false
	_busy = false
	if GameState.ending_locked:
		await get_tree().create_timer(0.8).timeout
		get_tree().change_scene_to_file("res://scenes/Ending.tscn")
