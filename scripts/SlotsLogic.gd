extends RefCounted
class_name SlotsLogic
## 3 軸單線老虎機。權重＋賠率校準目標 RTP = 96.0%
## 符號：0 櫻桃 1 檸檬 2 鈴 3 BAR 4 七

const SYMBOLS: PackedStringArray = ["櫻桃", "檸檬", "鈴鐺", "BAR", "７"]
const WEIGHTS: Array[int] = [40, 28, 18, 10, 4]  ## 總和 100

## 三連總派彩倍數（含本）
const PAY_TRIPLE: Dictionary = {0: 5, 1: 6, 2: 14, 3: 35, 4: 110}
## 左兩連：櫻桃/檸檬 2x；鈴 3x

static func _pick_symbol() -> int:
	var r := randi() % 100
	var acc := 0
	for i in WEIGHTS.size():
		acc += WEIGHTS[i]
		if r < acc:
			return i
	return WEIGHTS.size() - 1

static func spin() -> Array:
	return [_pick_symbol(), _pick_symbol(), _pick_symbol()]

static func payout_multiplier(reels: Array) -> int:
	if reels[0] == reels[1] and reels[1] == reels[2]:
		return int(PAY_TRIPLE.get(reels[0], 0))
	if reels[0] == reels[1]:
		if reels[0] == 0 or reels[0] == 1:
			return 2
		if reels[0] == 2:
			return 3
		return 0
	return 0

static func resolve(wager: int, reels: Array) -> int:
	return wager * payout_multiplier(reels)

static func theoretical_rtp() -> float:
	var total_w := 0.0
	var ev := 0.0
	for a in 5:
		for b in 5:
			for c in 5:
				var p: float = float(WEIGHTS[a] * WEIGHTS[b] * WEIGHTS[c])
				total_w += p
				ev += p * float(payout_multiplier([a, b, c]))
	return 0.0 if total_w <= 0.0 else ev / total_w
