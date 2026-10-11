extends RefCounted
class_name RouletteLogic
## 歐洲輪盤：0–36，單一零。Straight 35:1；紅黑／單雙／高低 1:1；打／列 2:1。
## 莊家優勢 ≈ 1/37 ≈ 2.7027%

const REDS: Array[int] = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36]

enum BetKind { STRAIGHT, RED, BLACK, ODD, EVEN, LOW, HIGH, DOZEN1, DOZEN2, DOZEN3 }

static func is_red(n: int) -> bool:
	return n in REDS

static func spin() -> int:
	return randi() % 37

static func payout_multiplier(kind: int) -> int:
	match kind:
		BetKind.STRAIGHT:
			return 35
		BetKind.DOZEN1, BetKind.DOZEN2, BetKind.DOZEN3:
			return 2
		_:
			return 1

static func wins(kind: int, number: int, straight_n: int = -1) -> bool:
	if number == 0:
		## 零：只有直注 0 贏；其他外注全輸
		return kind == BetKind.STRAIGHT and straight_n == 0
	match kind:
		BetKind.STRAIGHT:
			return number == straight_n
		BetKind.RED:
			return is_red(number)
		BetKind.BLACK:
			return not is_red(number)
		BetKind.ODD:
			return number % 2 == 1
		BetKind.EVEN:
			return number % 2 == 0
		BetKind.LOW:
			return number >= 1 and number <= 18
		BetKind.HIGH:
			return number >= 19 and number <= 36
		BetKind.DOZEN1:
			return number >= 1 and number <= 12
		BetKind.DOZEN2:
			return number >= 13 and number <= 24
		BetKind.DOZEN3:
			return number >= 25 and number <= 36
	return false

static func resolve(kind: int, wager: int, result: int, straight_n: int = -1) -> int:
	## 回傳派彩總額（含本）；輸 = 0
	if wins(kind, result, straight_n):
		return wager + wager * payout_multiplier(kind)
	return 0
