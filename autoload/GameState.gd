extends Node
## 全域遊戲狀態：現金、峰值、結局觸發

const START_CASH: int = 100_000
const TARGET_100M: int = 100_000_000
const TARGET_2B: int = 2_000_000_000
const DEBT_OWED: int = 100_000_000

signal cash_changed(new_cash: int)
signal stats_changed
signal ending_ready(ending_id: String)

var cash: int = START_CASH
var peak_cash: int = START_CASH
var reached_100m: bool = false
var showed_greed_line: bool = false
var total_wagered: int = 0
var total_returned: int = 0  ## 含本金退回／派彩總額
var bets_placed: int = 0
var games_played: Dictionary = {"roulette": 0, "baccarat": 0, "slots": 0}
var ending_id: String = ""  ## peak | relapse | broke | quit
var ending_locked: bool = false
var last_greed_message: String = ""

func reset() -> void:
	cash = START_CASH
	peak_cash = START_CASH
	reached_100m = false
	showed_greed_line = false
	total_wagered = 0
	total_returned = 0
	bets_placed = 0
	games_played = {"roulette": 0, "baccarat": 0, "slots": 0}
	ending_id = ""
	ending_locked = false
	last_greed_message = ""
	cash_changed.emit(cash)
	stats_changed.emit()

func format_money(n: int) -> String:
	var neg: bool = n < 0
	var v: int = absi(n)
	var s: String = str(v)
	var out: String = ""
	while s.length() > 3:
		out = "," + s.substr(s.length() - 3, 3) + out
		s = s.substr(0, s.length() - 3)
	out = s + out
	if neg:
		return "-$" + out
	return "$" + out

func net_pl() -> int:
	## 相對開局現金之累計損益
	return cash - START_CASH

func distance_to_100m() -> int:
	return maxi(0, TARGET_100M - cash)

func distance_to_2b() -> int:
	return maxi(0, TARGET_2B - cash)

func can_true_stop() -> bool:
	return cash >= TARGET_2B and not ending_locked

func apply_bet_result(wager: int, payout: int, game_key: String) -> void:
	## wager: 下注額（已從現金扣除前由呼叫端保證足夠）
	## payout: 派彩總額（含本金；輸則 0）
	if ending_locked:
		return
	if wager < 0 or payout < 0:
		return
	if cash < wager:
		return
	cash -= wager
	cash += payout
	total_wagered += wager
	total_returned += payout
	bets_placed += 1
	if games_played.has(game_key):
		games_played[game_key] = int(games_played[game_key]) + 1
	_after_cash_update()

func add_cash_direct(delta: int) -> void:
	## 測試／特殊用途
	cash += delta
	_after_cash_update()

func _after_cash_update() -> void:
	if cash > peak_cash:
		peak_cash = cash
	var just_crossed: bool = false
	if not reached_100m and cash >= TARGET_100M:
		reached_100m = true
		just_crossed = true
		last_greed_message = "贏返本唔夠爽——唔係而家衝，更待何時？"
		showed_greed_line = true
	cash_changed.emit(cash)
	stats_changed.emit()
	_check_auto_endings(just_crossed)

func _check_auto_endings(just_crossed: bool) -> void:
	if ending_locked:
		return
	## 翻本又輸返：曾經 >= 1億，而家跌返 < 1億（含破產）
	if reached_100m and not just_crossed and cash < TARGET_100M:
		_trigger_ending("relapse")
		return
	## 從未翻本就輸光
	if cash <= 0 and not reached_100m:
		cash = 0
		_trigger_ending("broke")
		return
	## 曾經翻本後破產（上面 relapse 已涵蓋 cash < 100M；cash==0 亦同）
	if cash <= 0 and reached_100m:
		cash = 0
		_trigger_ending("relapse")

func request_true_stop() -> bool:
	if can_true_stop():
		_trigger_ending("peak")
		return true
	return false

func request_quit() -> void:
	if ending_locked:
		return
	_trigger_ending("quit")

func _trigger_ending(id: String) -> void:
	if ending_locked:
		return
	ending_locked = true
	ending_id = id
	ending_ready.emit(id)

func ending_title() -> String:
	match ending_id:
		"peak":
			return "登峰造極"
		"relapse":
			return "翻本又輸返"
		"broke":
			return "賭到清零"
		"quit":
			return "放棄／逃出"
		_:
			return "結局"

func ending_body() -> String:
	match ending_id:
		"peak":
			return "你喺二百億關口停手。\n數字上，你贏咗。\n但呢個「勝利」只喺 Demo 存在——現實賭場，莊家優勢永遠喺度。\n真正登峰造極，係唔入場。"
		"relapse":
			return "你曾經翻過本，甚至嘗過「贏返本」嘅快感。\n之後……又輸返。\n貪婪話你仲差一步；莊家話：歡迎再嚟。\n翻本又輸返——呢個循環，就係賭博最常見嘅結局。"
		"broke":
			return "十萬本金，片刻清零。\n債務仲喺度；現金已經冇。\n賭場唔使趕你——概率會代勞。"
		"quit":
			return "你選擇離開。\n未到二百億，所以唔係「登峰造極」。\n但停手本身，已經係一種贏法。\n（Demo 鼓勵：現實請唔好賭。）"
		_:
			return ""

func house_edge_notes() -> String:
	return "輪盤(歐式)≈2.70%｜百家樂莊≈1.06% 閒≈1.24%｜老虎機RTP≈96%"
